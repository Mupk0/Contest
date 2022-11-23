//
//  ColorSpectrumPickerView.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 10.10.2022.
//

import UIKit

protocol ColorPickerViewDelegate: AnyObject {
    func colorPickerTouched(sender: ColorSpectrumPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State)
}

final class ColorSpectrumPickerView: UIView {
    enum Axis {
        case vertical
        case horizontal
    }
    
    private lazy var touchGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didSelectColor(gestureRecognizer:))
        )
        gesture.minimumPressDuration = 0
        gesture.allowableMovement = .greatestFiniteMagnitude
        return gesture
    }()
    
    private lazy var selectedView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: selectionViewSize))
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 3
        if isSelectionViewRounded { view.layer.cornerRadius = selectionViewSize.height / 2 }
        view.isHidden = true
        return view
    }()
    
    private let saturationExponentTop: Float = 0.0
    private let saturationExponentBottom: Float = 1.0
    
    private let elementSize: CGFloat
    private let isNeedGrayBar: Bool
    private let axis: Axis
    private let isShowInMirror: Bool
    private let selectionViewSize: CGSize
    private let isSelectionViewRounded: Bool
    private let isCenteredSelectionView: Bool
    
    weak var delegate: ColorPickerViewDelegate?
    
    required init(
        frame: CGRect = .zero,
        elementSize: CGFloat = 30.0,
        isNeedGrayBar: Bool = true,
        axis: Axis = .vertical,
        isShowInMirror: Bool = false,
        selectionViewSize: CGSize = CGSize(width: 30.0, height: 30.0),
        isSelectionViewRounded: Bool = false,
        isCenteredSelectionView: Bool = false
    ) {
        self.elementSize = elementSize
        self.isNeedGrayBar = isNeedGrayBar
        self.axis = axis
        self.isShowInMirror = isShowInMirror
        self.selectionViewSize = selectionViewSize
        self.isSelectionViewRounded = isSelectionViewRounded
        self.isCenteredSelectionView = isCenteredSelectionView
        
        super.init(frame: frame)
        
        clipsToBounds = true
        addGestureRecognizer(touchGesture)
        addSubview(selectedView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        for y in stride(from: .zero, to: rect.height, by: elementSize) {
            for x in stride(from: .zero, to: rect.width, by: elementSize) {
                let point = CGPoint(x: x, y: y)
                let color = getColorAtPoint(point, in: rect)
                let colorRect = getRoundedRectForPoint(point)
                context.setFillColor(color.cgColor)
                context.fill(colorRect)
            }
        }
    }
    
    @objc
    private func didSelectColor(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            let point = gestureRecognizer.location(in: self)
            if view.bounds.contains(point) {
                let color = getColorAtPoint(point, in: view.bounds)
                selectPoint(point, in: view.bounds, with: color)
                delegate?.colorPickerTouched(sender: self, color: color, point: point, state: gestureRecognizer.state)
            }
        }
    }
    
    func getPointForColor(_ color: UIColor, in rect: CGRect) -> CGPoint {
        lazy var mirrorRect = CGRect(origin: rect.origin, size: CGSize(width: rect.height, height: rect.width))
        let rect = axis == .vertical ? rect : mirrorRect
        let halfHeight = rect.height / 2.0
        
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        
        var xPos = hue * rect.width
        var yPos: CGFloat = 0
        
        if brightness >= 0.99 {
            let percentageY = powf(Float(saturation), 1.0 / saturationExponentBottom)
            yPos = isShowInMirror
            ? (saturation * halfHeight * 2.0 * CGFloat(percentageY))
            : (rect.height - (saturation * halfHeight))
        } else {
            yPos = isShowInMirror
            ? halfHeight + halfHeight * (1.0 - brightness)
            : halfHeight * brightness
        }
        
        if hue == .zero && saturation == .zero && isNeedGrayBar {
            color.getWhite(&hue, alpha: nil)
            yPos = .zero
            xPos = (1.0 - hue) * rect.width
        }
        
        let mirrorPoint = CGPoint(x: yPos, y: xPos)
        
        return axis == .vertical ? CGPoint(x: xPos, y: yPos) : mirrorPoint
    }
    
    func selectPoint(_ point: CGPoint, in bounds: CGRect, with color: UIColor) {
        let roundedPoint = getRoundedPoint(point)
        let roundedRect = isCenteredSelectionView
        ? CGRect(center: roundedPoint, size: selectionViewSize)
        : CGRect(origin: roundedPoint, size: selectionViewSize)
        
        selectedView.backgroundColor = color
        selectedView.frame = roundedRect
        selectedView.isHidden = false
    }
}

private extension ColorSpectrumPickerView {
    func getColorAtPoint(_ point: CGPoint, in rect: CGRect) -> UIColor {
        lazy var mirrorPoint = CGPoint(x: point.y, y: point.x)
        lazy var mirrorRect = CGRect(origin: rect.origin, size: CGSize(width: rect.height, height: rect.width))
        let point = axis == .vertical ? point : mirrorPoint
        let rect = axis == .vertical ? rect : mirrorRect
        
        let halfHeight = rect.height / 2.0
        let isPointOnTop = point.y < halfHeight
        let onePercentOfHalfHeight = halfHeight / 100.0
        let pointPercentOfHeight = point.y / onePercentOfHalfHeight
        let brightnessValue = pointPercentOfHeight / 100.0
        
        let color: UIColor
        let hue = point.x / rect.width
        if isNeedGrayBar && getRoundedPoint(point).y == .zero {
            color = UIColor(white: 1.0 - hue, alpha: 1.0)
        } else {
            var saturation: CGFloat
            let brightness: CGFloat
            
            if isShowInMirror {
                saturation = isPointOnTop ? (2 * point.y) / rect.height : 2.0 * (rect.height - point.y) / rect.height
                saturation = CGFloat(powf(Float(saturation), isPointOnTop ? saturationExponentBottom : saturationExponentTop))
                brightness = isPointOnTop ? 1.0 : 2.0 * (rect.height - point.y) / rect.height
            } else {
                saturation = isPointOnTop ? 2.0 * (rect.height - point.y) / rect.height : (rect.height - point.y) / halfHeight
                saturation = CGFloat(powf(Float(saturation), isPointOnTop ? saturationExponentTop : saturationExponentBottom))
                brightness = isPointOnTop ? brightnessValue : 1.0
            }
            
            color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        }
        
        return color
    }
    
    func getRoundedRectForPoint(_ point: CGPoint) -> CGRect {
        return CGRect(x: point.x, y: point.y, width: elementSize, height: elementSize)
    }
    
    func getRoundedPoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: elementSize * CGFloat(Int(point.x / elementSize)), y: elementSize * CGFloat(Int(point.y / elementSize)))
    }
}
