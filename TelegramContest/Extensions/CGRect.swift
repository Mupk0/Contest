//
//  CGRect.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 30.10.2022.
//

import CoreGraphics

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x: centerX, y: centerY)
        }
        set {
            centerX = newValue.x
            centerY = newValue.y
        }
    }
    
    var centerX: CGFloat {
        get {
            return midX
        }
        set {
            origin.x = newValue - width * 0.5
        }
    }
    
    var centerY: CGFloat {
        get {
            return midY
        }
        set {
            origin.y = newValue - height * 0.5
        }
    }
}
