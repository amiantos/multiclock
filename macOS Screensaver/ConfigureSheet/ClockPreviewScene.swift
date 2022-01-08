//
//  ClockPreviewScene.swift
//  Screensaver
//
//  Created by Brad Root on 1/6/22.
//

import SpriteKit

class ClockPreviewScene: SKScene, ManagerDelegate {
    
    let clockNode = ClockNode(size: CGSize(width: 150, height: 150))
    
    override func sceneDidLoad() {
        
        backgroundColor = .black
        
        clockNode.minuteHandNode.color = Database.standard.handColor
        clockNode.hourHandNode.color = Database.standard.handColor
        
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
    
    func updatedSettings() {
        clockNode.minuteHandNode.color = Database.standard.handColor
        clockNode.hourHandNode.color = Database.standard.handColor
        clockNode.clockFaceNode.color = Database.standard.dialColor
    }
    
}
