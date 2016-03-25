//AddressViewController has been reused with modifications from the
//"Routing with MapKit and Core Location" tutorial
//by Lyndsey Scott, available in the public domain at 
//raywenderlich.com/category/ios

import UIKit
import MapKit

class AddressTableView: UITableView {
    
    var mainViewController: ViewController!
    var addresses: [String]!
    var placemarkArray: [CLPlacemark]!
    var sender: UITextField!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension AddressTableView: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 18)
        label.textAlignment = .Center
        label.text = "Matches found:"
        label.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/225.0, alpha: 1)
        
        return label
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if addresses.count > indexPath.row {
            sender.text = addresses[indexPath.row]
            let mapItem = MKMapItem(placemark:
                MKPlacemark(coordinate: placemarkArray[indexPath.row].location!.coordinate,
                    addressDictionary: placemarkArray[indexPath.row].addressDictionary
                        as! [String:AnyObject]?))
            mainViewController.locationTuples[sender.tag].mapItem = mapItem
            mainViewController.centerMapOnLocation(mapItem.placemark.location!)
            mainViewController.mapView.addAnnotation(mapItem.placemark)
            sender.selected = true
        }
        removeFromSuperview()
    }
}

extension AddressTableView:UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AddressCell") as UITableViewCell!
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 11)
        
        if addresses.count > indexPath.row {
            cell.textLabel?.text = addresses[indexPath.row]
        } else {
            cell.textLabel?.text = "None of the above"
        }
        return cell
    }
}