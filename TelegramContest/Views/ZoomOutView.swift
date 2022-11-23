//
//  ZoomOutView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 30.10.2022.
//

import UIKit

protocol ZoomOutViewDelegate: AnyObject {
    func didTapZoomOutView()
}

final class ZoomOutView: UIView {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Zoom Out"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "zoomOut"))
        imageView.contentMode = .scaleAspectFit
        imageView.sizeToFit()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var frontView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
        return view
    }()
    
    weak var delegate: ZoomOutViewDelegate?
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 102, height: 22)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(textLabel)
        addSubview(frontView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 22),
            imageView.widthAnchor.constraint(equalToConstant: 22),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            frontView.heightAnchor.constraint(equalToConstant: 22),
            frontView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            frontView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            frontView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapView() {
        delegate?.didTapZoomOutView()
    }
}
