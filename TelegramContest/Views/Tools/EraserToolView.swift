//
//  EraserToolView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 20.10.2022.
//

import UIKit
import PencilKit

final class EraserToolView: UIView, ToolProtocol {
    private lazy var toolImageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "eraser")
        return imageView
    }()

    var tool: PKTool
    
    var color: UIColor
    var weight: CGFloat = .zero
    var width: CGFloat = .zero
    
    var isSelected: Bool = false
    var isUpdatingWeight: Bool = false
    
    required init(frame: CGRect = .zero, color: UIColor = .white) {
        self.color = color
        self.tool = PKEraserTool(.bitmap)
        
        super.init(frame: frame)

        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(toolImageView)
    }
}
