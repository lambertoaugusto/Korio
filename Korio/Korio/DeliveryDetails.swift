//
//  DeliveryDetails.swift
//  Korio
//
//  Created by Student on 2018-02-21.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class DeliveryDetails{
    var ReceiverName: String
    var DeliveryAddress: Address
    var DateOfDelivery: Date
    var SignatureRequired: Bool
    
    init(ReceiverName:String, address: Address, DeliveryDate:Date, SignRequired:Bool){
        self.ReceiverName = ReceiverName
        self.DeliveryAddress = address
        self.DateOfDelivery = DeliveryDate
        self.SignatureRequired = SignRequired
    }
    
    
    func saveDeliveryDetailsFirebase(id: String){
        // Points to Database pickups/"user_id"/"item_id"
        //var itemReference = FIREBASE().ref.child("packages").child(USER().id).child(key)
        
        let deliveryAddress = ["latitude": self.DeliveryAddress.latitude,
                               "longitude": self.DeliveryAddress.longitude,
                               "street": self.DeliveryAddress.street,
                               "city": self.DeliveryAddress.city,
                               "state": self.DeliveryAddress.state,
                               "postalCode": self.DeliveryAddress.postalCode,
                               "country": self.DeliveryAddress.country,
                               "countryCode": self.DeliveryAddress.countryCode] as [String : Any]
        
        let dateFormatterDel = DateFormatter()
        dateFormatterDel.dateFormat = "MM-dd-yyyy HH:mm"
        let strDateDel = dateFormatterDel.string(from: (self.DateOfDelivery))
        
        let packageData = ["receiverName":self.ReceiverName,
                           "deliveryAddress":deliveryAddress,
                           "deliveryDate":strDateDel,
                           "signatureRequired": self.SignatureRequired] as [String : Any]
        FIREBASE().ref.child(userId).child(id).updateChildValues(packageData)
        
        
        /*FIREBASE().ref.child(id).child("receiverName").setValue(self.ReceiverName)
        //FIREBASE().ref.child(id).child("deliveryAddress").setValue(self.DeliveryAddress)
        DeliveryAddress.saveAddress(type: "deliveryAddress", id: id)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let strDate = dateFormatter.string(from: self.DateOfDelivery)
        
        FIREBASE().ref.child(id).child("deliveryDate").setValue(strDate)
        
        FIREBASE().ref.child(id).child("signatureRequired").setValue(self.SignatureRequired)*/
        
    }
}
