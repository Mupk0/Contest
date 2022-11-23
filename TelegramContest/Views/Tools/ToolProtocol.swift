//
//  ToolProtocol.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 20.10.2022.
//

import UIKit
import PencilKit

protocol ToolProtocol: UIView {
    var tool: PKTool { get set }
    var color: UIColor { get set }
    var weight: CGFloat { get set }
    var width: CGFloat { get set }
    var isSelected: Bool { get set }
    var isUpdatingWeight: Bool { get set }
}
