//
//  ViewController.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/16/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        BadgeRequest.sharedInstance.updateBadges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

