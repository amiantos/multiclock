//
//  ClockController.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/22/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.


import Foundation
import SpriteKit

enum ClockMode {
    case automatic
    case manual
}

class ClockController {
    public var clusters: [ClusterNode] = []
    public var clocks: [ClockNode] = []
    
    public var mode: ClockMode = .automatic
    
    public weak var scene: SKScene?
    
    private var animationsCompleted: Int = 0
    
    private var animationQueue: [Animation] = []
    private var isAnimating: Bool = false
    
    private var timer: Timer?
    private var updateInterval: TimeInterval
    
    private var lastTimeDisplayed: String = "0000"
    
    private var timeSinceLastAnimation: Int = 30
    
    private var allAnimations: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9].shuffled()
    
    private var availableAnimations: [Int] = []
    
    init(size: CGSize) {
        for _ in 1...4 {
            let cluster = ClusterNode(size: CGSize(width: size.width/4, height: (size.width/4/2)*3))
            clusters.append(cluster)
            clocks.append(contentsOf: cluster.clocks)
        }

        Log.logLevel = .debug
        Log.useEmoji = true
        
        updateInterval = TimeInterval(1)
    }
    
    public func start() {
        if mode == .automatic {
            startTimer()
        }
    }

    public func queue(animations: [Animation]) {
        animationQueue.append(contentsOf: animations)
        startAnimationQueueIfNeeded()
    }
    
    // MARK: - Timer
    
    @objc func updateTime() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hhmm"
        if Date.is24Hour() {
            dateFormatter.dateFormat = "HHmm"
        }
        let timeString = dateFormatter.string(from: date)
        
        timeSinceLastAnimation += 1

        if timeString != lastTimeDisplayed && !isAnimating {
            lastTimeDisplayed = timeString
            
            if timeSinceLastAnimation <= 3 {
                queue(animations: [
                    Animation.currentTimePrint(),
                ])
            } else {
                queue(animations: [
                    Animation.spinBothHands(by: 180),
                    Animation.currentTimePrint(),
                ])
            }
        } else if timeSinceLastAnimation >= 20 && !isAnimating {
            if availableAnimations.isEmpty {
                availableAnimations = allAnimations
            }
            
            let number = availableAnimations.popLast()!
            Log.debug("Displaying random animation \(number)...")

            switch number {
            case 1:
                // this one is pretty cool imho
                queue(animations: [
                    Animation.positionBothHands(minuteDegrees: -225, hourDegrees: -225),
                    Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -225),
                    Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -45),
                    Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0),
                    Animation.currentTimePrint(),
                ])
            case 2:
                // simple time delay 2x full sweep
                queue(animations: [
                    Animation.spinBothHandsWithDelay(by: 720, delay: 0.5)
                ])
            case 3:
                // single sweep big delay
                queue(animations: [
                    Animation.spinBothHandsWithDelay(by: 360, delay: 1)
                ])
            case 4:
                // inward pointing pattern
                queue(animations: [
                    Animation.display(pattern: inwardPointPattern),
                    Animation.wait(duration: 5),
                    Animation.spinBothHands(by: 360),
                    Animation.display(pattern: halfDownHalfUp),
                    Animation.spinBothHands(by: 360),
                    Animation.positionBothHands(minuteDegrees: -180, hourDegrees: 0),
                    Animation.spinBothHands(by: 180),
                    Animation.currentTimePrint(),
                ])
            case 5:
                // horizontal lines pattern
                queue(animations: [
                    Animation.display(pattern: horizontalLinesPattern),
                    Animation.wait(duration: 10),
                    Animation.positionBothHands(minuteDegrees: -90, hourDegrees: -270),
                    Animation.positionBothHands(minuteDegrees: -90, hourDegrees: -90),
                    Animation.positionBothHands(minuteDegrees: -180, hourDegrees: -180),
                    Animation.currentTimePrint(),
                ])
            case 6:
                // display randomized clock hand positions
                queue(animations: [
                    Animation.display(pattern: Animation.randomizedPattern()),
                    Animation.wait(duration: 5),
                    Animation.spinBothHands(by: 180),
                    Animation.currentTimePrint(),
                ])
            case 7:
                // display randomized clock hand positions (right angles only)
                queue(animations: [
                    Animation.display(pattern: Animation.randomizedRightAnglePattern()),
                    Animation.wait(duration: 5),
                    Animation.spinBothHands(by: 180),
                    Animation.currentTimePrint(),
                ])
            case 8:
                // display box pattern
                queue(animations: [
                    Animation.display(pattern: boxPattern),
                    Animation.wait(duration: 5),
                    Animation.display(pattern: Animation.randomizedRightAnglePattern()),
                    Animation.spinBothHands(by: 180),
                    Animation.currentTimePrint(),
                ])
            default:
                // delay spin with current time as clock
                queue(animations: [
                    Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -225),
                    Animation.spinBothHandsWithDelay(by: 180, delay: 0.2),
                    Animation.currentTimeClock(),
                    Animation.wait(duration: 5),
                    Animation.positionBothHands(minuteDegrees: -225, hourDegrees: -225),
                    Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0),
                    Animation.currentTimePrint(),
                ])
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        queue(animations: [
            Animation.currentTimePrint(),
        ])

        let newTimer = Timer(timeInterval: updateInterval, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        newTimer.tolerance = 5
        RunLoop.main.add(newTimer, forMode: .common)

        timer = newTimer

        Log.debug("Manager: Timer Started")
    }

    private func stopTimer() {
        if let existingTimer = timer {
            Log.debug("Manager: Timer Stopped")
            existingTimer.invalidate()
            timer = nil
        }
    }
    
    // MARK: - Animations
    
    private func animationCompleted() {
        timeSinceLastAnimation = 0
        animationsCompleted += 1
        if animationsCompleted == 48 {
            Log.debug("All animations completed!")
            animationsCompleted = 0
            if animationQueue.isEmpty {
                Log.debug("Animation queue exhausted!")
                isAnimating = false
            } else {
                Log.debug("Running next animation...")
                runNextAnimation()
            }
        }
    }
    
    
    private func setCurrentTime(time: String) {
        if time != lastTimeDisplayed {
            Log.debug("New displayed time: \(time)")
            lastTimeDisplayed = time
        }
    }
    
    private func run(_ animation: Animation) {
        let actionGroup = animation.actions(clocks: clocks, clusters: clusters, completionHandler: animationCompleted, timeSetCompletionHandler: setCurrentTime)
        isAnimating = true
        timeSinceLastAnimation = 0
        scene?.run(actionGroup)
    }
    
    private func runNextAnimation() {
        let animation =  animationQueue.removeFirst()
        run(animation)
    }
    
    private func startAnimationQueueIfNeeded() {
        if !isAnimating {
            runNextAnimation()
        }
    }

}
