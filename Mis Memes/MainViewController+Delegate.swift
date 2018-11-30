//
//  MainViewController+Delegate.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/29/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

extension MainViewController: UICollectionViewDelegate {
    
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
}
