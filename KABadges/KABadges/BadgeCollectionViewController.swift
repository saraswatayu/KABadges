//
//  BadgeCollectionViewController.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/17/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData

class BadgeCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

    private let managedObjectContext: NSManagedObjectContext

    required init?(coder aDecoder: NSCoder) {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = try? fetchedResultsController.performFetch()
        fetchedResultsController.delegate = self
        
        BadgeRequest.sharedInstance.updateBadges()
    }
    
    // MARK: Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Badge")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.collectionView?.insertSections(NSIndexSet(index: sectionIndex))
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
        case .Update:
            self.collectionView?.reloadItemsAtIndexPaths([indexPath!])
        default:
            return
        }
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BadgeCell", forIndexPath: indexPath) as! BadgeCollectionViewCell
    
        let badge = fetchedResultsController.objectAtIndexPath(indexPath) as! Badge
        cell.configureForBadge(badge)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let badge = fetchedResultsController.objectAtIndexPath(indexPath) as! Badge
        performSegueWithIdentifier("BadgeDetail", sender: badge)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "BadgeDetail" else { return }
        guard let sender = sender else { return }
        
        let badge = sender as! Badge
        
        let detail = segue.destinationViewController as! BadgeDetailViewController
        detail.badge = badge
    }
}
