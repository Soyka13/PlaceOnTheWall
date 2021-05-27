//
//  Picture.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 10.03.2021.
//

import Foundation
import ARKit

class PaintingNode: SCNNode {
    
    var image: UIImage
    var imageAspectRatio: CGFloat {
        return image.size.width/image.size.height
    }
    
    lazy var width: CGFloat = image.size.width / 10000
    lazy var height: CGFloat = image.size.height / 10000
    
    let frameHeight: CGFloat = 0.05
    let frameLength: CGFloat = 0.02
    
    init(image: UIImage) {
        self.image = image
        super.init()
    }
    
    required init?(coder: NSCoder) {
        image = UIImage(systemName: "person.fill")!
        super.init(coder: coder)
    }
    
    func setup(position: SCNVector3) {
        // create image background
        let backgroundBox = SCNBox(width: width, height: height, length: frameLength/2, chamferRadius: 0.001)
        backgroundBox.firstMaterial?.diffuse.contents = UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 1)
        let backgroundBoxNode = SCNNode(geometry: backgroundBox)
        backgroundBoxNode.eulerAngles.x -= Float.pi/2
        backgroundBoxNode.position = SCNVector3(position.x, position.y + Float(backgroundBox.length)/2, position.z)
        addChildNode(backgroundBoxNode)
        
        // create image node
        let imageGeometry = SCNPlane(width: width, height: height)
        print("width \(width) height \(height)")

        let material = SCNMaterial()
        material.diffuse.contents = image
        imageGeometry.materials = [material]

        let imageNode = SCNNode(geometry: imageGeometry)
        imageNode.position = SCNVector3(position.x, position.y, position.z + Float(frameLength/2) + 0.0001)
        print("Position of image node: \(imageNode.position)")
        backgroundBoxNode.addChildNode(imageNode)

        // create top side of the frame
        let topPart = SCNBox(width: width, height: frameHeight, length: frameLength, chamferRadius: 0.001)
        let topPartNode = SCNNode(geometry: topPart)
        topPartNode.eulerAngles.x -= Float.pi / 2
        topPartNode.position = SCNVector3(0, topPart.length/2, -height/2 - topPart.height/2)
        print("Position of top part: \(topPartNode.position)")
        addChildNode(topPartNode)

        // create left side of the frame
        let leftSide = SCNBox(width: height, height: frameHeight, length: frameLength, chamferRadius: 0.001)
        let leftPartNode = SCNNode(geometry: leftSide)
        leftPartNode.eulerAngles.y -= Float.pi / 2
        leftPartNode.eulerAngles.x -= Float.pi / 2
        leftPartNode.position = SCNVector3(-width/2 - leftSide.height/2, leftSide.length/2, 0)
        print("Position of left part: \(leftPartNode.position)")
        addChildNode(leftPartNode)

        // create right part of the frame
        let rightSide = SCNBox(width: height, height: frameHeight, length: frameLength, chamferRadius: 0.001)
        let rightSideNode = SCNNode(geometry: rightSide)
        rightSideNode.eulerAngles.y -= Float.pi / 2
        rightSideNode.eulerAngles.x -= Float.pi / 2
        rightSideNode.position = SCNVector3(width/2 + rightSide.height/2, rightSide.length/2, 0)
        print("Position of right part: \(rightSideNode.position)")
        addChildNode(rightSideNode)

        // create bottom side of the frame
        let bottomSide = SCNBox(width: width, height: frameHeight, length: frameLength, chamferRadius: 0.001)
        let bottomSideNode = SCNNode(geometry: bottomSide)
        bottomSideNode.eulerAngles.x -= Float.pi / 2
        bottomSideNode.position = SCNVector3(0, bottomSide.length/2, height/2 + bottomSide.height/2)
        print("Position of bottom part: \(leftPartNode.position)")
        addChildNode(bottomSideNode)
    }
}
