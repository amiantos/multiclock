//
//  MCAnimations.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/23/21.
//

import Foundation
import SpriteKit

enum AnimationTypes {
    case positionBothHands
    case spinBothHands
    case currentTimePrint
    case currentTimeClock
    case wait
}

class Animation {
    private let animationType: AnimationTypes
    public var degrees: CGFloat = 0.0
    public let movementSpeed: CGFloat = 1
    public var duration: TimeInterval = 0
    public var minuteDegrees: CGFloat = 0.0
    public var hourDegrees: CGFloat = 0.0
    
    init(animation: AnimationTypes) {
        animationType = animation
    }
    
    public func actions(clocks: [ClockNode], clusters: [NumberClusterNode]) -> SKAction {
        
        switch animationType {
        case .spinBothHands:
            return spinBothHands(by: self.degrees, clocks: clocks)
        case .currentTimePrint:
            return currentTimePrint(clusters: clusters)
        case .currentTimeClock:
            return currentTimeClock(clocks: clocks)
        case .wait:
            return wait(clocks: clocks)
        case .positionBothHands:
            return positionBothHands(clocks: clocks)
        }
        
    }
    
    // Animations
    
    private func wait(clocks: [ClockNode]) -> SKAction {
        var actions: [SKAction] = []
        clocks.forEach { clock in
            actions.append(SKAction.run {
                let action = SKAction.wait(forDuration: self.duration)
                clock.run(action) {
                    NotificationCenter.default.post(name: NSNotification.Name("AnimationComplete"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("AnimationComplete"), object: nil)
                }
            })
        }
        return SKAction.group(actions)
    }
    
    private func positionBothHands(clocks: [ClockNode]) -> SKAction {
        var actions: [SKAction] = []
        clocks.forEach { clock in
            actions.append(getActionGroupForPosition(clock: clock, minuteDegrees: self.minuteDegrees, hourDegrees: self.hourDegrees))
        }
        return SKAction.group(actions)
    }
    
    private func currentTimePrint(clusters: [NumberClusterNode]) -> SKAction {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hhmm"
        let timeString = dateFormatter.string(from: date)
        let array = timeString.map(String.init)
        
        var actions: [SKAction] = []
        
        for (index, cluster) in clusters.enumerated() {
            if let numberConfig = numberConfigs[Int(array[index])!] {
                for (index, item) in numberConfig.enumerated() {
                    let clock = cluster.clocks[index]
                    actions.append(getActionGroupForPosition(clock: clock, minuteDegrees: item.1, hourDegrees: item.0))
                }
            }
            
        }
        return SKAction.group(actions)
    }
    
    private func currentTimeClock(clocks: [ClockNode]) -> SKAction {
        let date = Date()
        let minute = Int(date.get(.minute))!
        var hour = Int(date.get(.hour))!
        
        hour = hour > 12 ? hour - 12 : hour
        
        let hourFloat = CGFloat(hour) + (CGFloat(minute) / 60)
        
        var actions: [SKAction] = []
        clocks.forEach { clock in
            actions.append(getActionGroupForPosition(clock: clock, minuteDegrees: -CGFloat(((360/60)*minute)), hourDegrees: -CGFloat(((360/12)*hourFloat))))
        }
        return SKAction.group(actions)
    }
    
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
    
    // Utils
    
    private func getActionGroupForPosition(clock: ClockNode, minuteDegrees: CGFloat, hourDegrees: CGFloat) -> SKAction {
        let radianDifference = getRadianDifference(startDegrees: clock.minuteHandNode.zRotation.radiansToDegrees(), endDegrees: -minuteDegrees)
        let duration = radianDifference / movementSpeed
        
        let minuteHandAction = SKAction.run {
            let action = SKAction.rotate(byAngle: -radianDifference, duration: duration)
            clock.minuteHandNode.run(action) {
                NotificationCenter.default.post(name: NSNotification.Name("AnimationComplete"), object: nil)
            }
        }

        let radianDifferenceHour = getRadianDifference(startDegrees: clock.hourHandNode.zRotation.radiansToDegrees(), endDegrees: -hourDegrees)
        let durationHour = radianDifferenceHour / movementSpeed
        
        let hourHandAction = SKAction.run {
            let action = SKAction.rotate(byAngle: -radianDifferenceHour, duration: durationHour)
            clock.hourHandNode.run(action) {
                NotificationCenter.default.post(name: NSNotification.Name("AnimationComplete"), object: nil)
            }
        }
        
        return SKAction.group([minuteHandAction, hourHandAction])
        
    }
    
    private func getRadianDifference(startDegrees: CGFloat, endDegrees: CGFloat) -> CGFloat {
        
        var distanceInDegrees: CGFloat = 0.0
        if endDegrees >= startDegrees {
            distanceInDegrees = endDegrees - startDegrees
        } else {
            distanceInDegrees = 360-startDegrees+endDegrees
        }
        
        if abs(startDegrees - endDegrees) < 0.1 {
            return 0
        }
    
        return distanceInDegrees.degreesToRadians()
    }
    
    // Static methods for queuing animations
    
    static func spinBothHands(by degrees: CGFloat) -> Animation {
        let animation = Animation(animation: .spinBothHands)
        animation.degrees = degrees
        return animation
    }
    
    static func currentTimePrint() -> Animation {
        return Animation(animation: .currentTimePrint)
    }
    
    static func currentTimeClock() -> Animation {
        return Animation(animation: .currentTimeClock)
    }
    
    static func wait(duration: TimeInterval) -> Animation {
        let animation = Animation(animation: .wait)
        animation.duration = duration
        return animation
    }
    
    static func positionBothHands(minuteDegrees: CGFloat, hourDegrees: CGFloat) -> Animation {
        let animation = Animation(animation: .positionBothHands)
        animation.minuteDegrees = minuteDegrees
        animation.hourDegrees = hourDegrees
        return animation
    }
}

let numberConfigs: [Int: [(CGFloat, CGFloat)]] = [
    // Tuple format is (hour, minute)
    0: [
        (-90, -180),
        (-270, -180),
        (-180, 0),
        (-180, 0),
        (-90, 0),
        (-270, 0),
    ],
    1: [
        (-225, -225),
        (-180, -180),
        (-225, -225),
        (-180, 0),
        (-225, -225),
        (0, 0)
    ],
    2: [
        (-90, -90),
        (-270, -180),
        (-180, -90),
        (-270, 0),
        (0, -90),
        (-270, -270)
    ],
    3: [
        (-90, -90),
        (-270, -180),
        (-90, -90),
        (0, -270),
        (-90, -90),
        (-270, 0)
    ],
    4: [
        (-180, -180),
        (-180, -180),
        (0, -90),
        (0, -180),
        (-225, -225),
        (0, 0)
    ],
    5: [
        (-180, -90),
        (-270, -270),
        (0, -90),
        (-270, -180),
        (-90, -90),
        (-270, 0)
    ],
    6: [
        (-180, -90),
        (-270, -270),
        (0, -180),
        (-270, -180),
        (0, -90),
        (0, -270)
    ],
    7: [
        (-90, -90),
        (-270, -180),
        (-225, -225),
        (-180, 0),
        (-225, -225),
        (0, 0)
    ],
    8: [
        (-90, -180),
        (-270, -180),
        (-90, 0),
        (-270, 0),
        (0, -90),
        (-270, 0)
    ],
    9: [
        (-90, -180),
        (-270, -180),
        (-90, 0),
        (0, -180),
        (-90, -90),
        (-270, 0)
    ],
]
