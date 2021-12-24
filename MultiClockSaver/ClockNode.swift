//
//  ClockNode.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//

import SpriteKit

class ClockNode: SKNode {
    public let movementSpeed: CGFloat = 1
    
    public var debug: Bool = false
    
    private var minuteRotation: CGFloat = 0
    private var hourRotation: CGFloat = 0
    
    public let hourHandNode: SKSpriteNode = SKSpriteNode(texture: hourHandTexture)
    public let minuteHandNode: SKSpriteNode = SKSpriteNode(texture: minuteHandTexture)
    public let clockFaceNode: SKSpriteNode = SKSpriteNode(texture: clockFaceTexture)

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init()
        
        addChild(clockFaceNode)
        clockFaceNode.size = size
        clockFaceNode.zPosition = -2
        clockFaceNode.colorBlendFactor = 1
        clockFaceNode.color = .red
        clockFaceNode.alpha = 0.3
        
        hourHandNode.colorBlendFactor = 1
        hourHandNode.color = .white
        addChild(hourHandNode)
        hourHandNode.size = size
        
        minuteHandNode.colorBlendFactor = 1
        minuteHandNode.color = .white
        addChild(minuteHandNode)
        minuteHandNode.size = size
        
        
        clockFaceNode.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 5),
            SKAction.colorize(with: .orange, colorBlendFactor: 1, duration: 5),
            SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 5),
            SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 5),
            SKAction.colorize(with: .blue, colorBlendFactor: 1, duration: 5),
            SKAction.colorize(with: .purple, colorBlendFactor: 1, duration: 5)
        ])))
        
    }
    
    public func rotate(minuteDegrees: CGFloat, hourDegrees: CGFloat) {
        
        minuteHandNode.removeAllActions()
        hourHandNode.removeAllActions()
        
        // rotate minute hand
        let radianDifference = getRadianDifference(startDegrees: minuteHandNode.zRotation.radiansToDegrees(), endDegrees: -minuteDegrees)
        let duration = radianDifference / movementSpeed
        if radianDifference >= 0.1 {
            minuteHandNode.run(SKAction.rotate(byAngle: -radianDifference, duration: duration))
        }
        
        // rotate hour hand
        let radianDifferenceHour = getRadianDifference(startDegrees: hourHandNode.zRotation.radiansToDegrees(), endDegrees: -hourDegrees)
        let durationHour = radianDifferenceHour / movementSpeed
        if radianDifferenceHour >= 0.1 {
            hourHandNode.run(SKAction.rotate(byAngle: -radianDifferenceHour, duration: durationHour))
        }
    }
    
    public func rotate(by degrees: CGFloat) {
        let radians = degrees.degreesToRadians()
        hourHandNode.run(SKAction.rotate(byAngle: -radians, duration: radians / movementSpeed))
        minuteHandNode.run(SKAction.rotate(byAngle: -radians, duration: radians / movementSpeed))
    }
    
    
    private func getRadianDifference(startDegrees: CGFloat, endDegrees: CGFloat) -> CGFloat {
        
        if debug {
            print("Current degrees \(startDegrees)")
            print("Destination degrees \(endDegrees)")
        }
        var distanceInDegrees: CGFloat = 0.0
        if endDegrees >= startDegrees {
            distanceInDegrees = endDegrees - startDegrees
        } else {
            distanceInDegrees = 360-startDegrees+endDegrees
        }
        
        if abs(startDegrees - endDegrees) < 0.1 {
            return 0
        }
        
        if debug {
            print("Difference in degrees? \(distanceInDegrees)")
            print("Difference in radians? \(distanceInDegrees.degreesToRadians())")
        }
    
        return distanceInDegrees.degreesToRadians()
    }
    
}
