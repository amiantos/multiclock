//
//  Textures.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/21/21.
//

import SpriteKit


let hourHandTexture = SKTexture(imageNamed: "Hourhand")

let minuteHandTexture = SKTexture(imageNamed: "Minutehand")

let clockFaceTexture = SKTexture(imageNamed: "Clockface")

extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self * CGFloat.pi / 180
    }
}
