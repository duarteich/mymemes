//
//  MemeDetailsViewController.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/13/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit
import MaterialComponents

class MemeDetailsViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: MDCTextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var appBar = MDCAppBar()
    var nameController: MDCTextInputControllerOutlined?
    
    var meme: Meme?
    var image: UIImage?
    var delegate: MemeDetailsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(appBar.headerViewController)
        appBar.addSubviewsToParent()
        nameController = MDCTextInputControllerOutlined(textInput: nameTextField)
        let leftItem = UIBarButtonItem(title: "CANCEL", style: .plain, target: self, action: #selector(cancel))
        let saveItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(save))
        let shareItem = UIBarButtonItem(image: UIImage(named: "share_icon"), style: .plain, target: self, action: #selector(share))
        let deleteItem = UIBarButtonItem(image: UIImage(named: "delete_icon"), style: .plain, target: self, action: #selector(deleteMeme))
        if let meme = meme {
            title = meme.name
            nameTextField.isHidden = true
            if let image = getImage(imageName: meme.imageName) {
                self.image = image
                imageView.image = image
            }
            navigationItem.rightBarButtonItems = [shareItem, deleteItem]
        } else {
            title = NSLocalizedString("new_meme", comment: "")
            imageView.image = image
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
        delegate?.memeDetailsDidCancel()
    }
    
    @objc func save() {
        if nameTextField.text!.isEmpty {
            showAlertDialog(message: "Por favor, introduce el nombre del meme.", title: "Error", controller: self)
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
        delegate?.memeDetailsDidDelete(meme: meme)
    }

}
