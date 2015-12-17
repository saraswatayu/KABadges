//
//  Badge.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/16/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData

class Badge: NSManagedObject {

    @NSManaged var title: String
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Badge", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary[BadgeKeys.Title] as! String
        print(title)
    }
}

struct BadgeKeys {
    static let Title = "description"
    static let Description = "safe_extended_description"
}