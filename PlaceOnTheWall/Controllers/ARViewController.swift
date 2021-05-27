//
//  ARViewController.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 07.03.2021.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    
    var currentNode: SCNNode?
    
    var isPaintingPlaced = false
    
    var nodeHasMoved = false
    var draggedNode: SCNNode?
    var touchBeganTime: Date?
    
    var grids = [GridNode]()
    
    var paintingNumber: Int?
    
    var trackingStatus: String = "" {
        didSet {
            statusLabel.text = trackingStatus
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            trackingStatus = "AR World Tracking Not Supported"
            return
        }
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.configureARSession()
        sceneView.configureSceneView()
        sceneView.showSceneDebugInfo()
        
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleNode))
        self.sceneView.addGestureRecognizer(scaleGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.pauseARSession()
    }
    
    private func resetProperties() {
        isPaintingPlaced = false
        currentNode = nil
        grids.removeAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentNode = self.currentNode else {
            return
        }
        touches.forEach {
            let touch = $0
            if(touch.view == self.sceneView) {
                let viewTouchLocation = touch.location(in: sceneView)
                
                let results = sceneView.hitTest(viewTouchLocation, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
                guard !results.isEmpty else { return }
                for hitTestResult in results {
                    if hitTestResult.node == currentNode {
                        draggedNode = currentNode
                        touchBeganTime = Date()
                        nodeHasMoved = false
                        return
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchBeganTime = touchBeganTime, Date().timeIntervalSince1970 -  touchBeganTime.timeIntervalSince1970 > 0.3 else {
            return
        }
        
        guard let draggedNode = draggedNode else { return }
        touches.forEach { (touch) in
            
            if touch.view == self.sceneView {
                let viewTouchLocation = touch.location(in: sceneView)
                let results = sceneView.hitTest(viewTouchLocation, types: .existingPlane)
                guard results.count > 0 else { return }
                draggedNode.simdWorldTransform = results[0].worldTransform
                draggedNode.eulerAngles.x = -.pi/2
                nodeHasMoved = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard nodeHasMoved else { return }
        self.draggedNode = nil
        nodeHasMoved = false
    }
    
    @objc func scaleNode(gesture: UIPinchGestureRecognizer) {
        
        guard let currentNode = self.currentNode else { return }
        
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((currentNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((currentNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((currentNode.scale.z))
            currentNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
        }
    }
}

extension ARViewController {
    private func addPainting(to node: SCNNode) {
        let paintingNode = PaintingNode(image: UIImage(named: "painting\(paintingNumber ?? 0)")!)
        paintingNode.setup(position: node.position)

        node.addChildNode(paintingNode)
        currentNode = paintingNode
        
//        let frameNode = FrameNode()
//        frameNode.setup(position: node.position)
//        node.addChildNode(frameNode)
//        currentNode = frameNode
        isPaintingPlaced = true
    }
    
    private func addNodeAnchor(worldTransform: simd_float4x4) {
        sceneView.session.add(anchor: ARAnchor(name: "node_anchor", transform: worldTransform))
    }
    
    private func removeARPlaneNode(node: SCNNode) {
        for childNode in node.childNodes {
            childNode.removeFromParentNode()
        }
    }
}

// MARK: - ARSCNViewDelegate methods
extension ARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, !isPaintingPlaced, name == "node_anchor" {
            addPainting(to: node)
            self.grids.forEach { $0.removeFromParentNode() }
            return
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        if planeAnchor.extent.x * planeAnchor.extent.z > 0.1 {
            addNodeAnchor(worldTransform: anchor.transform)
            return
        }
        let grid = GridNode(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == planeAnchor.identifier
        }.first
        
        if planeAnchor.extent.x * planeAnchor.extent.z > 0.1 {
            addNodeAnchor(worldTransform: anchor.transform)
            return
        }
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        self.removeARPlaneNode(node: node)
    }
}

// MARK: - ARSessionDelegate methods
extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            self.trackingStatus = "Tacking:  Not available!"
            break
        case .normal:
            self.trackingStatus = ""
            break
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                self.trackingStatus = "Tracking: Limited due to excessive motion!"
                break
            case .insufficientFeatures:
                self.trackingStatus = "Tracking: Limited due to insufficient features!"
                break
            case .relocalizing:
                self.trackingStatus = "Tracking: Relocalizing..."
                break
            case .initializing:
                self.trackingStatus = "Tracking: Initializing..."
                break
            @unknown default:
                self.trackingStatus = "Tracking: Unknown..."
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        self.trackingStatus = "AR Session Failure: \(error.localizedDescription)"
        resetProperties()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.trackingStatus = "AR Session Was Interrupted!"
        print("sessionWasInterrupted")
        resetProperties()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.trackingStatus = "AR Session Interruption Ended"
        print("sessionInterruptionEnded")
        sceneView.resetARSession()
    }
}
