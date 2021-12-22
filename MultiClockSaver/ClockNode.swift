//
//  ClockNode.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//

import SpriteKit

class ClockNode: SKNode {
    public var debug: Bool = false
    
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
        
        minuteHandNode.removeAllActions()
        hourHandNode.removeAllActions()
        
        // rotate minute hand
        let radianDifference = getRadianDifference(startDegrees: minuteHandNode.zRotation.radiansToDegrees(), endDegrees: -minuteDegrees)
        let duration = radianDifference / 0.8
        if radianDifference >= 0.1 {
            minuteHandNode.run(SKAction.rotate(byAngle: -radianDifference, duration: duration))
        }
        
        // rotate hour hand
        let radianDifferenceHour = getRadianDifference(startDegrees: hourHandNode.zRotation.radiansToDegrees(), endDegrees: -hourDegrees)
        let durationHour = radianDifferenceHour / 0.8
        if radianDifferenceHour >= 0.1 {
            hourHandNode.run(SKAction.rotate(byAngle: -radianDifferenceHour, duration: durationHour))
        }
        
        
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
