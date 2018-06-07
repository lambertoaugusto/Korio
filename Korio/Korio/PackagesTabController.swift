//
//  PackagesTabController.swift
//  Korio
//
//  Created by Student on 2018-03-28.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage


class PackagesTabController: UIViewController , UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var packagesTable: UITableView!
    
    var packages = [String: NSDictionary]()
    
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var storageRef: StorageReference?
    
    var index = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("didLoad PackagesTabController")
        
        ref = Database.database().reference()
        // Points to the root reference
        storageRef = Storage.storage().reference()
        
        packagesTable?.tableFooterView = UIView.init(frame: .zero)
        packagesTable?.register(UINib.init(nibName: "HistoryViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        packagesTable?.dataSource = self
        packagesTable?.delegate = self
        
        handle = FIREBASE().ref.child(userId).observe(.childAdded, with: { (snapshot) in
            if(snapshot.exists()){
                print("package added!")
                let pack = snapshot.value as? NSDictionary
                let status = pack?.value(forKey: "status") as! String
                if(status == "posted" || status == "accepted" || status == "changed" || status == "authorized"){
                    if(status == "posted" || status == "accepted"){
                        FIREBASE().ref.child(userId).child(snapshot.key).child("new").setValue(false)
                        print("PackagesTabController")
                    }
                    self.packages[snapshot.key] = snapshot.value as? NSDictionary
                    self.packagesTable?.reloadData()
                }
                /*else{
                    if(self.packages.index(forKey: snapshot.key) != nil){
                        print("package removed!")
                        self.packages.removeValue(forKey: snapshot.key)
                        self.packagesTable?.reloadData()
                        //self.viewDidLoad()
                    }
                }*/
            }
            
        })
        
        FIREBASE().ref.child(userId).observe(.childChanged, with: { (snapshot) in
            if(snapshot.exists()){
                print("package changed!")
                let pack = snapshot.value as? NSDictionary
                let status = pack?.value(forKey: "status") as! String
                if(status != "posted" && status != "accepted" && status != "changed" && status != "authorized"){
                    if(self.packages.index(forKey: snapshot.key) != nil){
                        print("package removed!")
                        self.packages.removeValue(forKey: snapshot.key)
                        self.packagesTable?.reloadData()
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
            
        })
        
        //updateNewStatus();
        
    }
    
    func updateNewStatus(){
        for (_,value) in self.packages.enumerated(){
            if(value.value["new"] as! Bool){
                FIREBASE().ref.child(userId).child(value.key).child("new").setValue(false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
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
        performSegue(withIdentifier: "seguePackagesCell", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HistoryCellDetailsController
        {
            let vc = segue.destination as? HistoryCellDetailsController
            
            let value = Array(packages)[index].value
            
            vc?.package.id = Array(packages)[index].key
            vc?.package.packageDetails = PackageDetails(packDescription: value["description"] as! String, packValue: value["value"] as! Float, packSize: value["size"] as! Int, packWeight: value["weight"] as! Float)
            let url = value["url"] as? String
            if(!((url ?? "").isEmpty)){
                vc?.package.packageDetails?.url = URL(string: value["url"] as! String)
            }
            
            
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
            
            vc?.historyTabController = self
            vc?.status = value["status"] as! String
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
