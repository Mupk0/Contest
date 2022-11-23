//
//  TriangleView.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 10.10.2022.
//

import UIKit

final class TriangleView: UIView {
    
    private let color: UIColor
    
    init(frame: CGRect = .zero, color: UIColor = .white) {
        self.color = color
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   override func draw(_ rect: CGRect) {
       let triangle = CAShapeLayer()
       triangle.fillColor = color.cgColor
       triangle.lineCap = .round
       triangle.lineJoin = .round
       triangle.path = getRoundedTrianglePath(for: rect)
       triangle.position = .zero
       layer.addSublayer(triangle)
   }
}

private extension TriangleView {
    func getRoundedTrianglePath(for rect: CGRect) -> CGPath {
        let leftRadius = rect.height / 20
        let rightRadius = rect.height / 2
        let horizontalInset = rect.width / 50
        
        let point0 = CGPoint(x: horizontalInset, y: rect.midY)
        let point1 = CGPoint(x: horizontalInset, y: rect.midY - leftRadius)
        let point2 = CGPoint(x: rect.maxX - horizontalInset, y: .zero)
        let point3 = CGPoint(x: rect.maxX - horizontalInset, y: rect.maxY)
        let point4 = CGPoint(x: horizontalInset, y: rect.midY + leftRadius)
        let point5 = CGPoint(x: horizontalInset, y: rect.midY)
 
        let path = CGMutablePath()

        path.move(to: point0)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: leftRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: rightRadius)
        path.addArc(tangent1End: point3, tangent2End: point4, radius: rightRadius)
        path.addArc(tangent1End: point4, tangent2End: point5, radius: leftRadius)
        path.addArc(tangent1End: point5, tangent2End: point1, radius: .zero)
        
        path.closeSubpath()
        return path
   }
}
