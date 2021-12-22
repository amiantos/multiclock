//
//  ClocksController.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/22/21.
//

import Foundation

class ClocksController {
    public var clusters: [NumberClusterNode] = []
    public var clocks: [ClockNode] = []
    
    init() {
        for _ in 1...4 {
            let cluster = NumberClusterNode(size: CGSize(width: 480, height: 720))
            clusters.append(cluster)
            clocks.append(contentsOf: cluster.clocks)
        }
        
        clocks[0].debug = true
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
}
