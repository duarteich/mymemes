//
//  MainViewController+Delegate.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/29/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selecting {
            selectedMemes.append(filtering ? filteredMemes[indexPath.row] : memes[indexPath.row])
            if selectedMemes.isEmpty {
                navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
            } else {
                navigationItem.rightBarButtonItems = [deleteItem, shareItem] as? [UIBarButtonItem]
            }
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            let controller = storyboard?.instantiateViewController(withIdentifier: "memeDetailsViewController") as! MemeDetailsViewController
            controller.modalTransitionStyle = .crossDissolve
            controller.meme = filtering ? filteredMemes[indexPath.row] : memes[indexPath.row]
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let memesData = filtering ? self.filteredMemes : self.memes
        if let index = self.selectedMemes.index(where : { $0.imageName == memesData[indexPath.row].imageName }) {
            selectedMemes.remove(at: index)
        }
        if selectedMemes.isEmpty {
            navigationItem.rightBarButtonItems = [addItem] as? [UIBarButtonItem]
        } else {
            navigationItem.rightBarButtonItems = [deleteItem, shareItem] as? [UIBarButtonItem]
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
