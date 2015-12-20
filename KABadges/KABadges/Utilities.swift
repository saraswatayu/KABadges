//
//  Utilities.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/17/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit

final class Utilities {
    
    static func configureUI() {
        // Set Navigation Bar appearance
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.darkGrayColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.darkGrayColor()]
    }
}