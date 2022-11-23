//
//  DrawingViewController.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 09.10.2022.
//

import UIKit
import PencilKit

final class DrawingViewController: UIViewController {
    // MARK: - EditTypes
    
    private enum EditTypes: Int, CaseIterable {
        case drawing
        case textEditor
        
        var title: String {
            switch self {
            case .drawing:
                return "Draw"
            case .textEditor:
                return "Text"
            }
        }
    }
    
    private lazy var editTypeSegmentedControl: SegmentedControl = {
        let segmentControl = SegmentedControl()
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        
        segmentControl.items = EditTypes.allCases.map { $0.title }
        segmentControl.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        segmentControl.backGroundColor = .white.withAlphaComponent(0.1)
        segmentControl.padding = 2
        segmentControl.borderWidth = .zero
        segmentControl.thumbBorderWidth = 0.5
        segmentControl.thumbBorderColor = .black.withAlphaComponent(0.04)
        segmentControl.thumbColor = .white.withAlphaComponent(0.3)
        segmentControl.unselectedLabelColor = .white
        segmentControl.selectedLabelColor = .white
        segmentControl.selectedIndex = .zero
        segmentControl.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        
        return segmentControl
    }()
    
    private lazy var fontSizeSliderView: TriangleSliderView = {
        let sliderView = TriangleSliderView()
        sliderView.minimumValue = 10
        sliderView.maximumValue = 100
        sliderView.isHidden = true
        sliderView.addTarget(self, action: #selector(didFontSliderValueChanged(slider:event:)), for: .valueChanged)
        sliderView.value = 20
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        sliderView.transform = CGAffineTransform(rotationAngle: -CGFloat(CGFloat.pi / 2))
        return sliderView
    }()
    
    // MARK: - Buttons
    
    private lazy var undoButton: UIBarButtonItem = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "undo"), for: .normal)
        button.addTarget(self, action: #selector(didTapUndoButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        barButton.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButton.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        barButton.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        barButton.isEnabled = false
        return barButton
    }()
    
    private lazy var clearButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Clear All",
            style: .plain,
            target: self,
            action: #selector(didTapClearButton)
        )
        button.tintColor = .white
        button.isEnabled = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "download"), for: .normal)
        button.addTarget(self, action: #selector(didTapSaveToGalleryAndExit), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Tools
    
    private lazy var colorPickerView: CircleCurrectColorView = {
        let view = CircleCurrectColorView()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapColorPicker))
        let longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapColorPicker))
        view.addGestureRecognizer(recognizer)
        view.addGestureRecognizer(longRecognizer)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var spectrumColorsView: ColorSpectrumPickerView = {
        let view = ColorSpectrumPickerView(
            frame: .zero,
            elementSize: 1,
            isNeedGrayBar: false,
            axis: .horizontal,
            isShowInMirror: true,
            isSelectionViewRounded: true
        )
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.delegate = self
        return view
    }()
    
    // MARK: - Tools Stacks
    
    private lazy var toolsStackView: ToolsStackView = {
        let stackView = ToolsStackView()
        stackView.delegate = self
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var toolsWeightView: ToolsWeightView = {
        let view = ToolsWeightView()
        view.isHidden = true
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Canvas
    
    private lazy var photoView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var canvasView: PKCanvasView = {
        let view = PKCanvasView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCanvasView))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(callPinchGestureRecognizer))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(pinchGesture)
        
        view.overrideUserInterfaceStyle = .light
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        if #available(iOS 14.0, *) {
            view.drawingPolicy = .anyInput
        } else {
            view.allowsFingerDrawing = true
        }
        view.becomeFirstResponder()
        return view
    }()
    
    // MARK: - Text
    
    private lazy var textParametersView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textStyleView: UIImageView = {
        let imageView = UIImageView()
        let textStyleViewGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextStyleView))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "defaultStyle")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.sizeToFit()
        imageView.addGestureRecognizer(textStyleViewGesture)
        return imageView
    }()
    
    private lazy var textAlignmentView: UIImageView = {
        let imageView = UIImageView()
        let textAlignmentViewGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextAlignmentView))
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "textCenter")
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(textAlignmentViewGesture)
        imageView.sizeToFit()
        return imageView
    }()
    
    private lazy var fontsCollectionViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var fontsCollectionView: FontsCollectionView = {
        let collectionView = FontsCollectionView()
        collectionView.frame = fontsCollectionViewContainer.frame
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return collectionView
    }()
    
    private lazy var bottomBlurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    private lazy var topBlurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    private lazy var zoomOutButtonView: UIView = {
        let view = ZoomOutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private lazy var fontCollectionViewGradientLayer = CAGradientLayer()
    private lazy var topViewGradientLayer = CAGradientLayer()
    private lazy var bottomViewGradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    private var selectedTextView: TextView? {
        willSet {
            selectedTextView?.isSelected = false
            selectedTextView?.dashBorder?.removeFromSuperlayer()
            newValue?.isSelected = true
        }
        didSet {
            textParametersView.isHidden = selectedTextView == nil
            colorPickerView.isHidden = isColorPickerHidden
            toolsStackView.isHidden = selectedTextView != nil || editTypeSegmentedControl.selectedIndex == EditTypes.textEditor.rawValue
            
            if let selectedTool = toolsStackView.selectedTool,
               editTypeSegmentedControl.selectedIndex == EditTypes.drawing.rawValue,
               selectedTextView == nil {
                colorPickerView.color = selectedTool.color
            }
            
            fontsCollectionView.selectedTextView = selectedTextView
            
            updatingColorPickerFromTextColor()
            updatingViewModelTextStyle()
            updatingViewModelTextAlignment()
            fontsCollectionView.reloadData()
        }
    }
    
    private var isColorPickerHidden: Bool {
        switch editTypeSegmentedControl.selectedIndex {
        case EditTypes.drawing.rawValue:
            return false
        case EditTypes.textEditor.rawValue:
            return selectedTextView == nil
        default:
            return true
        }
    }
    
    // MARK: - Lifecycle
    
    init(image: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        photoView.image = image
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        makeConstraint()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        fontCollectionViewGradientLayer.removeFromSuperlayer()
        fontCollectionViewGradientLayer = fontsCollectionViewContainer.addGradient(
            colors: [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(1).cgColor,
                UIColor.black.withAlphaComponent(1).cgColor,
                UIColor.clear.cgColor
            ],
            locations: [0.0, 0.2, 0.7, 1.0],
            direction: .horizontal
        )
        fontsCollectionViewContainer.layer.mask = fontCollectionViewGradientLayer
        
        topViewGradientLayer.removeFromSuperlayer()
        topViewGradientLayer = topBlurEffectView.addGradient(
            colors: [UIColor.black.withAlphaComponent(1).cgColor, UIColor.black.withAlphaComponent(0).cgColor],
            points: (start: CGPoint(x: 0.0, y: 0.65), end: CGPoint(x: 0.0, y: 1.0))
        )
        topBlurEffectView.layer.mask = topViewGradientLayer

        bottomViewGradientLayer.removeFromSuperlayer()
        bottomViewGradientLayer = bottomBlurEffectView.addGradient(
            colors: [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor],
            points: (start: CGPoint(x: 0.0, y: 0.0), end: CGPoint(x: 0.0, y: 0.5))
        )
        bottomBlurEffectView.layer.mask = bottomViewGradientLayer
    }
    
    // MARK: - Slider & SegmentedControl changes
    
    @objc
    private func segmentValueChanged() {
        switch editTypeSegmentedControl.selectedIndex {
        case EditTypes.drawing.rawValue:
            toolsStackView.isHidden = false
            textParametersView.isHidden = true
            colorPickerView.isHidden = false
            canvasView.drawingGestureRecognizer.isEnabled = true
            
            if let selectedTool = toolsStackView.selectedTool {
                colorPickerView.color = selectedTool.color
            }
            didTapCanvasView()
        case EditTypes.textEditor.rawValue:
            toolsStackView.isHidden = true
            textParametersView.isHidden = false
            canvasView.drawingGestureRecognizer.isEnabled = false
            
            colorPickerView.color = .white
            
            let textView = TextView(
                frame: CGRect(origin: CGPoint(x: canvasView.center.x, y: canvasView.center.y - 100), size: .zero),
                viewModel: .init()
            )
            textView.output = self
            textView.sizeToFit()
            
            textView.handleEditAction()
            canvasView.addSubview(textView)
            
            canvasView.undoManager?.registerUndo(withTarget: self, handler: { _ in
                textView.removeFromSuperview()
            })
            updateUndoButton()
        default:
            return
        }
    }
    
    @objc
    private func didFontSliderValueChanged(slider: UISlider, event: UIEvent) {
        guard let selectedTextView = selectedTextView, let touchEvent = event.allTouches?.first else { return }
        
        switch touchEvent.phase {
        case .moved:
            let newValue: CGFloat = CGFloat(slider.value)
            selectedTextView.updatesFontSize(with: newValue)
        case .ended:
            selectedTextView.updateViewModelFont()
        default:
            break
        }
    }
    
    // MARK: - Button Actions
    
    @objc
    private func didTapCancelButton() {
        if canvasView.drawing.bounds.isEmpty {
            navigationController?.popViewController(animated: true)
        } else {
            let alertController = UIAlertController(
                title: "Остались несохраненные изменения",
                message: "",
                preferredStyle: .alert
            )
            let resumeAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
                self?.saveDraft()
                alertController.dismiss(animated: true) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                alertController.dismiss(animated: true) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
                alertController.dismiss(animated: true)
            }
            alertController.addAction(resumeAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
        }
    }
    
    @objc
    private func didTapShowColors() {
        let colorPicker = ColorPickerViewController()
        let navigationController = UINavigationController(rootViewController: colorPicker)
        self.navigationController?.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(navigationController, animated: true)
    }
    
    @objc
    private func didTapColorPicker() {
        let colorController = ColorPickerViewController()
        if let selectedTool = toolsStackView.selectedTool {
            colorController.currentColor = selectedTool.color
        }
        colorController.delegate = self
        let navigationController = UINavigationController(rootViewController: colorController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc
    private func didLongTapColorPicker() {
        spectrumColorsView.isHidden = false
        canvasView.drawingGestureRecognizer.isEnabled = false
    }
    
    @objc
    private func didTapTextStyleView() {
        guard let textView = selectedTextView, var viewModel = textView.viewModel else { return }
        switch viewModel.textStyle {
        case .default:
            viewModel.textStyle = .semi
        case .semi:
            viewModel.textStyle = .filled
        case .filled:
            viewModel.textStyle = .stroke
        case .stroke:
            viewModel.textStyle = .default
        }
        textView.viewModel = viewModel
        textView.updateView()
        updatingViewModelTextStyle()
    }
    
    @objc
    private func didTapTextAlignmentView() {
        guard let textView = selectedTextView, var viewModel = textView.viewModel else { return }
        switch viewModel.textAlignment {
        case .center:
            viewModel.textAlignment = .left
        case .left:
            viewModel.textAlignment = .right
        case .right:
            viewModel.textAlignment = .center
        }
        textView.viewModel = viewModel
        textView.updateView()
        updatingViewModelTextAlignment()
    }
    
    @objc
    private func didTapSaveToGalleryAndExit() {
        saveDraft()
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapClearButton() {
        canvasView.drawing = PKDrawing()
        canvasView.undoManager?.removeAllActions()
        for view in canvasView.subviews where view.isKind(of: TextView.self) {
            view.removeFromSuperview()
        }
        updateUndoButton()
    }
    
    @objc
    private func didTapUndoButton() {
        canvasView.undoManager?.undo()
        updateUndoButton()
    }
    
    @objc
    private func didTapCanvasView() {
        dismissKeyboard()
        selectedTextView = nil
        spectrumColorsView.isHidden = true
        if editTypeSegmentedControl.selectedIndex == EditTypes.drawing.rawValue {
            canvasView.drawingGestureRecognizer.isEnabled = true
        }
    }
    
    @objc
    private func callPinchGestureRecognizer(_ gestureRecognizer: UIPinchGestureRecognizer) {
        photoView.transform = photoView.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
        gestureRecognizer.scale = 1
        zoomOutButtonView.isHidden = false
    }
}

// MARK: - ToolsWeightViewDelegate

extension DrawingViewController: ToolsWeightViewDelegate {
    func didTapBackButton() {
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseInOut,
            animations: {
                self.editTypeSegmentedControl.isHidden = false
                self.toolsWeightView.isHidden = true
                
                self.cancelButton.isHidden = false
                self.downloadButton.isHidden = false
                
                self.colorPickerView.isHidden = false
            })
        
        toolsStackView.didCancelToolUpdatingWeight()
    }
    
    func didSliderValueChanged(value: Float) {
        guard let selectedTool = toolsStackView.selectedTool else { return }
        
        selectedTool.weight = CGFloat(value)
        canvasView.tool = selectedTool.tool
    }
}

// MARK: - PKCanvasViewDelegate

extension DrawingViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        selectedTextView = nil
        updateUndoButton()
    }
}

// MARK: - TextViewDelegate

extension DrawingViewController: TextViewDelegate {
    func didChangeTextViewViewModel(
        _ textView: TextView,
        from oldViewModel: TextView.ViewModel
    ) {
        canvasView.undoManager?.registerUndo(withTarget: self, handler: { _ in
            textView.viewModel = oldViewModel
            textView.updateView()
        })
        
        updateUndoButton()
    }
    
    func didChangeTextViewTransform(
        _ textView: TextView,
        oldTransform: CGAffineTransform,
        oldBoundsWidth: CGFloat
    ) {
        canvasView.undoManager?.registerUndo(withTarget: self, handler: { _ in
            textView.transform = oldTransform
            textView.bounds.size.width = oldBoundsWidth
        })
        
        updateUndoButton()
    }
    
    func didSelectTextView(_ textView: TextView) {
        selectedTextView = textView
    }
    
    func didTapDeleteAction(_ textView: TextView) {
        selectedTextView = nil
        textView.removeFromSuperview()
    }
    
    func didTapDuplicateAction(_ textView: TextView) {
        let newTextView = TextView(frame: CGRect(origin: textView.center, size: textView.bounds.size), viewModel: textView.viewModel)
        textView.isSelected = false
        newTextView.isSelected = false
        
        newTextView.output = self
        newTextView.sizeToFit()
        canvasView.addSubview(newTextView)
        newTextView.transform = textView.transform

        canvasView.undoManager?.registerUndo(withTarget: self, handler: { [weak self] _ in
            newTextView.removeFromSuperview()
            self?.updateUndoButton()
        })
    }
    
    func didBeginEditing(_ textView: TextView) {
        selectedTextView = textView
        fontSizeSliderView.isHidden = false
        fontSizeSliderView.value = Float(textView.viewModel?.font?.pointSize ?? CGFloat(fontSizeSliderView.value))
    }
    
    func didEndEditing(_ textView: TextView) {
        selectedTextView = nil
        fontSizeSliderView.isHidden = true
    }
}

// MARK: - ToolsStackViewDelegate

extension DrawingViewController: ToolsStackViewDelegate {
    func didSelectTool(_ tool: ToolProtocol?) {
        guard let tool = tool else { return }
        colorPickerView.color = tool.color
        canvasView.tool = tool.tool
    }
    
    func didSelectUpdatingWeightTool(_ tool: ToolProtocol?) {
        guard let tool = tool else { return }
        toolsWeightView.weightSlider.value = Float(tool.weight)
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseInOut,
            animations: {
                self.editTypeSegmentedControl.isHidden = true
                
                self.cancelButton.isHidden = true
                self.downloadButton.isHidden = true
                
                self.colorPickerView.isHidden = true
                
                self.toolsWeightView.isHidden = false
            })
    }
}

// MARK: - ColorPickerViewControllerDelegate

extension DrawingViewController: ColorPickerViewControllerDelegate {
    func didSelectColor(_ color: UIColor) {
        colorPickerView.color = color
        
        if let selectedTextView = selectedTextView {
            selectedTextView.viewModel?.textColor = color
            selectedTextView.updateView()
        } else if let selectedTool = toolsStackView.selectedTool,
                  editTypeSegmentedControl.selectedIndex == EditTypes.drawing.rawValue {
            selectedTool.color = color
            canvasView.tool = selectedTool.tool
        }
    }
}

// MARK: - ZoomOutViewDelegate

extension DrawingViewController: ZoomOutViewDelegate {
    func didTapZoomOutView() {
        photoView.transform = .identity
        zoomOutButtonView.isHidden = true
    }
}

// MARK: - ColorPickerViewDelegate

extension DrawingViewController: ColorPickerViewDelegate {
    func colorPickerTouched(
        sender: ColorSpectrumPickerView,
        color: UIColor,
        point: CGPoint,
        state: UIGestureRecognizer.State
    ) {
        if state == .ended {
            didSelectColor(color)
            sender.isHidden = true
        }
    }
}

// MARK: - Private Methods

private extension DrawingViewController {
    func addSubviews() {
        view.addSubview(photoView)
        view.addSubview(canvasView)
        view.addSubview(fontSizeSliderView)
        
        view.addSubview(bottomBlurEffectView)
        
        view.addSubview(cancelButton)
        view.addSubview(downloadButton)
        view.addSubview(editTypeSegmentedControl)
        
        view.addSubview(toolsStackView)
        
        view.addSubview(toolsWeightView)
        view.addSubview(colorPickerView)
        
        view.addSubview(topBlurEffectView)
        
        view.addSubview(textParametersView)
        textParametersView.addSubview(textStyleView)
        textParametersView.addSubview(textAlignmentView)
        
        textParametersView.addSubview(fontsCollectionViewContainer)
        fontsCollectionViewContainer.addSubview(fontsCollectionView)
        
        view.addSubview(spectrumColorsView)
    }
    
    func makeConstraint() {
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: toolsStackView.topAnchor),
            
            canvasView.topAnchor.constraint(equalTo: photoView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: photoView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: photoView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor),
            
            fontSizeSliderView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            fontSizeSliderView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -120),
            fontSizeSliderView.heightAnchor.constraint(equalToConstant: 32),
            fontSizeSliderView.widthAnchor.constraint(equalToConstant: 240),
            
            bottomBlurEffectView.topAnchor.constraint(equalTo: toolsStackView.topAnchor),
            bottomBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBlurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            cancelButton.heightAnchor.constraint(equalToConstant: 33),
            cancelButton.widthAnchor.constraint(equalToConstant: 33),
            
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            downloadButton.heightAnchor.constraint(equalToConstant: 33),
            downloadButton.widthAnchor.constraint(equalToConstant: 33),
            
            editTypeSegmentedControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            editTypeSegmentedControl.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 20),
            editTypeSegmentedControl.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -20),
            editTypeSegmentedControl.heightAnchor.constraint(equalToConstant: 33),
            
            toolsStackView.bottomAnchor.constraint(equalTo: editTypeSegmentedControl.topAnchor),
            toolsStackView.leadingAnchor.constraint(equalTo: editTypeSegmentedControl.leadingAnchor, constant: 20),
            toolsStackView.trailingAnchor.constraint(equalTo: editTypeSegmentedControl.trailingAnchor, constant: -20),
            toolsStackView.heightAnchor.constraint(equalToConstant: 120),
            
            toolsWeightView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            toolsWeightView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolsWeightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolsWeightView.heightAnchor.constraint(equalToConstant: 30),
            
            colorPickerView.bottomAnchor.constraint(equalTo: editTypeSegmentedControl.topAnchor, constant: -17.5),
            colorPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            colorPickerView.heightAnchor.constraint(equalToConstant: 33),
            colorPickerView.widthAnchor.constraint(equalToConstant: 33),
            
            topBlurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            topBlurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBlurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBlurEffectView.heightAnchor.constraint(equalToConstant: 120),
            
            spectrumColorsView.bottomAnchor.constraint(equalTo: colorPickerView.bottomAnchor),
            spectrumColorsView.leadingAnchor.constraint(equalTo: colorPickerView.leadingAnchor),
            spectrumColorsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            spectrumColorsView.heightAnchor.constraint(equalToConstant: 250),
            
            textParametersView.heightAnchor.constraint(equalToConstant: 30),
            textParametersView.bottomAnchor.constraint(equalTo: editTypeSegmentedControl.topAnchor, constant: -17.5),
            textParametersView.leadingAnchor.constraint(equalTo: colorPickerView.trailingAnchor, constant: 14),
            textParametersView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textStyleView.topAnchor.constraint(equalTo: textParametersView.topAnchor),
            textStyleView.bottomAnchor.constraint(equalTo: textParametersView.bottomAnchor),
            textStyleView.widthAnchor.constraint(equalToConstant: 30),
            textStyleView.leadingAnchor.constraint(equalTo: textParametersView.leadingAnchor),
            
            textAlignmentView.topAnchor.constraint(equalTo: textParametersView.topAnchor),
            textAlignmentView.heightAnchor.constraint(equalToConstant: 30),
            textAlignmentView.widthAnchor.constraint(equalToConstant: 30),
            textAlignmentView.leadingAnchor.constraint(equalTo: textStyleView.trailingAnchor, constant: 14),
            
            fontsCollectionViewContainer.topAnchor.constraint(equalTo: textParametersView.topAnchor),
            fontsCollectionViewContainer.bottomAnchor.constraint(equalTo: textParametersView.bottomAnchor),
            fontsCollectionViewContainer.leadingAnchor.constraint(equalTo: textAlignmentView.trailingAnchor),
            fontsCollectionViewContainer.trailingAnchor.constraint(equalTo: textParametersView.trailingAnchor),
        ])
    }
    
    func setupViews() {
        navigationItem.leftBarButtonItem = undoButton
        navigationItem.rightBarButtonItem = clearButton
        navigationItem.titleView = zoomOutButtonView
        
        toolsStackView.setDefaultTool()
    }
    
    func saveDraft() {
        fontSizeSliderView.isHidden = true
        cancelButton.isHidden = true
        downloadButton.isHidden = true
        editTypeSegmentedControl.isHidden = true
        toolsStackView.isHidden = true
        toolsWeightView.isHidden = true
        colorPickerView.isHidden = true
        textParametersView.isHidden = true
        
        let screenshot = view.makeScreenshot(with: photoView.bounds)
        UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
    }
    
    func updatingViewModelTextStyle() {
        guard let textView = selectedTextView, let viewModel = textView.viewModel else { return }
        switch viewModel.textStyle {
        case .default:
            textStyleView.image = #imageLiteral(resourceName: "defaultStyle")
        case .semi:
            textStyleView.image = #imageLiteral(resourceName: "filled")
        case .filled:
            textStyleView.image = #imageLiteral(resourceName: "semi")
        case .stroke:
            textStyleView.image = #imageLiteral(resourceName: "stroke")
        }
    }
    
    func updatingViewModelTextAlignment() {
        guard let textView = selectedTextView, let viewModel = textView.viewModel else { return }
        switch viewModel.textAlignment {
        case .center:
            textAlignmentView.image = #imageLiteral(resourceName: "textCenter")
        case .left:
            textAlignmentView.image = #imageLiteral(resourceName: "textLeft")
        case .right:
            textAlignmentView.image = #imageLiteral(resourceName: "textRight")
        }
    }
    
    func updatingColorPickerFromTextColor() {
        guard let textView = selectedTextView, let viewModel = textView.viewModel else { return }
        colorPickerView.color = viewModel.textColor
    }
    
    func updateUndoButton() {
        let isUndoEnabled = !canvasView.drawing.bounds.isEmpty || (canvasView.undoManager?.canUndo ?? false)
        undoButton.isEnabled = isUndoEnabled
        clearButton.isEnabled = isUndoEnabled
        downloadButton.isEnabled = isUndoEnabled
    }
}
