//
//  ClockPreviewScene.swift
//  Screensaver
//
//  Created by Brad Root on 1/6/22.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

class ClockPreviewScene: SKScene, ManagerDelegate {
    
    let clockNode = ClockNode(size: CGSize(width: 150, height: 150))
    
    override func sceneDidLoad() {
        
        backgroundColor = Database.standard.backgroundColor
        
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
        
        backgroundColor = Database.standard.backgroundColor
        
        clockNode.minuteHandNode.texture = handTextures[Database.standard.handDesign]?.minuteHandTexture
        clockNode.hourHandNode.texture = handTextures[Database.standard.handDesign]?.hourHandTexture
        
        clockNode.clockFaceNode.texture = dialTextures[Database.standard.dialDesign]!
    }
    
}
