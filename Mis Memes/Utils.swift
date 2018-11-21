//
//  Utils.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/19/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

func showAlertDialog(message: String, title: String, controller: UIViewController) {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
    alertViewController.addAction(action)
    controller.present(alertViewController, animated: true, completion: nil)
}
