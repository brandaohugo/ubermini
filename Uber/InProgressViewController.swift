//
//  InProgressViewController.swift
//  Uber
//
//  Created by Jan Dukaczewski on 22/03/16.
//  Copyright © 2016 Jan Dukaczewski. All rights reserved.
//

import Foundation
import UIKit

class InProgressViewController: UIViewController {
    
    var request: Request?
    
    override func viewDidLoad () {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let reviewViewController = segue.destinationViewController as! ReviewViewController
        reviewViewController.request = request
    }
}