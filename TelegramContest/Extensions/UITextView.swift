//
//  UITextView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 18.10.2022.
//

import UIKit

extension UITextView {
    func setFontSize(with size: CGFloat) {
        guard let oldFont = self.font else { return }
        self.font = oldFont.forSize(size)
    }

    func updateFontSize(with scale: CGFloat) {
        guard let oldFont = self.font else { return }
        let newSize = scale >= 1 ? oldFont.pointSize + scale : oldFont.pointSize - (scale + 1)
        self.font = oldFont.forSize(newSize)
    }

    func updateSize() {
        let contentSize = self.sizeThatFits(self.bounds.size)
        self.bounds = CGRect(origin: self.bounds.origin, size: CGSize(width: self.bounds.width, height: contentSize.height))
    }
}
