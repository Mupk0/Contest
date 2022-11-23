//
//  ViewModelConfigurable.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 09.10.2022.
//

public protocol ViewModelConfigurable {
    associatedtype ViewModel
    func configure(with viewModel: ViewModel)
}
