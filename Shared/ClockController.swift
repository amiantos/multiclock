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

class ClockController {
    public var clusters: [ClusterNode] = []
    public var clocks: [ClockNode] = []
    public weak var scene: SKScene?
    
    private var animationsCompleted: Int = 0
    
    private var animationQueue: [Animation] = []
    private var isAnimating: Bool = false
    
    private var timer: Timer?
    private var updateInterval: TimeInterval
    
    private var lastTimeDisplayed: String = "0000"
    
    private var timeSinceLastAnimation: Int = 30
    
    init(size: CGSize) {
        for _ in 1...4 {
            let cluster = ClusterNode(size: CGSize(width: size.width/4, height: (size.width/4/2)*3))
            clusters.append(cluster)
            clocks.append(contentsOf: cluster.clocks)
        }

        Log.logLevel = .debug
        Log.useEmoji = true
        
        updateInterval = TimeInterval(1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(animationCompleted), name: NSNotification.Name("AnimationComplete"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setCurrentTime(_:)), name: NSNotification.Name("SetCurrentTime"), object: nil)
    }
    
    public func start() {
        startTimer()
    }
    
    // MARK: - Timer
    
    @objc func setCurrentTime(_ notification: NSNotification) {
        if let time = notification.userInfo?["time"] as? String {
            if time != lastTimeDisplayed {
                Log.debug("New displayed time: \(time)")
                lastTimeDisplayed = time
            }
        }
    }
    
    @objc func updateTime() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hhmm"
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
            Log.debug("Displaying random animation...")
            
            let number = Int.random(in: 1...6)
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
                    Animation.display(pattern: testPattern),
                    Animation.wait(duration: 5),
                    Animation.spinBothHands(by: 360),
                    Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0),
                    Animation.spinBothHands(by: 360),
                    Animation.currentTimePrint(),
                ])
            case 5:
                queue(animations: [
                    Animation.display(pattern: horizontalLinesPattern),
                    Animation.wait(duration: 10),
                    Animation.positionBothHands(minuteDegrees: -90, hourDegrees: -270),
                    Animation.positionBothHands(minuteDegrees: -90, hourDegrees: -90),
                    Animation.positionBothHands(minuteDegrees: -180, hourDegrees: -180),
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
        newTimer.tolerance = 0.2
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
    
    @objc func animationCompleted() {
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
    
    private func run(_ animation: Animation) {
        let actionGroup = animation.actions(clocks: clocks, clusters: clusters)
        isAnimating = true
        timeSinceLastAnimation = 0
        scene?.run(actionGroup)
    }
    
    public func queue(animations: [Animation]) {
        animationQueue.append(contentsOf: animations)
        startAnimationQueueIfNeeded()
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
    
    // Helper functions for manually triggering animations
    
    public func showCurrentTime() {
        queue(animations: [Animation.currentTimePrint()])
    }
    
    public func returnToMidnight() {
        queue(animations: [Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0)])
    }
    
    public func moveAll(degrees: CGFloat) {
        queue(animations: [Animation.positionBothHands(minuteDegrees: degrees, hourDegrees: degrees)])
    }
    
    public func moveAll(minuteDegrees: CGFloat, hourDegrees: CGFloat) {
        queue(animations: [Animation.positionBothHands(minuteDegrees: minuteDegrees, hourDegrees: hourDegrees)])
    }
    
    public func setAllToCurrentTime() {
        queue(animations: [Animation.currentTimeClock()])
    }
    
    public func rotateAll(by degrees: CGFloat) {
        queue(animations: [Animation.spinBothHands(by: degrees)])
    }
    
    public func testQueue() {
        queue(animations: [
            Animation.spinBothHands(by: 360),
            Animation.currentTimePrint(),
        ])
    }
}
