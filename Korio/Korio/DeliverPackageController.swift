//
//  DeliverPackageController.swift
//  Korio
//
//  Created by Student on 2018-04-03.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Contacts

class DeliverPackageController: UIViewController {

    @IBOutlet weak var owner: UILabel!
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var pickPerson: UILabel!
    @IBOutlet weak var pickAddress: UITextView!
    @IBOutlet weak var pickDate: UILabel!
    @IBOutlet weak var receiver: UILabel!
    @IBOutlet weak var recAddress: UITextView!
    @IBOutlet weak var delDate: UILabel!
    @IBOutlet weak var sign: UILabel!
    @IBOutlet weak var inst: UILabel!
    
    var package : NSDictionary?
    var packageId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        descrip.text = package?.value(forKey: "description") as! String
        value.text = (package?.value(forKey: "value") as! Int).description
        size.text = SIZE().sizeData[package?.value(forKey: "size") as! Int]
        weight.text = (package?.value(forKey: "weight") as! Int).description
        pickPerson.text = package?.value(forKey: "pickupPerson") as! String
        
        let postalAddress = CNMutablePostalAddress()
        let pickAdd = package?.value(forKey: "pickupAddress") as! NSDictionary
        postalAddress.street = pickAdd.value(forKey: "street") as! String//placeMark?.thoroughfare ?? ""
        postalAddress.city = pickAdd.value(forKey: "city") as! String
        postalAddress.state = pickAdd.value(forKey: "state") as! String
        postalAddress.postalCode = pickAdd.value(forKey: "postalCode") as! String
        postalAddress.country = pickAdd.value(forKey: "country") as! String
        postalAddress.isoCountryCode = pickAdd.value(forKey: "countryCode") as! String
        
        self.pickAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        
        pickDate.text = package?.value(forKey: "pickupDate") as! String
        receiver.text = package?.value(forKey: "receiverName") as! String
        
        let postalAddress2 = CNMutablePostalAddress()
        let recAdd = package?.value(forKey: "deliveryAddress") as! NSDictionary
        postalAddress2.street = recAdd.value(forKey: "street") as! String
        postalAddress2.city = recAdd.value(forKey: "city") as! String
        postalAddress2.state = recAdd.value(forKey: "state") as! String
        postalAddress2.postalCode = recAdd.value(forKey: "postalCode") as! String
        postalAddress2.country = recAdd.value(forKey: "country") as! String
        postalAddress2.isoCountryCode = recAdd.value(forKey: "countryCode") as! String
        
        self.recAddress.text  = CNPostalAddressFormatter.string(from: postalAddress2, style: .mailingAddress)
        delDate.text = package?.value(forKey: "deliveryDate") as! String
        if(package?.value(forKey: "signatureRequired") as! Bool){
            sign.text = "Signature Required"
        }
        inst.text = package?.value(forKey: "specialInstructions") as! String
        // Do any additional setup after loading the view.
        owner.text = package?.value(forKey: "owner") as! String
    }
    
    @IBAction func DeliverPackage(_ sender: Any) {
        FIREBASE().ref.child(package?.value(forKey: "owner") as! String).child(packageId!).child("status").setValue("accepted")
        FIREBASE().ref.child(package?.value(forKey: "owner") as! String).child(packageId!).child("new").setValue(true)
        print("DeliverPackageController")
        FIREBASE().ref.child(package?.value(forKey: "owner") as! String).child(packageId!).child("deliveryPerson").setValue(userId)
        performSegue(withIdentifier: "deliveryAccepted", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.view.showToast(toastMessage: "Delivery accepted, please wait for user approval", duration: 4)
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
