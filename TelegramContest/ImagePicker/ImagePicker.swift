//
//  ImagePicker.swift
//  TelegramContest
//
//  Created by Кулагин Дмитрий on 09.10.2022.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

final class ImagePicker: NSObject {
    private let constants = Constants(); struct Constants {
        let pickerMediaTypes = ["public.image"]
        let takeCameraPhoto = "Сделать фото"
        let takeLibraryPhoto = "Выбрать из галереи"
        let cancel = "Отмена"
    }

    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = constants.pickerMediaTypes
        return pickerController
    }()

    private let presentationController: UIViewController
    private weak var delegate: ImagePickerDelegate?

    init(presentationController: UIViewController, delegate: ImagePickerDelegate? = nil) {
        self.presentationController = presentationController

        super.init()

        self.delegate = delegate
    }

    func present() {
        pickerController.sourceType = .photoLibrary
        presentationController.present(pickerController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        pickerController(picker, didSelect: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        pickerController(picker, didSelect: image)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        delegate?.didSelect(image: image)
        controller.dismiss(animated: true)
    }
}
