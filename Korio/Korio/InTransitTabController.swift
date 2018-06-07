//
//  InTransitTabController.swift
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

class InTransitTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTable: UITableView?
    
    var packages = [String: NSDictionary]()
    
    var index = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyTable?.tableFooterView = UIView.init(frame: .zero)
        historyTable?.register(UINib.init(nibName: "HistoryViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        historyTable?.dataSource = self
        historyTable?.delegate = self
        
        FIREBASE().ref.child(userId).observe(.childAdded, with: { (snapshot) in
            if(snapshot.exists()){
                let pack = snapshot.value as? NSDictionary
                if(pack?.value(forKey: "status") as! String == "expired"){
                    FIREBASE().ref.child(userId).child(snapshot.key).child("new").setValue(false)
                    print("InTransitTabController")
                    self.packages[snapshot.key] = snapshot.value as? NSDictionary
                    self.historyTable?.reloadData()
                }
            }
            
        })
        
        FIREBASE().ref.child(userId).observe(.childChanged, with: { (snapshot) in
            if(snapshot.exists()){
                print("package changed!")
                let pack = snapshot.value as? NSDictionary
                if(pack?.value(forKey: "status") as! String != "expired"){
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
                }
            }
            
        })


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
        performSegue(withIdentifier: "segueExpiredCell", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ExpiredDetailController
        {
            let vc = segue.destination as? ExpiredDetailController
            
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
