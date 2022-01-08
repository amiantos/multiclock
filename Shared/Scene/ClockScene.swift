//
//  ClockScene.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit
import GameplayKit

class ClockScene: SKScene, ManagerDelegate {
    public var controller: ClockController?
    
    private var backgroundNode: SKShapeNode?
    
    override func sceneDidLoad() {
        backgroundColor = .black
        
        controller = ClockController(size: frame.size)
        controller?.scene = self
        
        controller?.clusters.forEach({ cluster in
            addChild(cluster)
        })
        
        let clockSize = frame.size.width/4/2
        
        controller?.clusters[0].position = CGPoint(
            x: (clockSize/2),
            y: frame.size.height - (clockSize / 2) - ((frame.size.height - (clockSize * 3)) / 2)
        )
        controller?.clusters[1].position = CGPoint(
            x: (clockSize/2) + (clockSize * 2),
            y: frame.size.height - (clockSize / 2) - ((frame.size.height - (clockSize * 3)) / 2)
        )
        controller?.clusters[2].position = CGPoint(
            x: (clockSize/2) + (clockSize * 4),
            y: frame.size.height - (clockSize / 2) - ((frame.size.height - (clockSize * 3)) / 2)
        )
        controller?.clusters[3].position = CGPoint(
            x: (clockSize/2) + (clockSize * 6),
            y: frame.size.height - (clockSize / 2) - ((frame.size.height - (clockSize * 3)) / 2)
        )
        
        controller?.start()

    }
    
    func updatedSettings() {
        // Replace textures as needed
    }
    
    override func didMove(to view: SKView) {

    }
    
#if os(macOS)
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
#endif
    
}
