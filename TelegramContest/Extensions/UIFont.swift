//
//  UIFont.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 18.10.2022.
//

import UIKit

extension UIFont {
    func forSize(_ pointSize: CGFloat) -> UIFont {
        if !fontName.contains(".SF"), let font = UIFont(name: fontName, size: pointSize) {
            return font
        }

        return UIFont.systemFont(ofSize: pointSize)
    }
}
