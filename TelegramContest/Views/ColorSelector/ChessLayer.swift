//
//  ChessLayer.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 25.10.2022.
//

import UIKit

final class ChessLayer: CALayer {
    var elementSize: CGFloat = 12 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        for y in stride(from: .zero, to: bounds.height, by: elementSize) {
            for x in stride(from: .zero, to: bounds.width, by: elementSize) {
                let doubleElementSize = elementSize * 2
                let isRowDivide = x.truncatingRemainder(dividingBy: doubleElementSize) == .zero
                let isColumnDivide = y.truncatingRemainder(dividingBy: doubleElementSize) == .zero
                let point = CGPoint(x: x, y: y)
                let colorRect = CGRect(x: point.x, y: point.y, width: elementSize, height: elementSize)
                let color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                let isBlackColor = isColumnDivide == isRowDivide
                
                if isBlackColor {
                    ctx.setFillColor(color.cgColor)
                    ctx.fill(colorRect)
                }
            }
        }
    }
}
