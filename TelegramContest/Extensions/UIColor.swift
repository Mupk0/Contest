//
//  UIColor.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 23.10.2022.
//

import UIKit

extension UIColor {
    
    convenience init(fromHex:String) {
        var r = 0, g = 0, b = 0, a = 255
        let ch = fromHex.map { $0 }
        switch(ch.count) {
        case 6:
            r = 16 * (ch[0].hexDigitValue ?? 0) + (ch[1].hexDigitValue ?? 0)
            g = 16 * (ch[2].hexDigitValue ?? 0) + (ch[3].hexDigitValue ?? 0)
            b = 16 * (ch[4].hexDigitValue ?? 0) + (ch[5].hexDigitValue ?? 0)
            break
        case 4:
            a = 16 * (ch[3].hexDigitValue ?? 0) + (ch[3].hexDigitValue ?? 0)
            fallthrough
        case 3:  // Three digit #0D3 is the same as six digit #00DD33
            r = 16 * (ch[0].hexDigitValue ?? 0) + (ch[0].hexDigitValue ?? 0)
            g = 16 * (ch[1].hexDigitValue ?? 0) + (ch[1].hexDigitValue ?? 0)
            b = 16 * (ch[2].hexDigitValue ?? 0) + (ch[2].hexDigitValue ?? 0)
            break
        default:
            a = 0
            break
        }
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
        
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"%06x", rgb).uppercased()
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}
