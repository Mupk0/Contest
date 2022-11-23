//
//  ToolsStackView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 20.10.2022.
//

import UIKit

protocol ToolsStackViewDelegate: AnyObject {
    func didSelectTool(_ tool: ToolProtocol?)
    func didSelectUpdatingWeightTool(_ tool: ToolProtocol?)
}

// TODO: Добавить выбор стирания для ластика обьект/линию

final class ToolsStackView: UIStackView {
    
    // MARK: - Views
    
    lazy var penTool: PenToolView = {
        let view = PenToolView()
        view.addGestureRecognizer(penTapGesture)
        return view
    }()
    
    lazy var brushTool: BrushToolView = {
        let view = BrushToolView()
        view.addGestureRecognizer(brushTapGesture)
        return view
    }()
    
    lazy var pencilTool: PencilToolView = {
        let view = PencilToolView()
        view.addGestureRecognizer(pencilTapGesture)
        return view
    }()
    
    lazy var lassoTool: LassoToolView = {
        let view = LassoToolView()
        view.addGestureRecognizer(lassoTapGesture)
        return view
    }()
    
    lazy var eraserTool: EraserToolView = {
        let view = EraserToolView()
        view.addGestureRecognizer(eraserTapGesture)
        return view
    }()

    private lazy var gradientView: UIView = {
        let view = UIView(frame: frame)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Gestures
    
    private lazy var penTapGesture = UITapGestureRecognizer(
        target: self, action: #selector(callToolGestureRecognize)
    )
    private lazy var brushTapGesture = UITapGestureRecognizer(
        target: self, action: #selector(callToolGestureRecognize)
    )
    private lazy var pencilTapGesture = UITapGestureRecognizer(
        target: self, action: #selector(callToolGestureRecognize)
    )
    private lazy var lassoTapGesture = UITapGestureRecognizer(
        target: self, action: #selector(callToolGestureRecognize)
    )
    private lazy var eraserTapGesture = UITapGestureRecognizer(
        target: self, action: #selector(callToolGestureRecognize)
    )
    
    // MARK: - Properties
    
    var selectedTool: ToolProtocol? {
        didSet {
            delegate?.didSelectTool(selectedTool)
        }
    }
    var selectedUpdatingWeightTool: ToolProtocol? {
        didSet {
            delegate?.didSelectUpdatingWeightTool(selectedUpdatingWeightTool)
        }
    }
    
    weak var delegate: ToolsStackViewDelegate?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        makeConstraints()
        configureViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = gradientView.addGradient(
            colors: [UIColor.black.withAlphaComponent(1).cgColor, UIColor.black.withAlphaComponent(0).cgColor],
            points: (start: CGPoint(x: 0.0, y: 0.7), end: CGPoint(x: 0.0, y: 1.0))
        )
        layer.mask = gradientLayer
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for arrangedSubview in arrangedSubviews.reversed() {
            let subPoint = arrangedSubview.convert(point, from: self)
            if arrangedSubview.point(inside: subPoint, with: event) {
                if let result = arrangedSubview.hitTest(subPoint, with: event) {
                    return result
                } else {
                    return arrangedSubview
                }
            }
        }
        return self.point(inside: point, with: event) ? self : nil
    }

    // MARK: - Public methods
    
    func didCancelToolUpdatingWeight() {
        guard let tool = selectedUpdatingWeightTool else { return }
        
        tool.isUpdatingWeight = false
        selectedUpdatingWeightTool = nil
        animateTapTool(tool)
    }
    
    func setDefaultTool() {
        didTapTool(penTool)
        animateTapTool(penTool)
    }
    
    // MARK: - GestureRecognizer's methods
    
    @objc
    private func callToolGestureRecognize(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view as? ToolProtocol else { return }
        didTapTool(gestureView)
        animateTapTool(gestureView)
    }
}

// MARK: - Private

private extension ToolsStackView {
    func addSubviews() {
        addArrangedSubview(penTool)
        addArrangedSubview(brushTool)
        addArrangedSubview(pencilTool)
        addArrangedSubview(lassoTool)
        addArrangedSubview(eraserTool)
        
        addSubview(gradientView)
    }
    
    func makeConstraints() { }
    
    func configureViews() {
        axis = .horizontal
        alignment = .bottom
        spacing = 27
        distribution = .equalSpacing
    }
    
    func getHeightAndWidth(for view: ToolProtocol) -> (height: CGFloat, width: CGFloat) {
        var height: CGFloat {
            if view.isUpdatingWeight {
                return Constants.updatingWeightStateHeight
            } else if view.isSelected {
                return Constants.selectedHeight
            } else if selectedUpdatingWeightTool != nil {
                return .zero
            } else {
                return Constants.deselectedHeight
            }
        }
        var width: CGFloat {
            if view.isUpdatingWeight {
                return Constants.updatingWeightStateWidth
            } else if selectedUpdatingWeightTool != nil {
                return .zero
            } else {
                return Constants.defaultWidth
            }
        }
        return (height, width)
    }
    
    func getWeightWidth(for view: ToolProtocol) -> CGFloat {
        if view.isUpdatingWeight {
            return Constants.updatingWeightStateWidth - 12
        } else if view.isSelected {
            return Constants.defaultWidth - 4
        } else if selectedUpdatingWeightTool != nil {
            return .zero
        } else {
            return Constants.defaultWidth - 6
        }
    }
    
    func getHeightConstraint(for view: ToolProtocol) -> NSLayoutConstraint {
        return view.heightAnchor.constraint(
            equalToConstant: penTool.isSelected ? Constants.selectedHeight : Constants.deselectedHeight
        )
    }
    
    func getWidthConstraint(for view: ToolProtocol) -> NSLayoutConstraint {
        return view.widthAnchor.constraint(
            equalToConstant: penTool.isUpdatingWeight ? Constants.updatingWeightStateWidth : Constants.defaultWidth
        )
    }
    
    func didTapTool(_ tool: ToolProtocol) {
        let isNotUpdatingWeightTools = tool === lassoTool || tool === eraserTool
        for arrangedSubview in arrangedSubviews {
            if let view = arrangedSubview as? ToolProtocol {
                if view === tool {
                    if !view.isSelected && !view.isUpdatingWeight {
                        view.isSelected = true
                        selectedTool = view
                    } else if tool.isSelected && !view.isUpdatingWeight && !isNotUpdatingWeightTools {
                        view.isUpdatingWeight = true
                        selectedUpdatingWeightTool = view
                    }
                } else {
                    view.isSelected = false
                    view.isUpdatingWeight = false
                }
            }
        }
    }
    
    func animateTapTool(_ tool: ToolProtocol) {
        for arrangedSubview in arrangedSubviews {
            UIView.animate(
                withDuration: 0.25,
                delay: .zero,
                options: .curveEaseInOut,
                animations: {
                    self.updateToolsConstraints(arrangedSubview)
                    self.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    UIView.animate(
                        withDuration: 0.25,
                        delay: .zero,
                        options: .curveEaseInOut,
                        animations: {
                            guard let self = self else { return }
                            self.penTool.isHidden = self.penTool.frame.height == .zero
                            self.brushTool.isHidden = self.brushTool.frame.height == .zero
                            self.pencilTool.isHidden = self.pencilTool.frame.height == .zero
                            self.lassoTool.isHidden = self.lassoTool.frame.height == .zero
                            self.eraserTool.isHidden = self.eraserTool.frame.height == .zero
                            self.layoutIfNeeded()
                        })
                })
        }
    }
    
    func updateToolsConstraints(_ view: UIView) {
        guard let view = view as? ToolProtocol else { return }
        view.height(constant: getHeightAndWidth(for: view).height)
        view.width(constant: getHeightAndWidth(for: view).width)
        view.width = getWeightWidth(for: view)
    }
}

// MARK: - Constants

private extension ToolsStackView {
    enum Constants {
        static let selectedHeight: CGFloat = 88
        static let deselectedHeight: CGFloat = 72
        static let defaultWidth: CGFloat = 20
        static let updatingWeightStateHeight: CGFloat = 120
        static let updatingWeightStateWidth: CGFloat = 34
    }
}
