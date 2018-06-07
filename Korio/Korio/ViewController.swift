//
//  ViewController.swift
//  Korio
//
//  Created by Student on 2018-02-17.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

import FirebaseDatabase
import FirebaseStorage
import SDWebImage

import MapKit
import CoreLocation

import MBRateApp

import Firebase
import GoogleSignIn

//struct USERS {
 //   }



struct FIREBASE{
    var ref: DatabaseReference = Database.database().reference().child("packages")
    var storageRef: StorageReference = Storage.storage().reference().child("package-images")
    var signatureRef: StorageReference = Storage.storage().reference().child("signatures")
}

var package = Package()

//var usersIds: Array<String> = ["admin"]

//struct PACKAGE {
//    var package: Package = Package()
//}

struct SIZE{
    let sizeData = ["Small", "Medium", "Large"]
}

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //@IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var historyMenu: UIButton!
    @IBOutlet weak var myPackagesMenu: UIButton!
    @IBOutlet weak var myDeliveriesMenu: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var menuShowing = false
    
    //var ref: DatabaseReference?
    //var handle: DatabaseHandle?
    
    //var storageRef: StorageReference?
    
    var package: PackageDetails?
    
    //var packages = [String: NSDictionary]()
    
    @IBOutlet weak var imageTest: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    //@IBOutlet weak var viewForMap: UIView!
    var locationManager: CLLocationManager = CLLocationManager()
    //var mapView:MKMapView!
    var resultSearchController:UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    var packages = [String: NSDictionary]()
    
    var packagesAccepted = [String]()
    
    var packagesPosted = [String]()
    
    var packagesChanged = [String]()
    
    var packagesAuthorized = [String]()
    
    var packagesExpired = [String]()
    
    var packagesDelivered = [String]()
    
    var packagesTransit = [String]()
    
    var customPin:CustomPin?
    
    @IBAction func DeliveryAuthorizedUnwind(unwindSegue: UIStoryboardSegue){
        if let HistoryCellDetailsController = unwindSegue.source as? HistoryCellDetailsController {
           self.view.showToast(toastMessage: "Delivery Authorized", duration: 4)
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("logout")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "LogoutSegue", sender: self)
    }
    
    @IBAction func search(_ sender: Any) {
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
    
    @IBAction func openAndCloseMenu(_ sender: Any) {
        
        if(menuShowing){
            leadingConstraint.constant = -170
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else{
            leadingConstraint.constant = 0
            
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        menuShowing = !menuShowing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create and Add MapView to our main view
        //createMapView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //determineCurrentLocation()
    }
    
    /*func createMapView()
    {
        mapView = MKMapView()
        
        //let leftMargin:CGFloat = viewForMap.frame.
        //let topMargin:CGFloat = 0
        //let mapWidth:CGFloat = viewForMap.frame.sizeiewFor.width
        //let mapHeight:CGFloat = viewForMap.frame.size.height
        
        //mapView.frame = CGRect(leftMargin, topMargin, mapWidth, mapHeight)

        //mapView.sizeThatFits(CGSize(width: viewForMap.frame.size.width, height: viewForMap.frame.size.height))
        
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Or, if needed, we can position map in the center of the view
        mapView.frame = viewForMap.frame
        mapView.center = viewForMap.center
        
        viewForMap.addSubview(mapView)
        
    }*/
    
    /*func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
        }
    }*/
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

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
            })
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    /*func getUsers(){
        //let allUser: Array<String>
        /*FIREBASE().ref.child("users").observe(.childAdded, with: { (snapshot) in
            if(snapshot.exists()){
                usersIds.append(snapshot.value as! String)
            }
        })
        FIREBASE().ref.child("users").observe(.childChanged, with: { (snapshot) in
            if(snapshot.exists()){
                usersIds.append(snapshot.value as! String)
            }
        })*/
        
        FIREBASE().ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            for user in value!{
                usersIds.append(user.value as! String)
            }
            
        })
        
        //return
    }*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getUsers()
        
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

 
        //child added
        for user in usersIds{
            if(user != userId){
                FIREBASE().ref.child(user).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.exists()){
                        let pack = snapshot.value as? NSDictionary
                        let status = pack?.value(forKey: "status") as! String
                        let id = snapshot.key
                        let delPerson = pack?.value(forKey: "deliveryPerson") as? String
                        let new = (pack?.value(forKey: "new") as? Bool) ?? false
                        if(status == "posted"){
                            self.packages[snapshot.key] = snapshot.value as? NSDictionary
                            self.packages[snapshot.key]?.setValue(user, forKey: "owner")
                            self.addPackageOnMap()
                        }
                        else if(status == "changed"){
                            if(delPerson != nil && delPerson == userId){
                                if(new){
                                    self.packagesChanged.append(id)
                                    self.updateMyDeliveriesMenu()
                                }
                                else{
                                    if(self.packagesChanged.contains(id)){
                                        self.packagesChanged.remove(at: self.packagesChanged.index(of: id)!)
                                        self.updateMyDeliveriesMenu()
                                    }
                                }
                            }
                        }
                        else if(status == "authorized"){
                            if(delPerson != nil && delPerson == userId){
                                if(new){
                                    self.packagesAuthorized.append(id)
                                    self.updateMyDeliveriesMenu()
                                }
                                else{
                                    if(self.packagesAuthorized.contains(id)){
                                        self.packagesAuthorized.remove(at: self.packagesAuthorized.index(of: id)!)
                                        self.updateMyDeliveriesMenu()
                                    }
                                }
                            }
                        }
                        else if(status == "delivered"){
                            if(new){
                                self.packagesDelivered.append(id)
                                self.updateMyHistoryMenu()
                                
                            }
                            else{
                                if(self.packagesDelivered.contains(id)){
                                    self.packagesDelivered.remove(at: self.packagesDelivered.index(of: id)!)
                                    self.updateMyHistoryMenu()
                                }
                            }
                        }
                    }
                });
            }
            else{
                FIREBASE().ref.child(user).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.exists()){
                        let pack = snapshot.value as? NSDictionary
                        let new = (pack?.value(forKey: "new") as? Bool) ?? false
                        let id = snapshot.key
                        let status = pack?.value(forKey: "status") as! String
                        if(status == "accepted"){
                            if(new){
                                self.packagesAccepted.append(id)
                                self.updateMyPackagesMenu()
                            }
                            else{
                                if(self.packagesAccepted.contains(id)){
                                    self.packagesAccepted.remove(at: self.packagesAccepted.index(of: id)!)
                                    self.updateMyPackagesMenu()
                                }
                            }
                        }
                        else if(status == "posted"){
                            if(new){
                                self.packagesPosted.append(id)
                                self.updateMyPackagesMenu()
                            }
                            else{
                                if(self.packagesPosted.contains(id)){
                                    self.packagesPosted.remove(at: self.packagesPosted.index(of: id)!)
                                    self.updateMyPackagesMenu()
                                }
                            }
                        }
                        else if(status == "expired"){
                            if(new){
                                self.packagesExpired.append(id)
                                self.updateMyHistoryMenu()
                            }
                            else{
                                if(self.packagesExpired.contains(id)){
                                    self.packagesExpired.remove(at: self.packagesExpired.index(of: id)!)
                                    self.updateMyHistoryMenu()
                                }
                            }
                        }
                        else if(status == "transit"){
                            if(new){
                                self.packagesTransit.append(id)
                                self.updateMyPackagesMenu()
                                
                            }
                            else{
                                if(self.packagesTransit.contains(id)){
                                    self.packagesTransit.remove(at: self.packagesTransit.index(of: id)!)
                                    self.updateMyPackagesMenu()
                                }
                            }
                        }
                    }
                });
            }
        }
        
        //child changed
        for user in usersIds{
            if(user != userId){
                FIREBASE().ref.child(user).observe(.childChanged, with: { (snapshot) in
                    if(snapshot.exists()){
                        let pack = snapshot.value as? NSDictionary
                        let id = snapshot.key
                        let status = pack?.value(forKey: "status") as! String
                        let delPerson = pack?.value(forKey: "deliveryPerson") as? String
                        let new = (pack?.value(forKey: "new") as? Bool) ?? false
                        if(status == "changed"){
                            if(delPerson != nil && delPerson == userId){
                                if(new){
                                    self.packagesChanged.append(id)
                                    self.updateMyDeliveriesMenu()
                                }
                                else{
                                    if(self.packagesChanged.contains(id)){
                                        self.packagesChanged.remove(at: self.packagesChanged.index(of: id)!)
                                        self.updateMyDeliveriesMenu()
                                    }
                                }
                            }
                        }
                        if(status == "authorized"){
                            if(delPerson != nil && delPerson == userId){
                                if(new){
                                    self.packagesAuthorized.append(id)
                                    self.updateMyDeliveriesMenu()
                                }
                                else{
                                    if(self.packagesAuthorized.contains(id)){
                                        self.packagesAuthorized.remove(at: self.packagesAuthorized.index(of: id)!)
                                        self.updateMyDeliveriesMenu()
                                    }
                                }
                            }
                        }
                        else if(status == "delivered"){
                            if(new){
                                self.packagesDelivered.append(id)
                                self.updateMyHistoryMenu()
                            }
                            else{
                                if(self.packagesDelivered.contains(id)){
                                    self.packagesDelivered.remove(at: self.packagesDelivered.index(of: id)!)
                                    self.updateMyHistoryMenu()
                                }
                            }
                        }
                    }
                });
            }
            else{
                FIREBASE().ref.child(user).observe(.childChanged, with: { (snapshot) in
                    if(snapshot.exists()){
                        let pack = snapshot.value as? NSDictionary
                        let new = (pack?.value(forKey: "new") as? Bool) ?? false
                        let status = pack?.value(forKey: "status") as! String
                        let id = snapshot.key
                        
                        if(status == "accepted"){
                            if(new){
                                if(!self.packagesAccepted.contains(id)){
                                    self.packagesAccepted.append(id)
                                    self.updateMyPackagesMenu()
                                }
                            }
                            else{
                                if(self.packagesAccepted.contains(id)){
                                    self.packagesAccepted.remove(at: self.packagesAccepted.index(of: id)!)
                                    self.updateMyPackagesMenu()
                                }
                            }
                        }
                        else if(status == "posted"){
                            if(new){
                                if(!self.packagesPosted.contains(id)){
                                    self.packagesPosted.append(id)
                                    self.updateMyPackagesMenu()
                                }
                            }
                            else{
                                if(self.packagesPosted.contains(id)){
                                    self.packagesPosted.remove(at: self.packagesPosted.index(of: id)!)
                                    self.updateMyPackagesMenu()
                                }
                            }
                        }
                        else if(status == "expired"){
                            if(new){
                                self.packagesExpired.append(id)
                                self.updateMyHistoryMenu()
                            }
                            else{
                                if(self.packagesExpired.contains(id)){
                                    self.packagesExpired.remove(at: self.packagesExpired.index(of: id)!)
                                    self.updateMyHistoryMenu()
                                }
                            }
                        }
                        else if(status == "transit"){
                            if(new){
                                self.packagesTransit.append(id)
                                self.updateMyPackagesMenu()
                                
                            }
                            else{
                                if(self.packagesTransit.contains(id)){
                                    self.packagesTransit.remove(at: self.packagesTransit.index(of: id)!)
                                    self.updateMyPackagesMenu()
                                }
                            }
                        }
                    }
                });
            }
        }
    }
    
    func showRateDeliveryQuestionDialog(packDelivered: NSDictionary) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Rate Delivery", message: "Would you like to rate the driver of \(packDelivered.value(forKey: "description") as! String) delivered?", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            
            //getting the input values from user
            /*let instructions = alertController.textFields?[0].text
            self.specialInstructions.text = instructions
            package.specialInstruction = instructions
            
            self.buttonSpecialInstructions.isHidden = true
            self.labelSpecialInstructions.isHidden = false
            self.specialInstructions.isHidden = false
            */
            //self.labelMessage.text = "Name: " + name! + "Email: " + email!
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in }
        
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Instructions"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }

    
    func updateMyHistoryMenu(){
        if((self.packagesExpired.count + self.packagesDelivered.count) > 0){
            self.historyMenu.setTitle("History (\(self.packagesExpired.count + self.packagesDelivered.count))", for: .normal)
        }
        else{
            self.historyMenu.setTitle("History", for: .normal)
        }
    }
    
    func updateMyDeliveriesMenu(){
        if((self.packagesChanged.count+self.packagesAuthorized.count) > 0){
            self.myDeliveriesMenu.setTitle("My Deliveries (\(self.packagesChanged.count+self.packagesAuthorized.count))", for: .normal)
        }
        else{
            self.myDeliveriesMenu.setTitle("My Deliveries", for: .normal)
        }
    }
    
    func updateMyPackagesMenu(){
        if((self.packagesAccepted.count+self.packagesPosted.count+self.packagesTransit.count) > 0){
            self.myPackagesMenu.setTitle("My Packages (\(self.packagesAccepted.count+self.packagesPosted.count+self.packagesTransit.count))", for: .normal)
        }
        else{
            self.myPackagesMenu.setTitle("My Packages", for: .normal)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //print("tapped")
        if control == view.rightCalloutAccessoryView{
            let pin = view.annotation as? CustomPin
            print(pin?.package?.description) // annotation's title
            print(pin?.packageId) // annotation's subttitle
            self.customPin = pin
            performSegue(withIdentifier: "deliverPackageSegue", sender: self)
            //Perform a segue here to navigate to another viewcontroller
            // On tapping the disclosure button you will get here
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DeliverPackageController
        {
            let vc = segue.destination as? DeliverPackageController
            vc?.package = self.customPin?.package
            vc?.packageId = self.customPin?.packageId
        }
    }
    
    /*
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        print("viewForannotation")
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            //println("Pinview was nil")
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        
        let button = UIButton(type: .detailDisclosure) // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        
        return pinView
    }*/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKUserLocation) {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.tag = annotation.hash
            
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = rightButton
            
            return pinView
        }
        else {
            return nil
        }
    }
    
    func addPackageOnMap(){
        //mapView.removeAnnotations(mapView.annotations)
        for (index,value) in self.packages.enumerated(){
            //if(value.value.count == 11){
                let pickupAddress = value.value["pickupAddress"] as! NSDictionary
                let latitude = pickupAddress["latitude"] as! Double
                let longitude = pickupAddress["longitude"] as! Double
                let description = value.value["description"] as! String
                let price = value.value["value"] as! Float
                let owner = value.value["owner"] as! String
        
                //let annotationView = MKAnnotationView()

                //let detailButton: UIButton = UIButton(type: .detailDisclosure)
                //annotationView.rightCalloutAccessoryView = detailButton
            
                let annotation = CustomPin()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = owner + ":" + description
                annotation.subtitle = price.description
                annotation.package = value.value
                annotation.packageId = value.key
                let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
                mapView.addAnnotation(pinAnnotationView.annotation!)
                //let span = MKCoordinateSpanMake(0.05, 0.05)
                //let region = MKCoordinateRegionMake(placemark.coordinate, span)
                //mapView.setRegion(region, animated: true)*/
            //}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //override func viewWillDisappear(_ animated: Bool) {
    //    super.viewWillAppear(animated)
    //    Auth.auth().removeStateDidChangeListener(handle!)
    //}

   // @IBAction func searchLocation(_ sender: Any) {
  //      let searchController = UISearchController(searchResultsController: nil)
 //        searchController.searchBar.delegate = self
//        present(searchController, animated: true, completion: nil)
  //  }
    
   /* func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        //activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //create search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil
            {
                print("Error")
            }
            else{
                //removing annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                //getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
            
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                annotation.title = searchBar.text
                annotation.subtitle = "Location Subtitle"
                self.mapView.addAnnotation(annotation)
                
                //zooming in annotation
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }*/
    
    /*func writeTest(){
        ref?.child("users").childByAutoId().setValue("lamberto")
        //print(userID)
        //self.ref.child("users").child(userID).setValue(["username": "lamberto"])
    }
    
    func readTest(){
        handle = ref?.child("packages").child("lamberto").observe(.childAdded, with: { (snapshot) in
            //code to execute when a child is added under users
            if(snapshot.exists()){
            //try to convert the value of the data to a String
                //--let data = snapshot.value as? NSDictionary
                //self.packages[snapshot.key] = snapshot.value as? NSDictionary
                /*let enumerator = snapshot.
                while let listObject = enumerator.nextObject() as? DataSnapshot {
                    print("Key: \(listObject.key)")
                    let object = listObject.value as! [String: AnyObject]
                     print(object.description)
                }*/
            //just to know that data is not empty
            //--if let actualData = data{
            //--    print(actualData.)
            //--}
            }
            
            /*for (packageID, packageDetail) in self.packages{
                print("\(packageID):\(packageDetail.description)")
            }*/
            
        })
        
    }*/
    
    func createPackageDetails()->PackageDetails{
        let packageDetails = PackageDetails.init(packDescription: "Test2", packValue: 1, packSize: 1, packWeight: 1)
        
        //packageDetails.picture = imageTest.image
        
        print("ID: teste, name: \(packageDetails.description), value: \(packageDetails.value), size: \(packageDetails.size), weight: \(packageDetails.weight)")
        return packageDetails
    }
    
   /* @IBAction func buttonPackageImage(_ sender: Any) {
        getPackagePicture()
    }*/
    
    /*func getPackagePicture(){
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            //self.package!.picture = image
            self.imageTest.image = image
            self.uploadPackageImage(package: self.package!)
        }
    }*/
    
    /*func uploadPackageImage(package:PackageDetails){
        // Points to "images"
        let imagesRef = storageRef?.child("images")
        
        // Points to "images/imageName.jpg"
        // Note that you can use variables to create child values
        let fileName = "test"//package.id
        let packageRef = imagesRef?.child("\(fileName).jpg")
        
        // File path is "images/imageName.jpg"
        let path = packageRef?.fullPath;
        
        // File name is "space.jpg"
        let name = packageRef?.name;
        
        // Points to "bucket"
        let bucket = packageRef?.bucket
        
        print("name:\(String(describing: name)), path:\(String(describing: path)), Bucket:\(String(describing: bucket))")
        
        // Data in memory
        let data = imageTest.image?.jpegRepresentationData
        
        // Create a reference to the file you want to upload
        //let riversRef = storageRef.child("images/rivers.jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = packageRef?.putData(data as! Data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            package.url = metadata.downloadURL()
            print(package.url?.absoluteString)
            self.ref?.child("package").child(package.description).setValue(package.url?.absoluteString)
        }
        
        
    }*/
    /*@IBAction func loadImage(_ sender: Any) {
        showPackageImage()
    }*/
    
    @IBAction func createPost(_ sender: Any) {
        performSegue(withIdentifier: "createPost", sender: self)
    }
    
    
    /*func showPackageImage(){
        // Reference to an image file in Firebase Storage
        let reference = storageRef?.child("package/pack1")
        print("path:\(String(describing: reference?.fullPath))")
        let referenceUrl = URL(string: "https://firebasestorage.googleapis.com/v0/b/korio-d75bf.appspot.com/o/images%2Fpack2.jpg?alt=media&token=0e08ae5f-df4d-4fab-ba6a-375197d1f839")
        // UIImageView in your ViewController
        let imageView: UIImageView = self.imageTest
        
        // Placeholder image
        let placeholderImage = UIImage(named: "placeholder.jpg")
                
        // Load the image using SDWebImage
        imageView.sd_setImage(with: referenceUrl!, placeholderImage: placeholderImage)
    }*/
    
   /* func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }*/

}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        //selectedPin = placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        //let annotation = MKPointAnnotation()
        //annotation.coordinate = placemark.coordinate
        //annotation.title = placemark.name
        //if let city = placemark.locality,
        //    let state = placemark.administrativeArea {
        //    annotation.subtitle = "\(city) \(state)"
        //}
        //mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

//MARK: Add Toast method function in UIView Extension so can use in whole project.
extension UIView
{
    func showToast(toastMessage:String,duration:CGFloat)
    {
        //View to blur bg and stopping user interaction
        let bgView = UIView(frame: self.frame)
        bgView.backgroundColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.6))
        bgView.tag = 555
        
        //Label For showing toast text
        let lblMessage = UILabel()
        lblMessage.numberOfLines = 0
        lblMessage.lineBreakMode = .byWordWrapping
        lblMessage.textColor = .white
        lblMessage.backgroundColor = .black
        lblMessage.textAlignment = .center
        lblMessage.font = UIFont.init(name: "Helvetica Neue", size: 17)
        lblMessage.text = toastMessage
        
        //calculating toast label frame as per message content
        let maxSizeTitle : CGSize = CGSize(width: self.bounds.size.width-16, height: self.bounds.size.height)
        var expectedSizeTitle : CGSize = lblMessage.sizeThatFits(maxSizeTitle)
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeTitle = CGSize(width:maxSizeTitle.width.getminimum(value2:expectedSizeTitle.width), height: maxSizeTitle.height.getminimum(value2:expectedSizeTitle.height))
        lblMessage.frame = CGRect(x:((self.bounds.size.width)/2) - ((expectedSizeTitle.width+16)/2) , y: (self.bounds.size.height/2) - ((expectedSizeTitle.height+16)/2), width: expectedSizeTitle.width+16, height: expectedSizeTitle.height+16)
        lblMessage.layer.cornerRadius = 8
        lblMessage.layer.masksToBounds = true
        lblMessage.padding = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        bgView.addSubview(lblMessage)
        self.addSubview(bgView)
        lblMessage.alpha = 0
        
        UIView.animateKeyframes(withDuration:TimeInterval(duration) , delay: 0, options: [] , animations: {
            lblMessage.alpha = 1
        }, completion: {
            sucess in
            UIView.animate(withDuration:TimeInterval(duration), delay: 8, options: [] , animations: {
                lblMessage.alpha = 0
                bgView.alpha = 0
            })
            bgView.removeFromSuperview()
        })
    }
}

extension CGFloat
{
    func getminimum(value2:CGFloat)->CGFloat
    {
        if self < value2
        {
            return self
        }
        else
        {
            return value2
        }
    }
}

//MARK: Extension on UILabel for adding insets - for adding padding in top, bottom, right, left.

/*extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}*/

extension UILabel
{
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            if let insets = padding {
                contentSize.height += insets.top + insets.bottom
                contentSize.width += insets.left + insets.right
            }
            return contentSize
        }
    }
}

extension MKMapView {
    func searchForCustomAnnotation(like query: String) -> [MKAnnotation] {
        let allAnnotations = self.annotations;
        return allAnnotations.filter { annotation in
            if let customAnnotation = annotation as? MKPointAnnotation {
                return customAnnotation.title!.caseInsensitiveSearch(query);
            }
            else{
                return false
            }
        }
    }
}
/*
extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.first != nil {
            print("location:: \(locations)")
        }
        
    }
    
}*/


