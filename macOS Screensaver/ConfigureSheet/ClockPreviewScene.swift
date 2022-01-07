//
//  ClockPreviewScene.swift
//  Screensaver
//
//  Created by Brad Root on 1/6/22.
//

import SpriteKit

class ClockPreviewScene: SKScene {
    
    override func sceneDidLoad() {
        
        backgroundColor = .black
        
        let clockNode = ClockNode(size: CGSize(width: 150, height: 150))
        addChild(clockNode)
        clockNode.position = CGPoint(x: 75, y: 75)
        
        let rotation: CGFloat = -360
        clockNode.minuteHandNode.run(SKAction.repeatForever(
            SKAction.rotate(byAngle: rotation.degreesToRadians(), duration: 4)
        ))
        clockNode.hourHandNode.run(SKAction.repeatForever(
            SKAction.rotate(byAngle: rotation.degreesToRadians(), duration: 48)
        ))
    }
}
