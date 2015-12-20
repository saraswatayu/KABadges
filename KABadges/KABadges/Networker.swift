//
//  Request.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/18/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData

final class Networker : NSObject {
    
    static let sharedInstance = Networker()
    
    let session: NSURLSession = NSURLSession.sharedSession()
    let managedObjectContext: NSManagedObjectContext
    
    override init() {
        managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.parentContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("managedObjectContextDidSave:"), name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    // save main context's data each time this context has updates
    func managedObjectContextDidSave(notification: NSNotification) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
    }
    
    // update all data
    func update(path: String, type: AnyObject, completionHandler: (() -> ())? = nil) {
        guard let url = NSURL(string: path) else { return }
        guard type is Badge.Type || type is Category.Type else { return }

        // get data
        session.dataTaskWithURL(url, completionHandler: { data, response, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                let identifier = (type is Badge.Type) ? BadgeKeys.Identifier : CategoryKeys.Title
                
                // if there's an error fetching from online, and we don't have any data
                // use local store to add some data
                self.doesExist(nil, type: type, identifier: identifier, completionHandler: { existing in
                    if existing == nil {
                        let fileName = (type is Badge.Type) ? "KABadges" : "KABadgeCategories"
                        if let url = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
                            if let data = NSData(contentsOfFile: url) {
                                self.decodeJSON(data, type: type)
                            }
                        }
                    }
                    completionHandler?()
                })
            } else if let data = data {
                self.decodeJSON(data, type: type)
                completionHandler?()
            }
        }).resume()
    }
    
    private func decodeJSON(json: NSData, type: AnyObject) {
        do {
            if let result = try NSJSONSerialization.JSONObjectWithData(json, options: .AllowFragments) as? [[String : AnyObject]] {
                self.parseJSON(result, type: type)
                self.managedObjectContext.performBlock({
                    let _  = try? self.managedObjectContext.save()
                })
            }
        } catch let error as NSError {
            print("Parsing JSON Error: \(error.localizedDescription)")
        }
    }
    
    private func parseJSON(json: [[String : AnyObject]], type: AnyObject) {
        for object in json {
            let requiredProperties = (type is Badge.Type) ? BadgeKeys.requiredProperties : CategoryKeys.requiredProperties
            if validateResult(object, requiredKeys: requiredProperties) {
                let identifier = (type is Badge.Type) ? BadgeKeys.Identifier : CategoryKeys.Title
                doesExist(object, type: type, identifier: identifier, completionHandler: { existing in
                    if let existing = existing {
                        // update existing objects 
                        
                        if type is Badge.Type {
                            (existing as! Badge).updateBadgeInfo(object)
                        } else {
                            (existing as! Category).updateCategoryInfo(object)
                        }
                    } else {
                        // create new objects since they don't already exist
                        
                        if type is Badge.Type {
                            self.managedObjectContext.performBlock({
                                let _ = Badge(dictionary: object, context: self.managedObjectContext)
                            })
                        } else {
                            self.managedObjectContext.performBlock({
                                let _ = Category(dictionary: object, context: self.managedObjectContext)
                            })
                        }
                    }
                })
            }
        }
    }
    
    // checks to ensure JSON contains all values we need
    private func validateResult(result: [String : AnyObject], requiredKeys: [String]) -> Bool {
        for key in requiredKeys {
            if result[key] == nil {
                return false
            }
        }
        return true
    }
    
    // useful for checking if any objects exist
    // or if an object of a particular identifier exists
    // ensures duplicates aren't created, and updates old badges/categories
    private func doesExist(result: [String : AnyObject]?, type: AnyObject, identifier: String, completionHandler: (AnyObject?) -> ()) {
        let fetchRequest = NSFetchRequest(entityName: (type is Badge.Type) ? "Badge" : "Category")
        if let result = result {
            fetchRequest.predicate = NSPredicate(format: "identifier == \"\(result[identifier] as! String)\"")
        }
        
        var results: [AnyObject]? = nil
        self.managedObjectContext.performBlock({
            do {
                results = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                completionHandler(results?.first)
            } catch let error as NSError {
                print("Error Fetching First Object: \(error.localizedDescription)")
                completionHandler(nil)
            }
        })
    }
}