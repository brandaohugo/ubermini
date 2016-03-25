//
//  ReviewViewController.swift
//  Uber
//
//  Created by Jan Dukaczewski on 22/03/16.
//  Copyright © 2016 Jan Dukaczewski. All rights reserved.
//

import UIKit
import Foundation

class ReviewViewController: UIViewController {
    var request: Request?
    
    @IBOutlet weak var RatingLabel: UILabel!
    @IBOutlet weak var ReceiptFinalLabel: UILabel!
    @IBOutlet weak var RatingStepper: UIStepper!
    @IBOutlet weak var ReviewSubmitButton: UIButton!
    
    @IBAction func valueChanged(sender: AnyObject) {
        adjustRatingLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePaymentLabel()
    }
    
    func adjustRatingLabel() {
        switch RatingStepper.value {
        case 1: RatingLabel.text = "1 star"
        case 2: RatingLabel.text = "2 stars"
        case 3: RatingLabel.text = "3 stars"
        case 4: RatingLabel.text = "4 stars"
        case 5: RatingLabel.text = "5 stars"
        default: RatingLabel.text = "5 stars"
        }
    }
    
    func makePaymentLabel () {
        let str = NSString(format: "EUR %.2f", (request?.getPriceEstimate())!)
        ReceiptFinalLabel.text = str as String
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        request!.review("", rating: Int(RatingStepper.value))
    }
}