//
//  MemeCell.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/19/18.
//  Copyright © 2018 Making your app. All rights reserved.
//

import UIKit
import MaterialComponents

class MemeCell: MDCCardCollectionCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cornerRadius = 6.0
        isSelectable = true
        tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setBorderColor(.lightGray, for: .normal)
        setBorderWidth(1.0, for: .normal)
        setBorderColor(#colorLiteral(red: 0.3411764706, green: 0.1215686275, blue: 0.8980392157, alpha: 1), for: .selected)
        setBorderWidth(5.0, for: .selected)
    }

}
