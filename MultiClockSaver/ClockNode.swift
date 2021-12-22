//
//  ClockNode.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//

import SpriteKit

class ClockNode: SKNode {
    private var minuteRotation: CGFloat = 0
    private var hourRotation: CGFloat = 0
    
    private let hourHandNode: SKSpriteNode = SKSpriteNode(texture: hourHandTexture)
    private let minuteHandNode: SKSpriteNode = SKSpriteNode(texture: minuteHandTexture)
    private let clockFaceNode: SKSpriteNode = SKSpriteNode(texture: clockFaceTexture)

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init()
        
        addChild(clockFaceNode)
        clockFaceNode.size = size
        clockFaceNode.zPosition = -2
        
        hourHandNode.colorBlendFactor = 1
        hourHandNode.color = .black
        addChild(hourHandNode)
        hourHandNode.size = size
        
        minuteHandNode.colorBlendFactor = 1
        minuteHandNode.color = .black
        addChild(minuteHandNode)
        minuteHandNode.size = size
        
    }
    
    public func rotate(minuteDegrees: CGFloat, hourDegrees: CGFloat) {
        
        let rotateAction = SKAction.rotate(toAngle: minuteDegrees.degreesToRadians(), duration: 1, shortestUnitArc: false)
        minuteHandNode.run(rotateAction)
        
        let rotateAction2 = SKAction.rotate(toAngle: hourDegrees.degreesToRadians(), duration: 1, shortestUnitArc: false)
        hourHandNode.run(rotateAction2)
        
    }
    
}
