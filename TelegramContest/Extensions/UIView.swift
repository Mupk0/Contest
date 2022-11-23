//
//  UIView.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 10.10.2022.
//

import UIKit

enum GradientOrientation {
    case vertical
    case horizontal
}

extension UIView {
    /// Делает снимок с вьюхи по заданному размеру и координатам
    /// - Parameter rect: Область экрана необходимая для снимка
    /// - Returns: Снимок с экрана
    func makeScreenshot(with rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { (context) in
            self.layer.render(in: context.cgContext)
        }
    }
}

extension UIView {
    /// Возвращает вьюху в формате картинки
    var snapshot: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let capturedImage = renderer.image { context in
            layer.render(in: context.cgContext)
        }

        return capturedImage
    }
}

extension UIView {
    @discardableResult
    func addGradient(
        colors: [CGColor],
        points: (start: CGPoint, end: CGPoint)? = nil,
        locations: [NSNumber] = [0.0, 1.0],
        direction: GradientOrientation = .vertical
    ) -> CAGradientLayer {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.locations = locations
        if let points = points {
            gradientLayer.startPoint = points.start
            gradientLayer.endPoint = points.end
        } else {
            switch direction {
            case .horizontal:
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            case .vertical:
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
                gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
            }
        }
        gradientLayer.colors = colors
        gradientLayer.frame = CGRect(origin: .zero, size: frame.size)
        
        layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
}

extension UIView{
    
    func createGradientBlur() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
        UIColor.white.withAlphaComponent(0).cgColor,
        UIColor.white.withAlphaComponent(1).cgColor]
        let viewEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: viewEffect)
        effectView.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.size.height, width: self.bounds.width, height: self.bounds.size.height)
        gradientLayer.frame = effectView.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0 , y: 0.3)
        effectView.autoresizingMask = [.flexibleHeight]
        effectView.layer.mask = gradientLayer
        effectView.isUserInteractionEnabled = false //Use this to pass touches under this blur effect
        addSubview(effectView)
    }
}

extension UIView {
    func height(constant: CGFloat) {
        setConstraint(value: constant, attribute: .height)
    }
  
    func width(constant: CGFloat) {
        setConstraint(value: constant, attribute: .width)
    }
  
    private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }
  
    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
            multiplier: 1,
            constant: value
        )
        self.addConstraint(constraint)
    }
}
