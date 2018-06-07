//
//  TrackingInTransitController.swift
//  Korio
//
//  Created by Student on 2018-04-15.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import CoreLocation
import PubNub
import MapKit

class TrackingInTransitController: UIViewController, CLLocationManagerDelegate, PNDelegate{//, MKMapViewDelegate {
    
    private var locationManager = CLLocationManager()//first
    
    private var config = PNConfiguration(publishKey: "pub-c-69727155-e10b-4ab4-ba6e-a4fe291c8904", subscribeKey: "sub-c-3a47f6f0-40d5-11e8-b20a-be401e5b340a", secretKey:nil)//first
    private var channel = PNChannel()//first
    
    //private var channel2 = PNChannel()
    
    @IBOutlet weak var mapView: MKMapView!
    
    //private var locations = [CLLocation]()
    //private var coordinateList = [CLLocationCoordinate2D]()
    //private var isFirstMessage = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  self.mapView.delegate = self
        
        self.locationManager.delegate = self//first
        self.locationManager.requestAlwaysAuthorization()//first
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest//first
        self.locationManager.startUpdatingLocation()//first
        
        PubNub.setDelegate(self)//first
        PubNub.setConfiguration(self.config)//first
        PubNub.connect()//first
        self.channel = PNChannel.channel(withName: "Channel-Name", shouldObservePresence: false) as! PNChannel//first
        PubNub.subscribe(on: self.channel)//first

        // Do any additional setup after loading the view.
        
        //let message = "{\"lat\":-80.40325,\"lng\":-80.40325, \"alt\": -80.40325}"
        //PubNub.sendMessage(message as NSCopying & NSObjectProtocol, to: self.channel, compressed: true)
        
        //PubNub.setDelegate(self)
        //PubNub.setConfiguration(self.config)
        //PubNub.connect()
        //self.channel2 = PNChannel.channel(withName: "Channel-Name", shouldObservePresence: false) as! PNChannel
        //PubNub.subscribe(on: self.channel2)
    }
    
    //first
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error.localizedDescription)")
        let errorAlert = UIAlertView(title: "Error", message: "Failed to Get Your Location", delegate: nil, cancelButtonTitle: "Ok")
        errorAlert.show()
    }
    
    //first
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last as! CLLocation
        print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
        let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
        PubNub.sendMessage(message as NSCopying & NSObjectProtocol, to: self.channel, compressed: true)
    }
    /*
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        // Extract content from received message
        let receivedMessage = message.message as! [NSString : Double]
        let lng : CLLocationDegrees! = receivedMessage["lng"]
        let lat : CLLocationDegrees! = receivedMessage["lat"]
        let alt : CLLocationDegrees! = receivedMessage["alt"]
        let newLocation2D = CLLocationCoordinate2DMake(lat, lng)
        let newLocation = CLLocation(coordinate: newLocation2D, altitude: alt, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        self.locations.append(newLocation)
        self.coordinateList.append(newLocation.coordinate)
        // Drawing the line
        self.updateOverlay()
        // Focusing on the new position
        self.updateMapFrame()
        // Update Marker Position
        self.updateCurrentPositionMarker(currentLocation: newLocation)
    }
    
    func updateMapFrame() {
        let currentPosition = self.locations.last!
        let latitudeSpan = CLLocationDistance(500)
        let longitudeSpan = latitudeSpan
        let region = MKCoordinateRegionMakeWithDistance(currentPosition.coordinate, latitudeSpan, longitudeSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    func updateCurrentPositionMarker(currentLocation: CLLocation) {
        print("\(currentLocation.coordinate.latitude);\(currentLocation.coordinate.longitude)")
    }
    
    func updateOverlay() {
        // Build the overlay
        let line = MKPolyline(coordinates: &self.coordinateList, count: self.coordinateList.count)
        // Replace overlay
        if !self.isFirstMessage {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        self.mapView.add(line)
    }
    */
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
