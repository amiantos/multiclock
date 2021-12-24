//
//  ClocksController.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/22/21.
//

import Foundation
import SpriteKit

class ClocksController {
    public var clusters: [NumberClusterNode] = []
    public var clocks: [ClockNode] = []
    public weak var scene: SKScene?
    
    private var animationsCompleted: Int = 0
    
    private var animationQueue: [Animation] = []
    private var isAnimating: Bool = false
    
    private var timer: Timer?
    private var updateInterval: TimeInterval
    
    private var lastTimeDisplayed: String = "0000"
    
    init() {
        for _ in 1...4 {
            let cluster = NumberClusterNode(size: CGSize(width: 480, height: 720))
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

        if timeString != lastTimeDisplayed {
            lastTimeDisplayed = timeString
            clocks.forEach { clock in
                clock.removeAllActions()
                clock.hourHandNode.removeAllActions()
                clock.minuteHandNode.removeAllActions()
            }
            animationQueue.removeAll()
            
            run([
                Animation.spinBothHands(by: 180),
                Animation.currentTimePrint(),
            ])
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        run([
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
        scene?.run(actionGroup)
    }
    
    private func run(_ animations: [Animation]) {
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
        run([Animation.currentTimePrint()])
    }
    
    public func returnToMidnight() {
        run([Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0)])
    }
    
    public func moveAll(degrees: CGFloat) {
        run([Animation.positionBothHands(minuteDegrees: degrees, hourDegrees: degrees)])
    }
    
    public func moveAll(minuteDegrees: CGFloat, hourDegrees: CGFloat) {
        run([Animation.positionBothHands(minuteDegrees: minuteDegrees, hourDegrees: hourDegrees)])
    }
    
    public func setAllToCurrentTime() {
        run([Animation.currentTimeClock()])
    }
    
    public func rotateAll(by degrees: CGFloat) {
        run([Animation.spinBothHands(by: degrees)])
    }
    
    public func testQueue() {
        run([
            Animation.spinBothHands(by: 360),
            Animation.currentTimePrint(),
        ])
    }
}
