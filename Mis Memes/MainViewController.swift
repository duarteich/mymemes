//
//  ViewController.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/9/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

protocol MemeDetailsViewControllerDelegate {
    func memeDetailsDidSave(memeDetailsViewController: MemeDetailsViewController)
    func memeDetailsDidCancel()
}

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MemeDetailsViewControllerDelegate {

    fileprivate let itemsPerRow: CGFloat = 4
    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let memesPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("memes")
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    fileprivate var memes = [Meme]()
    fileprivate var selectedMemes = [Meme]()
    
    var addItem : UIBarButtonItem?
    let deleteItems = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
    var selecting: Bool = false {
        didSet {
            collectionView?.allowsMultipleSelection = selecting
            collectionView?.allowsSelection = selecting
            collectionView?.selectItem(at: nil, animated: true, scrollPosition: .top)
            selectedMemes.removeAll(keepingCapacity: false)
            if selecting {
                navigationItem.rightBarButtonItem = deleteItems
            } else {
                navigationItem.rightBarButtonItem = addItem
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        imagePicker.delegate = self
        addItem = UIBarButtonItem(barButtonSystemItem: .add
        , target: self, action: #selector(addMeme))
        navigationItem.rightBarButtonItem = addItem
        let leftItem = UIBarButtonItem(title: "Seleccionar", style: .plain, target: self, action: #selector(selectItems))
        navigationItem.leftBarButtonItem = leftItem
        loadMemes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMemes()
    }
    
    @objc func addMeme(_ sender: UIBarButtonItem) {
        imagePicker.allowsEditing = true
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
    
    @objc func selectItems() {
        if selecting {
            navigationItem.leftBarButtonItem?.title = "Seleccionar"
        } else {
            navigationItem.leftBarButtonItem?.title = "Cancelar"
        }
        selecting = !selecting
    }
    
    private func loadMemes() {
        if let data = UserDefaults.standard.value(forKey:"memes") as? Data {
            guard let memes = try? PropertyListDecoder().decode(Array<Meme>.self, from: data) else { return }
            self.memes = memes
            collectionView.reloadData()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
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
    
    func getDirectoryPath() -> NSURL {
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("memes")
        let url = NSURL(string: path)
        return url!
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCell", for: indexPath) as? MemeCell else {
            return MemeCell()
        }
        if let image = getImage(imageName: memes[indexPath.row].imageName) {
            cell.backgroundView = UIImageView(image: image)
        }
        return cell
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

