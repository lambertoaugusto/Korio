//
//  PackageDetails.swift
//  Korio
//
//  Created by Student on 2018-02-17.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PackageDetails{    
    var url: URL?
    var image: UIImage?
    var description: String
    var value: Float
    var size: Int
    var weight: Float
    
    init(packDescription: String, packValue: Float, packSize: Int, packWeight: Float) {
        self.description = packDescription
        self.value = packValue
        self.size = packSize
        self.weight = packWeight
    }
    
    func savePackageImageFirebase(id: String){
        // Points to Database package-images/"user_id"/"item_id".jpg
        let packageRef = FIREBASE().storageRef.child(userId).child("\(id).jpg")
        
        // Data in memory
        let data = self.image?.jpegRepresentationData
        
        // Upload the file to the path
        let uploadTask = packageRef.putData(data as! Data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            self.url = metadata.downloadURL()
            //print(self.url?.absoluteString)
            FIREBASE().ref.child(userId).child(id).child("url").setValue(self.url?.absoluteString)
        }
    }
    
    func savePackageDetailsFirebase(id: String){
        // Points to Database packages/"user_id"/"item_id"
        
        //self.id = itemReference.key
        
        let packageData = ["description":self.description,
                           "value":self.value,
                           "size":self.size,
                           "weight": self.weight] as [String : Any]
        FIREBASE().ref.child(userId).child(id).updateChildValues(packageData)
        
        /*FIREBASE().ref.child(id).child("description").setValue(self.description)
        FIREBASE().ref.child(id).child("value").setValue(self.value)
        FIREBASE().ref.child(id).child("size").setValue(self.size)
        FIREBASE().ref.child(id).child("weight").setValue(self.weight)*/
        
        //savePackageImageFirebase(itemRef: itemReference)
    }
}
