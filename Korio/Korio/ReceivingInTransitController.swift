//
//  ReceivingInTransitController.swift
//  Korio
//
//  Created by Student on 2018-04-16.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import PubNub
import MapKit

class ReceivingInTransitController: UIViewController, PNDelegate, MKMapViewDelegate {

    private var channel = PNChannel()
    private let config = PNConfiguration(publishKey: "pub-c-69727155-e10b-4ab4-ba6e-a4fe291c8904", subscribeKey: "sub-c-3a47f6f0-40d5-11e8-b20a-be401e5b340a", secretKey: "sec-c-NTU3ZDg1YzctNmMxNS00NTI1LTkyZDEtNzZjYzRiNTM3YmIx")
    
    private var mapView = MKMapView()
    private var locations = [CLLocation]()
    private var coordinateList = [CLLocationCoordinate2D]()
    private var isFirstMessage = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self

        PubNub.setDelegate(self)
        PubNub.setConfiguration(self.config)
        PubNub.connect()
        self.channel = PNChannel.channel(withName: "Channel-Name", shouldObservePresence: false) as! PNChannel
        PubNub.subscribe(on: self.channel)
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        // Building a view
        let screenFrame = UIScreen.main.applicationFrame
        let contentView = UIView(frame: screenFrame)
        // Add Map
        self.mapView = MKMapView(frame: screenFrame)
        contentView.addSubview(self.mapView)
        // Set the built view as our view
        self.view = contentView
    }
    
    func pubnubClient(_ client: PubNub!, didReceive message: PNMessage!) {
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
    
    func updateOverlay() {
        // Build the overlay
        let line = MKPolyline(coordinates: &self.coordinateList, count: self.coordinateList.count)
        // Replace overlay
        if !self.isFirstMessage {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        self.mapView.add(line)
    }
    
    func updateMapFrame() {
        let currentPosition = self.locations.last!
        let latitudeSpan = CLLocationDistance(500)
        let longitudeSpan = latitudeSpan
        let region = MKCoordinateRegionMakeWithDistance(currentPosition.coordinate, latitudeSpan, longitudeSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    func updateCurrentPositionMarker(currentLocation: CLLocation) {
        print("current position: \(currentLocation.coordinate.longitude) , \(currentLocation.coordinate.latitude)")
        //self.currentPositionMarker.coordinate = currentLocation.coordinate
        //self.mapView.addAnnotation(self.currentPositionMarker)
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
