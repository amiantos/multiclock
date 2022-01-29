//
//  ViewController.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            let scene = ClockScene(size: view.frame.size)
            view.showsFPS = true
            view.showsDrawCount = true
            view.showsNodeCount = true
            view.presentScene(scene)
            scene.controller?.mode = .manual
            scene.controller?.start()
            
            scene.controller?.scene?.backgroundColor = .blue
            
            scene.controller?.clocks.forEach({ clockNode in
                clockNode.clockFaceNode.texture = dialTextures[.indices]!
                clockNode.minuteHandNode.texture = handTextures[.appleWatchFilled]!.minuteHandTexture
                clockNode.hourHandNode.texture = handTextures[.appleWatchFilled]!.hourHandTexture
                clockNode.clockFaceNode.color = .white
            })
        }
    }
}

