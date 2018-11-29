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

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MemeDetailsViewControllerDelegate {

    fileprivate let itemsPerRow: CGFloat = 4
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    fileprivate var memes = [Meme]()
    fileprivate var selectedMemes = [Int]()
    fileprivate var premiumProduct: SKProduct?
    fileprivate var isPremium: Bool = false
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMemes()
    }
    
    @objc func addMeme(_ sender: UIBarButtonItem) {
        if(memes.count >= 5 && !isPremium) {
            let alertViewController = showBuyConfirmationDialog(message: "Para agregar más memes, necesitas la versión Premium de Mis Memes", title: "Mis Memes Premium") { response  in
                if response {
                    print("Ir a la App Store")
                    guard let product = self.premiumProduct else { return }
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(payment)
                } else {
                    print("No gracias!")
                }
            }
            present(alertViewController, animated: true, completion: nil)
        }
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
        selectedMemes.sort()
        var counter = 0
        for index in selectedMemes {
            deleteImage(imageName: memes[index - counter].imageName)
            memes.remove(at: index - counter)
            counter += 1
        }
        selecting = false
        UserDefaults.standard.set(try? PropertyListEncoder().encode(memes), forKey:"memes")
        loadMemes()
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCell", for: indexPath) as? MemeCell else {
            return MemeCell()
        }
        if let image = getImage(imageName: memes[indexPath.row].imageName) {
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selecting {
            selectedMemes.append(indexPath.row)
            if selectedMemes.isEmpty {
                navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
            } else {
                navigationItem.rightBarButtonItems = [deleteItem, shareItem] as? [UIBarButtonItem]
            }
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            let controller = storyboard?.instantiateViewController(withIdentifier: "memeDetailsViewController") as! MemeDetailsViewController
            controller.meme = memes[indexPath.row]
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedMemes.remove(at: indexPath.row)
        if selectedMemes.isEmpty {
            navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
        } else {
            navigationItem.rightBarButtonItems = [deleteItem, shareItem] as? [UIBarButtonItem]
        }
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

extension MainViewController: SKProductsRequestDelegate {
    
    func requestProducts() {
        let ids: Set<String> = ["premium"]
        let productsRequest = SKProductsRequest(productIdentifiers: ids)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Products ready: \(response.products.count)")
        print("Products not ready: \(response.invalidProductIdentifiers.count)")
        self.premiumProduct = response.products.first
    }
    
}

extension MainViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                print("failed")
                let errorMsg: String! = transaction.error?.localizedDescription
                showAlertDialog(message: "Ocurrió un error al completar la compra. Razón: \(errorMsg)", title: "Error", controller: self)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                print("restored")
                showAlertDialog(message: "Mis Memes Premium ha sido habilitado.", title: "Mis Memes Premium", controller: self)
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing:
                print("purchasing")
                break
            case .deferred:
                print("deferred")
                break
            }
        }
    }
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

