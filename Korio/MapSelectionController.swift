//
//  MapSelectionController.swift
//  Korio
//
//  Created by Student on 2018-03-17.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation
import Contacts

class MapSelectionController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var resultSearchController:UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    @IBAction func searchButton(_ sender: Any) {
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        let searchController = UISearchController(searchResultsController: locationSearchTable)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = locationSearchTable
        present(searchController, animated: true, completion: nil)
        //searchController.hidesNavigationBarDuringPresentation = false
        //searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    /*func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }*/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            //selectedPin = MKPlacemark.init(coordinate: (locations.first?.coordinate)!)
            let geoCoder = CLGeocoder()
            let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                self.selectedPin = MKPlacemark(placemark: placeMark)
                
                /*
                // use the Contacts framework to create a readable formatter address
                let postalAddress = CNMutablePostalAddress()
                postalAddress.street = (placeMark.addressDictionary?["Street"] as? String) ?? ""
                postalAddress.city = placeMark.locality ?? ""
                postalAddress.state = placeMark.administrativeArea ?? ""
                postalAddress.postalCode = placeMark.postalCode ?? ""
                postalAddress.country = placeMark.country ?? ""
                postalAddress.isoCountryCode = placeMark.isoCountryCode ?? ""
                
                let addressString = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                print(addressString)
                */
                
                
                // Address dictionary
                // Address dictionary
                //print(placeMark.addressDictionary as Any)
                /*
                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                    //print(locationName)
                }
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    //print(street)
                }
                // City
                if let city = placeMark.addressDictionary!["City"] as? NSString {
                    //print(city)
                }
                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                    //print(zip)
                }
                // Country
                if let country = placeMark.addressDictionary!["Country"] as? NSString {
                    //print(country)
                }*/
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }

    
    
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let placemark = mapView.
        print("*********\(String(describing: placemark.title))")
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "latitude = \(userLocation.coordinate.latitude)"
        myAnnotation.subtitle = "longitude = \(userLocation.coordinate.longitude)"
        mapView.addAnnotation(myAnnotation)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }*/

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let locationSearchTable = storyboard.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        

        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
*/
        // Create and Add MapView to our main view
        //createMapView()
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        determineCurrentLocation()
    }*/
    
    /*func determineCurrentLocation()
    {
        locationManager =
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }*/
}

extension MapSelectionController: HandleMapSearch {
        
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
