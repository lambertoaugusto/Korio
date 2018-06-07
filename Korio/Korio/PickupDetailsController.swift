//
//  PickupDetailsController.swift
//  Korio
//
//  Created by Student on 2018-02-21.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation
import Contacts

class PickupDetailsController: UIViewController {
    //@IBOutlet weak var date: UITextField!
    
    
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var person: UITextField!
    @IBOutlet weak var pickupDate: UIDatePicker!
    
    //var locationManager: CLLocationManager!
    
    //var packageDetails: PackageDetails!
    //var pickupDetails: PickupDetails!
    var placeMark: MKPlacemark!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.isMovingFromParentViewController){
            if !((self.address.text!).isEmpty){
                let addressObj = Address(lat: placeMark.coordinate.latitude, long: placeMark.coordinate.longitude, str: (placeMark.addressDictionary?["Street"] as? String)!, ct: placeMark.locality!, st: placeMark.administrativeArea!, pc: placeMark.postalCode!, co: placeMark.country!, coc: placeMark.countryCode!)
                package.addPickupDetails(address: addressObj, date: self.pickupDate.date)
                if(!((self.person.text ?? "").isEmpty)){
                    package.pickupDetails?.pickupPerson = self.person.text
                }
            }
            else{
                self.showAlert(title: "Error", message: "Pick up address is required!")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //print("PickupDetailsController viewDidLoad called")
        
        pickupDate.minimumDate = Date()
        
        // Do any additional setup after loading the view.
        
        let pickDetails = package.pickupDetails
        if(pickDetails != nil){
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = pickDetails?.pickupAddress.street ?? ""//placeMark?.thoroughfare ?? ""
            postalAddress.city = pickDetails?.pickupAddress.city ?? ""
            postalAddress.state = pickDetails?.pickupAddress.state ?? ""
            postalAddress.postalCode = pickDetails?.pickupAddress.postalCode ?? ""
            postalAddress.country = pickDetails?.pickupAddress.country ?? ""
            postalAddress.isoCountryCode = pickDetails?.pickupAddress.countryCode ?? ""
            
            self.address.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            
            pickupDate.setDate((pickDetails?.pickupDate)!, animated: false)
            if(!((pickDetails?.pickupPerson ?? "").isEmpty)){
                person.text = pickDetails?.pickupPerson
            }
        }
    }

    
    @IBAction func unwindToPickupDetails(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MapSelectionController {
            
            // use the Contacts framework to create a readable formatter address
            placeMark = sourceViewController.selectedPin!
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = (placeMark.addressDictionary?["Street"] as? String) ?? ""//placeMark?.thoroughfare ?? ""
            postalAddress.city = placeMark.locality ?? ""
            postalAddress.state = placeMark.administrativeArea ?? ""
            postalAddress.postalCode = placeMark.postalCode ?? ""
            postalAddress.country = placeMark.country ?? ""
            postalAddress.isoCountryCode = placeMark.isoCountryCode ?? ""
            
            self.address.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)

/*
            print("coor:\(String(describing: sourceViewController.selectedPin?.coordinate)), name:\(String(describing: sourceViewController.selectedPin?.name ?? "")), city:\(String(describing: sourceViewController.selectedPin?.locality ?? "")), state:\(String(describing: sourceViewController.selectedPin?.administrativeArea ?? "")), countryCode:\(String(describing: sourceViewController.selectedPin?.countryCode ?? "")),  title:\(String(describing: sourceViewController.selectedPin?.title ?? "")), country:\(String(describing: sourceViewController.selectedPin?.country ?? "")), Postal code:\(String(describing: sourceViewController.selectedPin?.postalCode ?? "")), subAdmArea:\(String(describing: sourceViewController.selectedPin?.subAdministrativeArea ?? "")), subLocality:\(String(describing: sourceViewController.selectedPin?.subLocality ?? ""))")*/
        
            //subtitle:\(String(describing: sourceViewController.selectedPin?.subtitle ?? "")), ,
        }
    }
    
    func showAlert(title: String, message: String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func pickupDetailsNext(_ sender: Any) {
        if !((self.address.text!).isEmpty){
            let addressObj = Address(lat: placeMark.coordinate.latitude, long: placeMark.coordinate.longitude, str: (placeMark.addressDictionary?["Street"] as? String)!, ct: placeMark.locality!, st: placeMark.administrativeArea!, pc: placeMark.postalCode!, co: placeMark.country!, coc: placeMark.countryCode!)
            package.addPickupDetails(address: addressObj, date: self.pickupDate.date)
            if(!((self.person.text ?? "").isEmpty)){
                package.pickupDetails?.pickupPerson = self.person.text
                performSegue(withIdentifier: "startDeliveryDetails", sender: self)
            }            
        }
        else{
            self.showAlert(title: "Error", message: "Pick up address is required!")
        }
    }
    
    
    @IBAction func addAddress(_ sender: Any) {
        performSegue(withIdentifier: "startMapSelection", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DeliveryDetailsController
        {
            let vc = segue.destination as? DeliveryDetailsController
                vc?.pickupDetails = self.pickupDetails
                vc?.packageDetails = self.packageDetails
        }
    }*/


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


