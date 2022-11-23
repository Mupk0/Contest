//
//  FontCollectionViewCell.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 29.10.2022.
//

import UIKit

final class FontCollectionViewCell: UICollectionViewCell {
    private lazy var backView: UIView = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fontLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: isSelected ? 1 : 0.33).cgColor
            layer.borderWidth = isSelected ? 0.67 : 0.33
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 9
        backgroundColor = .clear
        
        addSubview(backView)
        backView.addSubview(fontLabel)
        
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: 30),
            
            fontLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 8),
            fontLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -8),
            fontLabel.topAnchor.constraint(equalTo: backView.topAnchor),
            fontLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with fontName: String) {
        fontLabel.text = fontName
        if let font = UIFont(name: fontName, size: 13) {
            fontLabel.font = font
        }
        fontLabel.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        fontLabel.text = nil
        isSelected = false
    }
}
