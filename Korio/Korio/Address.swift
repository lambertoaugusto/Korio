//
//  Address.swift
//  Korio
//
//  Created by Student on 2018-03-21.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class Address{
    
    var latitude: Double
    var longitude: Double
    var street: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var countryCode: String
    
    init(lat: Double, long: Double, str: String, ct: String, st: String, pc: String, co: String, coc: String){
        latitude = lat
        longitude = long
        street = str
        city = ct
        state = st
        postalCode = pc
        country = co
        countryCode = coc
    }
    func saveAddress(type: String, id: String){
        FIREBASE().ref.child(userId).child(id).child(type).child("latitude").setValue(latitude)
        FIREBASE().ref.child(userId).child(id).child(type).child("longitude").setValue(longitude)
        FIREBASE().ref.child(userId).child(id).child(type).child("street").setValue(street)
        FIREBASE().ref.child(userId).child(id).child(type).child("city").setValue(city)
        FIREBASE().ref.child(userId).child(id).child(type).child("state").setValue(state)
        FIREBASE().ref.child(userId).child(id).child(type).child("postalCode").setValue(postalCode)
        FIREBASE().ref.child(userId).child(id).child(type).child("country").setValue(country)
        FIREBASE().ref.child(userId).child(id).child(type).child("countryCode").setValue(countryCode)
    }

}
