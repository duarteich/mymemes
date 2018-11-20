//
//  MemeCell.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/19/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit

class MemeCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 5 : 0
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = tintColor.cgColor
        isSelected = false
    }

}
