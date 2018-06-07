//
//  StartDeliveryController.swift
//  Korio
//
//  Created by Student on 2018-04-14.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MBRateApp

class StartDeliveryController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var package: Package = Package()
    var owner: String?
    
    var destItem: MKMapItem?
    
    var locationCurrent: CLLocation?
    
    var index: Int?
    
    @IBOutlet weak var finishDeliveryButton: UIButton!
    
    @IBAction func giveMeDirections(_ sender: Any) {
        let destCoordinates = CLLocationCoordinate2D(latitude: (self.package.deliveryDetails?.DeliveryAddress.latitude)!, longitude: (self.package.deliveryDetails?.DeliveryAddress.longitude)!)
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegionMakeWithDistance(destCoordinates, regionDistance, regionDistance)
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate:regionSpan.center), MKLaunchOptionsMapSpanKey:NSValue(mkCoordinateSpan:regionSpan.span)]
        //let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        destItem?.openInMaps(launchOptions: options)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        //mapView.showsTraffic = true
        mapView.showsUserLocation = true
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        locationManager.startMonitoringSignificantLocationChanges()
        
        let sourceCoordinates = locationManager.location?.coordinate
        let destCoordinates = CLLocationCoordinate2D(latitude: (self.package.deliveryDetails?.DeliveryAddress.latitude)!, longitude: (self.package.deliveryDetails?.DeliveryAddress.longitude)!)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates!)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        
        destItem = MKMapItem(placemark: destPlacemark)
        destItem?.name = package.packageDetails?.description
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = destCoordinates
        annotation.title = package.packageDetails?.description
        annotation.subtitle = "Receiver: "+(package.deliveryDetails?.ReceiverName)!
        mapView.addAnnotation(annotation)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            guard let response = response else{
                if let error = error {
                    print("something went wrong")
                }
                return
            }
            /*var overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            
            for route in response.routes as! [MKRoute]{
                self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
                
            }*/
            
            let route = response.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            //let bearing = self.getBearingBetweenTwoPoints(point1: sourceCoordinates!, point2: destCoordinates)
            //let centerPoint = self.locationWithBearing(bearing: bearing, distanceMeters: route.distance, origin: sourceCoordinates!)
            let rect = MKCoordinateRegionForMapRect(route.polyline.boundingMapRect)
            let regionDistance:CLLocationDistance = route.distance
            let regionSpan = MKCoordinateRegionMakeWithDistance(rect.center, regionDistance, regionDistance)
            
            //let rect = route.polyline.boundingMapRect
            //self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            self.mapView.setRegion(regionSpan, animated:true)
            
            //let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            //destItem.openInMaps(launchOptions: options)
            
        })
        
        /*let annotation = MKPointAnnotation()
        annotation.coordinate = (destItem?.placemark.coordinate)!
        annotation.title = package.packageDetails?.description
        annotation.subtitle = "Receiver: "+(package.deliveryDetails?.ReceiverName)!
        mapView.addAnnotation(annotation)*/

    }
    
    /*func XXRadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI
    }
    
    func getBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        // Returns a float with the angle between the two points
        let x = point1.longitude - point2.longitude
        let y = point1.latitude - point2.latitude
        
        return fmod(XXRadiansToDegrees(radians: atan2(y, x)), 360.0) + 90.0
    }

   func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        
        let lat1 = origin.latitude * M_PI / 180
        let lon1 = origin.longitude * M_PI / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / M_PI, longitude: lon2 * 180 / M_PI)
    }*/
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        if(locationCurrent == nil || (locationCurrent?.coordinate.latitude != newLocation.coordinate.latitude && locationCurrent?.coordinate.longitude != newLocation.coordinate.longitude)){
            locationCurrent = newLocation
            
            let position = ["longitude":newLocation.coordinate.longitude,
                            "latitude":newLocation.coordinate.latitude] as [String : Any]
            
            let packageData = ["position":position] as [String : Any]
            
            FIREBASE().ref.child(self.owner!).child(self.package.id!).updateChildValues(packageData)

            
            
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
        }
        mapView.showsUserLocation = true
    }
    
    @IBAction func finishDelivery(_ sender: Any) {
    //GetSignatureSegue
        if(self.package.deliveryDetails?.SignatureRequired)!{
            performSegue(withIdentifier: "GetSignatureSegue", sender: self)
        }
        else{
            //change status to delivered
            //FIREBASE().ref.child(self.owner!).child((package.id)!).child("status").setValue("delivered")
            //FIREBASE().ref.child(self.owner!).child((package.id)!).child("new").setValue(true)
            openRateScreen(descript: (self.package.packageDetails?.description)!, id: self.package.id!)
        }
    }
    
    func openRateScreen(descript: String, id: String){
        var rateUsInfo = MBRateUsInfo()
        //pack?.value(forKey: "description")
        rateUsInfo.title = "\(descript) was Delivered!"
        rateUsInfo.titleImage = UIImage(named: "icon")
        rateUsInfo.subtitle = "Please rate the sender"
        rateUsInfo.negative = "Darn. The sender should have been better."
        rateUsInfo.itunesId = "0"
        MBRateUs.sharedInstance.rateUsInfo = rateUsInfo
        
        MBRateUs.sharedInstance.showRateUs(base: self
            , positiveBlock: { (rate) -> Void in
                let packageData = ["senderRate":rate,
                                   "status": "delivered",
                                   "new":true] as [String : Any]
                
                FIREBASE().ref.child(self.owner!).child(id).updateChildValues(packageData)
                self.performSegue(withIdentifier: "unwindToDeliveriesTab", sender: self)
                //print(rate)
                
        }, negativeBlock: { (rate) -> Void in
            let packageData = ["senderRate":rate,
                               "status": "delivered",
                               "new":true] as [String : Any]
            
            FIREBASE().ref.child(self.owner!).child(id).updateChildValues(packageData)
            self.performSegue(withIdentifier: "unwindToDeliveriesTab", sender: self)
            //print(rate)
            
        }) { () -> Void in
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GetSignatureController
        {
            let vc = segue.destination as? GetSignatureController
            
            //let value = Array(packages)[index].value
            
            vc?.package = package
            vc?.owner = self.owner
            vc?.index = self.index
        }
        if segue.destination is MyDeliveriesTabController
        {
            let vc = segue.destination as? MyDeliveriesTabController
            vc?.view.showToast(toastMessage: "Delivery Completed", duration: 4)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
