//
//  ToolsWeightView.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 10.10.2022.
//

import UIKit

protocol ToolsWeightViewDelegate: AnyObject {
    func didTapBackButton()
    func didSliderValueChanged(value: Float)
}

final class ToolsWeightView: UIView {
    weak var delegate: ToolsWeightViewDelegate?

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    lazy var weightSlider: TriangleSliderView = {
        let slider = TriangleSliderView()
        slider.minimumValue = 1
        slider.maximumValue = 30
        slider.value = 10
        slider.addTarget(self, action: #selector(didSliderValueChanged(slider:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var emptyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backButton)
        addSubview(weightSlider)
        addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalTo: heightAnchor),
            
            emptyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            emptyView.topAnchor.constraint(equalTo: topAnchor),
            emptyView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyView.widthAnchor.constraint(equalToConstant: 80),
            
            weightSlider.bottomAnchor.constraint(equalTo: bottomAnchor),
            weightSlider.topAnchor.constraint(equalTo: topAnchor),
            weightSlider.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            weightSlider.trailingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didTapBackButton() {
        delegate?.didTapBackButton()
    }

    @objc
    private func didSliderValueChanged(slider: UISlider) {
        delegate?.didSliderValueChanged(value: slider.value)
    }
}
