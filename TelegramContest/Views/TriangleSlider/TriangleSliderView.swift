//
//  TriangleSliderView.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 10.10.2022.
//

import UIKit

final class TriangleSliderView: UISlider {
    private let triangleView: TriangleView
    
    override init(frame: CGRect) {
        triangleView = TriangleView(frame: frame, color: .white.withAlphaComponent(0.2))
        triangleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        super.init(frame: frame)

        minimumTrackTintColor = .clear
        maximumTrackTintColor = .clear
        backgroundColor = .clear
        
        insertSubview(triangleView, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
