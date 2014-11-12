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


class RainchasersAPI: NSObject {
    

    class func fetchFullRiverData() {
    
        var data: JSON!
    
        // Do the fetch
        Alamofire.request(.GET, "http://api.rainchasers.com/v1/river")
        .responseSwiftyJSON { (request, response, json, error) in
            data = json
            println(data)
        }

    }
   
}
