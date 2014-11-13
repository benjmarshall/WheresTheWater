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
        
        
        /*
        // Dummy routine to set up some river data for test!
        
        // Create array of rivers
        let new_rivers = ["Orchy", "Leven", "Garry", "North Esk", "Tummel", "Tay"]
        
        
        // Get App Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // Set up Core Data Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "River")
        
        // Fetch Core Data
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        rivers = fetchedResults!
        
        // Check length of list so we dont keep adding more......
        if  rivers.count < 10 {
        
            // Create blank entity
            let entity = NSEntityDescription.entityForName("River", inManagedObjectContext: managedContext)
            
            // Loop on new rivers array
            for new_river in new_rivers {
            
                // Create a new river object
                let river = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                river.setValue(new_river, forKey: "river")
                
                // And save the new river to the Rivers Core Data
                var error: NSError?
                if !managedContext.save(&error) {
                    // Debug Output
                    println("Could not save river to Core Data")
                }
                rivers.append(river)
            }
        }
        
        */
        
        // Test fetching JSON data from rainchasers!
        RainchasersAPI.downloadFullRiverData()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

