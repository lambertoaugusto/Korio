//
//  DeliveryDetailsController.swift
//  Korio
//
//  Created by Student on 2018-02-21.
//  Copyright © 2018 Korio. All rights reserved.
//
import MapKit
import UIKit
import Contacts

class DeliveryDetailsController: UIViewController {
    //@IBOutlet weak var signatureReqd: UITextField!
    //@IBOutlet weak var DeliveryDate: UITextField!
    
    @IBOutlet weak var ReceiverAddress: UITextView!
    
    @IBOutlet weak var Receievername: UITextField!
    
    @IBOutlet weak var deliverDate: UIDatePicker!
    @IBOutlet weak var requestSign: CheckBox!
    
    //var packageDetails: PackageDetails!
    //var pickupDetails: PickupDetails!
    //var deliveryDetails: DeliveryDetails!
    
    var placeMark: MKPlacemark!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deliverDate.minimumDate = package.pickupDetails?.pickupDate
        
        if(self.isMovingFromParentViewController){
            if !((self.ReceiverAddress.text!).isEmpty){
                if !((self.Receievername.text!).isEmpty){
                    let addressObj = Address(lat: placeMark.coordinate.latitude, long: placeMark.coordinate.longitude, str: (placeMark.addressDictionary?["Street"] as? String)!, ct: placeMark.locality!, st: placeMark.administrativeArea!, pc: placeMark.postalCode!, co: placeMark.country!, coc: placeMark.countryCode!)
                    
                    package.addDeliveryDetails(ReceiverName: self.Receievername.text!, address: addressObj, DeliveryDate: deliverDate.date, sign: requestSign.isChecked)
                }
                else{
                    self.showAlert(title: "Error", message: "Receiver name is required!")
                }
            }
            else{
                self.showAlert(title: "Error", message: "Receiver address is required!")
            }
        }
    }

    @IBAction func unwindToDeliveryDetails(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MapSelReceiveAddressController {
            
            // use the Contacts framework to create a readable formatter address
            placeMark = sourceViewController.selectedPin
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = (placeMark?.addressDictionary?["Street"] as? String) ?? ""//placeMark?.thoroughfare ?? ""
            postalAddress.city = placeMark?.locality ?? ""
            postalAddress.state = placeMark?.administrativeArea ?? ""
            postalAddress.postalCode = placeMark?.postalCode ?? ""
            postalAddress.country = placeMark?.country ?? ""
            postalAddress.isoCountryCode = placeMark?.isoCountryCode ?? ""
            
            self.ReceiverAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            
            /*print("coor:\(String(describing: sourceViewController.selectedPin?.coordinate)), name:\(String(describing: sourceViewController.selectedPin?.name ?? "")), city:\(String(describing: sourceViewController.selectedPin?.locality ?? "")), state:\(String(describing: sourceViewController.selectedPin?.administrativeArea ?? "")), countryCode:\(String(describing: sourceViewController.selectedPin?.countryCode ?? "")),  title:\(String(describing: sourceViewController.selectedPin?.title ?? "")), country:\(String(describing: sourceViewController.selectedPin?.country ?? "")), Postal code:\(String(describing: sourceViewController.selectedPin?.postalCode ?? "")), subAdmArea:\(String(describing: sourceViewController.selectedPin?.subAdministrativeArea ?? "")), subLocality:\(String(describing: sourceViewController.selectedPin?.subLocality ?? ""))")
            */
            //subtitle:\(String(describing: sourceViewController.selectedPin?.subtitle ?? "")), ,
        }
    }

    @IBAction func addReceiverAddress(_ sender: Any) {
        performSegue(withIdentifier: "startMapSelectionReceiveAddress", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deliverDate.minimumDate = package.pickupDetails?.pickupDate
        //print("DeliveryDetailsController viewDidLoad called")

        // Do any additional setup after loading the view.
        let deliDetails = package.deliveryDetails
        if(deliDetails != nil){
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = deliDetails?.DeliveryAddress.street ?? ""//placeMark?.thoroughfare ?? ""
            postalAddress.city = deliDetails?.DeliveryAddress.city ?? ""
            postalAddress.state = deliDetails?.DeliveryAddress.state ?? ""
            postalAddress.postalCode = deliDetails?.DeliveryAddress.postalCode ?? ""
            postalAddress.country = deliDetails?.DeliveryAddress.country ?? ""
            postalAddress.isoCountryCode = deliDetails?.DeliveryAddress.countryCode ?? ""
            
            self.ReceiverAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            
            self.Receievername.text = deliDetails?.ReceiverName
            self.requestSign.isChecked = (deliDetails?.SignatureRequired)!
            self.deliverDate.setDate((deliDetails?.DateOfDelivery)!, animated: false)
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

    @IBAction func DeliveryDetailsNext(_ sender: Any) {
        if !((self.ReceiverAddress.text!).isEmpty){
            if !((self.Receievername.text!).isEmpty){
                let addressObj = Address(lat: placeMark.coordinate.latitude, long: placeMark.coordinate.longitude, str: (placeMark.addressDictionary?["Street"] as? String)!, ct: placeMark.locality!, st: placeMark.administrativeArea!, pc: placeMark.postalCode!, co: placeMark.country!, coc: placeMark.countryCode!)
                package.addDeliveryDetails(ReceiverName: self.Receievername.text!, address: addressObj, DeliveryDate: deliverDate.date, sign: requestSign.isChecked)
                performSegue(withIdentifier: "startSummary", sender: self)
            }
            else{
                self.showAlert(title: "Error", message: "Receiver name is required!")
            }
        }
        else{
            self.showAlert(title: "Error", message: "Receiver address is required!")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SummaryController
        {
            let vc = segue.destination as? SummaryController
            vc?.packageDetails = self.packageDetails
            vc?.pickupDetails = self.pickupDetails
            vc?.deliveryDetails = self.deliveryDetails
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
