//
//  ChessSlider.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 25.10.2022.
//

import UIKit

final class ChessSlider: UISlider {
    
    var color: UIColor = .red {
        didSet {
            updateBackgroundColors()
            thumbColor = color.withAlphaComponent(CGFloat(value))
        }
    }
    
    var thumbColor: UIColor = .clear {
        didSet {
            createThumbImageView(with: thumbColor)
        }
    }
    
    private var baseLayer = CALayer()
    private var trackLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clear()
        setup()
        createThumbImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateBackgroundColors()
    }
    
    @objc
    private func didSliderValueChanged(slider: UISlider) {
        thumbColor = color.withAlphaComponent(CGFloat(slider.value))
    }
}

private extension ChessSlider {
    
    func clear() {
        tintColor = .clear
        maximumTrackTintColor = .clear
        backgroundColor = .clear
        thumbTintColor = .clear
    }
    
    func setup() {
        addTarget(self, action: #selector(didSliderValueChanged(slider:)), for: .valueChanged)
    }
    
    func updateBackgroundColors() {
        let baseLayer = ChessLayer()
        baseLayer.masksToBounds = true
        baseLayer.backgroundColor = UIColor.clear.cgColor
        baseLayer.frame = bounds
        baseLayer.cornerRadius = baseLayer.frame.height / 2
        baseLayer.setNeedsDisplay()
        
        let trackLayer = CAGradientLayer()
        trackLayer.masksToBounds = true
        trackLayer.frame = bounds
        trackLayer.cornerRadius = baseLayer.frame.height / 2
        trackLayer.colors = [UIColor.clear.cgColor, color.cgColor]
        trackLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        trackLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        self.baseLayer.removeFromSuperlayer()
        self.baseLayer = baseLayer
        
        self.trackLayer.removeFromSuperlayer()
        self.trackLayer = trackLayer
        
        layer.insertSublayer(baseLayer, at: 0)
        layer.insertSublayer(trackLayer, at: 1)
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
