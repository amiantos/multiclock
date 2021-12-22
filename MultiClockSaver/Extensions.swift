//
//  Extensions.swift
//  MultiClockSaver
//
//  Created by Brad Root on 12/22/21.
//

import Foundation


extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self * CGFloat.pi / 180
    }
    
    func radiansToDegrees() -> CGFloat {
        return abs(((self/CGFloat.pi) * 180).truncatingRemainder(dividingBy: 360))
    }
}

