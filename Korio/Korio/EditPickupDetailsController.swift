//
//  EditPickupDetailsController.swift
//  Korio
//
//  Created by Student on 2018-03-07.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Contacts
import MapKit

class EditPickupDetailsController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    //@IBOutlet weak var pickupDate: UITextField!
    
    @IBOutlet weak var pickupAddress: UITextView!
    @IBOutlet weak var pickupPerson: UITextField!
    
    var pickupDetails: PickupDetails?
    var id: String?
    
     var placeMark: MKPlacemark!
    
    @IBAction func addAddress(_ sender: Any) {
        performSegue(withIdentifier: "startMapSelectionEditPickup", sender: self)
    }
    
    @IBAction func unwindToEditPickupAddress(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MapSelPickupEditController {
            
            // use the Contacts framework to create a readable formatter address
            placeMark = sourceViewController.selectedPin!
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = (placeMark.addressDictionary?["Street"] as? String) ?? ""//placeMark?.thoroughfare ?? ""
            postalAddress.city = placeMark.locality ?? ""
            postalAddress.state = placeMark.administrativeArea ?? ""
            postalAddress.postalCode = placeMark.postalCode ?? ""
            postalAddress.country = placeMark.country ?? ""
            postalAddress.isoCountryCode = placeMark.isoCountryCode ?? ""
            
            self.pickupAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        }
    }
    
    
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.setDate((pickupDetails?.pickupDate)!, animated: false)
        if(!((pickupDetails?.pickupPerson ?? "").isEmpty)){
            pickupPerson.text = pickupDetails?.pickupPerson
        }
        
        //pickupDate.text = pickupDetails?.pickupDate
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = pickupDetails?.pickupAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress.city = pickupDetails?.pickupAddress.city ?? ""
        postalAddress.state = pickupDetails?.pickupAddress.state ?? ""
        postalAddress.postalCode = pickupDetails?.pickupAddress.postalCode ?? ""
        postalAddress.country = pickupDetails?.pickupAddress.country ?? ""
        postalAddress.isoCountryCode = pickupDetails?.pickupAddress.countryCode ?? ""
        
        pickupAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        
        
        let coordinate = CLLocationCoordinate2D(latitude: (self.pickupDetails?.pickupAddress.latitude)!, longitude: (self.pickupDetails?.pickupAddress.longitude)!)
        placeMark = MKPlacemark(coordinate: coordinate, postalAddress: postalAddress)
        
        //pickupPerson.text = pickupDetails?.pickupPerson
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(title: String, message: String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        //let itemReference = FIREBASE().ref.child("packages").child(USER().id).child((self.pickupDetails?.id)!)
        if !((self.pickupAddress.text!).isEmpty){
            
            let addressObj = Address(lat: placeMark.coordinate.latitude, long: placeMark.coordinate.longitude, str: (placeMark.addressDictionary?["Street"] as? String)!, ct: placeMark.locality!, st: placeMark.administrativeArea!, pc: placeMark.postalCode!, co: placeMark.country!, coc: placeMark.countryCode!)
            self.pickupDetails?.pickupAddress = addressObj
            self.pickupDetails?.pickupDate = self.datePicker.date
            if(!((self.pickupPerson.text ?? "").isEmpty)){
                self.pickupDetails?.pickupPerson = self.pickupPerson.text
            }
            do {
                try self.pickupDetails?.savePickUpDetailsFirebase(id: self.id!)
                FIREBASE().ref.child(userId).child(self.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.hasChild("deliveryPerson"){
                        print("exist delivery person")
                        let packageData = ["status": "changed",
                                           "new": true] as [String : Any]
                        FIREBASE().ref.child(userId).child(self.id!).updateChildValues(packageData)//FIREBASE().ref.child(USER().id).child(self.id!).child("status").setValue("changed")
                        //FIREBASE().ref.child(USER().id).child(self.id!).child("new").setValue(true)
                        print("EditPickupDetailsController")
                    }else{
                        print("delivery person doesn't exist")
                    }
                    
                    
                })

                performSegue(withIdentifier: "EditPickupDetailsUnwindSegue", sender: self)
            } catch let error {
                self.showAlert(title: "Error", message: "Can not save Pick up Details")
            }
        }
        else{
            self.showAlert(title: "Error", message: "Pick up address is required!")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HistoryCellDetailsController
        {
            var vc = segue.destination as? HistoryCellDetailsController
            vc?.package.pickupDetails = self.pickupDetails
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
