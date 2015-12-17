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

    @NSManaged var identifier: String
    @NSManaged var title: String
    @NSManaged var extendedDescription: String
    @NSManaged var category: NSNumber
    @NSManaged private var icon: NSData
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Badge", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        updateBadgeInfo(dictionary)
    }
    
    func updateBadgeInfo(dictionary: [String : AnyObject]) {
        identifier = dictionary[BadgeKeys.Identifier] as! String
        title = dictionary[BadgeKeys.Title] as! String
        extendedDescription = dictionary[BadgeKeys.Description] as! String
//        icon = NSData(contentsOfFile: dictionary[BadgeKeys.Icon] as! String)!
        category = dictionary[BadgeKeys.Category] as! Int
        print(category)
    }
    
    func getIcon() -> UIImage {
        return UIImage(data: icon)!
    }
}


struct BadgeKeys {
    static let Identifier = "name"
    static let Title = "description"
    static let Description = "safe_extended_description"
    static let Icon = "icon_src"
    static let Category = "badge_category"
}