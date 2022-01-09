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
    private let manager = Manager()

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
    @IBOutlet weak var handSwitcher: NSPopUpButton!
    
    @IBAction func handSwitcherAction(_ sender: NSPopUpButton) {
        switch sender.selectedTag() {
        case 1:
            manager.setHandDesign(.modernThin)
        case 2:
            manager.setHandDesign(.appleWatchSolid)
        case 3:
            manager.setHandDesign(.appleWatchFilled)
        case 4:
            manager.setHandDesign(.shout)
        default:
            manager.setHandDesign(.modern)
        }
    }
    @IBOutlet weak var dialSwitcher: NSPopUpButton!
    
    @IBAction func dialSwitcherAction(_ sender: NSPopUpButton) {
        switch sender.selectedTag() {
        case 1:
            manager.setDialDesign(.ringThick)
        case 2:
            manager.setDialDesign(.indices)
        default:
            manager.setDialDesign(.ringThin)
        }
    }
    
    
    @IBOutlet weak var handColorWell: NSColorWell!
    
    @IBAction func handColorWellAction(_ sender: NSColorWell) {
        let color = sender.color as NSColor
        // Ensure color is in the right colorspace
        if let normalizedCGColor = color.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil),
            let normalizedSKColor = SKColor(cgColor: normalizedCGColor) {
            manager.setHandColor(normalizedSKColor)
        }
    }
    
    @IBOutlet weak var dialColorWell: NSColorWell!
    
    @IBAction func dialColorWellAction(_ sender: NSColorWell) {
        let color = sender.color as NSColor
        // Ensure color is in the right colorspace
        if let normalizedCGColor = color.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil),
            let normalizedSKColor = SKColor(cgColor: normalizedCGColor) {
            manager.setDialColor(normalizedSKColor)
        }
    }
    
    // MARK: - View Setup

    override init() {
        super.init()
        let myBundle = Bundle(for: ConfigureSheetController.self)
        myBundle.loadNibNamed("ConfigureSheet", owner: self, topLevelObjects: nil)

        if let view = self.skView {
            let scene = ClockPreviewScene(size: view.frame.size)
            manager.delegate = scene
            skView.presentScene(scene)
        }
        
        loadSettings()
    }
    
    fileprivate func loadSettings() {
        handColorWell.color = manager.handColor
        dialColorWell.color = manager.dialColor
        
        switch manager.dialDesign {
        case .ringThin:
            dialSwitcher.selectItem(at: 0)
        case .ringThick:
            dialSwitcher.selectItem(at: 1)
        case .indices:
            dialSwitcher.selectItem(at: 2)
        }
        
        switch manager.handDesign {
        case .modern:
            handSwitcher.selectItem(at: 0)
        case .modernThin:
            handSwitcher.selectItem(at: 1)
        case .appleWatchSolid:
            handSwitcher.selectItem(at: 2)
        case .appleWatchFilled:
            handSwitcher.selectItem(at: 3)
        case .shout:
            handSwitcher.selectItem(at: 4)
        }
    }
}
