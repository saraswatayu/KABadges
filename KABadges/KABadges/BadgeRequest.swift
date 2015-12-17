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
                print("Network Error Updating Badges: " + error.description)
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
                    let badge = Badge(dictionary: badgeJSON, context: managedObjectContext)
                }
            }
        } catch let error as NSError {
            print ("Parsing JSON Error: " + error.description)
        }
    }
}