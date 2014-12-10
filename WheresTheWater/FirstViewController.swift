//
//  FirstViewController.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 04/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class FirstViewController: UIViewController {
    
    var rivers = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
               
        // Get App Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // Set up Core Data Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "DB_stats")
        
        // Fetch Core Data
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        var db_stats = [NSManagedObject]()
        
        if let results = fetchedResults {
            db_stats = results
            
            // Check any DB stats are stored
            if db_stats.isEmpty {
                // Do a full update
                //Debug Output
                println("No data found")
                println("Full Download Started")
                RainchasersAPI.deleteAllRivers()
                RainchasersAPI.downloadFullRiverData()
            } else {
                // Fetch latest full update time
                let fullUpdateTime = db_stats[0].valueForKey("full_update_time") as NSDate
                // Debug
                println("Full update time = \(fullUpdateTime)")
                // Create comparison times (1 week)
                let compareFullTime = NSDate(timeInterval: -604800, sinceDate: NSDate())
                let compareFullResult = fullUpdateTime.compare(compareFullTime)
                
                // First check to see if last full update was over 1 week ago
                if compareFullResult == NSComparisonResult.OrderedAscending {
                    // Do a full update
                    //Debug Output
                    println("Full Download Started")
                    RainchasersAPI.deleteAllRivers()
                    RainchasersAPI.downloadFullRiverData()
                }
                else {
                    // Check if we have ever done a refresh
                    if let updateTime = db_stats[0].valueForKey("update_time") as NSDate? {
                        // Create comparison times (15 mins)
                        let comapreTime = NSDate(timeInterval: -900, sinceDate: NSDate())
                        let compareResult = updateTime.compare(comapreTime)
                        
                        // Check to see if last update was more than 15 mins ago
                        if compareResult == NSComparisonResult.OrderedAscending {
                            // Do refresh
                            let updateLink = db_stats[0].valueForKey("resume_link") as String
                            //Debug Output
                            println("Refresh Started")
                            // Do Update
                            RainchasersAPI.downloadUpdateRiverData(updateLink)
                        } else {
                            //Debug Output
                            println("No refresh needed")
                        }
                    } else {
                        // No prevous refresh so best do one now!
                        //Debug Output
                        println("No previous refresh")
                        println("Refresh Started")
                        // Do Update
                        let updateLink = db_stats[0].valueForKey("resume_link") as String
                        RainchasersAPI.downloadUpdateRiverData(updateLink)
                    }
                }
            }
            
        } else {
            //Debug Output
            println("Failed to fetch database")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

