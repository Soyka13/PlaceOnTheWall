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
    
    let sceneManager = SceneManager()
    
    var currentAngleY: Float = 0.0
    
    var touchBeganTime: Date?
    
    var paintingNumber = 0 {
        didSet {
            sceneManager.paintingNumber = paintingNumber
        }
    }
    
    var tileHasMoved = false
    var draggedNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        sceneManager.showSceneDebugInfo()
        
        initCoachingOverlayView()
        
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleNode))
        self.sceneView.addGestureRecognizer(scaleGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateNode))
        self.sceneView.addGestureRecognizer(rotationGesture)
    }
    
    func initCoachingOverlayView() {
      let coachingOverlay = ARCoachingOverlayView()
      coachingOverlay.session = self.sceneView.session
      coachingOverlay.delegate = self
      coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
      coachingOverlay.activatesAutomatically = true
      coachingOverlay.goal = .verticalPlane
      self.sceneView.addSubview(coachingOverlay)
      
      NSLayoutConstraint.activate([
        NSLayoutConstraint(item:  coachingOverlay, attribute: .top, relatedBy: .equal,
                           toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  coachingOverlay, attribute: .bottom, relatedBy: .equal,
                           toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  coachingOverlay, attribute: .leading, relatedBy: .equal,
                           toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  coachingOverlay, attribute: .trailing, relatedBy: .equal,
                           toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
      ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let touch = $0
            if(touch.view == self.sceneView) {
                let viewTouchLocation = touch.location(in: sceneView)
                let arHitTestResult = sceneView.hitTest(viewTouchLocation, types: .featurePoint)
                guard arHitTestResult.count > 0 else {
                    return
                }
                
                let result = sceneView.hitTest(viewTouchLocation, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
                guard !result.isEmpty else {
                    return
                }
                
                tileHasMoved = false
                
                for hitTestResult in result {
                    let topNode = hitTestResult.node
                        draggedNode = topNode
                        
                        touchBeganTime = Date()
                        tileHasMoved = false
                        return
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchBeganTime = touchBeganTime, Date().timeIntervalSince1970 -  touchBeganTime.timeIntervalSince1970 > 0.3 else {
            return
        }
        guard let draggedNode = draggedNode else { return }
        touches.forEach {
            let touch = $0
            if touch.view == self.sceneView {
                let viewTouchLocation = touch.location(in: sceneView)
                let results = sceneView.hitTest(viewTouchLocation, types: .existingPlane)
                guard results.count > 0 else { return }
                draggedNode.simdWorldTransform = results[0].worldTransform
                draggedNode.eulerAngles.x = -.pi/2
                tileHasMoved = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard tileHasMoved else { return }
        
        self.draggedNode = nil
    }
    
    @objc func scaleNode(gesture: UIPinchGestureRecognizer) {
        
        guard let currentNode = sceneManager.currentParentNode?.childNodes.first else { return }
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((currentNode.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((currentNode.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((currentNode.scale.z))
            currentNode.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
        }
    }
    
    @objc func rotateNode(_ gesture: UIRotationGestureRecognizer) {
        
        guard let currentNode = sceneManager.currentParentNode?.childNodes.first else { return }
        
        let rotation = Float(gesture.rotation)
        
        if gesture.state == .changed {
            currentNode.eulerAngles.y = currentAngleY + rotation
        }
        
        if(gesture.state == .ended) {
            currentAngleY = currentNode.eulerAngles.y
        }
    }

}

extension ARViewController : ARCoachingOverlayViewDelegate {
  
  // MARK: - AR Coaching Overlay View
  
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
  }
  
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    
  }
  
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    
  }
}
