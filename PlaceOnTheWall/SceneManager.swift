//
//  SceneManager.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 08.03.2021.
//

import Foundation
import SceneKit
import ARKit

class SceneManager: NSObject {
    
    var sceneView: ARSCNView?
    
    var initVirtualTiles = false
    var currentParentNode: SCNNode?
    var paintingNumber: Int? 
    
    var grids = [Grid]()
    
    
    func attach(to arSceneView: ARSCNView) {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        sceneView = arSceneView
        sceneView?.delegate = self
        sceneView?.session.delegate = self
        
        sceneView?.autoenablesDefaultLighting = true
        sceneView?.scene.physicsWorld.gravity = SCNVector3(0, -3.0, 0)
        
        configureSceneView(self.sceneView!)
    }
    
    func showSceneDebugInfo() {
        sceneView?.debugOptions = .showFeaturePoints
        sceneView?.showsStatistics = true
    }
    
    private func configureSceneView(_ sceneView: ARSCNView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true
        sceneView.preferredFramesPerSecond = 60
    }
    
    func addPainting(to node: SCNNode) {
        let planeGeometry = SCNPlane(width: 0.25, height: 0.25)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "painting\(paintingNumber ?? 0)")
        planeGeometry.materials = [material]
        
        let paintingNode = SCNNode(geometry: planeGeometry)
        paintingNode.eulerAngles = SCNVector3(paintingNode.eulerAngles.x + (-Float.pi / 2), paintingNode.eulerAngles.y, paintingNode.eulerAngles.z)
        paintingNode.position = node.position
        node.addChildNode(paintingNode)
        
        initVirtualTiles = true
    }
    
    private func addNodeAnchor(worldTransform: simd_float4x4) {
        sceneView?.session.add(anchor: ARAnchor(name: "node_anchor", transform: worldTransform))
    }
}

extension SceneManager: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, !initVirtualTiles, name == "node_anchor" {
            addPainting(to: node)
            currentParentNode = node
            self.grids.forEach { $0.removeFromParentNode() }
            return
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        if planeAnchor.extent.x * planeAnchor.extent.z > 0.1 {
            addNodeAnchor(worldTransform: anchor.transform)
            return
        }
        let grid = Grid(anchor: planeAnchor)
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
}

extension SceneManager: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
