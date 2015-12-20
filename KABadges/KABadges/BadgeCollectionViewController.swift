//
//  BadgeCollectionViewController.swift
//  KABadges
//
//  Created by Ayush Saraswat on 12/17/15.
//  Copyright © 2015 Ayush Saraswat. All rights reserved.
//

import UIKit
import CoreData

class BadgeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

    private var managedObjectContext: NSManagedObjectContext
    private var selectedIndex: NSIndexPath?
    
    private var sectionChanges: [(NSFetchedResultsChangeType, NSIndexSet)]?
    private var rowChanges: [(NSFetchedResultsChangeType, NSIndexPath)]?

    required init?(coder aDecoder: NSCoder) {
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let _ = try? self.fetchedResultsController.performFetch()
        self.fetchedResultsController.delegate = self
    }
    
    // MARK: Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Badge")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "category", ascending: true), NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    // initialize changes array
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        sectionChanges = [(NSFetchedResultsChangeType, NSIndexSet)]()
        rowChanges = [(NSFetchedResultsChangeType, NSIndexPath)]()
    }
    
    // add section changes to array
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        sectionChanges?.append((type, NSIndexSet(index: sectionIndex)))
    }
    
    // add row changes to array
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type{
        case .Insert:
            rowChanges?.append((type, newIndexPath!))
            break
        case .Delete:
            rowChanges?.append((type, indexPath!))
            break
        case .Update:
            rowChanges?.append((type, indexPath!))
            break
        default:
            break
        }
    }
    
    // reload all section and row changes at once
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.collectionView?.performBatchUpdates({() -> Void in
            for change in self.sectionChanges! {
                switch (change) {
                case (.Insert, let indexSet):
                    self.collectionView?.insertSections(indexSet)
                    break
                case (.Update, let indexSet):
                    self.collectionView?.reloadSections(indexSet)
                    break
                case (.Delete, let indexSet):
                    self.collectionView?.deleteSections(indexSet)
                    break
                default:
                    break
                }
            }
            
            for change in self.rowChanges! {
                switch (change) {
                case (.Insert, let indexPath):
                    self.collectionView?.insertItemsAtIndexPaths([indexPath])
                case (.Update, let indexPath):
                    self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                case (.Delete, let indexPath):
                    self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                default:
                    break
                }
            }
        }, completion: nil)
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections![section].numberOfObjects
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = (selectedIndex == indexPath) ? "BadgeSelectedCell" : "BadgeCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! BadgeCollectionViewCell
    
        let badge = fetchedResultsController.objectAtIndexPath(indexPath) as! Badge
        cell.configureForBadge(badge)
    
        return cell
    }
    
    // display header which shows category name
    // category name is fetched each time header needs to be replaced
    // to-do: cache category names so fetches aren't required each time
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! BadgeCollectionHeaderView
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.predicate = NSPredicate(format: "category == \(indexPath.section)")
        
        do {
            let category = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Category]
            if let category = category {
                headerView.title.text = category.first!.title
            }
        } catch let error as NSError {
            print("Error Fetching Categories: \(error.localizedDescription)")
        }

        return headerView
    }

    // MARK: UICollectionViewDelegate

    // reload selected cell + old selected cell to reflect size/content change
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var reloadPaths = [indexPath]
        if let selectedIndex = selectedIndex where selectedIndex != indexPath { reloadPaths.append(selectedIndex) }
        selectedIndex = indexPath
        
        collectionView.reloadItemsAtIndexPaths(reloadPaths)
    }
    
    // make selected cell take up full screen width to show description, etc.
    // otherwise, set layout to be 3-column with space for badge name
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if  selectedIndex == indexPath {
            return CGSize(width: self.collectionView!.frame.size.width - 16, height: ((self.collectionView!.frame.size.width - 36) / 3))
        }
        return CGSize(width: (self.collectionView!.frame.size.width - 36) / 3, height: ((self.collectionView!.frame.size.width - 36) / 3) + 60)
    }
}