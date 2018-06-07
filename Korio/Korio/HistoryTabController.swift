//
//  HistoryTabController.swift
//  Korio
//
//  Created by Student on 2018-02-28.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import Contacts
import MBRateApp

class HistoryTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTable: UITableView?
    
    var packages = [String: NSDictionary]()
    
    //var ref: DatabaseReference?
    var handle: DatabaseHandle?
    //var storageRef: StorageReference?
    
    var index = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("didLoad HistoryTabController")
        
        //ref = Database.database().reference()
        // Points to the root reference
        //storageRef = Storage.storage().reference()
        
        historyTable?.tableFooterView = UIView.init(frame: .zero)
        historyTable?.register(UINib.init(nibName: "HistoryViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        historyTable?.dataSource = self
        historyTable?.delegate = self
        
        //for user in USERS().ids{
        //    if(user == USER().id){
                handle = FIREBASE().ref.child(userId).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.exists()){
                        let pack = snapshot.value as? NSDictionary
                        if(pack?.value(forKey: "status") as! String == "delivered" || pack?.value(forKey: "status") as! String == "cancelled"){
                            self.packages[snapshot.key] = snapshot.value as? NSDictionary
                            self.historyTable?.reloadData()
                        }
                        if(pack?.value(forKey: "status") as! String == "delivered" && pack?.value(forKey: "new") as! Bool){
                            self.openRateScreen(descript: pack?.value(forKey: "description") as! String, id: snapshot.key)
                        }
                    }
            
                })
        //    }
       // }
        
       // for user in USERS().ids{
       //     if(user == USER().id){
                FIREBASE().ref.child(userId).observe(.childChanged, with: { (snapshot) in
                    if(snapshot.exists()){
                        print("package changed!")
                        let pack = snapshot.value as? NSDictionary
                        if(pack?.value(forKey: "status") as! String != "delivered" && pack?.value(forKey: "status") as! String != "cancelled"){
                            if(self.packages.index(forKey: snapshot.key) != nil){
                                print("package removed!")
                                self.packages.removeValue(forKey: snapshot.key)
                                self.historyTable?.reloadData()
                                //self.viewDidLoad()
                            }
                            
                        }
                        else{
                            if(self.packages.index(forKey: snapshot.key) == nil){
                                print("package added again!")
                                self.packages[snapshot.key] = snapshot.value as? NSDictionary
                                //self.packages[snapshot.key]?.setValue(user, forKey: "owner")
                                self.historyTable?.reloadData()
                            }
                            if(pack?.value(forKey: "status") as! String == "delivered" && pack?.value(forKey: "new") as! Bool){
                                self.openRateScreen(descript: pack?.value(forKey: "description") as! String, id: snapshot.key)
                            }
                        }
                    }
                    
                })
     //       }
     //   }
        
        /*FIREBASE().ref.observe(.childChanged, with: { (snapshot) in
            if(snapshot.exists()){
                print("package changed!")
                let pack = snapshot.value as? NSDictionary
                if(pack?.value(forKey: "status") as! String != "delivered" || pack?.value(forKey: "status") as! String != "cancelled"){
                    if(self.packages.index(forKey: snapshot.key) != nil){
                        print("package removed!")
                        self.packages.removeValue(forKey: snapshot.key)
                        self.historyTable?.reloadData()
                        //self.viewDidLoad()
                    }
                    
                }
                else{
                    if(self.packages.index(forKey: snapshot.key) == nil){
                        print("package added again!")
                        self.packages[snapshot.key] = snapshot.value as? NSDictionary
                        self.packagesTable?.reloadData()
                    }
                }
            }
            
        })*/

    }
    
    func openRateScreen(descript: String, id: String){
        var rateUsInfo = MBRateUsInfo()
        //pack?.value(forKey: "description")
        rateUsInfo.title = "\(descript) was Delivered!"
        rateUsInfo.titleImage = UIImage(named: "icon")
        rateUsInfo.itunesId = "0"
        MBRateUs.sharedInstance.rateUsInfo = rateUsInfo
        
        MBRateUs.sharedInstance.showRateUs(base: self
            , positiveBlock: { (rate) -> Void in
                let packageData = ["driverRate":rate,
                                   "new":false] as [String : Any]
                
                FIREBASE().ref.child(userId).child(id).updateChildValues(packageData)
                self.viewDidLoad()
                //print(rate)
                
        }, negativeBlock: { (rate) -> Void in
            let packageData = ["driverRate":rate,
                               "new":false] as [String : Any]
            
            FIREBASE().ref.child(userId).child(id).updateChildValues(packageData)
            self.viewDidLoad()
            //print(rate)
            
        }) { () -> Void in
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return packages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! HistoryViewCell
        let value = Array(packages)[indexPath.row].value
        cell.packageImage?.text = value["description"] as? String
        cell.packageName?.text = value["status"] as? String
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "segueHistoryCell", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HistoryDetailController
        {
            let vc = segue.destination as? HistoryDetailController
            
            let value = Array(packages)[index].value
            
            vc?.package.id = Array(packages)[index].key
            
            vc?.package.packageDetails = PackageDetails(packDescription: value["description"] as! String, packValue: value["value"] as! Float, packSize: value["size"] as! Int, packWeight: value["weight"] as! Float)
            let url = value["url"] as? String
            if(!((url ?? "").isEmpty)){
                vc?.package.packageDetails?.url = URL(string: value["url"] as! String)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            var dateDate = dateFormatter.date(from: value["pickupDate"] as! String)
            
            let pickupAddress = value["pickupAddress"] as! NSDictionary
            let pickupAddressObj = Address(lat: pickupAddress["latitude"] as! Double, long: pickupAddress["longitude"] as! Double, str: (pickupAddress["street"] as? String)!, ct: (pickupAddress["city"] as? String)!, st: (pickupAddress["state"] as? String)!, pc: (pickupAddress["postalCode"] as? String)!, co: (pickupAddress["country"] as? String)!, coc: (pickupAddress["countryCode"] as? String)!)
            vc?.package.pickupDetails = PickupDetails(address: pickupAddressObj, date: dateDate!)
            let pickPer = value["pickupPerson"] as? String
            if(!((pickPer ?? "").isEmpty)){
                vc?.package.pickupDetails?.pickupPerson = value["pickupPerson"] as? String
            }
            //vc?.pickupDetails.id = Array(packages)[index].key
            
            dateDate = dateFormatter.date(from: value["deliveryDate"] as! String)
            
            let deliveryAddress = value["deliveryAddress"] as! NSDictionary
            let deliveryAddressObj = Address(lat: deliveryAddress["latitude"] as! Double, long: deliveryAddress["longitude"] as! Double, str: (deliveryAddress["street"] as? String)!, ct: (deliveryAddress["city"] as? String)!, st: (deliveryAddress["state"] as? String)!, pc: (deliveryAddress["postalCode"] as? String)!, co: (deliveryAddress["country"] as? String)!, coc: (deliveryAddress["countryCode"] as? String)!)
            vc?.package.deliveryDetails = DeliveryDetails(ReceiverName: value["receiverName"] as! String, address: deliveryAddressObj, DeliveryDate: dateDate!, SignRequired: value["signatureRequired"] as! Bool)
            
            vc?.package.specialInstruction = value["specialInstructions"] as! String
            //vc?.package.id = Array(packages)[index].key
            /*let label = UILabel()
            label.text = value["description"] as! String
            vc?.descript = label
            //vc?.descript.text = value["description"] as! String
            label.text = (value["value"] as! Float).description
            vc?.value = label
            label.text = (value["size"] as! Int).description
            vc?.size = label
            label.text = (value["weight"] as! Float).description
            vc?.weight = label
            
            /*let url = value["url"] as? String
            if(!((url ?? "").isEmpty)){
                vc?.package.packageDetails?.url = URL(string: value["url"] as! String)
            }*/
            
            
             //   PackageDetails(packName: , packValue: , packSize: , packWeight: )
            //vc?.packageDetails.id =
            
            //let reference = storageRef?.child("package-images").child("lamberto").child(Array(packages)[index].key)
            //let referenceUrl = )
            //vc?.packageDetails.url = referenceUrl
            /*
            // UIImageView in your ViewController
            let placeholderImage = UIImage()
            vc?.packageImage = UIImageView(image: placeholderImage)
            let imageView: UIImageView = (vc?.packageImage)!
            // Placeholder image
            
            // Load the image using SDWebImage
            imageView.sd_setImage(with: referenceUrl!, placeholderImage: placeholderImage)
            */
            //let dateFormatter = DateFormatter()
            //dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            //var dateDate = dateFormatter.date(from: value["pickupDate"] as! String)
            
            let pickupAddress = value["pickupAddress"] as! NSDictionary
            //let pickupAddressObj = Address(lat: pickupAddress["latitude"] as! Double, long: pickupAddress["longitude"] as! Double, str: (pickupAddress["street"] as? String)!, ct: (pickupAddress["city"] as? String)!, st: (pickupAddress["state"] as? String)!, pc: (pickupAddress["postalCode"] as? String)!, co: (pickupAddress["country"] as? String)!, coc: (pickupAddress["countryCode"] as? String)!)
            
            
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = (pickupAddress["street"] as! String!) ?? "" //placeMark?.thoroughfare ?? ""
            postalAddress.city = (pickupAddress["city"] as! String!) ?? ""
            postalAddress.state = (pickupAddress["state"] as! String!) ?? ""
            postalAddress.postalCode = (pickupAddress["postalCode"] as! String!) ?? ""
            postalAddress.country = (pickupAddress["country"] as! String!) ?? ""
            postalAddress.isoCountryCode = (pickupAddress["countryCode"] as! String!) ?? ""
            
            let textView = UITextView()
            textView.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            vc?.pickAddress = textView
            
            label.text = value["pickupDate"] as! String
            vc?.pickDate = label
            
            //self.pickupAddressView.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
            
            let pickPer = value["pickupPerson"] as? String
            if(!((pickPer ?? "").isEmpty)){
                label.text = value["pickupPerson"] as? String
                vc?.pickPerson = label
            }
            //vc?.pickupDetails.id = Array(packages)[index].key
            
            label.text = value["deliveryDate"] as! String
            vc?.delDate = label
            
            let deliveryAddress = value["deliveryAddress"] as! NSDictionary
            
            let postalAddressRec = CNMutablePostalAddress()
            postalAddressRec.street = (deliveryAddress["street"] as! String!) ?? ""
            postalAddressRec.city = (deliveryAddress["city"] as! String!) ?? ""
            postalAddressRec.state = (deliveryAddress["state"] as! String!) ?? ""
            postalAddressRec.postalCode = (deliveryAddress["postalCode"] as! String!) ?? ""
            postalAddressRec.country = (deliveryAddress["country"] as! String!) ?? ""
            postalAddressRec.isoCountryCode = (deliveryAddress["countryCode"] as! String!) ?? ""
            
            textView.text = CNPostalAddressFormatter.string(from: postalAddressRec, style: .mailingAddress)
            vc?.recAddress = textView
            
            if(value["signatureRequired"] as! Bool){
                label.text = "Signature Required"
                vc?.signature = label
            }
            */
            //vc?.historyTabController = self
        }
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
