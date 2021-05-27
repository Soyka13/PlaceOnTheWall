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
        // create top side of the frame
        let topPart = SCNBox(width: 0.1, height: 0.01, length: 0.02, chamferRadius: 0.001)
        let topPartNode = SCNNode(geometry: topPart)
        topPartNode.eulerAngles = SCNVector3(topPartNode.eulerAngles.x + (-Float.pi / 2), topPartNode.eulerAngles.y , topPartNode.eulerAngles.z)
        topPartNode.position = position
        print("Position of top part: \(topPartNode.position)")
        addChildNode(topPartNode)
        
        // create left side of the frame
        let leftSide = SCNBox(width: 0.1, height: 0.01, length: 0.02, chamferRadius: 0.001)
        let leftPartNode = SCNNode(geometry: leftSide)
        leftPartNode.eulerAngles = SCNVector3(topPartNode.eulerAngles.x , topPartNode.eulerAngles.y + (-Float.pi / 2), topPartNode.eulerAngles.z)
        leftPartNode.position = SCNVector3(topPartNode.position.x - Float(leftSide.width)/2 - Float(topPart.height)/2, 0, topPartNode.position.z + Float(leftSide.width)/2 + Float(topPart.height)/2)
        print("Position of left part: \(leftPartNode.position)")
        addChildNode(leftPartNode)
        
        // create right part of the frame
        let rightSide = SCNBox(width: 0.1, height: 0.01, length: 0.02, chamferRadius: 0.001)
        let rightSideNode = SCNNode(geometry: rightSide)
        rightSideNode.eulerAngles = SCNVector3(topPartNode.eulerAngles.x , topPartNode.eulerAngles.y + (-Float.pi / 2), topPartNode.eulerAngles.z)
        rightSideNode.position = SCNVector3(topPartNode.position.x + Float(rightSide.width)/2 + Float(topPart.height)/2, 0, topPartNode.position.z + Float(rightSide.width)/2 + Float(topPart.height)/2)
        print("Position of right part: \(rightSideNode.position)")
        addChildNode(rightSideNode)

        // create bottom side of the frame
        let bottomSide = SCNBox(width: 0.1, height: 0.01, length: 0.02, chamferRadius: 0.001)
        let bottomSideNode = SCNNode(geometry: bottomSide)
        bottomSideNode.eulerAngles = SCNVector3(bottomSideNode.eulerAngles.x + (-Float.pi / 2), bottomSideNode.eulerAngles.y , bottomSideNode.eulerAngles.z)
        bottomSideNode.position = SCNVector3(topPartNode.position.x , topPartNode.position.y , topPartNode.position.z + Float(leftSide.width) + Float(leftSide.height))
        print("Position of bottom part: \(leftPartNode.position)")
        addChildNode(bottomSideNode)
        
        // create image node
        let imageGeometry = SCNPlane(width: 0.1, height: 0.1)
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        imageGeometry.materials = [material]
        
        let imageNode = SCNNode(geometry: imageGeometry)
        imageNode.eulerAngles = SCNVector3(self.eulerAngles.x + (-Float.pi / 2), self.eulerAngles.y, self.eulerAngles.z)
        imageNode.position = SCNVector3(topPartNode.position.x, 0, topPartNode.position.z + Float(rightSide.width)/2 + Float(topPart.height)/2)
        print("Position of image node: \(imageNode.position)")
        addChildNode(imageNode)
    }
}
