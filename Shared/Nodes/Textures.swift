//
//  Textures.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SpriteKit

enum HandDesign: String {
    case modern = "modern"
    case modernThin = "modernThin"
    case appleWatchSolid = "appleWatchSolid"
    case appleWatchFilled = "appleWatchFilled"
    case shout = "shout"
    case lcd = "lcd"
    case traditional = "traditional"
}

enum DialDesign: String {
    case ringThin = "ringThin"
    case ringIndices = "ringIndices"
    case ringThick = "ringThick"
    case indices = "indices"
    case cutOff = "cufOff"
}

struct HandTextureSet {
    let hourHandTexture: SKTexture?
    let minuteHandTexture: SKTexture?
}

let handTextures: [HandDesign: HandTextureSet] = [
    .modern: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "modernHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "modernMinuteHand")
    ),
    .modernThin: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "modernThinHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "modernThinMinuteHand")
    ),
    .appleWatchFilled: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "appleWatchFilledHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "appleWatchFilledMinuteHand")
    ),
    .appleWatchSolid: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "appleWatchSolidHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "appleWatchSolidMinuteHand")
    ),
    .shout: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "shoutHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "shoutMinuteHand")
    ),
    .lcd: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "lcdHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "lcdMinuteHand")
    ),
    .traditional: HandTextureSet(
        hourHandTexture: FileGrabber.shared.getSKTexture(named: "traditionalHourHand"),
        minuteHandTexture: FileGrabber.shared.getSKTexture(named: "traditionalMinuteHand")
    ),
]

let dialTextures: [DialDesign: SKTexture?] = [
    .ringThin: FileGrabber.shared.getSKTexture(named: "ringThinDial"),
    .ringIndices: FileGrabber.shared.getSKTexture(named: "ringIndicesDial"),
    .ringThick: FileGrabber.shared.getSKTexture(named: "ringThickDial"),
    .indices: FileGrabber.shared.getSKTexture(named: "indicesDial"),
    .cutOff: FileGrabber.shared.getSKTexture(named: "cutOffDial")
]
