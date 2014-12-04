//
//  RiverTableViewController.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 06/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit
import CoreData

class RiverTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    // Our local copy of the Rivers database to be grabbed from CoreData
    var rivers = [NSManagedObject]()
    // An array for filtered rivers
    var filteredRivers = [NSManagedObject]()
    // An index to tell us which global level filter is currently applied
    var stateScope = 1
    // An array of level options
    let levelOptions = ["Any Level","Not Empty","Scrape","Low","Medium","High","Very High","Huge"]
    // Level filter Button Label
    @IBOutlet weak var levelButtonLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get App Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // Set up Core Data Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "River")
        
        // Fetch Core Data
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        if let results = fetchedResults {
            rivers = results
        } else {
            //Debug Output
            println("Error: failed to fetch Rivers Core Data")
        }
        
        if filteredRivers == [] {
            filteredRivers = rivers
        }

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Do an initial search to start with "not empty" list
        let selectedScope = ""
        let searchText = ""
        filterContentForSearchText(searchText, scope: selectedScope)
        self.tableView.reloadData()
    
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
        return filteredRivers.count

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as RiverUITableViewCell
        
        var river: NSManagedObject
        
        river = filteredRivers[indexPath.row]

        // Cell text to be river name
        cell.titleLabel.text = river.valueForKey("river") as String?
        // Subtext to be grade
        
        var gradeText = river.valueForKey("grade_text") as String
        cell.gradeLabel.text = "Grade \(gradeText)"

        var stateText = river.valueForKey("state_text") as String!
        if stateText == nil {
            stateText = "No Level Data"
        }
        cell.stateLabel.text = stateText

        return cell
    }
    
    func alphabetical(r1: NSManagedObject, r2:NSManagedObject) -> Bool {
        let r1Name = r1.valueForKey("river") as String
        let r2Name = r2.valueForKey("river") as String
        return r1Name < r2Name
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        // Filter the array using the filter method
        self.filteredRivers = self.rivers.filter({( river: NSManagedObject) -> Bool in
            
            // Check global level filter first
            var levelMatch = false
            
            switch self.stateScope {
            case 0:
                levelMatch = true
            case 1:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("Empty") != nil {
                        levelMatch = false
                    } else if levelText.rangeOfString("No Level Data") != nil {
                        levelMatch = false
                    } else {
                        levelMatch = true
                    }
                }
            case 2:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("Scrape") != nil {
                        levelMatch = true
                    }
                }
            case 3:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("Low") != nil {
                        levelMatch = true
                    }
                }
            case 4:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("Medium") != nil {
                        levelMatch = true
                    }
                }
            case 5:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("High") != nil {
                        levelMatch = true
                    }
                }
            case 6:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("Very High") != nil {
                        levelMatch = true
                    }
                }
            case 7:
                if let levelText = (river.valueForKey("state_text")as String?) {
                    if levelText.rangeOfString("Huge") != nil {
                        levelMatch = true
                    }
                }
            default:
                levelMatch = true
                
            }
            
            // Now do text search
            var titleMatch = false
            var gradeMatch = false
            if scope == "Title" {
                if (river.valueForKey("river") as String).rangeOfString(searchText) != nil {
                    titleMatch = true
                }
            } else if scope == "Grade" {
                // Remove spaces from search string in case people type spaces in...
                let searchTextNoSpaces = searchText.stringByReplacingOccurrencesOfString(" ", withString: "")
                // Convert to array of search characters
                let searchArray = Array(searchTextNoSpaces)
                // Search for each character in the grade string
                var gradeNumMatches = 0
                for searchCharacter in searchArray {
                    if (river.valueForKey("grade_text") as String).rangeOfString("\(searchCharacter)") != nil {
                        gradeNumMatches += 1
                    }
                }
                if gradeNumMatches == searchArray.count {
                    gradeMatch = true
                }
            } else {
                titleMatch = true
                gradeMatch = true
            }
            
            return (levelMatch & (titleMatch | gradeMatch))
        
        })
        self.filteredRivers.sort(alphabetical)
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let scopes = searchBar.scopeButtonTitles as [String]
        let scopeIndex = searchBar.selectedScopeButtonIndex as Int!
        let selectedScope = scopes[scopeIndex] as String
        self.filterContentForSearchText(searchText, scope: selectedScope)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

        switch selectedScope {
        case 0 :
            searchBar.text = ""
            searchBar.keyboardType = UIKeyboardType.Default
        case 1:
            searchBar.text = ""
            searchBar.keyboardType = UIKeyboardType.NumbersAndPunctuation
        default:
            searchBar.text = ""
            searchBar.keyboardType = UIKeyboardType.Default
        }
        
        // Force reload of keyboard
        searchBar.resignFirstResponder()
        searchBar.becomeFirstResponder()
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Remove filtered list when exiting the search view to fix crash in segue
        filteredRivers = rivers
        let selectedScope = ""
        let searchText = ""
        filterContentForSearchText(searchText, scope: selectedScope)
        self.tableView.reloadData()
    }
    
    
    // Force filtered cells to correct height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    @IBAction func levelButton(sender: AnyObject) {
        // Add global level filter
        if stateScope < 7 {
            stateScope += 1
        } else {
            stateScope = 0
        }
        levelButtonLabel.title = levelOptions[stateScope]
        
        let selectedScope = ""
        let searchText = ""
        filterContentForSearchText(searchText, scope: selectedScope)
        self.tableView.reloadData()
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
            if let sourceTableView = sourceViewController.tableView.indexPathForSelectedRow()?.row {
                indexPath = sourceViewController.tableView.indexPathForSelectedRow()!.row
                destViewController.river = self.filteredRivers[indexPath]
            } else {
                indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!.row
                destViewController.river = self.filteredRivers[indexPath]
            }
        }
    }

}
