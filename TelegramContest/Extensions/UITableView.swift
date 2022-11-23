//
//  UITableView.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 09.10.2022.
//

import UIKit

extension UITableView {
    func registerCell<TCell: UITableViewCell>(_ cellType: TCell.Type, reuseID: String? = nil) {
        let normalizedReuseID = reuseID ?? cellType.defaultReuseID
        register(cellType, forCellReuseIdentifier: normalizedReuseID)
    }

    func dequeueReusableCell<TCell: UITableViewCell>(_ cellType: TCell.Type, reuseID: String? = nil) -> TCell? {
        let normalizedReuseID = reuseID ?? cellType.defaultReuseID
        return dequeueReusableCell(withIdentifier: normalizedReuseID) as? TCell
    }

    func dequeue<TCell: UITableViewCell>(_ cellClass: TCell.Type, for indexPath: IndexPath) -> TCell? {
        dequeueReusableCell(withIdentifier: String(describing: cellClass), for: indexPath) as? TCell
    }

    func dequeueReusableCellWithAutoregistration<TCell: UITableViewCell>(_ cellType: TCell.Type, reuseID: String? = nil) -> TCell? {
        registerCell(cellType, reuseID: reuseID)

        let cell = dequeueReusableCell(cellType, reuseID: reuseID)
        assert(cell != nil, "UITableView can not dequeue cell with type \(cellType) for reuseID \(reuseID ?? cellType.defaultReuseID)")

        return cell
    }
}

extension UITableView {
    func makeConfiguratedCell<T: ViewModelConfigurable & UITableViewCell>(cellType: T.Type, viewModel: T.ViewModel) -> T? {
        let cell = dequeueReusableCellWithAutoregistration(cellType)
        cell?.configure(with: viewModel)
        return cell
    }
}
