//
//  RequestViewController.swift
//  Uber
//
//  Created by Jan Dukaczewski on 21/03/16.
//  Copyright © 2016 Jan Dukaczewski. All rights reserved.
//

import UIKit
import Foundation

class RequestViewController: UIViewController {
    @IBOutlet weak var EstimateLabel: UILabel!
    @IBOutlet weak var DriverLabel: UILabel!
    @IBOutlet weak var RatingLabel: UILabel!
    @IBOutlet weak var CarLabel: UILabel!
    @IBOutlet weak var LicensePlateLabel: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    var request: Request?
    
    var estimate: Double = 0
    var driver: String = ""
    var rating: Double = 0
    var car: String = ""
    var licensePlate: String = ""
    var phoneNumberText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimate = request!.getPriceEstimate()
        driver = request!.getDriver().getName()
        rating = request!.getDriver().getRating()
        car = "\(request!.getDriver().getVehicle().getMake()) \(request!.getDriver().getVehicle().getModel())"
        licensePlate = request!.getDriver().getVehicle().getLicense()
        phoneNumberText = request!.getDriver().getPhoneNumber()
        
        makeLabels()
    }
    
    func makeLabels() {
        let deltaEstimate = 0.15*estimate
        let lowerEstimate = Int(estimate-deltaEstimate)
        let upperEstimate = Int(estimate+deltaEstimate)
        
        let estimateLabelText = NSString(format: "EUR %d-%d", lowerEstimate, upperEstimate)
        let driverRatingLabel = NSString(format: "%.2f stars", rating)
        
        EstimateLabel.text = estimateLabelText as String
        DriverLabel.text = driver
        RatingLabel.text = driverRatingLabel as String
        CarLabel.text = car
        LicensePlateLabel.text = licensePlate
        phoneNumber.text = phoneNumberText
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewInProgress" {
            let inProgressViewController = segue.destinationViewController as?  InProgressViewController
            inProgressViewController!.request = request
        }
    }
}