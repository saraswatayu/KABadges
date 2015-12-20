//
//  Category.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/18/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData
import Nuke

class Category: NSManagedObject {
    
    @NSManaged var title: String
    @NSManaged var extendedDescription: String
    @NSManaged var category: NSNumber
    @NSManaged var identifier: String
    
    @NSManaged var iconUrl: String
    @NSManaged var iconImage: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        updateCategoryInfo(dictionary)
    }
    
    func updateCategoryInfo(dictionary: [String : AnyObject]) {
        title = dictionary[CategoryKeys.Title] as! String
        extendedDescription = dictionary[CategoryKeys.Description] as! String
        iconUrl = dictionary[CategoryKeys.Icon] as! String
        category = dictionary[CategoryKeys.Category] as! NSNumber
        identifier = dictionary[CategoryKeys.Title] as! String
    }
    
    func getIconImage(completionHandler: (image: UIImage?) -> ()) {
        if let iconImage = iconImage {
            completionHandler(image: UIImage(data: iconImage))
        } else {
            Nuke.taskWithURL(NSURL(string: self.iconUrl)!) {
                completionHandler(image: $0.image)
                if let icon = $0.image {
                    self.iconImage = UIImagePNGRepresentation(icon)
                }
            }.resume()
        }
    }
}

struct CategoryKeys {
    static let Title = "type_label"
    static let Category = "category"
    static let Icon = "icon_src"
    static let Description = "description"
    
    static let requiredProperties = [Title, Category, Icon, Description]
}