//
//  RainchasersAPI.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 12/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import CoreData


class RainchasersAPI: NSObject {
    

    class func printFirstPageRiverData() {
    
        var data: JSON!
    
        // Do the fetch
        Alamofire.request(.GET, "http://api.rainchasers.com/v1/river")
        .responseSwiftyJSON { (request, response, json, error) in
            data = json
            println(data)
        }

    }
    
    class func capitaliseString(inputString: String) -> String {
        
        let firstLetter = inputString[inputString.startIndex]
        let firstLetterString = "\(firstLetter)"
        let firstLetterCapitalised = firstLetterString.uppercaseString
        let indexOfSecondLetter = advance(inputString.startIndex, 1)
        let remainingLetters = inputString[indexOfSecondLetter..<inputString.endIndex]
        let outputString = firstLetterCapitalised + remainingLetters
        return outputString
    }
    
    class func deleteAllRivers() {
        
        // Debug Output
        println("Deleting all rivers")
        
        // Get App Delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        
        // Set up Core Data Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "River")
        
        // Fetch Core Data
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        var rivers = [NSManagedObject]()
        rivers = fetchedResults!
        
        // Delete all rivers
        for river in rivers {
            managedContext.deleteObject(river)
        }
        
        // And save to Core Data
        if !managedContext.save(&error) {
            // Debug Output
            println("Could not save to Core Data")
        }

        
    }
    
    class func downloadFullRiverData(in_link:String = "http://api.rainchasers.com/v1/river") {
         
        // Do the request
        Alamofire.request(.GET, in_link)
            .responseSwiftyJSON { (request, response, json, error) in
                
                // Response handler
                
                // Get App Delegate
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                
                // If we get a valid repsonse the process the received data
                let status = json["status"]
                // Debug
                //println(status)
                if status == 200 {
                    let data = json["data"]
 
                    // Set up Core Data Fetch Request
                    let fetchRequest = NSFetchRequest(entityName: "River")

                    // Fetch Core Data
                    var error: NSError?
                    let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                    var rivers = [NSManagedObject]()
                    rivers = fetchedResults!
                    
                    // Create blank entity
                    let entity = NSEntityDescription.entityForName("River", inManagedObjectContext: managedContext)
                    
                    // Loop over downloaded rivers
                    for (key: String, subJSON: JSON) in data {
                        
                        // Create a new river object
                        let river = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                        river.setValue(subJSON["uuid"].string, forKey: "uuid")
                        river.setValue(subJSON["url"].string, forKey: "url")
                        river.setValue(subJSON["river"].string, forKey: "river")
                        river.setValue(subJSON["section"].string, forKey: "section")
                        river.setValue(subJSON["desc"].string, forKey: "desc")
                        river.setValue(subJSON["directions"].string, forKey: "directions")
                        river.setValue(subJSON["grade"]["max"].string, forKey: "grade_max")
                        river.setValue(subJSON["grade"]["text"].string, forKey: "grade_text")
                        river.setValue(subJSON["grade"]["value"].string, forKey: "grade_value")
                        river.setValue(subJSON["km"].string, forKey: "km")
                        river.setValue(subJSON["state"]["value"].floatValue, forKey: "state_value")
                        river.setValue(subJSON["state"]["time"].string, forKey: "state_time")
                        if let stateText = subJSON["state"]["text"].string {
                            let stateTextCapitalised = self.capitaliseString(stateText)
                            river.setValue(stateTextCapitalised, forKey: "state_text")
                        }
                        river.setValue(subJSON["state"]["source"]["type"].string, forKey: "state_source_type")
                        river.setValue(subJSON["state"]["source"]["name"].string, forKey: "state_source_name")
                        river.setValue(subJSON["state"]["source"]["value"].floatValue, forKey: "state_source_value")
                        if subJSON["position"][0] != nil {
                            for (key2: String, subJSON2: JSON) in subJSON["position"] {
                                if subJSON2["type"].string == "putin" {
                                    river.setValue(subJSON2["lat"].string, forKey: "putin_lat")
                                    river.setValue(subJSON2["lng"].string, forKey: "putin_lng")
                                }
                                else {
                                    river.setValue(subJSON2["lat"].string, forKey: "takeout_lat")
                                    river.setValue(subJSON2["lng"].string, forKey: "takeout_lng")
                                }
                            }
                        }
                        
                        rivers.append(river)

                    }
                    
                    // And save the new river to the Rivers Core Data
                    if !managedContext.save(&error) {
                        // Debug Output
                        println("Could not save river to Core Data")
                    }
                    
                }
                
                // Check for more data and perform next request if needed
                if let out_link = json["meta"]["link"]["next"].string {
                    RainchasersAPI.downloadFullRiverData(in_link: out_link)
                } else {
                    
                    // Create refresh link
                    let update_link = json["meta"]["link"]["resume"].string
                    
                    // Set up Core Data Fetch Request
                    let fetchRequest = NSFetchRequest(entityName: "DB_stats")
                    
                    // Fetch Core Data
                    var error: NSError?
                    let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                    var db_stats = [NSManagedObject]()
                    
                    if let results = fetchedResults {
                        db_stats = results
                        if db_stats.count > 0 {
                            db_stats[0].setValue(NSDate(), forKey: "full_update_time")
                            //Debug Output
                            println(NSDate())
                            println(update_link)
                            db_stats[0].setValue(update_link, forKey: "resume_link")
                        } else {
                            //Debug Output
                            println("No DB stats yet")
                            
                            // Create blank entity
                            let entity = NSEntityDescription.entityForName("DB_stats", inManagedObjectContext: managedContext)
                            
                            // Create a new river object
                            let db_stat = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                            db_stat.setValue(NSDate(), forKey: "full_update_time")
                            //Debug Output
                            println(NSDate())
                            println(update_link)
                            db_stat.setValue(update_link, forKey: "resume_link")
                            db_stats.append(db_stat)
                        }
                        // And save to Core Data
                        var error: NSError?
                        if !managedContext.save(&error) {
                            // Debug Output
                            println("Could not save to Core Data")
                        }

                    } else {
                        //Debug Output
                        println("Failed to fetch database")
                    }
                    
                    // Debug
                    println("Fetch Complete")
                    
                }
                
                
        }
        
    }
    
    class func downloadUpdateRiverData(in_link:String) {
        
       
        // Do the request
        Alamofire.request(.GET, in_link)
            .responseSwiftyJSON { (request, response, json, error) in
                
                // Response handler
                
                // Get App Delegate
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                
                // If we get a valid repsonse the process the received data
                let status = json["status"]
                // Debug
                println(status)
                if status == 200 {
                    let data = json["data"]
                    
                    // Loop over downloaded rivers
                    for (key: String, subJSON: JSON) in data {
                        
                        // Set up Core Data Fetch Request
                        let fetchRequest = NSFetchRequest(entityName: "River")
                        let uuid = subJSON["uuid"].stringValue as String
                        println(uuid)
                        let fetchPredicate = NSPredicate(format: "uuid = %s", uuid)
                        fetchRequest.predicate = fetchPredicate
                        
                        // Fetch Core Data
                        var error: NSError?
                        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                        var rivers = [NSManagedObject]()
                        rivers = fetchedResults!
                        
                        if rivers.count > 0 {
                            
                            //Debug Output
                            println("Updating River")
                            
                            let river = rivers[0]

                            river.setValue(subJSON["uuid"].string, forKey: "uuid")
                            river.setValue(subJSON["url"].string, forKey: "url")
                            river.setValue(subJSON["river"].string, forKey: "river")
                            river.setValue(subJSON["section"].string, forKey: "section")
                            river.setValue(subJSON["desc"].string, forKey: "desc")
                            river.setValue(subJSON["directions"].string, forKey: "directions")
                            river.setValue(subJSON["grade"]["max"].string, forKey: "grade_max")
                            river.setValue(subJSON["grade"]["text"].string, forKey: "grade_text")
                            river.setValue(subJSON["grade"]["value"].string, forKey: "grade_value")
                            river.setValue(subJSON["km"].string, forKey: "km")
                            river.setValue(subJSON["state"]["value"].floatValue, forKey: "state_value")
                            river.setValue(subJSON["state"]["time"].string, forKey: "state_time")
                            if let stateText = subJSON["state"]["text"].string {
                                let stateTextCapitalised = self.capitaliseString(stateText)
                                river.setValue(stateTextCapitalised, forKey: "state_text")
                            }
                            river.setValue(subJSON["state"]["source"]["type"].string, forKey: "state_source_type")
                            river.setValue(subJSON["state"]["source"]["name"].string, forKey: "state_source_name")
                            river.setValue(subJSON["state"]["source"]["value"].floatValue, forKey: "state_source_value")
                            if subJSON["position"][0] != nil {
                                for (key2: String, subJSON2: JSON) in subJSON["position"] {
                                    if subJSON2["type"].string == "putin" {
                                        river.setValue(subJSON2["lat"].string, forKey: "putin_lat")
                                        river.setValue(subJSON2["lng"].string, forKey: "putin_lng")
                                    }
                                    else {
                                        river.setValue(subJSON2["lat"].string, forKey: "takeout_lat")
                                        river.setValue(subJSON2["lng"].string, forKey: "takeout_lng")
                                    }
                                }
                            }
                            
                        } else {
                            
                            //Debug Output
                            println("Adding River")
                            
                            // Create blank entity
                            let entity = NSEntityDescription.entityForName("River", inManagedObjectContext: managedContext)
                            
                            // Create a new river object
                            let river = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                            river.setValue(subJSON["uuid"].string, forKey: "uuid")
                            river.setValue(subJSON["url"].string, forKey: "url")
                            river.setValue(subJSON["river"].string, forKey: "river")
                            river.setValue(subJSON["section"].string, forKey: "section")
                            river.setValue(subJSON["desc"].string, forKey: "desc")
                            river.setValue(subJSON["directions"].string, forKey: "directions")
                            river.setValue(subJSON["grade"]["max"].string, forKey: "grade_max")
                            river.setValue(subJSON["grade"]["text"].string, forKey: "grade_text")
                            river.setValue(subJSON["grade"]["value"].string, forKey: "grade_value")
                            river.setValue(subJSON["km"].string, forKey: "km")
                            river.setValue(subJSON["state"]["value"].floatValue, forKey: "state_value")
                            river.setValue(subJSON["state"]["time"].string, forKey: "state_time")
                            if let stateText = subJSON["state"]["text"].string {
                                let stateTextCapitalised = self.capitaliseString(stateText)
                                river.setValue(stateTextCapitalised, forKey: "state_text")
                            }
                            river.setValue(subJSON["state"]["source"]["type"].string, forKey: "state_source_type")
                            river.setValue(subJSON["state"]["source"]["name"].string, forKey: "state_source_name")
                            river.setValue(subJSON["state"]["source"]["value"].floatValue, forKey: "state_source_value")
                            if subJSON["position"][0] != nil {
                                for (key2: String, subJSON2: JSON) in subJSON["position"] {
                                    if subJSON2["type"].string == "putin" {
                                        river.setValue(subJSON2["lat"].string, forKey: "putin_lat")
                                        river.setValue(subJSON2["lng"].string, forKey: "putin_lng")
                                    }
                                    else {
                                        river.setValue(subJSON2["lat"].string, forKey: "takeout_lat")
                                        river.setValue(subJSON2["lng"].string, forKey: "takeout_lng")
                                    }
                                }
                            }
                            rivers.append(river)
                        }
                        
                    }
                    // And save the new river to the Rivers Core Data
                    var error: NSError?
                    if !managedContext.save(&error) {
                        // Debug Output
                        println("Could not save river to Core Data")
                    }
                    
                }
                
                // Check for more data and perform next request if needed
                if let out_link = json["meta"]["link"]["next"].string {
                    RainchasersAPI.downloadUpdateRiverData(out_link)
                } else {
                    let update_link = json["meta"]["link"]["resume"].string
                    
                    // Set up Core Data Fetch Request
                    let fetchRequest = NSFetchRequest(entityName: "DB_stats")
                    
                    // Fetch Core Data
                    var error: NSError?
                    let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                    var db_stats = [NSManagedObject]()
                    
                    if let results = fetchedResults {
                        db_stats = results
                        if db_stats.count > 0 {
                            db_stats[0].setValue(NSDate(), forKey: "update_time")
                            //Debug Output
                            println(NSDate())
                            println(update_link)
                            db_stats[0].setValue(update_link, forKey: "resume_link")
                        } else {
                            //Debug Output
                            println("No DB stats yet")
                            
                            // Create blank entity
                            let entity = NSEntityDescription.entityForName("DB_stats", inManagedObjectContext: managedContext)
                            
                            // Create a new river object
                            let db_stat = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                            db_stat.setValue(NSDate(), forKey: "update_time")
                            //Debug Output
                            println(NSDate())
                            println(update_link)
                            db_stat.setValue(update_link, forKey: "resume_link")
                            db_stats.append(db_stat)
                        }
                        // And save to Core Data
                        var error: NSError?
                        if !managedContext.save(&error) {
                            // Debug Output
                            println("Could not save to Core Data")
                        }

                    } else {
                        //Debug Output
                        println("Failed to fetch database")
                    }
                    
                }
                
                
        }
        
        
    }
   
}
