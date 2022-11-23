//
//  UICollectionView.swift
//  TelegramContest
//
//  Created by Dmitry Kulagin on 29.10.2022.
//

import UIKit

extension UICollectionView {
    func register<TCell: UICollectionViewCell>(_ cellClass: TCell.Type) {
        register(cellClass, forCellWithReuseIdentifier: cellClass.defaultReuseID)
    }

    func dequeue<TCell: UICollectionViewCell>(_ cellClass: TCell.Type, for indexPath: IndexPath) -> TCell? {
        dequeueReusableCell(withReuseIdentifier: cellClass.defaultReuseID, for: indexPath) as? TCell
    }

    func dequeueReusableCellWithAutoregistration<TCell: UICollectionViewCell>(
        _ cellType: TCell.Type,
        reuseID: String? = nil,
        for indexPath: IndexPath
    ) -> TCell? {
        let normalizedReuseID = reuseID ?? cellType.defaultReuseID
        register(cellType, forCellWithReuseIdentifier: normalizedReuseID)

        let cell = dequeueReusableCell(withReuseIdentifier: normalizedReuseID, for: indexPath) as? TCell
        assert(
            cell != nil,
            "UICollectionView cannot dequeue cell with type \(cellType) for reuseID \(normalizedReuseID)"
        )
        return cell
    }

    func dequeueReusableSupplementaryViewWithAutoregistration<TView: UICollectionReusableView>(
        _ viewType: TView.Type,
        ofKind elementKind: String,
        reuseID: String? = nil,
        for indexPath: IndexPath
    ) -> TView? {
        let normalizedReuseID = reuseID ?? viewType.defaultReuseID
        register(viewType, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: normalizedReuseID)

        let cell = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: normalizedReuseID, for: indexPath) as? TView
        assert(
            cell != nil,
            "UICollectionView cannot dequeue supplementaryView with type \(viewType) for reuseID \(normalizedReuseID)"
        )
        return cell
    }
}

extension UICollectionReusableView {
    static var defaultReuseID: String { String(describing: self) }
}
