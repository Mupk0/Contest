//
//  FontsCollectionView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 31.10.2022.
//

import UIKit

final class FontsCollectionView: UICollectionView {
    
    private lazy var fontNames = Fonts.allCases
    
    var selectedTextView: TextView?
    
    required init(frame: CGRect = .zero) {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.estimatedItemSize = CGSize(width: 70, height: 30)
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumLineSpacing = 12
        
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        bounces = false
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        dataSource = self
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension FontsCollectionView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fontNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithAutoregistration(
            FontCollectionViewCell.self,
            for: indexPath
        ) else { fatalError("cell has not been implemented") }
        
        let font = fontNames[indexPath.item]
        cell.configure(with: font.name)
        
        if let selectedTextView = selectedTextView, let selectedTextViewFont = selectedTextView.font {
            cell.isSelected = font.rawValue == selectedTextViewFont.fontName
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let font = fontNames[indexPath.item]
        if let selectedTextView = selectedTextView,
           let selectedTextViewFont = selectedTextView.font {
            if let font = UIFont(name: font.rawValue, size: selectedTextViewFont.pointSize) {
                selectedTextView.font = font
            }
            collectionView.reloadData()
            selectedTextView.updateViewModelFont()
            selectedTextView.updateSize()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let fontName = fontNames[indexPath.item]
        if let font = UIFont(name: fontName.rawValue, size: 13) {
            let width = fontName.name.widthOfString(usingFont: font)
            return CGSize(width: width, height: 30)
        } else {
            return CGSize(width: 70, height: 30)
        }
    }
}
