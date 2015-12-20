//
//  Badge.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/16/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData
import Nuke

class Badge: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var title: String
    @NSManaged var extendedDescription: String
    @NSManaged var category: NSNumber
    
    @NSManaged var iconUrl: String
    @NSManaged var iconImage: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Badge", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        updateBadgeInfo(dictionary)
        
        if iconImage == nil {
            Nuke.taskWithURL(NSURL(string: self.iconUrl)!) {
                if let icon = $0.image {
                    self.iconImage = UIImagePNGRepresentation(icon)
                    do {
                        try context.save()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            }.resume()
        }
    }
    
    func updateBadgeInfo(dictionary: [String : AnyObject]) {
        identifier = dictionary[BadgeKeys.Identifier] as! String
        title = dictionary[BadgeKeys.Title] as! String
        extendedDescription = dictionary[BadgeKeys.Description] as! String
        iconUrl = (dictionary["icons"] as! [String: AnyObject])["large"] as! String
        category = dictionary[BadgeKeys.Category] as! Int
    }
    
    func getIconImage(completionHandler: (image: UIImage?) -> ()) {
        if let iconImage = iconImage {
            completionHandler(image: UIImage(data: iconImage))
        } else {
            completionHandler(image: nil)
        }
    }
}

struct BadgeKeys {
    static let Identifier = "name"
    static let Title = "description"
    static let Description = "safe_extended_description"
    static let Icon = "icon_src"
    static let Category = "badge_category"
    
    static let requiredProperties = [Identifier, Title, Description, Icon, Category]
}