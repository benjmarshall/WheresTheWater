//
//  RiverTableViewController.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 06/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit
import CoreData

class RiverTableViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // Our local copy of the Rivers database to be grabbed from CoreData
    var rivers = [NSManagedObject]()
    // An array for filtered rivers
    var filteredRivers = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get App Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // Set up Core Data Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "River")
        //let fetchPredicate = NSPredicate(format: "river contains %s", "Dee")
        //fetchRequest.predicate = fetchPredicate
        
        // Fetch Core Data
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            rivers = results
        } else {
            //Debug Output
            println("Error: failed to fetch Rivers Core Data")
        }


        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Added to fix bug which keeps cell selected when swiping back from detail view
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let tableSelection = self.tableView.indexPathForSelectedRow()
        if tableSelection != nil {
            self.tableView.deselectRowAtIndexPath(tableSelection!, animated: animated)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        // How many rivers?
        if tableView == self.searchDisplayController!.searchResultsTableView {
            // Filtered List
            return filteredRivers.count
        } else {
            // Full List
            return rivers.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as RiverUITableViewCell
        
        var river: NSManagedObject
        
        // Check to to see if we are filtering
        if tableView == self.searchDisplayController!.searchResultsTableView {
            river = filteredRivers[indexPath.row]
        } else {
           river = rivers[indexPath.row]
        }
        
        // Cell text to be river name
        cell.textLabel.text = river.valueForKey("river") as String?
        // Subtext to be grade
        var stateText = river.valueForKey("state_text") as String!
        if stateText == nil {
            stateText = "No Level Data"
        }
        let gradeText = river.valueForKey("grade_text") as String
        cell.detailTextLabel?.text = "Grade \(gradeText) - \(stateText)"
        // Set background colour
        //cell.backgroundColor == UIColor.greenColor()
        //cell.contentView.backgroundColor = UIColor.greenColor()
        cell.stateLabel.text = stateText

        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        // Filter the array using the filter method
        self.filteredRivers = self.rivers.filter({( river: NSManagedObject) -> Bool in
            //let categoryMatch = (scope == "All") || (river.valueForKey("river") == scope)
            if scope == "Title" {
                let titleMatch = (river.valueForKey("river") as String).rangeOfString(searchText)
                return titleMatch != nil
            } else {
                let gradeMatch = (river.valueForKey("grade_text") as String).rangeOfString(searchText)
                return gradeMatch != nil
            }
            //return categoryMatch && (stringMatch != nil)
            
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        let scopes = self.searchDisplayController?.searchBar.scopeButtonTitles as [String]
        let scopeIndex = self.searchDisplayController?.searchBar.selectedScopeButtonIndex as Int!
        let selectedScope = scopes[scopeIndex] as String
        self.filterContentForSearchText(searchString, scope: selectedScope)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let scope = self.searchDisplayController?.searchBar.scopeButtonTitles as [String]
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text, scope: scope[searchOption])
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Remove filtered list when exiting the search view to fix crash in segue
        filteredRivers = []
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "RiverDetailSegue" {
            var destViewController = segue.destinationViewController as RiverDetailViewController
            var sourceViewController = segue.sourceViewController as RiverTableViewController
            var indexPath: Int
            if self.filteredRivers.count > 0 {
                indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!.row
                destViewController.river = self.filteredRivers[indexPath]
            } else {
                indexPath = sourceViewController.tableView.indexPathForSelectedRow()!.row
                destViewController.river = self.rivers[indexPath]
            }
        }
    }

}
