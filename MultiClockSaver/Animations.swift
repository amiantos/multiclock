//
//  MCAnimations.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/23/21.
//

import Foundation
import SpriteKit

enum AnimationTypes {
    case spinBothHands
}

class Animation {
    private let animationType: AnimationTypes
    public var degrees: CGFloat = 0.0
    
    init(animation: AnimationTypes) {
        animationType = animation
    }
    
    public func actions(clocks: [ClockNode], clusters: [NumberClusterNode]) -> SKAction {
        
        switch animationType {
        case .spinBothHands:
            return spinBothHands(by: self.degrees, clocks: clocks)
        }
        
    }
    
    // Animations
    
    private func spinBothHands(by degrees: CGFloat, clocks: [ClockNode]) -> SKAction {
        let radians = degrees.degreesToRadians()
        var actions: [SKAction] = []
        clocks.forEach { clock in
            let minuteHandAction = SKAction.run {
                let action = SKAction.rotate(byAngle: -radians, duration: radians / clock.movementSpeed)
                clock.minuteHandNode.run(action) {
                    NotificationCenter.default.post(name: NSNotification.Name("AnimationComplete"), object: nil)
                }
            }
            let hourHandAction = SKAction.run {
                let action = SKAction.rotate(byAngle: -radians, duration: radians / clock.movementSpeed)
                clock.hourHandNode.run(action) {
                    NotificationCenter.default.post(name: NSNotification.Name("AnimationComplete"), object: nil)
                }
            }
            let group = SKAction.group([minuteHandAction, hourHandAction])
            actions.append(group)
        }
        return SKAction.group(actions)
    }
    
    // Static methods for queuing animations
    
    static func spinBothHands(by degrees: CGFloat) -> Animation {
        let animation = Animation(animation: .spinBothHands)
        animation.degrees = degrees
        return animation
    }
}
