//
//  GameViewController.swift
//  MultiClock
//
//  Created by Brad Root on 12/24/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            let scene = ClockScene(size: view.frame.size)
            view.presentScene(scene)
        }
    }

}
