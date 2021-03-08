//
//  ARViewController.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 07.03.2021.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var currentAngleY: Float = 0.0
    var previousLoc = CGPoint.init(x: 0, y: 0)
    var isRotating = false
    
    var paintingNumber = 0
    
    var currentNode: SCNNode? {
        get {
            return sceneView.scene.rootNode.childNode(withName: "painting\(paintingNumber)", recursively: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("painting number \(paintingNumber)")
        initSceneView()
        initScene()
        initARSession()
        loadModels()
        
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleNode))
        self.sceneView.addGestureRecognizer(scaleGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode))
        self.sceneView.addGestureRecognizer(rotationGesture)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        
        self.sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func upTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveUp = SCNAction.repeat(SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 0.1), count: 1)
        currentNode.runAction(moveUp)
    }

    @IBAction func downTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveDown = SCNAction.repeat(SCNAction.moveBy(x: 0, y: -0.05, z: 0, duration: 0.1), count: 1)
        currentNode.runAction(moveDown)
    }
    
    @IBAction func leftTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveLeft = SCNAction.repeat(SCNAction.moveBy(x: -0.05, y: 0, z: 0, duration: 0.1), count: 1)
        currentNode.runAction(moveLeft)
    }
    
    @IBAction func rightTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveRight = SCNAction.repeat(SCNAction.moveBy(x: 0.05, y: 0, z: 0, duration: 0.1), count: 1)
        currentNode.runAction(moveRight)
    }
    
    @IBAction func forwardTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveForward = SCNAction.repeat(SCNAction.moveBy(x: 0, y: 0, z: 0.05, duration: 0.1), count: 1)
        currentNode.runAction(moveForward)
    }
    
    @IBAction func backwardTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveBackward = SCNAction.repeat(SCNAction.moveBy(x: 0, y: 0, z: -0.05, duration: 0.1), count: 1)
        currentNode.runAction(moveBackward)
    }
    
    @IBAction func rotateRightTapped(_ sender: Any) {
        guard let currentNode = currentNode else { return }
        let moveBackward = SCNAction.repeat(SCNAction.rotateBy(x: 0, y: CGFloat(0.1 * Double.pi), z: 0, duration: 0.1), count: 1)
        currentNode.runAction(moveBackward)
    }
    
    
    // MARK: - Initialization
    
    func initSceneView() {
        sceneView.delegate = self
    }
    
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        scene.physicsWorld.speed = 1
        //      scene.physicsWorld.timeStep = 1.0 / 60.0
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let sessionConfig: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
        sessionConfig.planeDetection = .vertical
        sceneView.session.delegate = self
        sceneView.debugOptions = .showFeaturePoints
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = true
        sceneView.preferredFramesPerSecond = 60
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
        sceneView.session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        sceneView.delegate = self
    }
    
    func loadModels() {
        guard let paintingScene = SCNScene(named: "Paintings.scnassets/Paintings/Painting\(paintingNumber).scn") else { return }
        
        guard let paintingNode = paintingScene.rootNode.childNode(withName: "painting\(paintingNumber)", recursively: false) else { return }
        
        sceneView.scene.rootNode.addChildNode(paintingNode)
    }
    
    @objc func scaleNode(gesture: UIPinchGestureRecognizer) {
        
        guard let currentNode = currentNode else { return }
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((currentNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((currentNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((currentNode.scale.z))
            currentNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
            
        }
        if gesture.state == .ended { }
        
    }
    
    @objc func rotateNode(_ gesture: UIRotationGestureRecognizer) {
        
        guard let currentNode = currentNode else { return }
        
        let rotation = Float(gesture.rotation)
        
        if gesture.state == .changed {
            isRotating = true
            currentNode.eulerAngles.y = currentAngleY + rotation
        }
        
        if(gesture.state == .ended) {
            currentAngleY = currentNode.eulerAngles.y
            isRotating = false
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let currentNode = currentNode else { return }
        
        if !isRotating{
            
            let currentTouchPoint = gesture.location(in: self.sceneView)
            
            guard let hitTest = self.sceneView.hitTest(currentTouchPoint, types: .existingPlane).first else { return }
            
            let worldTransform = hitTest.worldTransform
            
            let newPosition = SCNVector3(worldTransform.columns.3.x, worldTransform.columns.3.y, worldTransform.columns.3.z)
            
            currentNode.simdPosition = float3(newPosition.x, newPosition.y, newPosition.z)
            
        }
    }
    
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

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
}
