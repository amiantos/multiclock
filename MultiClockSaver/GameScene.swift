//
//  GameScene.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    public var controller: ClocksController?
    
    private var backgroundNode: SKShapeNode?
    
    override func sceneDidLoad() {
        backgroundColor = .black
        
        controller = ClocksController()
        controller?.scene = self
        
        controller?.clusters.forEach({ cluster in
            addChild(cluster)
        })
        
        controller?.clusters[0].position = CGPoint(x: 120, y: frame.height-240)
        controller?.clusters[1].position = CGPoint(x: 600, y: frame.height-240)
        controller?.clusters[2].position = CGPoint(x: 1080, y: frame.height-240)
        controller?.clusters[3].position = CGPoint(x: 1560, y: frame.height-240)
        
        controller?.start()

    }
    
    override func didMove(to view: SKView) {

    }
    
    override func keyUp(with event: NSEvent) {
        if let character = event.characters {
            switch character {
            case "t":
                controller?.showCurrentTime()
            case "d":
                controller?.returnToMidnight()
            case "x":
                controller?.moveAll(degrees: -45)
            case "c":
                controller?.moveAll(minuteDegrees: -45, hourDegrees: -225)
            case "r":
                controller?.setAllToCurrentTime()
            case "p":
                controller?.rotateAll(by: 360)
            case "o":
                controller?.queue(animations: [
                    Animation.display(pattern: horizontalLinesPattern),
                    Animation.wait(duration: 10),
                    Animation.positionBothHands(minuteDegrees: -90, hourDegrees: -270),
                    Animation.positionBothHands(minuteDegrees: -90, hourDegrees: -90),
                    Animation.positionBothHands(minuteDegrees: -180, hourDegrees: -180),
                    Animation.currentTimePrint(),
                ])
            default:
                break
            }
        }
    }
    
    
}
