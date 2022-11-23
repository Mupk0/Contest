//
//  ViewController.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 09.10.2022.
//

import UIKit
import PencilKit

final class MainViewController: UIViewController {
    
    private lazy var imagePicker = ImagePicker(presentationController: self, delegate: self)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        addSubviews()
        
        hideKeyboardWhenTappedAround()
    }
}

private extension MainViewController {
    func addSubviews() {
        view.addSubview(tableView)
    }
}

// MARK: - Rows

private extension MainViewController {
    enum Rows: CaseIterable {
        case nativePicker
        
        init?(indexPath: IndexPath) {
            guard let row = (Rows.allCases.first { $0.indexPath == indexPath }) else { return nil }
            self = row
        }
        
        var title: String {
            switch self {
            case .nativePicker:
                return "UIImagePickerController"
            }
        }
        
        var indexPath: IndexPath {
            switch self {
            case .nativePicker:
                return IndexPath(row: .zero, section: .zero)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Rows.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithAutoregistration(UITableViewCell.self)
        else { fatalError("cell has not been implemented") }
        cell.textLabel?.text = Rows.allCases[indexPath.row].title
        cell.selectionStyle = .none
        cell.separatorInset = .zero
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowType = Rows(indexPath: indexPath) else { return }
        switch rowType {
        case .nativePicker:
            imagePicker.present()
        }
    }
}

// MARK: - ImagePickerDelegate

extension MainViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else { return }
        let drawingViewController = DrawingViewController(image: image)
        navigationController?.pushViewController(drawingViewController, animated: true)
    }
}
