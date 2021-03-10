//
//  Picture.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 10.03.2021.
//

import Foundation
import ARKit

class PaintingNode: SCNNode {
    
    var image: UIImage?
    let width: CGFloat = 0.3
    let height: CGFloat = 0.3
    
    override init() {
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    func setup(image: UIImage?, position: SCNVector3) {
        let planeGeometry = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = image
        planeGeometry.materials = [material]
        
        self.geometry = planeGeometry
        self.eulerAngles = SCNVector3(self.eulerAngles.x + (-Float.pi / 2), self.eulerAngles.y, self.eulerAngles.z)
        self.position = position
    }
}
