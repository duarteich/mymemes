//
//  MemeDetailsViewController.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/13/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

class MemeDetailsViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme?
    var image: UIImage?
    var delegate: MemeDetailsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let leftItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMeme))
        if let meme = meme {
            title = meme.name
            nameTextField.isHidden = true
            if let image = getImage(imageName: meme.imageName) {
                self.image = image
                imageView.image = image
            }
            navigationItem.rightBarButtonItems = [shareItem, deleteItem]
        } else {
            title = "Nuevo Meme"
            imageView.image = image
            navigationItem.leftBarButtonItem = leftItem
            navigationItem.rightBarButtonItem = saveItem
        }
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
