//
//  ViewController.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/9/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit
import StoreKit

protocol MemeDetailsViewControllerDelegate {
    func memeDetailsDidSave(memeDetailsViewController: MemeDetailsViewController)
    func memeDetailsDidCancel()
    func memeDetailsDidDelete(meme: Meme)
}

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MemeDetailsViewControllerDelegate {

    let itemsPerRow: CGFloat = 4
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    var memes = [Meme]()
    var selectedMemes = [Int]()
    var premiumProduct: SKProduct?
    var isPremium: Bool = false
    
    var addItem : UIBarButtonItem?
    var leftItem: UIBarButtonItem?
    var deleteItem: UIBarButtonItem?
    var shareItem: UIBarButtonItem?
    var selecting: Bool = false {
        didSet {
            collectionView?.allowsMultipleSelection = selecting
            collectionView?.selectItem(at: nil, animated: true, scrollPosition: .top)
            selectedMemes.removeAll(keepingCapacity: false)
            if selecting {
                navigationItem.leftBarButtonItem?.title = "Cancelar"
            } else {
                navigationItem.leftBarButtonItem?.title = "Seleccionar"
                 navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePicker.delegate = self
        addItem = UIBarButtonItem(barButtonSystemItem: .add
        , target: self, action: #selector(addMeme))
        deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItems))
        shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareItems))
        navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
        leftItem = UIBarButtonItem(title: "Seleccionar", style: .plain, target: self, action: #selector(selectItems))
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print("Documents Directory: \(documentsPath)")
        }
        requestProducts()
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handlePurchaseNotification(_:)),
                                               name: .MisMemesPurchaseNotification,
                                               object: nil)
        SKPaymentQueue.default().add(self)
        isPremium = UserDefaults.standard.bool(forKey: "premium")
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handlePurchaseNotification(_:)),
                                               name: .MisMemesPurchaseNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMemes()
    }
    
    @objc func addMeme(_ sender: UIBarButtonItem) {
        if(memes.count >= 5 && !isPremium) {
            restorePurchases()
        } else {
            selectImage()
        }
    }
    
    func selectImage() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func memeDetailsDidCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    func memeDetailsDidSave(memeDetailsViewController: MemeDetailsViewController) {
        navigationController?.popViewController(animated: true)
        guard let image = memeDetailsViewController.imageView?.image else { return }
        guard let name = memeDetailsViewController.nameTextField.text else { return }
        let imageName = name.replacingOccurrences(of: " ", with: "_")
        saveImageDocumentDirectory(image: image, imageName: imageName)
        let meme = Meme(name: name, imageName: imageName)
        memes.append(meme)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(memes), forKey:"memes")
        loadMemes()
    }
    
    func memeDetailsDidDelete(meme: Meme) {
        let alertViewController = showConfirmationDialog(message: "¿Deseas eliminar este meme de tu colección?", title: "Mis Memes") { response in
            if response {
                if let index = self.memes.index(where : { $0.imageName == meme.imageName}) {
                    self.memes.remove(at: index)
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(self.memes), forKey:"memes")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        present(alertViewController, animated: true, completion: nil)
    }
    
    @objc func selectItems() {
        selecting = !selecting
    }
    
    @objc func deleteItems() {
        let alertViewController = showConfirmationDialog(message: "¿Deseas eliminar los memes seleccionados de tu colección?", title: "Mis Memes") { response in
            if response {
                self.selectedMemes.sort()
                var counter = 0
                for index in self.selectedMemes {
                    self.deleteImage(imageName: self.memes[index - counter].imageName)
                    self.memes.remove(at: index - counter)
                    counter += 1
                }
                self.selecting = false
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.memes), forKey:"memes")
                self.loadMemes()
            }
        }
        present(alertViewController, animated: true, completion: nil)
    }
    
    @objc func shareItems() {
        var images = [UIImage]()
        for index in selectedMemes {
            guard let image = getImage(imageName: memes[index].imageName) else { continue }
            images.append(image)
        }
        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func loadMemes() {
        if let data = UserDefaults.standard.value(forKey:"memes") as? Data {
            guard let memes = try? PropertyListDecoder().decode(Array<Meme>.self, from: data) else { return }
            self.memes = memes
            if !memes.isEmpty {
                navigationItem.leftBarButtonItem = leftItem
                collectionView.restore()
            } else {
                navigationItem.leftBarButtonItem = nil
                collectionView.setEmptyMessage("Aún no has agregado memes 😔\n Presiona + para comenzar")
            }
            collectionView.reloadData()
        } else {
            collectionView.setEmptyMessage("Aún no has agregado memes 😔\n Presiona + para comenzar")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            let controller = storyboard?.instantiateViewController(withIdentifier: "memeDetailsViewController") as! MemeDetailsViewController
            controller.image = pickedImage
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func saveImageDocumentDirectory(image: UIImage, imageName: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: memesPath) {
            try! fileManager.createDirectory(atPath: memesPath, withIntermediateDirectories: true, attributes: nil)
        }
        let url = NSURL(string: memesPath)
        let imagePath = url?.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        let imageData = image.jpegData(compressionQuality: 0.8)
        fileManager.createFile(atPath: urlString as String, contents: imageData, attributes: nil)
    }
    
    func deleteImage(imageName: String) {
        let fileManager = FileManager.default
        let url = NSURL(string: memesPath)
        let imagePath = url?.appendingPathComponent(imageName)
        let urlString: String = imagePath!.absoluteString
        if fileManager.fileExists(atPath: urlString) {
            try! fileManager.removeItem(atPath: urlString)
        }
    }
    
    func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("memes")
        let url = NSURL(string: path)
        return url!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension Notification.Name {
    static let MisMemesPurchaseNotification = Notification.Name("MisMemesPurchaseNotification")
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

