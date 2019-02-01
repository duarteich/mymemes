//
//  ViewController.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/9/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit
import MaterialComponents

protocol MemeDetailsViewControllerDelegate {
    func memeDetailsDidSave(memeDetailsViewController: MemeDetailsViewController)
    func memeDetailsDidCancel(memeDetailsViewController: MemeDetailsViewController)
    func memeDetailsDidDelete(controller: MemeDetailsViewController, meme: Meme)
}

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, MemeDetailsViewControllerDelegate {
    
    var appBar = MDCAppBar()

    let itemsPerRow: CGFloat = 2
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imagePicker = UIImagePickerController()
    var memes = [Meme]()
    var filteredMemes = [Meme]()
    var selectedMemes = [Meme]()
    var filtering = false
    var isPremium: Bool = false
    
    var addItem : UIBarButtonItem?
    var cancelItem: UIBarButtonItem?
    var selectItem: UIBarButtonItem?
    var deleteItem: UIBarButtonItem?
    var shareItem: UIBarButtonItem?
    var selecting: Bool = false {
        didSet {
            collectionView?.allowsMultipleSelection = selecting
            collectionView?.selectItem(at: nil, animated: true, scrollPosition: .top)
            selectedMemes.removeAll(keepingCapacity: false)
            if selecting {
                navigationItem.leftBarButtonItem = cancelItem
            } else {
                navigationItem.leftBarButtonItem = selectItem
                navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppBar()
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        addItem = UIBarButtonItem(image: UIImage(named: "add_icon"), style: .plain, target: self, action: #selector(addMeme(_:)))
        shareItem = UIBarButtonItem(image: UIImage(named: "share_icon"), style: .plain, target: self, action: #selector(shareItems))
        deleteItem = UIBarButtonItem(image: UIImage(named: "delete_icon"), style: .plain, target: self, action: #selector(deleteItems))
        navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
        selectItem = UIBarButtonItem(title: NSLocalizedString("select", comment: ""), style: .plain, target: self, action: #selector(selectItems))
        cancelItem = UIBarButtonItem(title: NSLocalizedString("cancel", comment: ""), style: .plain, target: self, action: #selector(selectItems))
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        self.collectionView.addGestureRecognizer(tap)
        self.view.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
        self.collectionView.backgroundColor = ApplicationScheme.shared.colorScheme.surfaceColor
    }
    
    func configureAppBar() {
        self.addChild(appBar.headerViewController)
        let headerView = appBar.headerViewController.headerView
        print(headerView.bounds.height)
        appBar.addSubviewsToParent()
        MDCAppBarColorThemer.applySemanticColorScheme(ApplicationScheme.shared.colorScheme, to: self.appBar)
    }
    
    @objc func endEditing() {
        searchBar.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.text = ""
        loadMemes()
        selecting = false
    }
    
    @objc func addMeme(_ sender: UIBarButtonItem) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "memeDetailsViewController") as! MemeDetailsViewController
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func memeDetailsDidCancel(memeDetailsViewController: MemeDetailsViewController) {
        memeDetailsViewController.dismiss(animated: true, completion: nil)
    }
    
    func memeDetailsDidSave(memeDetailsViewController: MemeDetailsViewController) {
        guard let image = memeDetailsViewController.imageView?.image else { return }
        guard let name = memeDetailsViewController.nameTextField.text?.trimmingCharacters(in: .whitespaces) else { return }
        if nameIsUsed(name) {
            showAlertDialog(message: NSLocalizedString("name_already_exists", comment: ""), title: NSLocalizedString("appname", comment: ""), controller: self)
            return
        }
        memeDetailsViewController.dismiss(animated: true, completion: nil)
        let imageName = name.replacingOccurrences(of: " ", with: "_")
        saveImageDocumentDirectory(image: image, imageName: imageName)
        let meme = Meme(name: name, imageName: imageName)
        memes.append(meme)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(memes), forKey:"memes")
        loadMemes()
    }
    
    func memeDetailsDidDelete(controller: MemeDetailsViewController, meme: Meme) {
        let alertViewController = showConfirmationDialog(message: NSLocalizedString("delete_single_confirmation", comment: ""), title: NSLocalizedString("appname", comment: "")) { response in
            if response {
                self.loadMemes()
                if let index = self.memes.index(where : { $0.imageName == meme.imageName}) {
                    self.memes.remove(at: index)
                    self.deleteImage(imageName: meme.imageName)
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(self.memes), forKey:"memes")
                    controller.dismiss(animated: true, completion: nil)
                }
            }
        }
        controller.present(alertViewController, animated: true, completion: nil)
    }
    
    func nameIsUsed(_ name: String) -> Bool {
        if self.memes.contains(where: { $0.name == name}) {
            return true
        }
        return false
    }
    
    @objc func selectItems() {
        selecting = !selecting
    }
    
    @objc func deleteItems() {
        searchBar.text = ""
        let alertViewController = showConfirmationDialog(message: NSLocalizedString("delete_multiple_confirmation", comment: ""), title: NSLocalizedString("appname", comment: "")) { response in
            if response {
                for meme in self.selectedMemes {
                    if let index = self.memes.index(where : { $0.imageName == meme.imageName}) {
                        self.memes.remove(at: index)
                        self.deleteImage(imageName: meme.imageName)
                    }
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
        for meme in selectedMemes {
            guard let image = getImage(imageName: meme.imageName) else { continue }
            images.append(image)
        }
        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func loadMemes() {
        filtering = false
        if let data = UserDefaults.standard.value(forKey:"memes") as? Data {
            guard let memes = try? PropertyListDecoder().decode(Array<Meme>.self, from: data) else { return }
            self.memes = memes
            if !memes.isEmpty {
                navigationItem.leftBarButtonItem = selectItem
                //searchBar.isHidden = false
                collectionView.restore()
            } else {
                navigationItem.leftBarButtonItem = nil
                searchBar.isHidden = true
                collectionView.setEmptyMessage(NSLocalizedString("no_memes", comment: ""))
            }
            collectionView.reloadData()
        } else {
            collectionView.setEmptyMessage(NSLocalizedString("no_memes", comment: ""))
            searchBar.isHidden = true
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            let controller = storyboard?.instantiateViewController(withIdentifier: "memeDetailsViewController") as! MemeDetailsViewController
            controller.image = pickedImage
            controller.delegate = self
            present(controller, animated: true, completion: nil)
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

}

//MARK: - UIScrollViewDelegate
extension MainViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.appBar.headerViewController.headerView.trackingScrollView {
            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == self.appBar.headerViewController.headerView.trackingScrollView) {
            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                           willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if (scrollView == headerView.trackingScrollView) {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity,
                                                     targetContentOffset: targetContentOffset)
        }
    }
}



