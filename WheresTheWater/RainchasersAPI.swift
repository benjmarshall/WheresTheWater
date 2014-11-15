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
    
    
    class func downloadFullRiverData(in_link:String = "http://api.rainchasers.com/v1/river") {
        
        // Debug
        println(in_link)
        
        // Do the request
        Alamofire.request(.GET, in_link)
            .responseSwiftyJSON { (request, response, json, error) in
                
                // Response handler
                
                // If we get a valid repsonse the process the received data
                let status = json["status"]
                // Debug
                println(status)
                if status == 200 {
                    let data = json["data"]
                    
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
                        
                        
                        // And save the new river to the Rivers Core Data
                        var error: NSError?
                        if !managedContext.save(&error) {
                            // Debug Output
                            println("Could not save river to Core Data")
                        }
                        rivers.append(river)
                    }
                    
                }
                
                // Check for more data and perform next request if needed
                if let out_link = json["meta"]["link"]["next"].string {
                    RainchasersAPI.downloadFullRiverData(in_link: out_link)
                }
                
                
        }
        
        
    }
   
}
