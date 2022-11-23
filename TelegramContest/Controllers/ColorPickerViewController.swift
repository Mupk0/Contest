//
//  ColorPickerViewController.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 10.10.2022.
//

import UIKit

protocol ColorPickerViewControllerDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

// TODO: Доделать коллекцию цветов
final class ColorPickerViewController: UIViewController {
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Grid", "Spectrum", "Sliders"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(didControlValueChanged(control:)), for: .valueChanged)
        return control
    }()
    
    private lazy var gridColorsView: ColorSpectrumPickerView = {
        let view = ColorSpectrumPickerView(
            frame: .zero,
            elementSize: 30,
            isNeedGrayBar: true,
            axis: .vertical
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.delegate = self
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
    
    private lazy var slidersContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var redSlider: Slider = {
        let slider = Slider()
        slider.colors = .init(startColor: .black, endColor: .red)
        slider.isHidden = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.addTarget(self, action: #selector(didSliderValueChanged(slider:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var greenSlider: Slider = {
        let slider = Slider()
        slider.colors = .init(startColor: .black, endColor: .green)
        slider.isHidden = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.addTarget(self, action: #selector(didSliderValueChanged(slider:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var blueSlider: Slider = {
        let slider = Slider()
        slider.colors = .init(startColor: .black, endColor: .blue)
        slider.isHidden = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.addTarget(self, action: #selector(didSliderValueChanged(slider:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var redSliderTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 8, left: 10, bottom: 8, right: 10)
        textView.text = "0"
        textView.textAlignment = .center
        textView.keyboardType = .numberPad
        textView.inputAccessoryView = toolbar()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var greenSliderTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 8, left: 10, bottom: 8, right: 10)
        textView.text = "0"
        textView.textAlignment = .center
        textView.keyboardType = .numberPad
        textView.inputAccessoryView = toolbar()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var blueSliderTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 8, left: 10, bottom: 8, right: 10)
        textView.text = "0"
        textView.textAlignment = .center
        textView.keyboardType = .numberPad
        textView.inputAccessoryView = toolbar()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var hexColorTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 7, left: 0, bottom: 0, right: 0)
        textView.text = ""
        textView.textAlignment = .center
        textView.inputAccessoryView = toolbar()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var redSliderLabel: UILabel = {
        let label = UILabel()
        label.text = "RED"
        label.textColor = UIColor(red: 0.922, green: 0.922, blue: 0.961, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var greenSliderLabel: UILabel = {
        let label = UILabel()
        label.text = "GREEN"
        label.textColor = UIColor(red: 0.922, green: 0.922, blue: 0.961, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var blueSliderLabel: UILabel = {
        let label = UILabel()
        label.text = "BLUE"
        label.textColor = UIColor(red: 0.922, green: 0.922, blue: 0.961, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var opacitySlider: ChessSlider = {
        let slider = ChessSlider()
        slider.color = .black
        slider.isHidden = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1
        slider.addTarget(self, action: #selector(didSliderValueChanged(slider:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var opacitySliderLabel: UILabel = {
        let label = UILabel()
        label.text = "OPACITY"
        label.textColor = UIColor(red: 0.922, green: 0.922, blue: 0.961, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var opacitySliderTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textView.textColor = .white
        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 8, left: 10, bottom: 8, right: 10)
        textView.text = "100%"
        textView.textAlignment = .center
        textView.keyboardType = .numberPad
        textView.inputAccessoryView = toolbar()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.282, green: 0.282, blue: 0.29, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var currentColorView: RectangleCurrentColorView = {
        let view = RectangleCurrentColorView()
        view.currentColor = currentColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var currentColor: UIColor {
        get {
            return UIColor(
                _colorLiteralRed: redSlider.value, green: greenSlider.value, blue: blueSlider.value, alpha: opacitySlider.value
            )
        }
        set {
            let rgba = newValue.rgba
            redSlider.value = Float(rgba.red)
            greenSlider.value = Float(rgba.green)
            blueSlider.value = Float(rgba.blue)
            
            opacitySlider.value = Float(rgba.alpha)
            opacitySlider.color = newValue.withAlphaComponent(1)
            
            currentColorView.currentColor = newValue
            
            updateSliders()
            updateHexTextView()
            selectPointsOnGrigViews()
        }
    }
    
    weak var delegate: ColorPickerViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        addSubviews()
        makeConstraints()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectPointsOnGrigViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    @objc
    private func close() {
        navigationController?.dismiss(animated: true)
        delegate?.didSelectColor(currentColor)
    }
    
    @objc
    private func didTapPippete() {
        // TODO: Доработать выбор цвета по пипетке
    }
    
    @objc
    private func didControlValueChanged(control: UISegmentedControl) {
        switch control.selectedSegmentIndex {
        case 0:
            gridColorsView.isHidden = false
            spectrumColorsView.isHidden = true
            slidersContainer.isHidden = true
            return
        case 1:
            gridColorsView.isHidden = true
            spectrumColorsView.isHidden = false
            slidersContainer.isHidden = true
            return
        case 2:
            gridColorsView.isHidden = true
            spectrumColorsView.isHidden = true
            slidersContainer.isHidden = false
            return
        default:
            return
        }
    }
    
    @objc
    private func didSliderValueChanged(slider: UISlider) {
        if slider === opacitySlider {
            currentColor = currentColor.withAlphaComponent(CGFloat(slider.value))
            opacitySliderTextView.text = "\(Int(slider.value * 100))%"
        } else {
            currentColor = UIColor(
                red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1
            )
        }
    }
}

private extension ColorPickerViewController {
    func addSubviews() {
        view.addSubview(blurEffectView)
        view.addSubview(segmentedControl)
        view.addSubview(gridColorsView)
        view.addSubview(spectrumColorsView)
        
        view.addSubview(slidersContainer)
        
        slidersContainer.addSubview(redSlider)
        slidersContainer.addSubview(greenSlider)
        slidersContainer.addSubview(blueSlider)
        
        slidersContainer.addSubview(redSliderTextView)
        slidersContainer.addSubview(greenSliderTextView)
        slidersContainer.addSubview(blueSliderTextView)
        
        slidersContainer.addSubview(redSliderLabel)
        slidersContainer.addSubview(greenSliderLabel)
        slidersContainer.addSubview(blueSliderLabel)
        
        slidersContainer.addSubview(hexColorTextView)
        
        view.addSubview(opacitySliderLabel)
        view.addSubview(opacitySlider)
        view.addSubview(opacitySliderTextView)
        
        view.addSubview(separatorView)
        
        view.addSubview(currentColorView)
    }
    
    func makeConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            gridColorsView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            gridColorsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gridColorsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gridColorsView.heightAnchor.constraint(equalToConstant: 300),
            
            spectrumColorsView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            spectrumColorsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            spectrumColorsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            spectrumColorsView.heightAnchor.constraint(equalToConstant: 300),
            
            slidersContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            slidersContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            slidersContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            slidersContainer.heightAnchor.constraint(equalToConstant: 328),
            
            redSliderLabel.topAnchor.constraint(equalTo: slidersContainer.topAnchor, constant: 16),
            redSliderLabel.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor, constant: 4),
            
            redSliderTextView.topAnchor.constraint(equalTo: redSliderLabel.bottomAnchor, constant: 4),
            redSliderTextView.heightAnchor.constraint(equalToConstant: 36),
            redSliderTextView.widthAnchor.constraint(equalToConstant: 77),
            redSliderTextView.trailingAnchor.constraint(equalTo: slidersContainer.trailingAnchor),
            
            redSlider.heightAnchor.constraint(equalToConstant: 36),
            redSlider.topAnchor.constraint(equalTo: redSliderLabel.bottomAnchor, constant: 4),
            redSlider.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor),
            redSlider.trailingAnchor.constraint(equalTo: redSliderTextView.leadingAnchor, constant: -12),
            
            greenSliderLabel.topAnchor.constraint(equalTo: redSliderTextView.bottomAnchor, constant: 29),
            greenSliderLabel.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor, constant: 4),
            
            greenSliderTextView.topAnchor.constraint(equalTo: greenSliderLabel.bottomAnchor, constant: 4),
            greenSliderTextView.heightAnchor.constraint(equalToConstant: 36),
            greenSliderTextView.widthAnchor.constraint(equalToConstant: 77),
            greenSliderTextView.trailingAnchor.constraint(equalTo: slidersContainer.trailingAnchor),
            
            greenSlider.heightAnchor.constraint(equalToConstant: 36),
            greenSlider.topAnchor.constraint(equalTo: greenSliderLabel.bottomAnchor, constant: 4),
            greenSlider.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor),
            greenSlider.trailingAnchor.constraint(equalTo: greenSliderTextView.leadingAnchor, constant: -12),
            
            blueSliderLabel.topAnchor.constraint(equalTo: greenSliderTextView.bottomAnchor, constant: 29),
            blueSliderLabel.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor, constant: 4),
            
            blueSliderTextView.topAnchor.constraint(equalTo: blueSliderLabel.bottomAnchor, constant: 4),
            blueSliderTextView.heightAnchor.constraint(equalToConstant: 36),
            blueSliderTextView.widthAnchor.constraint(equalToConstant: 77),
            blueSliderTextView.trailingAnchor.constraint(equalTo: slidersContainer.trailingAnchor),
            
            blueSlider.heightAnchor.constraint(equalToConstant: 36),
            blueSlider.topAnchor.constraint(equalTo: blueSliderLabel.bottomAnchor, constant: 4),
            blueSlider.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor),
            blueSlider.trailingAnchor.constraint(equalTo: blueSliderTextView.leadingAnchor, constant: -12),
            
            hexColorTextView.topAnchor.constraint(equalTo: blueSliderTextView.bottomAnchor, constant: 29),
            hexColorTextView.heightAnchor.constraint(equalToConstant: 36),
            hexColorTextView.widthAnchor.constraint(equalToConstant: 80),
            hexColorTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            opacitySliderLabel.topAnchor.constraint(equalTo: hexColorTextView.bottomAnchor, constant: 20),
            opacitySliderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            opacitySlider.heightAnchor.constraint(equalToConstant: 35),
            opacitySlider.topAnchor.constraint(equalTo: opacitySliderLabel.bottomAnchor, constant: 4),
            opacitySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            opacitySlider.trailingAnchor.constraint(equalTo: opacitySliderTextView.leadingAnchor, constant: -12),
            
            opacitySliderTextView.topAnchor.constraint(equalTo: opacitySliderLabel.bottomAnchor, constant: 4),
            opacitySliderTextView.heightAnchor.constraint(equalToConstant: 36),
            opacitySliderTextView.widthAnchor.constraint(equalToConstant: 77),
            opacitySliderTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.topAnchor.constraint(equalTo: opacitySlider.bottomAnchor, constant: 24),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            currentColorView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 22),
            currentColorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            currentColorView.heightAnchor.constraint(equalToConstant: 82),
            currentColorView.widthAnchor.constraint(equalToConstant: 82),
        ])
    }
    
    func configureViews() {
        navigationItem.title = "Colors"
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: #imageLiteral(resourceName: "pippete"),
//            style: .plain,
//            target: self,
//            action: #selector(didTapPippete)
//        )
//        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(close)
        )
        
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
    }
    
    func updateSliders() {
        redSlider.colors = .init(
            startColor: UIColor(_colorLiteralRed: 0, green: greenSlider.value, blue: blueSlider.value, alpha: 1),
            endColor: UIColor(_colorLiteralRed: 1, green: greenSlider.value, blue: blueSlider.value, alpha: 1)
        )
        greenSlider.colors = .init(
            startColor: UIColor(_colorLiteralRed: redSlider.value, green: 0, blue: blueSlider.value, alpha: 1),
            endColor: UIColor(_colorLiteralRed: redSlider.value, green: 1, blue: blueSlider.value, alpha: 1)
        )
        blueSlider.colors = .init(
            startColor: UIColor(_colorLiteralRed: redSlider.value, green: greenSlider.value, blue: 0, alpha: 1),
            endColor: UIColor(_colorLiteralRed: redSlider.value, green: greenSlider.value, blue: 1, alpha: 1)
        )
        
        redSlider.thumbColor = currentColor
        greenSlider.thumbColor = currentColor
        blueSlider.thumbColor = currentColor
        
        redSliderTextView.text = String(Int(redSlider.value * 255))
        greenSliderTextView.text = String(Int(greenSlider.value * 255))
        blueSliderTextView.text = String(Int(blueSlider.value * 255))
        
        opacitySlider.color = currentColor.withAlphaComponent(1)
    }
    
    func updateHexTextView() {
        let hexCode = currentColor.toHexString()
        hexColorTextView.text = hexCode
    }
    
    func selectPointsOnGrigViews() {
        selectColorOnColorsView(currentColor, view: gridColorsView)
        selectColorOnColorsView(currentColor, view: spectrumColorsView)
    }
    
    func selectColorOnColorsView(_ color: UIColor, view: ColorSpectrumPickerView) {
        let point = view.getPointForColor(color, in: view.bounds)
        view.selectPoint(point, in: view.bounds, with: color)
    }
}

extension ColorPickerViewController: ColorPickerViewDelegate {
    func colorPickerTouched(sender: ColorSpectrumPickerView, color: UIColor, point: CGPoint, state: UIGestureRecognizer.State) {
        currentColor = color
    }
}

extension ColorPickerViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === hexColorTextView {
            let color = UIColor(fromHex: textView.text)
            if let components = color.cgColor.components {
                redSlider.value = Float(components[0])
                greenSlider.value = Float(components[1])
                blueSlider.value = Float(components[2])
                opacitySlider.value = 1
                updateSliders()
            }
        } else if textView === opacitySliderTextView {
            if let text = textView.text, let value = Int(text.replacingOccurrences(of: "%", with: "")) {
                currentColor = currentColor.withAlphaComponent(CGFloat(value) / 100)
                opacitySlider.value = Float(value) / 100
            }
        } else if var number = Float(textView.text) {
            if number > 255 { number = 255 }
            let floatValue = Float(number / 255)
            if textView === redSliderTextView {
                redSlider.value = floatValue
            } else if textView === greenSliderTextView {
                greenSlider.value = floatValue
            } else if textView === blueSliderTextView {
                blueSlider.value = floatValue
            }
            currentColor = UIColor(
                red: CGFloat(redSlider.value),
                green: CGFloat(greenSlider.value),
                blue: CGFloat(blueSlider.value),
                alpha: CGFloat(opacitySlider.value)
            )
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView === hexColorTextView {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= 6
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView === hexColorTextView {
            currentColor = currentColor
        }
        if textView === opacitySliderTextView, let text = textView.text {
            var value: Int = 0
            if text.isEmpty {
                value = 0
            }
            if let intValue = Int(text.replacingOccurrences(of: "%", with: "")) {
                if intValue > 100 {
                    value = 100
                } else {
                    value = intValue
                }
            }
            textView.text = "\(value)%"
            opacitySlider.value = Float(value) / 100
        }
        return true
    }
}
