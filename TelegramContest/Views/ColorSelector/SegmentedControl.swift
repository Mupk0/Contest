//
//  SegmentedControl.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 19.10.2022.
//

import UIKit

class SegmentedControl: UIControl {
    
    fileprivate var labels = [UILabel]()
    private var thumbView = UIView()
    
    var items: [String] = ["item1", "item2"] {
        didSet {
            if items.count > 0 { setupLabels() }
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet { displayNewSelectedIndex() }
    }
    
    var selectedLabelColor: UIColor = .black {
        didSet { setSelectedColors() }
    }
    
    var unselectedLabelColor: UIColor = .white {
        didSet { setSelectedColors() }
    }
    
    var thumbColor: UIColor = .white {
        didSet { setSelectedColors() }
    }
    
    var thumbBorderColor: UIColor = .clear {
        didSet { thumbView.layer.borderColor = thumbBorderColor.cgColor }
    }
    
    var thumbBorderWidth: CGFloat = .zero {
        didSet { thumbView.layer.borderWidth = thumbBorderWidth }
    }
    
    var borderColor: UIColor = UIColor.white {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    var borderWidth: CGFloat = .zero {
        didSet { layer.borderWidth = borderWidth }
    }
    
    var backGroundColor: UIColor = UIColor.clear {
        didSet { backgroundColor = backGroundColor }
    }
    
    var font: UIFont? = UIFont.systemFont(ofSize: 12) {
        didSet { setFont() }
    }
    
    var padding: CGFloat = 0 {
        didSet { setupLabels() }
    }
    
    required override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if labels.count > 0 {
            let label = labels[selectedIndex]
            label.textColor = selectedLabelColor
            thumbView.frame = label.frame
            thumbView.backgroundColor = thumbColor
            thumbView.layer.cornerRadius = thumbView.frame.height / 2
            thumbView.layer.borderColor = thumbBorderColor.cgColor
            thumbView.layer.borderWidth = thumbBorderWidth
            displayNewSelectedIndex()
        }
        layer.cornerRadius = frame.height / 2
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex : Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
}

private extension SegmentedControl {
    func setupView() {
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        layer.borderWidth = 0.5
        
        backgroundColor = UIColor.clear
        setupLabels()
        insertSubview(thumbView, at: 0)
    }
    
    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        for index in 1 ... items.count {
            let label = UILabel()
            label.text = items[index - 1]
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = font
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(labels, mainView: self)
    }
    
    func displayNewSelectedIndex() {
        for (_, item) in labels.enumerated() {
            item.textColor = unselectedLabelColor
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, animations: {
            self.thumbView.frame = label.frame
        })
    }
    
    func addIndividualItemConstraints(_ items: [UIView], mainView: UIView) {
        for (index, button) in items.enumerated() {
            button.topAnchor.constraint(equalTo: mainView.topAnchor, constant: padding).isActive = true
            button.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -padding).isActive = true
            
            if index == .zero {
                button.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding).isActive = true
            } else {
                let prevButton: UIView = items[index - 1]
                let firstItem: UIView = items[0]
                
                button.leadingAnchor.constraint(equalTo: prevButton.trailingAnchor, constant: padding).isActive = true
                button.widthAnchor.constraint(equalTo: firstItem.widthAnchor).isActive = true
            }
            
            if index == items.count - 1 {
                button.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding).isActive = true
            } else {
                let nextButton: UIView = items[index + 1]
                button.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -padding).isActive = true
            }
        }
    }
    
    func setSelectedColors() {
        for item in labels {
            item.textColor = unselectedLabelColor
        }
        
        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }
        
        thumbView.backgroundColor = thumbColor
    }
    
    func setFont() {
        for item in labels {
            item.font = font
        }
    }
}
