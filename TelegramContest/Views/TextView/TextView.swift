//
//  TextView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 18.10.2022.
//

import UIKit

protocol TextViewDelegate: AnyObject {
    func didTapDeleteAction(_ textView: TextView)
    func didTapDuplicateAction(_ textView: TextView)
    func didBeginEditing(_ textView: TextView)
    func didEndEditing(_ textView: TextView)
    func didSelectTextView(_ textView: TextView)
    func didChangeTextViewViewModel(_ textView: TextView, from oldViewModel: TextView.ViewModel)
    func didChangeTextViewTransform(_ textView: TextView, oldTransform: CGAffineTransform, oldBoundsWidth: CGFloat)
}

final class TextView: UITextView {
    private enum TouchState {
        case leftTouch
        case rightTouch
        case middleTouch
        case none
    }
    
    // MARK: - Gestures
    
    private lazy var rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(callRotationGestureRecognize))
    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(callLongPressGestureRecognize))
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapGestureRecognize))
    private lazy var doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(callDoubleTapGestureRecognize))
    
    // MARK: - Views
    
    var dashBorder: CAShapeLayer?
    var leftCircleLayer: CAShapeLayer?
    var rightCircleLayer: CAShapeLayer?
    
    // MARK: - Properties
    
    weak var output: TextViewDelegate?
    
    var viewModel: ViewModel? {
        didSet {
            guard let oldValue = oldValue else { return }
            output?.didChangeTextViewViewModel(self, from: oldValue)
        }
    }
    
    var isSelected: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    private let touchProxyFactor: CGFloat = 10
    private var touchState: TouchState = .none
    
    private lazy var lastTransform = self.transform
    private lazy var updatedTransform = self.transform
    
    private lazy var lastBoundsWidth = self.bounds.width
    private lazy var updatedBoundsWidth = self.bounds.width
    
    // MARK: - Lifecycle
    
    required init(frame: CGRect = .zero, viewModel: ViewModel? = nil) {
        let textContainer = NSTextContainer.default()
        let storage = NSTextStorage()
        let textLayoutManager = NSLayoutManager.default()
        
        textLayoutManager.addTextContainer(textContainer)
        storage.addLayoutManager(textLayoutManager)
        
        super.init(frame: frame, textContainer: textContainer)
        
        self.viewModel = viewModel
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isSelected {
            insertDashBorder()
            insertCircles()
        } else {
            dashBorder?.removeFromSuperlayer()
            leftCircleLayer?.removeFromSuperlayer()
            rightCircleLayer?.removeFromSuperlayer()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in self.subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if subview.point(inside: subPoint, with: event) {
                if let result = subview.hitTest(subPoint, with: event) {
                    return result
                } else {
                    return subview
                }
            }
        }
        return self.point(inside: point, with: event) ? self : nil
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any!) -> Bool {
        switch action {
        case #selector(handleDeleteAction(_:)), #selector(handleEditAction), #selector(handleDuplicateAction(_:)):
            return true
        default:
            return false
        }
    }
    
    // MARK: - Touch Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isSelected else { return }
        let touchStart = touch.location(in: self)
        
        touchState = .none
        
        if touchStart.x > bounds.maxX - touchProxyFactor && touchStart.x < bounds.maxX + touchProxyFactor {
            touchState = .rightTouch
            return
        } else if touchStart.x > bounds.minX - touchProxyFactor &&  touchStart.x < bounds.minX + touchProxyFactor {
            touchState = .leftTouch
            return
        } else {
            touchState = .middleTouch
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isSelected else { return }
        
        let currentTouchPoint = touch.location(in: self)
        let previousTouchPoint = touch.previousLocation(in: self)
        
        let deltaX = currentTouchPoint.x - previousTouchPoint.x
        let halfDeltaX = deltaX / 2
        let deltaY = currentTouchPoint.y - previousTouchPoint.y
        
        lastTransform = transform
        lastBoundsWidth = bounds.width
        
        switch touchState {
        case .leftTouch:
            let newTransform = transform.translatedBy(x: halfDeltaX, y: .zero)
            let newBoundsWidth = bounds.size.width - deltaX
            
            updatedTransform = newTransform
            updatedBoundsWidth = newBoundsWidth
            
            transform = newTransform
            bounds.size.width = newBoundsWidth
            
            updateSize()
        case .rightTouch:
            let newTransform = transform.translatedBy(x: halfDeltaX, y: .zero)
            let newBoundsWidth = bounds.size.width + deltaX
            
            updatedTransform = newTransform
            updatedBoundsWidth = newBoundsWidth
            
            transform = newTransform
            bounds.size.width = newBoundsWidth
            
            updateSize()
        case .middleTouch:
            let newTransform = transform.translatedBy(x: deltaX, y: deltaY)
            
            updatedTransform = newTransform
            
            transform = newTransform
        case .none:
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchState != .none {
            output?.didChangeTextViewTransform(
                self,
                oldTransform: lastTransform,
                oldBoundsWidth: lastBoundsWidth
            )
            lastTransform = updatedTransform
            lastBoundsWidth = updatedBoundsWidth
        }
    }
    
    // MARK: - Updating View's methods
    
    func updateView() {
        guard let viewModel = viewModel else { return }
        
        textAlignment = viewModel.textAlignment.value
        text = viewModel.text
        font = viewModel.font
        textColor = viewModel.textColor
        
        if let textLayoutManager = layoutManager as? TextLayoutManager {
            switch viewModel.textStyle {
            case .default:
                textLayoutManager.lineBackgroundOptions = []
                textLayoutManager.lineBackgroundColor = .clear
                textLayoutManager.lineBorderColor = .clear
                textLayoutManager.lineBorderWidth = 0
                typingAttributes[.strokeWidth] = 0
            case .filled:
                textLayoutManager.lineBackgroundOptions = [.fill]
                textLayoutManager.lineBackgroundColor = .black
                textLayoutManager.lineBorderColor = .clear
                textLayoutManager.lineBorderWidth = 0
                typingAttributes[.strokeWidth] = 0
            case .semi:
                textLayoutManager.lineBackgroundOptions = [.fill]
                textLayoutManager.lineBackgroundColor = .white.withAlphaComponent(0.5)
                textLayoutManager.lineBorderColor = .clear
                textLayoutManager.lineBorderWidth = 0
                typingAttributes[.strokeWidth] = 0
            case .stroke:
                textLayoutManager.lineBackgroundOptions = []
                textLayoutManager.lineBackgroundColor = .clear
                textLayoutManager.lineBorderColor = .clear
                textLayoutManager.lineBorderWidth = 0
                typingAttributes[.strokeWidth] = 10 * contentScaleFactor
                typingAttributes[.strokeColor] = UIColor.black
            }
            
            let stringRange = NSRange(location: 0, length: textStorage.mutableString.length)
            if stringRange.length > 0 {
                textStorage.addAttributes(typingAttributes, range: stringRange)
            }
            setNeedsDisplay()
        }
        updateSize()
    }
    
    func updatesFontSize(with size: CGFloat) {
        setFontSize(with: size)
        updateSize()
    }
    
    func updateViewModelFont() {
        guard let font = font else { return }
        viewModel?.font = font
    }
    
    // MARK: - GestureRecognizer's methods
    
    @objc
    private func callRotationGestureRecognize(_ gestureRecognizer: UIRotationGestureRecognizer) {
        guard isSelected else { return }
        switch gestureRecognizer.state {
        case .began:
            lastTransform = transform
            lastBoundsWidth = bounds.width
        case .changed:
            let newTransform = transform.rotated(by: gestureRecognizer.rotation)
            
            updatedTransform = newTransform
            
            transform = newTransform
        case .ended:
            output?.didChangeTextViewTransform(
                self,
                oldTransform: lastTransform,
                oldBoundsWidth: lastBoundsWidth
            )
            lastTransform = updatedTransform
        default:
            break
        }
        
        gestureRecognizer.rotation = 0
    }
    
    @objc
    private func callLongPressGestureRecognize(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view, let superview = superview else { return }
        selectTextView()
        showMenu(gestureView: gestureView, superview: superview)
    }
    
    @objc
    private func callTapGestureRecognize(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view, let superview = superview else { return }
        selectTextView()
        showMenu(gestureView: gestureView, superview: superview)
    }
    
    @objc
    private func callDoubleTapGestureRecognize(_ gestureRecognizer: UITapGestureRecognizer) {
        handleEditAction()
    }
    
    // MARK: - UIMenuController Actions
    
    @objc
    private func handleDeleteAction(_ controller: UIMenuController) {
        output?.didTapDeleteAction(self)
    }
    
    @objc
    func handleEditAction() {
        isEditable = true
        becomeFirstResponder()
    }
    
    @objc
    private func handleDuplicateAction(_ controller: UIMenuController) {
        output?.didTapDuplicateAction(self)
    }
}

// MARK: - Private

private extension TextView {
    func configureViews() {
        delegate = self
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
        addGestureRecognizer(rotationGesture)
        addGestureRecognizer(longPressGesture)
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        clipsToBounds = false
        isOpaque = false
        
        textContainer.lineBreakMode = .byCharWrapping
        
        isEditable = false
        backgroundColor = .clear
        textContainerInset = .init(top: 8.0, left: 12.0, bottom: 4.0, right: 12.0)
        
        updateView()
    }
    
    func showMenu(gestureView: UIView, superview: UIView) {
        let menuController = UIMenuController.shared
        
        guard !menuController.isMenuVisible, gestureView.canBecomeFirstResponder else { return }
        
        menuController.menuItems = [
            UIMenuItem(title: "Delete", action: #selector(handleDeleteAction(_:))),
            UIMenuItem(title: "Edit", action: #selector(handleEditAction)),
            UIMenuItem(title: "Duplicate", action: #selector(handleDuplicateAction(_:)))
        ]
        
        menuController.update()
        
        gestureView.becomeFirstResponder()
        menuController.showMenu(from: superview, rect: frame)
    }
    
    func insertDashBorder() {
        dashBorder?.removeFromSuperlayer()
        guard let viewModel = viewModel else { return }
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = viewModel.dashWidth
        dashBorder.strokeColor = viewModel.dashColor.cgColor
        dashBorder.lineDashPattern = [viewModel.dashLength, viewModel.betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if viewModel.cornerRadius > .zero {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: viewModel.cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.cornerRadius = viewModel.cornerRadius
        
        layer.addSublayer(dashBorder)
        
        self.dashBorder = dashBorder
    }
    
    func insertCircles() {
        leftCircleLayer?.removeFromSuperlayer()
        rightCircleLayer?.removeFromSuperlayer()
        guard let viewModel = viewModel else { return }
        
        let halfSize: CGFloat = 5.5
        let desiredLineWidth: CGFloat = 2.0
        
        func getCirclePath(isLeft: Bool) -> UIBezierPath {
            return UIBezierPath(
                arcCenter: CGPoint(
                    x: isLeft ? bounds.minX : bounds.maxX,
                    y: bounds.centerY
                ),
                radius: halfSize - desiredLineWidth / 2,
                startAngle: .zero,
                endAngle: .pi * 2,
                clockwise: true
            )
        }
        
        let leftCircleLayer = CAShapeLayer()
        leftCircleLayer.path = getCirclePath(isLeft: true).cgPath
        
        leftCircleLayer.fillColor = viewModel.dashColor.cgColor
        leftCircleLayer.strokeColor = viewModel.dashColor.cgColor
        leftCircleLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(leftCircleLayer)
        self.leftCircleLayer = leftCircleLayer
        
        let rightCircleLayer = CAShapeLayer()
        rightCircleLayer.path = getCirclePath(isLeft: false).cgPath
        
        rightCircleLayer.fillColor = viewModel.dashColor.cgColor
        rightCircleLayer.strokeColor = viewModel.dashColor.cgColor
        rightCircleLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(rightCircleLayer)
        self.rightCircleLayer = rightCircleLayer
    }
    
    func selectTextView() {
        isSelected = true
        setNeedsLayout()
        output?.didSelectTextView(self)
    }
}

// MARK: - UITextViewDelegate

extension TextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel?.text = textView.text
        textView.updateSize()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let textView = textView as? TextView else { fatalError("incorrect type TextView") }
        isSelected = true
        isEditable = true
        output?.didBeginEditing(textView)
        insertDashBorder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let textView = textView as? TextView else { fatalError("incorrect type TextView") }
        isSelected = false
        isEditable = false
        output?.didEndEditing(textView)
        dashBorder?.removeFromSuperlayer()
        if textView.text.isEmpty { self.removeFromSuperview() }
    }
}

// MARK: - ViewModel

extension TextView {
    struct ViewModel: Equatable {
        let cornerRadius: CGFloat
        let dashWidth: CGFloat
        let dashColor: UIColor
        let dashLength: CGFloat
        let betweenDashesSpace: CGFloat
        var textAlignment: TextAlignment
        var text: String
        var font: UIFont?
        var textColor: UIColor
        var textStyle: TextStyles

        init(
            cornerRadius: CGFloat = 12,
            dashWidth: CGFloat = 2,
            dashColor: UIColor = .white,
            dashLength: CGFloat = 6,
            betweenDashesSpace: CGFloat = 3,
            textAlignment: TextAlignment = .center,
            text: String = "Text",
            font: UIFont? = UIFont(name: Fonts.arial.rawValue, size: 30),
            textColor: UIColor = .white,
            textStyle: TextStyles = .default
        ) {
            self.cornerRadius = cornerRadius
            self.dashWidth = dashWidth
            self.dashColor = dashColor
            self.dashLength = dashLength
            self.betweenDashesSpace = betweenDashesSpace
            self.textAlignment = textAlignment
            self.text = text
            self.font = font
            self.textColor = textColor
            self.textStyle = textStyle
        }
    }
    
    enum TextStyles: Equatable {
        case `default`
        case filled
        case semi
        case stroke
    }
    
    enum TextAlignment: Equatable {
        case center
        case left
        case right
        
        var value: NSTextAlignment {
            switch self {
            case .center:
                return .center
            case .left:
                return .left
            case .right:
                return .right
            }
        }
    }
}
