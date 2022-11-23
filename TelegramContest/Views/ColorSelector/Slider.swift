//
//  Slider.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 22.10.2022.
//

import UIKit

struct Colors {
    let startColor: UIColor
    let endColor: UIColor
}

final class Slider: UISlider {
    var colors: Colors = .init(startColor: .clear, endColor: .clear) {
        didSet {
            updateBackgroundColors()
        }
    }
    
    var thumbColor: UIColor = .clear {
        didSet {
            createThumbImageView(with: thumbColor)
        }
    }
    
    private var baseLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clear()
        createThumbImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBackgroundColors()
    }
}

private extension Slider {
    
    func clear() {
        tintColor = .clear
        maximumTrackTintColor = .clear
        backgroundColor = .clear
        thumbTintColor = .clear
    }
    
    func updateBackgroundColors() {
        let baseLayer = CAGradientLayer()
        baseLayer.masksToBounds = true
        baseLayer.backgroundColor = UIColor.white.cgColor
        baseLayer.frame = bounds
        baseLayer.cornerRadius = baseLayer.frame.height / 2

        baseLayer.colors = [colors.startColor.cgColor, colors.endColor.cgColor]
        baseLayer.startPoint = .init(x: 0, y: 0.5)
        baseLayer.endPoint = .init(x: 1, y: 0.5)
        
        self.baseLayer.removeFromSuperlayer()
        self.baseLayer = baseLayer
        
        layer.insertSublayer(baseLayer, at: 0)
    }

    func createThumbImageView(with color: UIColor = .clear) {
        let thumbView = ThumbView(frame: .init(origin: .zero, size: CGSize(width: frame.height, height: frame.height)))
        thumbView.thumbBackgroundColor = color
        
        let thumbSnapshot = thumbView.snapshot
        
        let states: [UIControl.State] = [.normal, .highlighted, .application, .disabled, .focused, .reserved, .selected]
        
        for state in states {
            setThumbImage(thumbSnapshot, for: state)
        }
    }
}
