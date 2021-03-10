//
//  ARSCNView+Extensions.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 08.03.2021.
//

import Foundation
import SceneKit
import ARKit

extension ARSCNView {
    func showSceneDebugInfo() {
        debugOptions = .showFeaturePoints
        showsStatistics = true
    }
    
    func configureSceneView() {
        autoenablesDefaultLighting = true
        scene.physicsWorld.gravity = SCNVector3(0, -3.0, 0)
        antialiasingMode = .multisampling4X
        automaticallyUpdatesLighting = true
        preferredFramesPerSecond = 60
    }
    
    func configureARSession() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .vertical
        config.isLightEstimationEnabled = true
        self.session.run(config)
    }
    
    func resetARSession() {
        guard let config = self.session.configuration as? ARWorldTrackingConfiguration else { return }
        print("session reseted")
        self.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func pauseARSession() {
        print("session paused")
        self.session.pause()
    }
}
