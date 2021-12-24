//
//  GameScene.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//

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
        
        controller?.clusters[0].position = CGPoint(x: 150, y: frame.height-150)
        controller?.clusters[1].position = CGPoint(x: 630, y: frame.height-150)
        controller?.clusters[2].position = CGPoint(x: 1110, y: frame.height-150)
        controller?.clusters[3].position = CGPoint(x: 1590, y: frame.height-150)

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
                controller?.testQueue()
            default:
                break
            }
        }
    }
    
    
}
