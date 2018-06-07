//
//  DeliveryCellDetailController.swift
//  Korio
//
//  Created by Student on 2018-04-04.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Contacts

class DeliveryCellDetailController: UIViewController {
    
    var package: Package = Package()
    
    var status: String?
    var owner: String?
    var msg: String?
    var index: Int?
    
    @IBOutlet weak var packageValue: UILabel!
    @IBOutlet weak var packageDescription: UILabel!
    @IBOutlet weak var packageImage: UIImageView!
    @IBOutlet weak var pickupAddress: UITextView!
    @IBOutlet weak var pickupPerson: UILabel!
    @IBOutlet weak var packageWeight: UILabel!
    @IBOutlet weak var receiverPerson: UILabel!
    @IBOutlet weak var pickupDate: UILabel!
    @IBOutlet weak var receiverAddress: UITextView!
    @IBOutlet weak var deliveryDate: UILabel!
    @IBOutlet weak var packageSize: UILabel!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var deliveyButton: UIButton!

    @IBOutlet weak var acceptButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.packageValue.text = self.package.packageDetails?.value.description
        self.packageDescription.text = self.package.packageDetails?.description
        self.packageWeight.text = self.package.packageDetails?.weight.description
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = package.pickupDetails?.pickupAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress.city = package.pickupDetails?.pickupAddress.city ?? ""
        postalAddress.state = package.pickupDetails?.pickupAddress.state ?? ""
        postalAddress.postalCode = package.pickupDetails?.pickupAddress.postalCode ?? ""
        postalAddress.country = package.pickupDetails?.pickupAddress.country ?? ""
        postalAddress.isoCountryCode = package.pickupDetails?.pickupAddress.countryCode ?? ""
        
        self.pickupAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        
        self.pickupPerson.text = package.pickupDetails?.pickupPerson ?? "self"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var strDate = dateFormatter.string(from: (package.pickupDetails?.pickupDate)!)
        self.pickupDate.text = strDate
        
        self.receiverPerson.text = package.deliveryDetails?.ReceiverName
        
        let postalAddress2 = CNMutablePostalAddress()
        postalAddress2.street = package.deliveryDetails?.DeliveryAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress2.city = package.deliveryDetails?.DeliveryAddress.city ?? ""
        postalAddress2.state = package.deliveryDetails?.DeliveryAddress.state ?? ""
        postalAddress2.postalCode = package.deliveryDetails?.DeliveryAddress.postalCode ?? ""
        postalAddress2.country = package.deliveryDetails?.DeliveryAddress.country ?? ""
        postalAddress2.isoCountryCode = package.deliveryDetails?.DeliveryAddress.countryCode ?? ""
        
        self.receiverAddress.text  = CNPostalAddressFormatter.string(from: postalAddress2, style: .mailingAddress)
        
        strDate = dateFormatter.string(from: (package.deliveryDetails?.DateOfDelivery)!)
        self.deliveryDate.text = strDate
        self.packageSize.text = SIZE().sizeData[(package.packageDetails?.size)!]

        if(self.status == "accepted"){
            self.statusLabel.text = "Waiting for approval"
            self.acceptButton.isHidden = true
            self.rejectButton.isHidden = true
            self.deliveyButton.isHidden = true
        }
        else if(self.status == "changed"){
            self.statusLabel.text = "Package changed"
            self.acceptButton.isHidden = false
            self.rejectButton.isHidden = false
            self.deliveyButton.isHidden = true
        }
        else if(self.status == "authorized"){
            self.statusLabel.text = "Package authorized"
            self.acceptButton.isHidden = true
            self.rejectButton.isHidden = true
            self.deliveyButton.isHidden = false
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func accept(_ sender: Any) {
        FIREBASE().ref.child(self.owner!).child(self.package.id!).child("status").setValue("accepted")
        FIREBASE().ref.child(self.owner!).child(self.package.id!).child("new").setValue(true)
        print("deliveryCellDetailController")
        self.msg = "Package changes accepted!"
        performSegue(withIdentifier: "segueDelRejectedOrAccepted", sender: self)
    }

    @IBAction func reject(_ sender: Any) {
        FIREBASE().ref.child(self.owner!).child(self.package.id!).child("status").setValue("reposted")
        let ref = FIREBASE().ref.child(self.owner!).child(self.package.id!).child("deliveryPerson")
        ref.removeValue()
        self.msg = "Package Rejected!"
        performSegue(withIdentifier: "segueDelRejectedOrAccepted", sender: self)
    }
    
    @IBAction func startDelivery(_ sender: Any) {
        performSegue(withIdentifier: "startDeliverySegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.view.showToast(toastMessage: self.msg!, duration: 4)
        }
        else if segue.destination is StartDeliveryController
        {
            let vc = segue.destination as? StartDeliveryController
            vc?.package = self.package
            vc?.owner = self.owner
            vc?.index = self.index
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
