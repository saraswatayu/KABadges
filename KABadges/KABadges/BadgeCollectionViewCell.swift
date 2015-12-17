//
//  BadgeCollectionViewCell.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/17/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit

class BadgeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var image: UIImageView!
    
    func configureForBadge(badge: Badge) {
        title.text = badge.title
//        image.image = badge.getIcon()
    }
}
