//
//  Data.swift
//  Uber
//
//  Created by Hugo Brandao, Evans Daniil
//  Translated from Java to Swift by Jan Dukaczewski, on 18/03/16.
//  Copyright © 2016 Jan Dukaczewski. All rights reserved.
//

import Foundation

protocol Locations {
    func setPickup(pickup: String)
    func setDestination(destination: String)
    
    func requestNavigation()
    func calculateDistance() -> Double
    
    func getPickup() -> String
    func getDestination() -> String
}

protocol Payment {
    func setPromoCode(promoCode: String) -> Bool
    func executePayment()
    func getAmount() -> Double
    func getPaid() -> Bool
    func setPayment(method: PaymentMethod, amount: Double)
}

protocol PaymentMethod {
    func getIban() -> String
    func getcvv() -> String
    func getName() -> String
    func getExpirationDate() -> String
}

protocol ProductType {
    func getPriceRate(id: Int) -> Double
    func findDriver(serviceID: Int) -> Driver
    func rateDriver(review: Review, name: String)
}

protocol RideManagement {
    func startRide()
    func endRide(destination: String)
    func requestNavigation()
    func acceptOrDecline(accept: Bool, driver: Driver)
    func review(description: String, rating: Int)
}

protocol RideRequest {
    func setPickupLocation(pickup: String)
    func setDestinationLocation(destination: String)
    func setPaymentMethod(method: PaymentMethod)
    func setPromoCode(promo: String)
    func review(description: String, rating: Int)
    
    func getPickupLocation() -> String
    func getDestinationLocation() -> String
    func getPaymentMethod() -> PaymentMethod
    func getPromoCode() -> String
}

protocol VehicleType {
    func getLicense() -> String
    func getModel() -> String
    func getMake() -> String
    func getCapacity() -> Int
    func getCategory() -> Int
}

class Card: PaymentMethod {
    private var iban: String
    private var cvv: String
    private var name: String
    private var expirationDate: String
    
    init (iban: String, cvv: String, name: String, expirationDate: String) {
        self.iban = iban
        self.cvv = cvv
        self.expirationDate = expirationDate
        self.name = name
    }
    
    func getIban() -> String {
        return iban
    }
    
    func getcvv() -> String {
        return cvv
    }
    
    func getName() -> String {
        return name
    }
    
    func getExpirationDate() -> String {
        return expirationDate
    }
}

class Driver {
    private var name: String
    private var phoneNumber: String
    private var vehicle: Vehicle?
    private var request: RideManagement?
    private var rating: Double
    private var reviews: [Review]
    
    init (name: String, phoneNumber: String, reviews: [Review]) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.reviews = reviews
        self.rating = 0
    }
    
    func determineRating () {
        self.rating = 0
        for review in reviews {
            self.rating += Double(review.rating)
        }
        self.rating = self.rating/Double(reviews.count)
    }
    
    func notifyDriver(req: RideManagement) {
        self.request = req
        req.acceptOrDecline(true, driver: self)
    }
    
    func setVehicle (vehicle: Vehicle) {
        self.vehicle = vehicle
    }
    
    func getVehicle () -> Vehicle {
        return self.vehicle!
    }
    
    func getRequest() -> RideManagement {
        return self.request!
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getPhoneNumber() -> String {
        return self.phoneNumber
    }
    
    func getRating() -> Double {
        return self.rating
    }
}

class Location: Locations {
    private var pickupAddress: String
    private var destinationAddress: String
    private var distance: Double
    
    init (pickupAddress: String, destinationAddress: String, distance: Double) {
        self.pickupAddress = pickupAddress
        self.destinationAddress = destinationAddress
        self.distance = distance
    }
    
    func setPickup(pickup: String) {
        self.pickupAddress = pickup
    }
    
    func setDestination(destination: String) {
        self.destinationAddress = destination
    }
    
    func calculateDistance() -> Double {
        return distance
    }
    
    func getPickup() -> String {
        return self.pickupAddress
    }
    
    func getDestination() -> String {
        return self.destinationAddress
    }
    
    func requestNavigation() {
        //returns route directions
    }
}

class PaymentProcessing: Payment, PaymentMethod {
    private var promoCode: String
    private var receipt: Receipt
    private var method: PaymentMethod
    
    init (amount: Double, method: PaymentMethod) {
        self.promoCode = "0"
        let receipt = Receipt(amount: amount)
        self.receipt = receipt
        self.method = method
    }
    
    func setPayment(method: PaymentMethod, amount: Double) {
        let receipt = Receipt(amount: amount)
        self.receipt = receipt
        self.method = method
    }
    
    func setPromoCode(promocode: String) -> Bool {
        self.promoCode = promocode
        return true
    }
    
    func executePayment() {
        if promoCode == "0" { //promoCode == "0" means no promo code
            receipt.pay()
        }
        else {
            receipt.payDiscount(promoCode)
        }
    }
    
    func getAmount() -> Double {
        return self.receipt.getAmount()
    }
    
    func getPaid() -> Bool {
        return self.receipt.getPaid()
    }
    
    func getIban() -> String {
        return method.getIban()
    }
    
    func getcvv() -> String {
        return method.getcvv()
    }
    
    func getName() -> String {
        return method.getName()
    }
    
    func getExpirationDate() -> String {
        return method.getExpirationDate()
    }
}

class Product {
    private var productID: Int
    private var priceRate: Double
    private var nameOfProduct: String
    
    init(productID: Int, priceRate: Double, nameOfProduct: String) {
        self.productID = productID
        self.priceRate = priceRate
        self.nameOfProduct = nameOfProduct
    }
    
    func getPrice() -> Double {
        return priceRate
    }
}

class Receipt {
    private var amount: Double
    private var paid: Bool
    
    init(amount: Double) {
        self.amount = amount
        self.paid = false
    }
    
    func pay() {
        self.paid = true
    }
    
    func payDiscount(promoCode: String) {
        self.paid = true
    }
    
    func getAmount() -> Double {
        return amount
    }
    
    func getPaid() -> Bool {
        return self.paid
    }
}

class Request: RideRequest, RideManagement {
    private var locations: Locations
    private var service: ProductType
    private var method: PaymentMethod
    private var promoCode: String
    private var rideStarted: Bool
    private var rideEnded: Bool
    private var accepted: Bool
    private var serviceID: Int
    private var driver: Driver
    
    init (pickup: String, destination: String, distance: Double, serviceID: Int, method: PaymentMethod, service: ProductType) {
        let location = Location(pickupAddress: pickup, destinationAddress: destination, distance: distance)
        self.locations = location
        self.method = method
        self.service = service
        self.serviceID = serviceID
        self.promoCode = "0"
        self.rideStarted = false
        self.rideEnded = false
        self.accepted = false
        self.driver = service.findDriver(serviceID)
    }
    
    func setPickupLocation(pickup: String) {
        self.locations.setPickup(pickup)
    }
    
    func setDestinationLocation(destination: String) {
        self.locations.setDestination(destination)
    }
    
    func setPaymentMethod(method: PaymentMethod) {
        self.method = method
    }
    
    func setService(service: Service) {
        self.service = service
    }
    
    func setPromoCode(promo: String) {
        self.promoCode = promo
    }
    
    func review(description: String, rating: Int) {
        let review = Review(review: description, rating: rating)
        service.rateDriver(review, name: driver.getName())
        driver.determineRating()
    }
    
    func getPickupLocation() -> String {
        return self.locations.getDestination()
    }
    
    func getPaymentMethod() -> PaymentMethod {
        return self.method
    }
    
    func getPriceEstimate() -> Double {
        var estimate = self.locations.calculateDistance() * service.getPriceRate(self.serviceID) + 5
        if estimate < 9.0 {
            return 9.0
        }
        else {
            return estimate
        }
    }
    
    func getPromoCode() -> String {
        return self.promoCode
    }
    
    func getDestinationLocation() -> String {
        return self.locations.getDestination()
    }
    
    func getDriver() -> Driver {
        return self.driver
    }
    
    func startRide() {
        self.rideStarted = true
    }
    
    func endRide(destination: String) {
        self.rideEnded = true
        self.locations.setDestination(destination)
        
    }
    
    func requestNavigation() {
        self.locations.requestNavigation()
    }
    
    func acceptOrDecline(accept: Bool, driver: Driver) {
        if (accept) {
            self.accepted = accept
            self.driver = driver
        }
        else {
            self.driver = self.service.findDriver(serviceID)
        }
    }
}

class Review {
    private var description: String
    private var rating: Int
    
    init (review: String, rating: Int) {
        self.description = review
        self.rating = rating
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func getRatings() -> Int {
        return self.rating
    }
}

class Service: ProductType {
    
    private var drivers: [Driver] = []
    private var products: [Product] = []
    private var dataFile: String
    private var dataFilePath: String
    private var data: NSMutableDictionary
    
    
    func rateDriver (review: Review, name: String) {
        let drivers = data["Drivers"] as! NSMutableArray
        
        for i in 0...drivers.count-1 {
            
            let driverDict = drivers[i] as! NSMutableDictionary
            
            if driverDict.valueForKey("name") as! String == name {
                let reviews = driverDict.valueForKey("reviews") as! NSMutableArray
                reviews.addObject(review.rating)
                data.writeToFile(dataFilePath, atomically: true)
                self.data = NSMutableDictionary(contentsOfFile: dataFilePath)!
                print(review.rating)
            }
        }
    }
    
    init (dataFile: String) {
        self.dataFile = dataFile
        self.dataFilePath = NSBundle.mainBundle().pathForResource(dataFile, ofType: "plist")!
        self.data = NSMutableDictionary(contentsOfFile: dataFilePath)!
        
        let driversInit = data["Drivers"] as! NSArray
        let vehiclesInit = data["Vehicles"] as! NSArray
        let productsInit = data["Products"] as! NSArray
        
        var vehicles: [Vehicle] = []
        
        for i in 0...vehiclesInit.count-1 {
            let vehicleDict = vehiclesInit[i] as! NSDictionary
            
            let vehicleModel = vehicleDict.valueForKey("model") as! String
            let vehicleMake = vehicleDict.valueForKey("make") as! String
            let vehicleCategory = vehicleDict.valueForKey("category") as! Int
            let vehicleCapacity = vehicleDict.valueForKey("capacity") as! Int
            let vehicleLicensePlate = vehicleDict.valueForKey("licensePlate") as! String
            
            let vehicle = Vehicle(license: vehicleLicensePlate, model: vehicleModel, make: vehicleMake, capacity: vehicleCapacity, category: vehicleCategory)
            vehicles.append(vehicle)
            
        }
        
        for i in 0...driversInit.count-1 {
            let driverDict = driversInit[i] as! NSDictionary
        
            let driverName = driverDict.valueForKey("name") as! String
            let driverPhoneNumber = driverDict.valueForKey("phoneNumber") as! String
            //let driverVehicle = driverDict.valueForKey("activeVehicle") as! String
            let driverReviews = driverDict.valueForKey("reviews") as! NSMutableArray
            
            var driverReviewsObject: [Review] = []
            
            for i in 0...driverReviews.count-1 {
                let review = Review(review: "", rating: driverReviews[i] as! Int)
                driverReviewsObject.append(review)
            }
            
            let driver = Driver(name: driverName, phoneNumber: driverPhoneNumber, reviews: driverReviewsObject)
            driver.setVehicle(vehicles[i])
            driver.determineRating()
            drivers.append(driver)
        }
        
        for i in 0...productsInit.count-1 {
            let productDict = productsInit[i] as! NSDictionary
            
            let productID = productDict.valueForKey("ID") as! Int
            let productRate = productDict.valueForKey("Rate") as! Double
            let productName = productDict.valueForKey("name") as! String
            
            let product = Product(productID: productID, priceRate: productRate, nameOfProduct: productName)
            products.append(product)
        }
    }
    
    func addDriver (driver: Driver) {
        drivers.append(driver)
    }
    
    func getPriceRate(id: Int) -> Double {
        return products[id].getPrice()
    }
    
    func findDriver(serviceID: Int) -> Driver {
        
        var result: Driver?
        for driver in drivers {
            if driver.getVehicle().getCategory() == serviceID {
                result = driver
                return result!
            }
        }
        return result!
    }
}

class Vehicle {
    private var license: String
    private var capacity: Int
    private var model: String
    private var make: String
    private var category: Int
    
    init (license: String, model: String, make: String, capacity: Int, category: Int) {
        self.license = license;
        self.model = model;
        self.make = make;
        self.capacity = capacity;
        self.category = category;
    }
    
    func getLicense() -> String {
        return self.license
    }
    
    func getModel() -> String {
        return self.model
    }
    
    func getMake() -> String {
        return self.make
    }
    
    func getCategory() -> Int {
        return self.category
    }
    
    func getCapacity() -> Int {
        return self.capacity
    }
}