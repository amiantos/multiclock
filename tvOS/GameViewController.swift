//
//  GameViewController.swift
//  MultiClock
//
//  Created by Brad Root on 12/24/21.
//

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
