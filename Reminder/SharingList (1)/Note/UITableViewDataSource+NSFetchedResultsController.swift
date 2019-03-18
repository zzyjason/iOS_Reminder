//
//  UITableViewDataSource+NSFetchedResultsController.swift
//  Reminder
//
//  Created by Yijia Huang on 9/26/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData

// MARK: - extension of note table view controller
extension SharingListNotesTableViewController {
    
    // MARK : - UITableViewDataSource
    
    /// Asks the data source to return the number of sections in the table view.
    ///
    /// - Parameter tableView: table view
    /// - Returns: number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section
    /// - Returns: number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fbList != nil {
            return fbnotes.count
        } else {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        }
    }
    
    /// Asks the data source for the title of the footer of the specified section of the table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section
    /// - Returns: title of section
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    /// Asks the data source to return the titles for the sections for a table view.
    ///
    /// - Parameter tableView: table view
    /// - Returns: titles of section
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    /// Asks the data source to return the index of the section having the given title and section title index.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - title: title
    ///   - index: index
    /// - Returns: section for index title
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
}
