//
//  EditDeliveryDetailsController.swift
//  Korio
//
//  Created by Student on 2018-03-07.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Contacts
import MapKit

class EditDeliveryDetailsController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    //@IBOutlet weak var deliveryDate: UITextField!
    
    @IBOutlet weak var receiverAddress: UITextView!
    
    @IBOutlet weak var receiver: UITextField!
    
    @IBOutlet weak var checkBox: CheckBox!
    
    @IBAction func addAddress(_ sender: Any) {
        performSegue(withIdentifier: "startMapSelectionEditDelivery", sender: self)
    }
    var deliveryDetails: DeliveryDetails?
    var id: String?
    
    var placeMark: MKPlacemark!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = deliveryDetails?.DeliveryAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress.city = deliveryDetails?.DeliveryAddress.city ?? ""
        postalAddress.state = deliveryDetails?.DeliveryAddress.state ?? ""
        postalAddress.postalCode = deliveryDetails?.DeliveryAddress.postalCode ?? ""
        postalAddress.country = deliveryDetails?.DeliveryAddress.country ?? ""
        postalAddress.isoCountryCode = deliveryDetails?.DeliveryAddress.countryCode ?? ""
        
        self.receiverAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)

        self.receiver.text = deliveryDetails?.ReceiverName
        self.checkBox.isChecked = (deliveryDetails?.SignatureRequired)!
        self.datePicker.setDate((deliveryDetails?.DateOfDelivery)!, animated: false)

        
        let coordinate = CLLocationCoordinate2D(latitude: (self.deliveryDetails?.DeliveryAddress.latitude)!, longitude: (self.deliveryDetails?.DeliveryAddress.longitude)!)
        placeMark = MKPlacemark(coordinate: coordinate, postalAddress: postalAddress)
        //deliveryDate.text = deliveryDetails?.DateOfDelivery
        //receiver.text = deliveryDetails?.ReceiverName
        //receiverAddress.text = deliveryDetails?.DeliveryAddress
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToEditDeliveryAddress(sender: UIStoryboardSegue) {
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
            
            self.receiverAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        }
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
        //let itemReference = FIREBASE().ref.child("packages").child(USER().id).child((self.deliveryDetails?.id)!)
        
        if !((self.receiverAddress.text!).isEmpty){
            if !((self.receiver.text!).isEmpty){
                self.deliveryDetails?.DateOfDelivery = datePicker.date
                
                let addressObj = Address(lat: placeMark.coordinate.latitude, long: placeMark.coordinate.longitude, str: (placeMark.addressDictionary?["Street"] as? String)!, ct: placeMark.locality!, st: placeMark.administrativeArea!, pc: placeMark.postalCode!, co: placeMark.country!, coc: placeMark.countryCode!)
                
                self.deliveryDetails?.DeliveryAddress = addressObj
                self.deliveryDetails?.ReceiverName = self.receiver.text!
                self.deliveryDetails?.SignatureRequired = checkBox.isChecked
                do {
                    try deliveryDetails?.saveDeliveryDetailsFirebase(id: self.id!)
                    FIREBASE().ref.child(userId).child(self.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.hasChild("deliveryPerson"){
                            print("exist delivery person")
                            let packageData = ["status": "changed",
                                               "new": true] as [String : Any]
                            
                            FIREBASE().ref.child(userId).child(self.id!).updateChildValues(packageData)
                            //FIREBASE().ref.child(USER().id).child(self.id!).child("status").setValue("changed")
                            //FIREBASE().ref.child(USER().id).child(self.id!).child("new").setValue(true)
                                print("editDeliveryDetailsController")
                            
                        }else{
                            print("delivery person doesn't exist")
                        }
                        
                        
                    })

                    performSegue(withIdentifier: "EditDeliveryDetailsUnwindSegue", sender: self)
                } catch let error {
                    self.showAlert(title: "Error", message: "Can not save Delivery Details!")
                }
                
            }
            else{
                self.showAlert(title: "Error", message: "Receiver name is required!")
            }
        }
        else{
            self.showAlert(title: "Error", message: "Receiver address is required!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HistoryCellDetailsController
        {
            var vc = segue.destination as? HistoryCellDetailsController
            vc?.package.deliveryDetails = self.deliveryDetails
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
