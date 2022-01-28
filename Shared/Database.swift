//
//  Database.swift
//  MultiClock
//
//  Created by Brad Root on 1/8/22.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

extension SKColor {
    static let defaultHandColor = SKColor(hue: 0, saturation: 0, brightness: 0.90, alpha: 1)
    static let defaultDialColor = SKColor(hue: 0, saturation: 0, brightness: 0.05, alpha: 1)
    static let defaultBackgroundColor = SKColor(hue: 0, saturation: 0, brightness: 0, alpha: 1)
}

struct Database {
    fileprivate enum Key {
        static let handColor = "multiClockHandColor"
        static let dialColor = "multiClockDialColor"
        static let backgroundColor = "multiClockBackgroundColor"
        static let handDesign = "multiClockHandDesign"
        static let dialDesign = "multiClockDialDesign"
    }
    
    static var standard: UserDefaults {
        var database = UserDefaults.standard
        if let customDatabase = UserDefaults(suiteName: "net.amiantos.MultiClockScreensaverSettings") {
            database = customDatabase
        }
        
        database.register(defaults: [
            Key.handColor: archiveData(SKColor.defaultHandColor),
            Key.dialColor: archiveData(SKColor.defaultDialColor),
            Key.backgroundColor: archiveData(SKColor.defaultBackgroundColor),
            Key.dialDesign: DialDesign.ringThin.rawValue,
            Key.handDesign: HandDesign.modern.rawValue
        ])
        
        return database
    }
}

extension UserDefaults {
    
    // Getters
    
    var handColor: SKColor {
        return unarchiveColor(data(forKey: Database.Key.handColor)!)
    }
    
    var dialColor: SKColor {
        return unarchiveColor(data(forKey: Database.Key.dialColor)!)
    }
    
    var backgroundColor: SKColor {
        return unarchiveColor(data(forKey: Database.Key.backgroundColor)!)
    }
    
    var handDesign: HandDesign {
        return HandDesign(rawValue: string(forKey: Database.Key.handDesign)!) ?? .modern
    }
    
    var dialDesign: DialDesign {
        return DialDesign(rawValue: string(forKey: Database.Key.dialDesign)!) ?? .ringThin
    }
    
    // Setters
    
    func set(handColor: SKColor) {
        set(archiveData(handColor), for: Database.Key.handColor)
    }
    
    func set(dialColor: SKColor) {
        set(archiveData(dialColor), for: Database.Key.dialColor)
    }
    
    func set(backgroundColor: SKColor) {
        set(archiveData(backgroundColor), for: Database.Key.backgroundColor)
    }
    
    func set(handDesign: HandDesign) {
        set(handDesign.rawValue, for: Database.Key.handDesign)
    }
    
    func set(dialDesign: DialDesign) {
        set(dialDesign.rawValue, for: Database.Key.dialDesign)
    }
}

private extension UserDefaults {
    func set(_ object: Any?, for key: String) {
        set(object, forKey: key)
        synchronize()
    }
}

private func archiveData(_ data: Any) -> Data {
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        return data
    } catch {
        fatalError("Failed to archive data")
    }
}

private func unarchiveColor(_ data: Data) -> SKColor {
    do {
        let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SKColor
        return color!
    } catch {
        fatalError("Failed to unarchive data")
    }
}
