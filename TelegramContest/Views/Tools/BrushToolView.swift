//
//  BrushToolView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 20.10.2022.
//

import UIKit
import PencilKit

final class BrushToolView: UIView, ToolProtocol {
    private lazy var toolImageView: UIImageView = {
        let imageView = UIImageView(frame: bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "brush")
        return imageView
    }()
    
    private lazy var toolTipImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "brushTip").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color
        return imageView
    }()
    
    private lazy var weightView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var weightViewHeightConstraint: NSLayoutConstraint = {
        let constraint = weightView.heightAnchor.constraint(equalToConstant: weight)
        return constraint
    }()
    
    private lazy var weightViewWidthConstraint: NSLayoutConstraint = {
        let constraint = weightView.widthAnchor.constraint(equalToConstant: width)
        return constraint
    }()
    
    var tool: PKTool
    
    var color: UIColor {
        didSet {
            tool = PKInkingTool(.pen, color: color, width: weight)
            toolTipImageView.tintColor = color
            weightView.backgroundColor = color
        }
    }
    
    var weight: CGFloat {
        didSet {
            tool = PKInkingTool(.marker, color: color, width: weight)
            weightViewHeightConstraint.constant = weight
        }
    }
    
    var width: CGFloat {
        didSet {
            weightViewWidthConstraint.constant = width
        }
    }
    
    var isSelected: Bool = false
    var isUpdatingWeight: Bool = false
    
    required init(frame: CGRect = .zero, color: UIColor = .white, weight: CGFloat = 10, width: CGFloat = .zero) {
        self.color = color
        self.weight = weight
        self.width = width
        self.tool = PKInkingTool(.marker, color: color, width: width)
        
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(toolImageView)
        addSubview(toolTipImageView)
        addSubview(weightView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            weightView.topAnchor.constraint(equalTo: centerYAnchor),
            weightView.centerXAnchor.constraint(equalTo: centerXAnchor),
            weightViewWidthConstraint,
            weightViewHeightConstraint,
        ])
    }
}
