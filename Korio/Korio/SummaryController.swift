//
//  SummaryController.swift
//  Korio
//
//  Created by Student on 2018-02-25.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Contacts

class SummaryController: UIViewController {
    
    //var packageDetails: PackageDetails!
    //var pickupDetails: PickupDetails!
    //var deliveryDetails: DeliveryDetails!

    @IBOutlet weak var specialInstructions: UILabel!
    @IBOutlet weak var signatureRequired: UILabel!
    @IBOutlet weak var labelSpecialInstructions: UILabel!
    @IBOutlet weak var buttonSpecialInstructions: UIButton!
    
    @IBOutlet weak var receiverAddressView: UITextView!
    
    @IBOutlet weak var deliveryDateView: UILabel!
    @IBOutlet weak var pickupDateView: UILabel!
    @IBOutlet weak var receiverView: UILabel!
    
    @IBOutlet weak var pickupAddressView: UITextView!

    @IBOutlet weak var pickupPersonView: UILabel!
    @IBOutlet weak var weightView: UILabel!
    @IBOutlet weak var sizeView: UILabel!
    @IBOutlet weak var valueView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if ((package.specialInstruction ?? "").isEmpty){
            self.buttonSpecialInstructions.isHidden = false
            self.labelSpecialInstructions.isHidden = true
            self.specialInstructions.isHidden = true
        }
        else{
            self.specialInstructions.text = package.specialInstruction
            self.buttonSpecialInstructions.isHidden = true
            self.labelSpecialInstructions.isHidden = false
            self.specialInstructions.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("SummaryController viewDidLoad called")
        
        if ((package.specialInstruction ?? "").isEmpty){
            self.buttonSpecialInstructions.isHidden = false
            self.labelSpecialInstructions.isHidden = true
            self.specialInstructions.isHidden = true
        }
        else{
            self.specialInstructions.text = package.specialInstruction
            self.buttonSpecialInstructions.isHidden = true
            self.labelSpecialInstructions.isHidden = false
            self.specialInstructions.isHidden = false
        }
        
        
        //showing package details
        self.descriptionView.text = package.packageDetails?.description
        self.valueView.text = package.packageDetails?.value.description
        self.sizeView.text = SIZE().sizeData[(package.packageDetails?.size)!]
        self.weightView.text = package.packageDetails?.weight.description
        
        //insert image if exists
        
        //showing pickup details
        self.pickupPersonView.text = (package.pickupDetails?.pickupPerson ?? "self")
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = package.pickupDetails?.pickupAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress.city = package.pickupDetails?.pickupAddress.city ?? ""
        postalAddress.state = package.pickupDetails?.pickupAddress.state ?? ""
        postalAddress.postalCode = package.pickupDetails?.pickupAddress.postalCode ?? ""
        postalAddress.country = package.pickupDetails?.pickupAddress.country ?? ""
        postalAddress.isoCountryCode = package.pickupDetails?.pickupAddress.countryCode ?? ""
        
        self.pickupAddressView.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var strDate = dateFormatter.string(from: (package.pickupDetails?.pickupDate)!)
        self.pickupDateView.text = strDate
        
        //showing delivery details
        self.receiverView.text = package.deliveryDetails?.ReceiverName
        
        let postalAddressRec = CNMutablePostalAddress()
        postalAddressRec.street = package.deliveryDetails?.DeliveryAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddressRec.city = package.deliveryDetails?.DeliveryAddress.city ?? ""
        postalAddressRec.state = package.deliveryDetails?.DeliveryAddress.state ?? ""
        postalAddressRec.postalCode = package.deliveryDetails?.DeliveryAddress.postalCode ?? ""
        postalAddressRec.country = package.deliveryDetails?.DeliveryAddress.country ?? ""
        postalAddressRec.isoCountryCode = package.deliveryDetails?.DeliveryAddress.countryCode ?? ""
        
        
        self.receiverAddressView.text = CNPostalAddressFormatter.string(from: postalAddressRec, style: .mailingAddress)
        
        strDate = dateFormatter.string(from: (package.deliveryDetails?.DateOfDelivery)!)
        self.deliveryDateView.text = strDate
        if(package.deliveryDetails?.SignatureRequired)!{
            self.signatureRequired.text = "Signature Required"
        }
        else{
            self.signatureRequired.text = "Signature Not Required"
        }
        
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

    
    @IBAction func SaveFirebase(_ sender: Any) {
        //package.generateID()
        //package.packageDetails?.savePackageDetailsFirebase(id: package.id!)
        package.save(specialInstructions: self.specialInstructions.text ?? "", status: "posted")
        if(package.packageDetails?.image != nil){
            package.packageDetails?.savePackageImageFirebase(id: package.id!)
        }
        //package.pickupDetails?.savePickUpDetailsFirebase(id: package.id!)
        //package.deliveryDetails?.saveDeliveryDetailsFirebase(id: package.id!)
        //if(buttonSpecialInstructions.isHidden){
        //    FIREBASE().ref.child(package.id!).child("specialInstructions").setValue(self.specialInstructions.text)
        //}
        performSegue(withIdentifier: "postSegue", sender: self)
        
        //print("calling save FirebaseTest")
        /*do {
            try package.generateID()
            do {
                try package.packageDetails?.savePackageDetailsFirebase(id: package.id!)
                if(package.packageDetails?.url != nil){
                    do {
                        try package.packageDetails?.savePackageImageFirebase(id: package.id!)
                        do {
                            try package.pickupDetails?.savePickUpDetailsFirebase(id: package.id!)
                            do {
                                try package.deliveryDetails?.saveDeliveryDetailsFirebase(id: package.id!)
                                if(buttonSpecialInstructions.isHidden){
                                    do {
                                        try FIREBASE().ref.child(package.id!).child("specialInstructions").setValue(self.specialInstructions.text)
                                    } catch let error {
                                        FIREBASE().ref.child(package.id!).removeValue()
                                        FIREBASE().storageRef.child("\(package.id!).jpg").delete{ error in
                                            if let error = error {
                                                // Uh-oh, an error occurred!
                                            } else {
                                                // File deleted successfully
                                            }
                                        }
                                        showAlert(title: "Connection Error", message: "Can not save Special Instructions")
                                    }
                                }
                            } catch let error {
                                FIREBASE().ref.child(package.id!).removeValue()
                                FIREBASE().storageRef.child("\(package.id!).jpg").delete{ error in
                                    if let error = error {
                                        // Uh-oh, an error occurred!
                                    } else {
                                        // File deleted successfully
                                    }
                                }
                                showAlert(title: "Connection Error", message: "Can not save Delivery Details")
                            }
                        } catch let error {
                            FIREBASE().ref.child(package.id!).removeValue()
                            FIREBASE().storageRef.child("\(package.id!).jpg").delete{ error in
                                if let error = error {
                                    // Uh-oh, an error occurred!
                                } else {
                                    // File deleted successfully
                                }
                            }
                            showAlert(title: "Connection Error", message: "Can not save Pick up Details")
                        }
                    } catch let error {
                        FIREBASE().ref.child(package.id!).removeValue()
                        showAlert(title: "Connection Error", message: "Can not save Package Image")
                    }
                }
            } catch let error {
                showAlert(title: "Connection Error", message: "Can not save Package Details")
            }
        } catch let error {
            showAlert(title: "Connection Error", message: "Can not generate Package ID")
        }*/
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.view.showToast(toastMessage: "Package posted!", duration: 2)
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func addSpecialInstructions(_ sender: Any) {
        showInputDialog()
    }
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Special Instructions", message: "Enter your special instructions", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            let instructions = alertController.textFields?[0].text
            self.specialInstructions.text = instructions
            package.specialInstruction = instructions
            
            self.buttonSpecialInstructions.isHidden = true
            self.labelSpecialInstructions.isHidden = false
            self.specialInstructions.isHidden = false
            
            //self.labelMessage.text = "Name: " + name! + "Email: " + email!
            
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        
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

}
