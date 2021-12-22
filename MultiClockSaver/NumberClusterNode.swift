//
//  NumberClusterNode.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//

import SpriteKit

class NumberClusterNode: SKNode {
    public var clocks: [ClockNode] = []
    
    private var numberConfigs: [Int: [(CGFloat, CGFloat)]] = [
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init()
        
        for _ in 1...6 {
            clocks.append(ClockNode(size: CGSize(width: size.width / 2, height: size.height / 3)))
        }
        
        clocks.forEach { node in
            addChild(node)
        }
        
        clocks[0].position = CGPoint(x: 0, y: 0)
        clocks[1].position = CGPoint(x: size.width / 2, y:0)
        
        clocks[2].position = CGPoint(x: 0, y: -(size.height / 3))
        clocks[3].position = CGPoint(x: size.width / 2, y: -(size.height / 3))
        
        clocks[4].position = CGPoint(x: 0, y: -(size.height / 3)*2)
        clocks[5].position = CGPoint(x: size.width / 2, y: -(size.height / 3)*2)
        
    }
    
    public func setNumber(_ number: Int) {
        if let numberConfig = numberConfigs[number] {
            for (index, item) in numberConfig.enumerated() {
                let foundClock = clocks[index]
                foundClock.rotate(minuteDegrees: item.1, hourDegrees: item.0)
            }
        }
    }


    
}
