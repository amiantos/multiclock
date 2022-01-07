//
//  ConfigureSheetController.swift
//  Life Saver Screensaver
//
//  Created by Brad Root on 5/21/19.
//  Copyright © 2019 Brad Root. All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Cocoa
import SpriteKit

final class ConfigureSheetController: NSObject {
//    private let manager = LSManager()

    // MARK: - Config Actions and Outlets

    @IBOutlet var window: NSWindow?
    
    @IBOutlet var skView: SKView!

    @IBAction func closeButtonAction(_ sender: NSButton) {
        guard let window = window else { return }
        window.sheetParent?.endSheet(window)
    }
    
    @IBAction func gitHubLinkAction(_ sender: NSButton) {
        URLType.github.open()
    }
    
    @IBAction func twitterLinkAction(_ sender: NSButton) {
        URLType.twitter.open()
    }
    
    @IBAction func bradLinkAction(_ sender: NSButton) {
        URLType.brad.open()
    }
    
    // MARK: - View Setup

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)

        if let view = self.skView {
            let scene = ClockPreviewScene(size: view.frame.size)
            skView.presentScene(scene)
        }
    }
    
    

    fileprivate func loadSettings() {
//        backgroundColorWell.color = manager.backgroundColor
//
//        let textColor = manager.textColor
//        if textColor == SKColor.lightTextColor {
//            textColorControl.selectedSegment = 1
//        } else {
//            textColorControl.selectedSegment = 0
//        }
//
//        updateSyncLabel()
    }

    fileprivate func updateSyncLabel() {
//        let df = DateFormatter()
//        df.dateFormat = "yyyy-MM-dd"
//        lastSyncTimeLabel.stringValue = "Last Update: \(df.string(from: manager.lastSyncTime))"
    }
}
