//
//  ThumbView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 27.10.2022.
//

import UIKit

final class ThumbView: UIView {
    var thumbBackgroundColor: UIColor = .clear {
        didSet {
            thumbView.backgroundColor = thumbBackgroundColor
        }
    }
    
    private let inset: CGFloat = 3
    
    private lazy var thumbView: UIView = {
        let view = UIView(
            frame: CGRect(
                origin: CGPoint(x: inset, y: inset),
                size: CGSize(width: frame.width - inset * 2, height: frame.height - inset * 2)
            )
        )
        view.layer.borderWidth = inset
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = view.frame.height / 2
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(thumbView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
