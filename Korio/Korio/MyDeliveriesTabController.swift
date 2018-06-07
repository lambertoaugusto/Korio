//
//  MyDeliveriesTabController.swift
//  Korio
//
//  Created by Student on 2018-04-04.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class MyDeliveriesTabController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var packagesTable: UITableView!
    
    var packages = [String: NSDictionary]()
    
    //var ref: DatabaseReference?
    //var handle: DatabaseHandle?
    //var storageRef: StorageReference?
    
    var index = 0;


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        packagesTable?.tableFooterView = UIView.init(frame: .zero)
        packagesTable?.register(UINib.init(nibName: "HistoryViewCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        packagesTable?.dataSource = self
        packagesTable?.delegate = self
        
        for user in usersIds{
            if(user != userId){
                FIREBASE().ref.child(user).observe(.childAdded, with: { (snapshot) in
                    if(snapshot.exists()){
                        print("package added!")
                        let pack = snapshot.value as? NSDictionary
                        let delPerson = pack?.value(forKey: "deliveryPerson") as? String
                        
                        if(delPerson != nil && delPerson == userId){
                            let status = pack?.value(forKey: "status") as? String
                            if(status == "changed" || status == "authorized"){
                            FIREBASE().ref.child(user).child(snapshot.key).child("new").setValue(false)
                                print("MyDeliveriesTabController")
                            }
                            self.packages[snapshot.key] = snapshot.value as? NSDictionary
                            self.packages[snapshot.key]?.setValue(user, forKey: "owner")
                            self.packagesTable?.reloadData()
                        }
                
                    }
            
                })
            }
        }
        
        for user in usersIds{
            FIREBASE().ref.child(user).observe(.childChanged, with: { (snapshot) in
                if(snapshot.exists()){
                    print("package changed!")
                    let pack = snapshot.value as? NSDictionary
                    let delPerson = pack?.value(forKey: "deliveryPerson") as? String
                    
                    if(delPerson != nil){
                        if(delPerson != userId){
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
                                self.packages[snapshot.key]?.setValue(user, forKey: "owner")
                                self.packagesTable?.reloadData()
                            }
                        }
                    }
                    else{
                        if(self.packages.index(forKey: snapshot.key) != nil){
                            print("package removed!")
                            self.packages.removeValue(forKey: snapshot.key)
                            self.packagesTable?.reloadData()
                            //self.viewDidLoad()
                        }
                    }
                }
            
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        performSegue(withIdentifier: "segueDeliveryCell", sender: self)
    }
    
    @IBAction func unwindToDeliveriesTab(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? StartDeliveryController {
            self.viewDidLoad()
            packagesTable?.reloadData()
        }
        else if let sourceViewController = sender.source as? GetSignatureController {
            self.viewDidLoad()
            packagesTable?.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DeliveryCellDetailController
        {
            let vc = segue.destination as? DeliveryCellDetailController
            
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
            
            dateDate = dateFormatter.date(from: value["deliveryDate"] as! String)
            
            let deliveryAddress = value["deliveryAddress"] as! NSDictionary
            let deliveryAddressObj = Address(lat: deliveryAddress["latitude"] as! Double, long: deliveryAddress["longitude"] as! Double, str: (deliveryAddress["street"] as? String)!, ct: (deliveryAddress["city"] as? String)!, st: (deliveryAddress["state"] as? String)!, pc: (deliveryAddress["postalCode"] as? String)!, co: (deliveryAddress["country"] as? String)!, coc: (deliveryAddress["countryCode"] as? String)!)
            vc?.package.deliveryDetails = DeliveryDetails(ReceiverName: value["receiverName"] as! String, address: deliveryAddressObj, DeliveryDate: dateDate!, SignRequired: value["signatureRequired"] as! Bool)
            
            vc?.status = value["status"] as! String
            vc?.owner = value["owner"] as! String
            vc?.index = index
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
