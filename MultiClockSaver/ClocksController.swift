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
    
    public func showCurrentTime() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hhmm"
        let timeString = dateFormatter.string(from: date)
        let array = timeString.map(String.init)
        
        clusters[0].setNumber(Int(array[0])!)
        clusters[1].setNumber(Int(array[1])!)
        clusters[2].setNumber(Int(array[2])!)
        clusters[3].setNumber(Int(array[3])!)
    }
    
    public func returnToMidnight() {
        clocks.forEach { clock in
            clock.rotate(minuteDegrees: 0, hourDegrees: 0)
        }
    }
    
    public func moveAll(degrees: CGFloat) {
        clocks.forEach { clock in
            clock.rotate(minuteDegrees: degrees, hourDegrees: degrees)
        }
    }
    
    public func moveAll(minuteDegrees: CGFloat, hourDegrees: CGFloat) {
        clocks.forEach { clock in
            clock.rotate(minuteDegrees: minuteDegrees, hourDegrees: hourDegrees)
        }
    }
    
    public func setAllToCurrentTime() {
        let date = Date()
        let minute = Int(date.get(.minute))!
        var hour = Int(date.get(.hour))!
        
        hour = hour > 12 ? hour - 12 : hour
        
        let hourFloat = CGFloat(hour) + (CGFloat(minute) / 60)
        
        print("hour float: \(hourFloat)")
        
        clocks.forEach { clock in
            clock.rotate(
                minuteDegrees: -CGFloat(((360/60)*minute)),
                hourDegrees: -CGFloat(((360/12)*hourFloat))
            )
        }
    }
    
    public func rotateAll(by degrees: CGFloat) {
        let animation = Animation.spinBothHands(by: degrees)
        run(animation)
    }
    
    public func testQueue() {
        run([Animation.spinBothHands(by: 90), Animation.spinBothHands(by: 360)])
    }
}
