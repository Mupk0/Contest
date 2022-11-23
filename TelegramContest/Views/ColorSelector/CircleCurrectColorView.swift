//
//  CircleCurrectColorView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 19.10.2022.
//

import UIKit

final class CircleCurrectColorView: UIView {
    
    var color: UIColor = .white {
        didSet {
            setup()
        }
    }

    private var gradientLayer: CAGradientLayer?
    private var ovalShapeLayer: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setup()
    }
}

private extension CircleCurrectColorView {
    func setup() {
        clipsToBounds = true
        layer.cornerRadius = frame.height / 2
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic
        gradientLayer.frame = bounds
        gradientLayer.colors = Constants.gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath(
            ovalIn: CGRect(
                x: Constants.shapeLayerWidth,
                y: Constants.shapeLayerWidth,
                width: frame.width - Constants.shapeLayerWidth * 2,
                height: frame.height - Constants.shapeLayerWidth * 2
            )
        )
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = Constants.shapeLayerWidth
        gradientLayer.mask = shapeLayer
        shapeLayer.strokeEnd = 1

        let ovalPath = UIBezierPath(
            ovalIn: CGRect(
                x: Constants.shapeLayerWidth * 2.5,
                y: Constants.shapeLayerWidth * 2.5,
                width: frame.width - Constants.shapeLayerWidth * 5,
                height: frame.height - Constants.shapeLayerWidth * 5
            )
        )
        
        let ovalShapeLayer = CAShapeLayer()
        ovalShapeLayer.path = ovalPath.cgPath
        ovalShapeLayer.fillColor = color.cgColor
        ovalShapeLayer.lineWidth = .zero
        ovalShapeLayer.strokeColor = UIColor.clear.cgColor
        
        self.gradientLayer?.removeFromSuperlayer()
        self.ovalShapeLayer?.removeFromSuperlayer()
        
        layer.addSublayer(gradientLayer)
        layer.addSublayer(ovalShapeLayer)
        
        self.gradientLayer = gradientLayer
        self.ovalShapeLayer = ovalShapeLayer
    }
}

// MARK: - Constants

private extension CircleCurrectColorView {
    enum Constants {
        static let shapeLayerWidth: CGFloat = 3.5
        static let gradientColors: [CGColor] = [
            UIColor(red: 0.42, green: 0.36, blue: 0.91, alpha: 1.00).cgColor,
            UIColor(red: 0.31, green: 0.78, blue: 0.88, alpha: 1.00).cgColor,
            UIColor(red: 0.30, green: 0.91, blue: 0.53, alpha: 1.00).cgColor,
            UIColor(red: 0.53, green: 0.90, blue: 0.27, alpha: 1.00).cgColor,
            UIColor(red: 0.89, green: 0.89, blue: 0.27, alpha: 1.00).cgColor,
            UIColor(red: 0.91, green: 0.58, blue: 0.27, alpha: 1.00).cgColor,
            UIColor(red: 0.90, green: 0.27, blue: 0.27, alpha: 1.00).cgColor,
            UIColor(red: 0.75, green: 0.29, blue: 0.76, alpha: 1.00).cgColor
        ]
    }
}
