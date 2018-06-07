//
//  PickupDetails.swift
//  Korio
//
//  Created by Student on 2018-02-18.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class PickupDetails{
    var pickupAddress: Address
    var pickupPerson: String?
    var pickupDate: Date
    
    init(address: Address, date: Date){
        self.pickupAddress = address
        self.pickupDate = date
    }
    
    func savePickUpDetailsFirebase(id: String){
        // Points to Database pickups/"user_id"/"item_id"
        //var itemReference = child("packages").child(USER().id).child(key)
        
        let pickupAddress = ["latitude": self.pickupAddress.latitude,
                             "longitude": self.pickupAddress.longitude,
                             "street": self.pickupAddress.street,
                             "city": self.pickupAddress.city,
                             "state": self.pickupAddress.state,
                             "postalCode": self.pickupAddress.postalCode,
                             "country": self.pickupAddress.country,
                             "countryCode": self.pickupAddress.countryCode] as [String : Any]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let strDate = dateFormatter.string(from: (self.pickupDate))

        let packageData = ["pickupAddress":pickupAddress,
                           "pickupPerson":self.pickupPerson,
                           "pickupDate":strDate] as [String : Any]
        FIREBASE().ref.child(userId).child(id).updateChildValues(packageData)

        
        
        /*pickupAddress.saveAddress(type: , id: id)
        FIREBASE().ref.child(id).child().setValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let strDate = dateFormatter.string(from: self.pickupDate)
        
        FIREBASE().ref.child(id).child().setValue(strDate)*/
    }

}
