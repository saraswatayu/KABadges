//
//  BadgeCollectionViewCell.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/17/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import Nuke

class BadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var image: UIImageView!
    
    @IBOutlet var extendedDescription: UILabel?
    
    func configureForBadge(badge: Badge) {
        self.layer.borderColor = nil
        self.layer.borderWidth = 0.0
        self.layer.cornerRadius = 0.0
        
        title.text = badge.title
        
        image.image = nil
        badge.getIconImage() { iconImage in
            self.image.image = iconImage
        }
        
        if let extendedDescription = extendedDescription {
            extendedDescription.text = badge.extendedDescription
            self.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.layer.borderWidth = 1.0
            self.layer.cornerRadius = 5.0
        }
    }
}
