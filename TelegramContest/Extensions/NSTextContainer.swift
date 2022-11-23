//
//  NSTextContainer.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 28.10.2022.
//

import UIKit

extension NSTextContainer {
    static func `default`() -> NSTextContainer {
        let container: NSTextContainer = {
            let container = NSTextContainer(size: .zero)
            container.widthTracksTextView = true
            container.heightTracksTextView = true
            container.lineFragmentPadding = .zero
            return container
        }()
        return container
    }
}
