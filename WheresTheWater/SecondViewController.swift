//
//  SecondViewController.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 04/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Our Table View
    @IBOutlet var tableView: UITableView!

    // Our local copy of the Rivers database to be grabbed from CoreData
    var rivers = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Table Data Source
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // How many rivers?
        return rivers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Queue rivers into cells
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let river = rivers[indexPath.row]
        // Cell text to be river name
        cell.textLabel.text = river.valueForKey("name") as String?
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("RiverDetailSegue", sender: indexPath.row)
        println("didselectrow")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RiverDetailSegue" {
            var destViewController = segue.destinationViewController as RiverDetailViewController
            var indexPath = sender as Int
            destViewController.river = self.rivers[indexPath]
            println("didpreparesegue")
        }
    }

   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

