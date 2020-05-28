//
//  MainViewController+SearchBar.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 12/4/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtering = !searchText.isEmpty
        filteredMemes = memes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        collectionView.reloadData()
    }
}
