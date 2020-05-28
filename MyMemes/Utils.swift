//
//  Utils.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/19/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

let memesPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("memes")
let ok = NSLocalizedString("ok", comment: "")
let cancel = NSLocalizedString("cancel", comment: "")
let buy = NSLocalizedString("buy", comment: "")

func showAlertDialog(message: String, title: String, controller: UIViewController) {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: ok, style: .default, handler: nil)
    alertViewController.addAction(action)
    controller.present(alertViewController, animated: true, completion: nil)
}

func showConfirmationDialog(message: String, title: String, completion: @escaping (_ result: Bool) -> ()) -> UIAlertController {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: ok, style: .default, handler: { action in
        completion(true)
    })
    let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
        completion(false)
    })
    alertViewController.addAction(okAction)
    alertViewController.addAction(cancelAction)
    return alertViewController
}

func showBuyConfirmationDialog(message: String, title: String, completion: @escaping (_ result: Bool) -> ()) -> UIAlertController {
    let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: buy, style: .default, handler: { action in
        completion(true)
    })
    let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
        completion(false)
    })
    alertViewController.addAction(okAction)
    alertViewController.addAction(cancelAction)
    return alertViewController
}

func getImage(imageName: String) -> UIImage? {
    let fileManager = FileManager.default
    let url = NSURL(string: memesPath)
    guard let imagePath = url?.appendingPathComponent(imageName) else { return nil }
    if fileManager.fileExists(atPath: imagePath.absoluteString) {
        return UIImage(contentsOfFile: imagePath.absoluteString)
    }
    return nil
}
