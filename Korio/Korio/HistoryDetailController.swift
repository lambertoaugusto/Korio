//
//  HistoryDetailController.swift
//  Korio
//
//  Created by Student on 2018-03-30.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Contacts

class HistoryDetailController: UIViewController {

    @IBOutlet weak var descript: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var pickPerson: UILabel!
    @IBOutlet weak var pickAddress: UITextView!
    @IBOutlet weak var pickDate: UILabel!
    @IBOutlet weak var receiver: UILabel!
    @IBOutlet weak var recAddress: UITextView!
    @IBOutlet weak var delDate: UILabel!
    @IBOutlet weak var signature: UILabel!
    @IBOutlet weak var instructions: UILabel!
    
    var package: Package = Package()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.value.text = self.package.packageDetails?.value.description
        self.descript.text = self.package.packageDetails?.description
        self.weight.text = self.package.packageDetails?.weight.description

        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = package.pickupDetails?.pickupAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress.city = package.pickupDetails?.pickupAddress.city ?? ""
        postalAddress.state = package.pickupDetails?.pickupAddress.state ?? ""
        postalAddress.postalCode = package.pickupDetails?.pickupAddress.postalCode ?? ""
        postalAddress.country = package.pickupDetails?.pickupAddress.country ?? ""
        postalAddress.isoCountryCode = package.pickupDetails?.pickupAddress.countryCode ?? ""
        
        self.pickAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        
        self.pickPerson.text = package.pickupDetails?.pickupPerson ?? "self"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var strDate = dateFormatter.string(from: (package.pickupDetails?.pickupDate)!)
        self.pickDate.text = strDate
        
        self.receiver.text = package.deliveryDetails?.ReceiverName
        
        let postalAddress2 = CNMutablePostalAddress()
        postalAddress2.street = package.deliveryDetails?.DeliveryAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress2.city = package.deliveryDetails?.DeliveryAddress.city ?? ""
        postalAddress2.state = package.deliveryDetails?.DeliveryAddress.state ?? ""
        postalAddress2.postalCode = package.deliveryDetails?.DeliveryAddress.postalCode ?? ""
        postalAddress2.country = package.deliveryDetails?.DeliveryAddress.country ?? ""
        postalAddress2.isoCountryCode = package.deliveryDetails?.DeliveryAddress.countryCode ?? ""
        
        self.recAddress.text  = CNPostalAddressFormatter.string(from: postalAddress2, style: .mailingAddress)
        
        strDate = dateFormatter.string(from: (package.deliveryDetails?.DateOfDelivery)!)
        self.delDate.text = strDate
        self.size.text = SIZE().sizeData[(package.packageDetails?.size)!]
        
        if(package.deliveryDetails?.SignatureRequired)!{
            self.signature.text = "Signature Required"
        }

        self.instructions.text = package.specialInstruction
        // Do any additional setup after loading the view.
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
