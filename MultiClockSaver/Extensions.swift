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

extension Date {
    
    func get(_ type: Calendar.Component)-> String {
        let calendar = Calendar.current
        let t = calendar.component(type, from: self)
        return (t < 10 ? "0\(t)" : t.description)
    }
}

