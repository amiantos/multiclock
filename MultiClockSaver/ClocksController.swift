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
    
    init() {
        for _ in 1...4 {
            let cluster = NumberClusterNode(size: CGSize(width: 480, height: 720))
            clusters.append(cluster)
            clocks.append(contentsOf: cluster.clocks)
        }
        
        clocks[0].debug = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(animationCompleted), name: NSNotification.Name("AnimationComplete"), object: nil)
    }
    
    @objc public func animationCompleted() {
        animationsCompleted += 1
        if animationsCompleted == 48 {
            print("All animations completed!")
            animationsCompleted = 0
            if animationQueue.isEmpty {
                print("Animation queue exhausted!")
                isAnimating = false
            } else {
                print("Running next animation...")
                runNextAnimation()
            }
        }
    }
    
    public func run(_ animation: Animation) {
        let actionGroup = animation.actions(clocks: clocks, clusters: clusters)
        isAnimating = true
        scene?.run(actionGroup)
    }
    
    public func run(_ animations: [Animation]) {
        animationQueue.append(contentsOf: animations)
        startAnimationQueueIfNeeded()
    }
    
    public func runNextAnimation() {
        let animation =  animationQueue.removeFirst()
        run(animation)
    }
    
    public func startAnimationQueueIfNeeded() {
        if !isAnimating {
            runNextAnimation()
        }
    }
    
    // Helper functions for manually triggering animations
    
    public func showCurrentTime() {
        run(Animation.currentTimePrint())
    }
    
    public func returnToMidnight() {
        run(Animation.positionBothHands(minuteDegrees: 0, hourDegrees: 0))
    }
    
    public func moveAll(degrees: CGFloat) {
        run(Animation.positionBothHands(minuteDegrees: degrees, hourDegrees: degrees))
    }
    
    public func moveAll(minuteDegrees: CGFloat, hourDegrees: CGFloat) {
        run(Animation.positionBothHands(minuteDegrees: minuteDegrees, hourDegrees: hourDegrees))
    }
    
    public func setAllToCurrentTime() {
        run(Animation.currentTimeClock())
    }
    
    public func rotateAll(by degrees: CGFloat) {
        run(Animation.spinBothHands(by: degrees))
    }
    
    public func testQueue() {
        run([
            Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -225),
            Animation.spinBothHands(by: 360),
            Animation.currentTimeClock(),
            Animation.wait(duration: 5),
            Animation.currentTimePrint(),
            Animation.wait(duration: 5),
            Animation.spinBothHands(by: 360),
            Animation.positionBothHands(minuteDegrees: -45, hourDegrees: -225)
        ])
    }
}
