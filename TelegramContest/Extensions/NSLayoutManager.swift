//
//  NSLayoutManager.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 28.10.2022.
//

import UIKit

extension NSLayoutManager {
    static func `default`() -> NSLayoutManager {
        let textLayoutManager: TextLayoutManager = {
            let layoutManager = TextLayoutManager()
            layoutManager.allowsNonContiguousLayout = false
            layoutManager.usesFontLeading = false
            if #available(iOS 12.0, *) {
                layoutManager.limitsLayoutForSuspiciousContents = false
            }
            return layoutManager
        }()
        return textLayoutManager
    }
}
