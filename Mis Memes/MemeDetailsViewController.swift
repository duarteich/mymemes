//
//  MemeDetailsViewController.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/13/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit
import MaterialComponents

class MemeDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: MDCTextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: MDCRaisedButton!
    
    @IBAction func selectImage(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    var appBar = MDCAppBar()
    let imagePicker = UIImagePickerController()
    var nameController: MDCTextInputControllerOutlined?
    
    var meme: Meme?
    var image: UIImage?
    var delegate: MemeDetailsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(appBar.headerViewController)
        appBar.addSubviewsToParent()
        imagePicker.delegate = self
        nameController = MDCTextInputControllerOutlined(textInput: nameTextField)
        selectImageButton.setTitle(NSLocalizedString("select_image", comment: ""), for: .normal)
        let leftItem = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(cancel))
        let saveItem = UIBarButtonItem(title: NSLocalizedString("save", comment: ""), style: .plain, target: self, action: #selector(save))
        let shareItem = UIBarButtonItem(image: UIImage(named: "share_icon"), style: .plain, target: self, action: #selector(share))
        let deleteItem = UIBarButtonItem(image: UIImage(named: "delete_icon"), style: .plain, target: self, action: #selector(deleteMeme))
        let backItem = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .plain, target: self, action: #selector(back))
        if let meme = meme {
            title = meme.name
            nameTextField.isHidden = true
            selectImageButton.isHidden = true
            if let image = getImage(imageName: meme.imageName) {
                self.image = image
                imageView.image = image
                imageView.isHidden = false
            }
            navigationItem.rightBarButtonItems = [shareItem, deleteItem]
            navigationItem.leftBarButtonItem = backItem
        } else {
            title = NSLocalizedString("new_meme", comment: "")
            navigationItem.leftBarButtonItem = leftItem
            navigationItem.rightBarButtonItem = saveItem
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
    }
    
    @objc func endEditing() {
        nameTextField.resignFirstResponder()
    }
    
    @objc func cancel() {
        delegate?.memeDetailsDidCancel(memeDetailsViewController: self)
    }
    
    @objc func save() {
        if nameTextField.text!.isEmpty {
            showAlertDialog(message: NSLocalizedString("empty_name", comment: ""), title: "Error", controller: self)
            return
        }
        delegate?.memeDetailsDidSave(memeDetailsViewController: self)
    }
    
    @objc func share() {
        guard let imageToShare = self.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func deleteMeme() {
        guard let meme = self.meme else { return }
        delegate?.memeDetailsDidDelete(controller: self, meme: meme)
    }
    
    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: - UIImagePickerControllerDelegate
extension MemeDetailsViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.image = pickedImage
            self.imageView.isHidden = false
            self.imageView.image = self.image
        }
        dismiss(animated: true, completion: nil)
    }
}
