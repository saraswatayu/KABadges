//
//  BadgeRequest.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/16/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData

class BadgeRequest {
    
    static let sharedInstance = BadgeRequest()

    private let session: NSURLSession
    private let managedObjectContext: NSManagedObjectContext
    
    init() {
        session = NSURLSession.sharedSession()
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func updateBadges() {
        guard let url = NSURL(string: "http://www.khanacademy.org/api/v1/badges") else { return }

        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            if let error = error {
                
                // if we don't have internet, and no badges are loaded, load them from the local JSON
                if error.code == -1009 {
                    if self.checkForExistingBadge() == nil {
                        if let filePath = NSBundle.mainBundle().pathForResource("KABadges", ofType: "json") {
                            if let jsonData = NSData(contentsOfFile: filePath) {
                                self.parseBadgeJSON(jsonData)
                            }
                        }
                    }
                }
                print("Network Error Updating Badges: \(error.code)")
            } else if let data = data {
                self.parseBadgeJSON(data)
            }
        })
        task.resume()
    }
    
    func parseBadgeJSON(data: NSData) {
        do {
            if let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [[String : AnyObject]] {
                for badgeJSON in result {
                    if validateBadgeJSON(badgeJSON) {
                        if let existingBadge = checkForExistingBadge(badgeJSON) {
                            existingBadge.updateBadgeInfo(badgeJSON)
                        } else {
                            let _ = Badge(dictionary: badgeJSON, context: self.managedObjectContext)
                        }
                        
                        do {
                            try self.managedObjectContext.save()
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        } catch let error as NSError {
            print ("Parsing JSON Error: " + error.description)
        }
    }
    
    func validateBadgeJSON(badgeJSON: [String : AnyObject]) -> Bool {
        guard let _ = badgeJSON[BadgeKeys.Identifier] as? String,
              let _ = badgeJSON[BadgeKeys.Title] as? String,
              let _ = badgeJSON[BadgeKeys.Description] as? String,
              let _ = badgeJSON[BadgeKeys.Icon] as? String,
              let _ = badgeJSON[BadgeKeys.Category] as? Int else { return false }
        return true
    }
    
    // Ensures that there are no duplicate badges
    // If the badgeJSON is nil, it can be used to check if any badges exist (first-time loading w/o internet connection)
    func checkForExistingBadge(badgeJSON: [String : AnyObject]? = nil) -> Badge? {
        let fetchRequest = NSFetchRequest(entityName: "Badge")
        
        if let badge = badgeJSON {
//            fetchRequest.predicate = NSPredicate(format: "identifier == \(badge[BadgeKeys.Identifier])")
            return nil
        }
        
        do {
            let results = try self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Badge]
            if let results = results where results.count > 0 {
                return results.first!
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return nil
    }
}