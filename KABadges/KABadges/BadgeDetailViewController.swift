//
//  BadgeDetailViewController.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/17/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit

class BadgeDetailViewController: UIViewController {
    
    var badge: Badge!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = badge.title
        descriptionLabel.text = badge.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
