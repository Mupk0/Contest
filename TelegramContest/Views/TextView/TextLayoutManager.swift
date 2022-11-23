//
//  TextLayoutManager.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 28.10.2022.
//

import UIKit

/// Text layout manager
final class TextLayoutManager: NSLayoutManager {
    
    /// Line background options
    var lineBackgroundOptions: LineBackgroundOptions = []
    
    /// Line height percentage for cornerRadius, default value is`0.13`
    var lineHeightPercentageForCornerRadius: CGFloat = 0.13

    /// Line background content inset, default value is`UIEdgeInsets(top: 2.0, left: 12.0, bottom: 2.0, right: 12.0) `
    var lineBackgroundInset: UIEdgeInsets = UIEdgeInsets(top: 2.0, left: 12.0, bottom: 2.0, right: 12.0)
                
    /// Line background color, default value is `.clear`
    var lineBackgroundColor: UIColor = .clear
    
    /// Scale of clear line width
    private let scaleOfClearLineWidth: CGFloat = 1.5

    /// Line boder width, default value is `0.0`
    var lineBorderWidth: CGFloat = 0.0
    
    /// Line boder color, default value is `.clear`
    var lineBorderColor: UIColor = .clear
    
    /// Whether draw glyphs with outside stroke or not, default value is `true`
    var isCanDrawGlyphsOutsideStroke: Bool = true
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        guard !lineBackgroundOptions.isEmpty,
              let textStorage = textStorage else { return }
        let characterRange = NSRange(location: 0, length: textStorage.mutableString.length)
        guard characterRange.length > 0 else { return }
        let lineRects = lineRects(forGlyphRange: characterRange)
        if lineBackgroundOptions.contains(.fill) {
            fillBackground(lineRects, at: origin, color: lineBackgroundColor)
        }
    }
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        // Fix error rect for lineBackgroundInset.bottom
        let containerOrigin = CGPoint(x: origin.x, y: origin.y - lineBackgroundInset.bottom)
        
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: containerOrigin)
        strokeOuter(forGlyphRange: glyphsToShow, at: containerOrigin)
    }
}

extension TextLayoutManager {
    /// Line background options
    struct LineBackgroundOptions: OptionSet {
        
        let rawValue: UInt
        
        init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Fill background with color
        static var fill: Self {
            Self.init(rawValue: 1)
        }
    }
}

private extension TextLayoutManager {

    func lineRects(forGlyphRange glyphsToShow: NSRange) -> [CGRect] {
        var rects: [CGRect] = []
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        let glyphRange = self.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        let inset = lineBackgroundInset
                
        enumerateLineFragments(forGlyphRange: glyphRange) { [unowned self] (rect, usedRect, textContainer, glyphRange, stop) in
            
            if propertyForGlyph(at: glyphRange.location) == .controlCharacter {
                return
            }
            
            if let lineText = textContainer.layoutManager?.textStorage?.attributedSubstring(from: glyphRange).string.replacingOccurrences(of: " ", with: ""),
               lineText.isEmpty || lineText == "\n",
               let paragraphStyle = textContainer.layoutManager?.textStorage?.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
               paragraphStyle.alignment == .center {
                    rects.append(CGRect(x: usedRect.origin.x - inset.left - usedRect.size.width * 0.5,
                                        y: usedRect.origin.y - inset.top - inset.bottom,
                                        width: usedRect.size.width + inset.left + inset.right,
                                        height: usedRect.size.height + inset.top + inset.bottom))
                    return
             }
             
            rects.append(CGRect(x: usedRect.origin.x - inset.left,
                                y: usedRect.origin.y - inset.top - inset.bottom, // Fix error rect for lineBackgroundInset.bottom
                                width: usedRect.size.width + inset.left + inset.right,
                                height: usedRect.size.height + inset.top + inset.bottom))
        }
        optimizeLineRects(&rects)
        return rects
    }
    
    func optimizeLineRects(_ lineRects: inout [CGRect]) {
        guard lineRects.count > 1 else { return }

        func processIndex(_ index: Int) {
            guard index > 0, index < lineRects.count else { return }
            let lastLineRect = lineRects[index - 1]
            let currentLineRect = lineRects[index]
            guard lastLineRect.maxY >= currentLineRect.minY else { return }
           
            let cornerRadius = currentLineRect.size.height * lineHeightPercentageForCornerRadius

            let currentLineRectTopLeft = currentLineRect.origin
            let currentLineRectTopRight = CGPoint(x: currentLineRect.maxX, y: currentLineRect.minY)

           let lastLineRectBottomLeft = CGPoint(x: lastLineRect.minX, y: lastLineRect.maxY)
           let lastLineRectBottomRight = CGPoint(x: lastLineRect.maxX, y: lastLineRect.maxY)

           let leftRadius = (currentLineRectTopLeft.x - lastLineRectBottomLeft.x) * 0.5
           let rightRadius = (currentLineRectTopRight.x - lastLineRectBottomRight.x) * 0.5

           if (leftRadius > 0.0 && abs(leftRadius) < cornerRadius) || (rightRadius < 0.0 && abs(rightRadius) < cornerRadius) {
               lineRects[index] = CGRect(x: lastLineRect.minX, y: currentLineRect.minY, width: lastLineRect.width, height: currentLineRect.height)
               processIndex(index + 1)
           } else if (leftRadius < 0.0 && abs(leftRadius) < cornerRadius) || (rightRadius > 0.0 && abs(rightRadius) < cornerRadius)  {
               lineRects[index - 1] = CGRect(x: currentLineRect.minX, y: lastLineRect.minY, width: currentLineRect.width, height: lastLineRect.height)
                processIndex(index - 1)
           }
        }

        for index in 1..<lineRects.count {
            processIndex(index)
        }
    }

    func fillBackground(_ lineRects: [CGRect], at origin: CGPoint, color: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)
        context.setBlendMode(.normal)
        UIColor.clear.setStroke()
        color.setFill()
        
        let backgroundPath = UIBezierPath()
        var lastLineRect: CGRect = .zero
        lineRects.enumerated().forEach {
            let cornerRadius = $0.element.height * lineHeightPercentageForCornerRadius
            backgroundPath.append(UIBezierPath(roundedRect: $0.element, cornerRadius: cornerRadius))

            if $0.offset > 0, lastLineRect.maxY >= $0.element.minY {

                // Current line rect top side points
                let currentLineRectTopLeft = $0.element.origin
                let currentLineRectTopRight = CGPoint(x: $0.element.maxX, y: $0.element.minY)

                // Last line rect bottom side points
                let lastLineRectBottomLeft = CGPoint(x: lastLineRect.minX, y: lastLineRect.maxY)
                let lastLineRectBottomRight = CGPoint(x: lastLineRect.maxX, y: lastLineRect.maxY)

                let leftRadius = (currentLineRectTopLeft.x - lastLineRectBottomLeft.x) * 0.5
                let rightRadius = (lastLineRectBottomRight.x - currentLineRectTopRight.x) * 0.5

                // Left corner
                if leftRadius >= cornerRadius { // Left corner inside
                    
                    // Fix current left corner
                    let fixedPath = UIBezierPath(arcCenter: CGPoint(x: currentLineRectTopLeft.x + cornerRadius, y: lastLineRectBottomLeft.y + cornerRadius ),
                                                 radius: cornerRadius,
                                                 startAngle: CGFloat.pi,
                                                 endAngle: CGFloat.pi * 1.5,
                                                 clockwise: true)
                    fixedPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x, y: lastLineRectBottomLeft.y))
                    fixedPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x, y: lastLineRectBottomLeft.y + cornerRadius))
                    backgroundPath.append(fixedPath.reversing())
                    
                    // Show left corner
                    let cornerPath = UIBezierPath(arcCenter: CGPoint(x: currentLineRectTopLeft.x - cornerRadius, y: lastLineRectBottomLeft.y + cornerRadius ),
                                                  radius: cornerRadius,
                                                  startAngle: CGFloat.pi * 1.5,
                                                  endAngle: 0.0,
                                                  clockwise: true)
                    cornerPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x, y: lastLineRectBottomLeft.y))
                    cornerPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x - cornerRadius, y: lastLineRectBottomLeft.y))
                    backgroundPath.append(cornerPath)

                } else if leftRadius <= -cornerRadius {  // Left corner outside
                                        
                    // Fix last left corner
                    let fixedPath = UIBezierPath(arcCenter: CGPoint(x: lastLineRectBottomLeft.x + cornerRadius, y: currentLineRectTopLeft.y - cornerRadius ),
                                                 radius: cornerRadius,
                                                 startAngle: CGFloat.pi * 0.5,
                                                 endAngle: CGFloat.pi,
                                                 clockwise: true)
                    fixedPath.addLine(to: CGPoint(x: lastLineRectBottomLeft.x, y: currentLineRectTopLeft.y))
                    fixedPath.addLine(to: CGPoint(x: lastLineRectBottomLeft.x + cornerRadius, y: currentLineRectTopLeft.y))
                    backgroundPath.append(fixedPath.reversing())

                    // Show left corner
                    let cornerPath = UIBezierPath(arcCenter: CGPoint(x: lastLineRectBottomLeft.x - cornerRadius, y: currentLineRectTopLeft.y - cornerRadius),
                                                  radius: cornerRadius,
                                                  startAngle: 0.0,
                                                  endAngle: CGFloat.pi * 0.5,
                                                  clockwise: true)
                    cornerPath.addLine(to: CGPoint(x: lastLineRectBottomLeft.x, y: currentLineRectTopLeft.y))
                    cornerPath.addLine(to: CGPoint(x: lastLineRectBottomLeft.x, y: currentLineRectTopLeft.y - cornerRadius))
                    backgroundPath.append(cornerPath)
 
                } else if leftRadius == .zero { // Left corner equtal
 
                    // Fix last left corner
                    let fixedLastPath = UIBezierPath(arcCenter: CGPoint(x: lastLineRectBottomLeft.x + cornerRadius, y: lastLineRectBottomLeft.y - cornerRadius),
                                                      radius: cornerRadius,
                                                      startAngle: CGFloat.pi * 0.5,
                                                      endAngle: CGFloat.pi,
                                                      clockwise: true)
                    fixedLastPath.addLine(to: CGPoint(x: lastLineRectBottomLeft.x, y: lastLineRectBottomLeft.y))
                    fixedLastPath.addLine(to: CGPoint(x: lastLineRectBottomLeft.x + cornerRadius, y: lastLineRectBottomLeft.y))
                    backgroundPath.append(fixedLastPath.reversing())

                    // Fix current left corner
                    let fixedCurrentPath = UIBezierPath(arcCenter: CGPoint(x: currentLineRectTopLeft.x + cornerRadius, y: currentLineRectTopLeft.y + cornerRadius),
                                                        radius: cornerRadius,
                                                        startAngle: CGFloat.pi,
                                                        endAngle: CGFloat.pi * 1.5,
                                                        clockwise: true)
                    fixedCurrentPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x, y: currentLineRectTopLeft.y))
                    fixedCurrentPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x, y: currentLineRectTopLeft.y + cornerRadius))
                    backgroundPath.append(fixedCurrentPath.reversing())
                }

                // Right corner
                if (rightRadius >= cornerRadius) { // Right corner inside
                     
                    // Fix current right corner
                    let fixedPath = UIBezierPath(arcCenter: CGPoint(x: currentLineRectTopRight.x - cornerRadius, y: lastLineRectBottomRight.y + cornerRadius ),
                                                 radius: cornerRadius,
                                                 startAngle: CGFloat.pi * 1.5,
                                                 endAngle: 0.0,
                                                 clockwise: true)
                    fixedPath.addLine(to: CGPoint(x: currentLineRectTopRight.x, y: lastLineRectBottomRight.y))
                    fixedPath.addLine(to: CGPoint(x: currentLineRectTopLeft.x - cornerRadius, y: lastLineRectBottomRight.y))
                    backgroundPath.append(fixedPath.reversing())
                    
                    // Show right corner
                    let cornerPath = UIBezierPath(arcCenter: CGPoint(x: currentLineRectTopRight.x + cornerRadius, y: lastLineRectBottomRight.y + cornerRadius ),
                                                  radius: cornerRadius,
                                                  startAngle: CGFloat.pi,
                                                  endAngle: CGFloat.pi * 1.5,
                                                  clockwise: true)
                    cornerPath.addLine(to: CGPoint(x: currentLineRectTopRight.x, y: lastLineRectBottomRight.y))
                    cornerPath.addLine(to: CGPoint(x: currentLineRectTopRight.x, y: lastLineRectBottomRight.y + cornerRadius))
                    backgroundPath.append(cornerPath)
                    
                } else if rightRadius <= -cornerRadius { // Right corner outside
                    
                    // Fix last right corner
                    let fixedPath = UIBezierPath(arcCenter: CGPoint(x: lastLineRectBottomRight.x - cornerRadius, y: currentLineRectTopRight.y - cornerRadius ),
                                                 radius: cornerRadius,
                                                 startAngle: 0.0,
                                                 endAngle: CGFloat.pi * 0.5,
                                                 clockwise: true)
                    fixedPath.addLine(to: CGPoint(x: lastLineRectBottomRight.x, y: lastLineRectBottomRight.y))
                    fixedPath.addLine(to: CGPoint(x: lastLineRectBottomRight.x, y: currentLineRectTopLeft.y - cornerRadius))
                    backgroundPath.append(fixedPath.reversing())
                    
                    // Show right corner
                    let cornerPath = UIBezierPath(arcCenter: CGPoint(x: lastLineRectBottomRight.x + cornerRadius, y: currentLineRectTopRight.y - cornerRadius),
                                                  radius: cornerRadius,
                                                  startAngle: CGFloat.pi * 0.5,
                                                  endAngle: CGFloat.pi,
                                                  clockwise: true)
                    
                    cornerPath.addLine(to: CGPoint(x: lastLineRectBottomRight.x, y: currentLineRectTopRight.y))
                    cornerPath.addLine(to: CGPoint(x: lastLineRectBottomRight.x + cornerRadius, y: currentLineRectTopRight.y))
                    backgroundPath.append(cornerPath)

                    
                } else if rightRadius == .zero { // Right corner equtal
                    
                    // Fix last right corner
                    let fixedLastPath = UIBezierPath(arcCenter: CGPoint(x: lastLineRectBottomRight.x - cornerRadius, y: lastLineRectBottomRight.y - cornerRadius),
                                                      radius: cornerRadius,
                                                      startAngle: 0.0,
                                                      endAngle: CGFloat.pi * 0.5,
                                                      clockwise: true)
                    fixedLastPath.addLine(to: CGPoint(x: lastLineRectBottomRight.x, y: lastLineRectBottomRight.y))
                    fixedLastPath.addLine(to: CGPoint(x: lastLineRectBottomRight.x, y: lastLineRectBottomRight.y - cornerRadius))
                    backgroundPath.append(fixedLastPath.reversing())

                    // Fix current right corner
                    let fixedCurrentPath = UIBezierPath(arcCenter: CGPoint(x: currentLineRectTopRight.x - cornerRadius, y: currentLineRectTopRight.y + cornerRadius),
                                                        radius: cornerRadius,
                                                        startAngle: CGFloat.pi * 1.5,
                                                        endAngle: 0.0,
                                                        clockwise: true)
                    fixedCurrentPath.addLine(to: CGPoint(x: currentLineRectTopRight.x, y: currentLineRectTopRight.y))
                    fixedCurrentPath.addLine(to: CGPoint(x: currentLineRectTopRight.x - cornerRadius, y: currentLineRectTopRight.y))
                    backgroundPath.append(fixedCurrentPath.reversing())
                }
            }
            lastLineRect = $0.element
        }
        backgroundPath.stroke()
        backgroundPath.fill()
        
        context.restoreGState()
    }
    
    func strokeOuter(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        guard isCanDrawGlyphsOutsideStroke,
              let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        context.translateBy(x: origin.x, y: origin.y)

        enumerateLineFragments(forGlyphRange: glyphsToShow) { (rect, usedRect, textContainer, glyphRange, stop) in
            guard let textStorage = textContainer.layoutManager?.textStorage,
                  let strokeWidth = textStorage.attribute(.strokeWidth, at: glyphRange.location, effectiveRange: nil),
                  let strokeWidthF = Float(String(describing: strokeWidth)),
                  strokeWidthF > 0.0 else {
                return
            }
            let attributedText = NSMutableAttributedString(attributedString: textStorage.attributedSubstring(from: glyphRange))
            attributedText.removeAttribute(.backgroundColor, range: NSRange(location: 0, length: glyphRange.length))
            attributedText.removeAttribute(.strokeWidth, range: NSRange(location: 0, length: glyphRange.length))
            attributedText.draw(at: usedRect.origin)
        }
         
        context.restoreGState()
    }
}
