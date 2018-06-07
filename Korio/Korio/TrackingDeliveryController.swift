//
//  TrackingDeliveryController.swift
//  Korio
//
//  Created by Student on 2018-04-18.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TrackingDeliveryController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let manager = CLLocationManager()
    var package:Package = Package()
    var startPosition:[String:Double] = ["latitude":0,"longitude":0]
    var deliveryPerson:String = ""
    var annotation:MKPointAnnotation?
    var annotation2:MKPointAnnotation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let destCoordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        annotation2?.coordinate = destCoordinates
        //
        
        //let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //let packLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //let region: MKCoordinateRegion = MKCoordinateRegionMake(packLocation, span)
        //mapView.setRegion(region, animated: true)
        
        
        //self.mapView.showsUserLocation = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsPointsOfInterest = true
        //mapView.showsTraffic = true
        mapView.showsUserLocation = true
        
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            //manager.startUpdatingLocation()
        }

        
        let sourceCoordinates = CLLocationCoordinate2D(latitude: startPosition["latitude"]!, longitude: startPosition["longitude"]!)
        let destCoordinates = CLLocationCoordinate2D(latitude: (self.package.deliveryDetails?.DeliveryAddress.latitude)!, longitude: (self.package.deliveryDetails?.DeliveryAddress.longitude)!)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        
        let destItem = MKMapItem(placemark: destPlacemark)
        destItem.name = package.packageDetails?.description
        
        annotation = MKPointAnnotation()
        annotation?.coordinate = destCoordinates
        annotation?.title = package.packageDetails?.description
        annotation?.subtitle = "Receiver: "+(package.deliveryDetails?.ReceiverName)!
        /*DispatchQueue.main.async {
            self.mapView.addAnnotation(self.annotation!)
        }*/
        mapView.addAnnotation(annotation!)
        
        annotation2 = MKPointAnnotation()
        annotation2?.coordinate = sourceCoordinates
        annotation2?.title = "Deliver"
        annotation2?.subtitle = self.deliveryPerson
        /*DispatchQueue.main.async {
            self.mapView.addAnnotation(self.annotation2!)
        }*/
        
        mapView.addAnnotation(annotation2!)
        
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
        
        
        
        
        /*FIREBASE().ref.child(USER().id).child((package.id)!).observe(.childAdded, with: { (snapshot) in
            if(snapshot.exists()){
                let key = snapshot.key
                if(key == "position"){
                    let position = snapshot.value as? NSDictionary
                    let newLat = position?.value(forKey: "latitude") as! Double
                    let newLog = position?.value(forKey: "longitude") as! Double
                    
                    
                    self.locationManager(self.manager, didUpdateLocations: [CLLocation(latitude: newLat, longitude: newLog)])
                    /*let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                    let packLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLat, newLog)
                    let region: MKCoordinateRegion = MKCoordinateRegionMake(packLocation, span)
                    self.mapView.setRegion(region, animated: true)*/
                    
                }
            }
        })*/

        FIREBASE().ref.child(userId).child((package.id)!).observe(.childChanged, with: { (snapshot) in
            if(snapshot.exists()){
                let key = snapshot.key
                if(key == "position"){
                    let position = snapshot.value as? NSDictionary
                    let newLat = position?.value(forKey: "latitude") as! Double
                    let newLog = position?.value(forKey: "longitude") as! Double
                    
                    self.locationManager(self.manager, didUpdateLocations: [CLLocation(latitude: newLat, longitude: newLog)])
                    
                    /*let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                    let packLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(newLat, newLog)
                    let region: MKCoordinateRegion = MKCoordinateRegionMake(packLocation, span)
                    self.mapView.setRegion(region, animated: true)
                    */
                }
            }
        })
        // Do any additional setup after loading the view.
    }
    
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
