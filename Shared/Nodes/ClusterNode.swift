//
//  ClusterNode.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

class ClusterNode: SKNode {
    public var clocks: [ClockNode] = []

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
}
