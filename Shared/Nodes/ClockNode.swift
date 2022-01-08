//
//  ClockNode.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

class ClockNode: SKNode {
    public var debug: Bool = false
    
    private var minuteRotation: CGFloat = 0
    private var hourRotation: CGFloat = 0
    
    public let hourHandNode: SKSpriteNode = SKSpriteNode(texture: hourHandTexture)
    public let minuteHandNode: SKSpriteNode = SKSpriteNode(texture: minuteHandTexture)
    public let clockFaceNode: SKSpriteNode = SKSpriteNode(texture: clockFaceTexture)

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize) {
        super.init()
    
        addChild(clockFaceNode)
        clockFaceNode.size = size
        clockFaceNode.zPosition = -1
        clockFaceNode.colorBlendFactor = 1
        clockFaceNode.color = Database.standard.dialColor
        clockFaceNode.alpha = 1
        
        hourHandNode.colorBlendFactor = 1
        hourHandNode.color = Database.standard.handColor
        addChild(hourHandNode)
        hourHandNode.size = size
        hourHandNode.zPosition = 0
        
        minuteHandNode.colorBlendFactor = 1
        minuteHandNode.color = Database.standard.handColor
        addChild(minuteHandNode)
        minuteHandNode.size = size
        hourHandNode.zPosition = 1
        
//        clockFaceNode.run(SKAction.repeatForever(SKAction.sequence([
//            SKAction.fadeAlpha(to: 0.1, duration: 5),
//            SKAction.fadeAlpha(to: 0.5, duration: 5)
//        ])))
        
        
//        clockFaceNode.run(SKAction.repeatForever(SKAction.sequence([
//            SKAction.colorize(with: .orange, colorBlendFactor: 1, duration: 5),
//            SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 5),
//            SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 5),
//            SKAction.colorize(with: .blue, colorBlendFactor: 1, duration: 5),
//            SKAction.colorize(with: .purple, colorBlendFactor: 1, duration: 5),
//            SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 5),
//        ])))
        
    }

}
