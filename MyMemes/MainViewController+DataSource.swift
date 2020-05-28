//
//  MainViewController+DataSource.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/29/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if filtering {
            return filteredMemes.count
        } else {
            return memes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCell", for: indexPath) as? MemeCell else {
            return MemeCell()
        }
        let memesData = filtering ? self.filteredMemes : self.memes
        if let image = getImage(imageName: memesData[indexPath.row].imageName) {
            cell.imageView.image = image
        }
        return cell
    }
}
