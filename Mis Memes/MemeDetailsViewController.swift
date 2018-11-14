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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let meme = meme {
            title = meme.name
        } else {
            title = "Nuevo meme"
            imageView.image = self.image
        }
        let leftItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = leftItem
        let rightItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func save() {
        navigationController?.popViewController(animated: true)
    }

}
