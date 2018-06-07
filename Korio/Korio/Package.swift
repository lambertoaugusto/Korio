//
//  Package.swift
//  Korio
//
//  Created by Student on 2018-03-09.
//  Copyright © 2018 Korio. All rights reserved.
//

import Foundation

class Package{
    var id: String?
    var packageDetails: PackageDetails?
    var pickupDetails: PickupDetails?
    var deliveryDetails: DeliveryDetails?
    var specialInstruction: String?
    
    /*func generateID(){
        id = FIREBASE().ref.childByAutoId().key
    }*/
    
    func save(specialInstructions: String, status: String){
        id = FIREBASE().ref.child(userId).childByAutoId().key
        
        let pickupAddress = ["latitude": pickupDetails?.pickupAddress.latitude,
                             "longitude": pickupDetails?.pickupAddress.longitude,
                             "street": pickupDetails?.pickupAddress.street,
                             "city": pickupDetails?.pickupAddress.city,
                             "state": pickupDetails?.pickupAddress.state,
                             "postalCode": pickupDetails?.pickupAddress.postalCode,
                             "country": pickupDetails?.pickupAddress.country,
                             "countryCode": pickupDetails?.pickupAddress.countryCode] as [String : Any]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let strDate = dateFormatter.string(from: (pickupDetails?.pickupDate)!)
        
        let deliveryAddress = ["latitude": deliveryDetails?.DeliveryAddress.latitude,
                             "longitude": deliveryDetails?.DeliveryAddress.longitude,
                             "street": deliveryDetails?.DeliveryAddress.street,
                             "city": deliveryDetails?.DeliveryAddress.city,
                             "state": deliveryDetails?.DeliveryAddress.state,
                             "postalCode": deliveryDetails?.DeliveryAddress.postalCode,
                             "country": deliveryDetails?.DeliveryAddress.country,
                             "countryCode": deliveryDetails?.DeliveryAddress.countryCode] as [String : Any]
        
        let dateFormatterDel = DateFormatter()
        dateFormatterDel.dateFormat = "MM-dd-yyyy HH:mm"
        let strDateDel = dateFormatterDel.string(from: (deliveryDetails?.DateOfDelivery)!)
        
        let packageData = ["description":packageDetails?.description,
                           "value":packageDetails?.value,
                           "size":packageDetails?.size,
                           "weight": packageDetails?.weight,
                           "pickupAddress": pickupAddress,
                           "pickupPerson": pickupDetails?.pickupPerson,
                           "pickupDate": strDate,
                           "receiverName": deliveryDetails?.ReceiverName,
                           "deliveryAddress": deliveryAddress,
                           "deliveryDate": strDateDel,
                           "signatureRequired": deliveryDetails?.SignatureRequired,
                           "specialInstructions": specialInstructions,
                           "status": status,
                           "appId": appID] as [String : Any]
        
        FIREBASE().ref.child(userId).child(id!).updateChildValues(packageData)
    }
    
    func addPackageDetails(packDescription: String, packValue: Float, packSize: Int, packWeight: Float){
        packageDetails = PackageDetails.init(packDescription: packDescription, packValue: packValue, packSize: packSize, packWeight: packWeight)
    }
    
    func addPickupDetails(address:Address, date: Date){
        pickupDetails = PickupDetails.init(address: address, date: date)
    }
    
    func addDeliveryDetails(ReceiverName:String, address: Address, DeliveryDate:Date, sign:Bool){
        deliveryDetails = DeliveryDetails.init(ReceiverName: ReceiverName, address: address, DeliveryDate: DeliveryDate, SignRequired:sign)
    }
}
