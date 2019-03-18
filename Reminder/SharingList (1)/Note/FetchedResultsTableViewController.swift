//
//  FetchedResultsTableViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 9/26/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData

/// fetch results table view controller
class FetchedResultsTableViewController: ReminderStandardTableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Methods
    /// Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
    ///
    /// - Parameter controller: controller
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    /// Notifies the receiver of the addition or removal of a section.
    ///
    /// - Parameters:
    ///   - controller: controller
    ///   - sectionInfo: section
    ///   - sectionIndex: index path
    ///   - type: type
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections([sectionIndex], with: .automatic)
        case .delete:
            tableView.deleteSections([sectionIndex], with: .automatic)
        default:
            break
        }
    }
    
    /// Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    ///
    /// - Parameters:
    ///   - controller: controller
    ///   - anObject: anObject
    ///   - indexPath: index path
    ///   - type: type
    ///   - newIndexPath: new index path
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    /// Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
    ///
    /// - Parameter controller: controller
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
