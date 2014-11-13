//
//  RiverDetailViewController.swift
//  WheresTheWater
//
//  Created by Ben Marshall on 05/11/2014.
//  Copyright (c) 2014 Ben Marshall. All rights reserved.
//

import UIKit
import CoreData

class RiverDetailViewController: UIViewController {

    @IBOutlet weak var riverNameLabel: UILabel!
    
    var river: NSManagedObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add River Details
        riverNameLabel.text = river.valueForKey("river") as String?
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
