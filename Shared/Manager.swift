//
//  Manager.swift
//  MultiClock
//
//  Created by Brad Root on 1/8/22.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

protocol ManagerDelegate: AnyObject {
    func updatedSettings()
}

final class Manager {
    weak var delegate: ManagerDelegate?
    
    private(set) var handColor: SKColor
    private(set) var dialColor: SKColor
    private(set) var backgroundColor: SKColor
    private(set) var handDesign: HandDesign
    private(set) var dialDesign: DialDesign
    
    init() {
        handColor = Database.standard.handColor
        dialColor = Database.standard.dialColor
        backgroundColor = Database.standard.backgroundColor
        handDesign = Database.standard.handDesign
        dialDesign = Database.standard.dialDesign
    }
    
    // MARK: Setters
    
    func setHandColor(_ color: SKColor) {
        Database.standard.set(handColor: color)
        delegate?.updatedSettings()
    }
    
    func setDialColor(_ color: SKColor) {
        Database.standard.set(dialColor: color)
        delegate?.updatedSettings()
    }
    
    func setBackgroundColor(_ color: SKColor) {
        Database.standard.set(backgroundColor: color)
        delegate?.updatedSettings()
    }
    
    func setHandDesign(_ handDesign: HandDesign) {
        Database.standard.set(handDesign: handDesign)
        delegate?.updatedSettings()
    }
    
    func setDialDesign(_ dialDesign: DialDesign) {
        Database.standard.set(dialDesign: dialDesign)
        delegate?.updatedSettings()
    }
}
