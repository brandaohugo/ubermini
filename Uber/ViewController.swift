//
//  ViewController.swift
//  Uber
//
//  Created by Jan Dukaczewski on 18/03/16.
//  Copyright © 2016 Jan Dukaczewski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var originField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    @IBOutlet weak var RequestButton: UIButton!
    @IBOutlet weak var serviceButtonX: UIButton!
    @IBOutlet weak var serviceButtonBLACK: UIButton!
    @IBOutlet weak var serviceButtonVAN: UIButton!
    @IBOutlet weak var ConfirmRequestButton: UIButton!
    @IBOutlet weak var RequestInfoLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    var locationTuples: [(textField: UITextField!, mapItem: MKMapItem?)]!
    
    var locationsArray: [(textField: UITextField!, mapItem: MKMapItem?)] {
        let locations = locationTuples.filter({$0.mapItem != nil})
        return locations
    }
    
    var productType: Int = 0 //0 = "UberX", 1 = "UberBLACK", 2 = "UberVAN". UberX is the default service
    var visa: PaymentMethod = Card(iban: "", cvv: "", name: "", expirationDate: "")
    var service: Service = Service(dataFile: "Service")
    var routeLengthInKm = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTuples = [(originField, nil), (destinationField, nil)]
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
            
                if locationManager.location != nil {
                centerMapOnLocation(locationManager.location!)
            }
        }
        
        ConfirmRequestButton.hidden = true
        RequestInfoLabel.hidden = true
        activityIndicator.hidden = true
    }
    
    @IBAction func originEntered(sender: UITextField) {
        view.endEditing(true)
        CLGeocoder().geocodeAddressString(sender.text!,
            completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let placemarks = placemarks {
                    var addresses = [String]()
                    for placemark in placemarks {
                        addresses.append(self.formatAddressFromPlacemark(placemark))
                    }
                    self.showAddressTable(addresses,
                        placemarks:placemarks, sender: sender)
                } else {
                    self.showAlert("Address not found.")
                }
        })
    }
    
    @IBAction func destinationEntered(sender: UITextField) {
        view.endEditing(true)
        CLGeocoder().geocodeAddressString(sender.text!,
            completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                if let placemarks = placemarks {
                    var addresses = [String]()
                    for placemark in placemarks {
                        addresses.append(self.formatAddressFromPlacemark(placemark))
                    }
                    self.showAddressTable(addresses,
                        placemarks:placemarks, sender: sender)
                } else {
                    self.showAlert("Address not found.")
                }
        })
    }
    
    @IBAction func selectProductX(sender: AnyObject) {
        productType = 0
    }
    
    @IBAction func selectProductBLACK(sender: AnyObject) {
        productType = 1
    }
    
    @IBAction func selectProductVAN(sender: AnyObject) {
        productType = 2
    }
    
    @IBAction func createRequest(sender: AnyObject) {
        activityIndicator.hidden = false
        RequestInfoLabel.hidden = false
        findRouting(0, distance: 0, route: nil)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if locationTuples[0].mapItem == nil || locationTuples[1].mapItem == nil {
                showAlert("Enter destination first.")
                return false
        } else {
            return true
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let request: Request = Request(pickup: "", destination: "", distance: routeLengthInKm, serviceID: productType, method: visa, service: service)
        let requestViewController = segue.destinationViewController as! RequestViewController
        requestViewController.request = request
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showAddressTable(addresses: [String],
        placemarks: [CLPlacemark], sender: UITextField) {
            let addressTableView = AddressTableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
            addressTableView.addresses = addresses
            addressTableView.placemarkArray = placemarks
            addressTableView.mainViewController = self
            addressTableView.sender = sender
            addressTableView.delegate = addressTableView
            addressTableView.dataSource = addressTableView
            view.addSubview(addressTableView)
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joinWithSeparator(", ")
    }
    
    func findRouting(index: Int, var distance: Double, var route: MKRoute?) {
            let request: MKDirectionsRequest = MKDirectionsRequest()
            request.source = locationsArray[index].mapItem
            request.destination = locationsArray[index+1].mapItem
            request.requestsAlternateRoutes = false
            request.transportType = .Automobile
            
            let directions = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler ({
                (response: MKDirectionsResponse?, error: NSError?) in
                if let routeResponse = response?.routes {
                    let quickestRouteForSegment: MKRoute = routeResponse[0]
                    route = quickestRouteForSegment
                    distance += quickestRouteForSegment.distance
                    
                    if index+2 < self.locationsArray.count {
                        self.findRouting(index+1, distance: distance, route: route)
                    }
                    else {
                        self.routeLengthInKm += distance
                        self.routeLengthInKm /= 1000
                        
                        self.activityIndicator.hidden = true
                        self.RequestInfoLabel.hidden = true
                        self.ConfirmRequestButton.hidden = false
                    }
                } else if let _ = error {
                    let alert = UIAlertController(title: nil,
                        message: "No drivers available.", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "OK",
                        style: .Cancel) { (alert) -> Void in
                            self.navigationController?.popViewControllerAnimated(true)
                    }
                    alert.addAction(okButton)
                    self.presentViewController(alert, animated: true,
                        completion: nil)
                }
            })
    }
    
    func showAlert(alertString: String) {
        let alert = UIAlertController(title: nil, message: alertString, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK",
            style: .Cancel) { (alert) -> Void in
        }
        alert.addAction(okButton)
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {

            locationTuples[textField.tag].mapItem = nil
            return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(locations.last!,
            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    self.locationTuples[0].mapItem = MKMapItem(placemark:
                        MKPlacemark(coordinate: placemark.location!.coordinate,
                            addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    self.originField.text = self.formatAddressFromPlacemark(placemark)
                }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}