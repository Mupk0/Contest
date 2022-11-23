//
//  RectangleCurrentColorView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 26.10.2022.
//

import UIKit

final class RectangleCurrentColorView: UIView {
    var currentColor: UIColor = .clear {
        didSet {
            backgroundView.backgroundColor = currentColor
        }
    }
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 10
        addSubview(backgroundView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        context.closePath()
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
    }
}
