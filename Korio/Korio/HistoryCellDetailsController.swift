//
//  HistoryCellDetailsController.swift
//  Korio
//
//  Created by Student on 2018-03-01.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

import Contacts

class HistoryCellDetailsController: UIViewController {
    
    var historyTabController: Any!
    
    //var ref: DatabaseReference?
    //let userID = Auth.auth().currentUser!.uid
    //var handle: DatabaseHandle?
    
    //var storageRef: StorageReference?
    
    //var packageDetails: PackageDetails!
    //var pickupDetails: PickupDetails!
    //var deliveryDetails: DeliveryDetails!
    
    var package: Package = Package()
    
    @IBOutlet weak var packageValue: UILabel!
    @IBOutlet weak var packageDescription: UILabel!
    @IBOutlet weak var packageImage: UIImageView!
    @IBOutlet weak var pickupAddress: UILabel!
    @IBOutlet weak var pickupPerson: UILabel!
    @IBOutlet weak var packageWeight: UILabel!
    @IBOutlet weak var receiverPerson: UILabel!
    @IBOutlet weak var pickupDate: UILabel!
    @IBOutlet weak var receiverAddress: UILabel!
    @IBOutlet weak var deliveryDate: UILabel!
    @IBOutlet weak var packageSize: UILabel!
    @IBOutlet weak var authorizeButton: UIButton!
    
    var status: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ref = Database.database().reference()
        // Points to the root reference
       // storageRef = Storage.storage().reference()
        
        self.packageValue.text = self.package.packageDetails?.value.description
        self.packageDescription.text = self.package.packageDetails?.description
        self.packageWeight.text = self.package.packageDetails?.weight.description
        if(self.package.packageDetails?.url != nil){
            //self.packageImage.image = packageDetails.image
            let imageView: UIImageView = self.packageImage
        
            // Placeholder image
            let placeholderImage = UIImage()
        
            // Load the image using SDWebImage
            imageView.sd_setImage(with: self.package.packageDetails?.url, placeholderImage: placeholderImage)
        }
        print("item changed")
        
        let postalAddress = CNMutablePostalAddress()
        postalAddress.street = package.pickupDetails?.pickupAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress.city = package.pickupDetails?.pickupAddress.city ?? ""
        postalAddress.state = package.pickupDetails?.pickupAddress.state ?? ""
        postalAddress.postalCode = package.pickupDetails?.pickupAddress.postalCode ?? ""
        postalAddress.country = package.pickupDetails?.pickupAddress.country ?? ""
        postalAddress.isoCountryCode = package.pickupDetails?.pickupAddress.countryCode ?? ""
        
        self.pickupAddress.text = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
       
        self.pickupPerson.text = package.pickupDetails?.pickupPerson ?? "self"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var strDate = dateFormatter.string(from: (package.pickupDetails?.pickupDate)!)
        self.pickupDate.text = strDate
        
        self.receiverPerson.text = package.deliveryDetails?.ReceiverName
        
        let postalAddress2 = CNMutablePostalAddress()
        postalAddress2.street = package.deliveryDetails?.DeliveryAddress.street ?? ""//placeMark?.thoroughfare ?? ""
        postalAddress2.city = package.deliveryDetails?.DeliveryAddress.city ?? ""
        postalAddress2.state = package.deliveryDetails?.DeliveryAddress.state ?? ""
        postalAddress2.postalCode = package.deliveryDetails?.DeliveryAddress.postalCode ?? ""
        postalAddress2.country = package.deliveryDetails?.DeliveryAddress.country ?? ""
        postalAddress2.isoCountryCode = package.deliveryDetails?.DeliveryAddress.countryCode ?? ""
        
        self.receiverAddress.text  = CNPostalAddressFormatter.string(from: postalAddress2, style: .mailingAddress)
        
        strDate = dateFormatter.string(from: (package.deliveryDetails?.DateOfDelivery)!)
        self.deliveryDate.text = strDate
        self.packageSize.text = SIZE().sizeData[(package.packageDetails?.size)!]
        
        if(status == "accepted"){
            self.authorizeButton.isHidden = false
        }
        else{
            self.authorizeButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editImage(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            //self.package!.picture = image
            self.packageImage.image = image
            self.uploadPackageImage(package: self.package.packageDetails!)
        }
    }
    
    @IBAction func authorizeDelivery(_ sender: Any) {
        FIREBASE().ref.child(userId).child(self.package.id!).child("status").setValue("authorized")
        FIREBASE().ref.child(userId).child(self.package.id!).child("new").setValue(true)
        //print("deliveryCellDetailController")
        //self.msg = "Package changes accepted!"
        //performSegue(withIdentifier: "segueDeliveryAuthorized", sender: self)
    }
    @IBAction func editPackageDetails(_ sender: Any) {
        performSegue(withIdentifier: "segueEditPackageDetails", sender: self)
    }
    @IBAction func editPickupDetails(_ sender: Any) {
        performSegue(withIdentifier: "segueEditPickupDetails", sender: self)
    }
    @IBAction func editDeliveryDetails(_ sender: Any) {
        performSegue(withIdentifier: "segueEditDeliveryDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is EditPackageDetailsController
        {
            let vc = segue.destination as? EditPackageDetailsController
            //vc?.id = self.packageDetails.id
            vc?.packageDetails = self.package.packageDetails
            vc?.id = self.package.id
        }
        else if segue.destination is EditPickupDetailsController
        {
            let vc = segue.destination as? EditPickupDetailsController
            //vc?.id = self.packageDetails.id
            vc?.pickupDetails = self.package.pickupDetails
            vc?.id = self.package.id
        }
        else if segue.destination is EditDeliveryDetailsController
        {
            let vc = segue.destination as? EditDeliveryDetailsController
            //vc?.id = self.packageDetails.id
            vc?.deliveryDetails = self.package.deliveryDetails
            vc?.id = self.package.id
        }
        /*else if segue.destination is ViewController
        {
            let vc = segue.destination as? ViewController
            vc?.view.showToast(toastMessage: "Delivery Authorized", duration: 4)
        }*/
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func uploadPackageImage(package:PackageDetails){
        // Points to "images"
        //let imagesRef = storageRef?.child("package-images").child("lamberto")
        
        // Points to "images/imageName.jpg"
        // Note that you can use variables to create child values
        //let fileName = packageDetails.id
        let packageRef = FIREBASE().storageRef.child(userId).child("\(self.package.id ?? "").jpg")
        
        // File path is "images/imageName.jpg"
        //let path = packageRef?.fullPath;
        
        // File name is "space.jpg"
        //let name = packageRef?.name;
        
        // Points to "bucket"
        //let bucket = packageRef?.bucket
        
        //print("name:\(String(describing: name)), path:\(String(describing: path)), Bucket:\(String(describing: bucket))")
        
        // Data in memory
        let data = packageImage.image?.jpegRepresentationData
        
        // Create a reference to the file you want to upload
        //let riversRef = storageRef.child("images/rivers.jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = packageRef.putData(data as! Data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            self.package.packageDetails?.url = metadata.downloadURL()
            //print(package.url?.absoluteString)
        FIREBASE().ref.child(userId).child(self.package.id!).child("url").setValue(self.package.packageDetails?.url?.absoluteString)
            if let tabController = self.historyTabController as? HistoryTabController{
                tabController.historyTable?.reloadData()
                tabController.viewDidLoad()
            }
            else if let tabController = self.historyTabController as? PackagesTabController{
                tabController.packagesTable.reloadData()
                tabController.viewDidLoad()
            }
        }
    }
    
    @IBAction func HistoryCellDetailsUnwind(unwindSegue: UIStoryboardSegue){
        if let editPackageDetailsController = unwindSegue.source as? EditPackageDetailsController {
            //self.packageDetails = editPackageDetailsController.packageDetails
            self.viewDidLoad()
            /*if let tabController = self.historyTabController as? HistoryTabController{
                tabController.viewDidLoad()
                tabController.historyTable?.reloadData()
            }
            else if let tabController = self.historyTabController as? PackagesTabController{
                tabController.viewDidLoad()
                tabController.packagesTable.reloadData()
            }*/
        }
        else if let editPickupDetailsController = unwindSegue.source as? EditPickupDetailsController {
            //self.packageDetails = editPackageDetailsController.packageDetails
            self.viewDidLoad()
            /*if let tabController = self.historyTabController as? HistoryTabController{
                tabController.viewDidLoad()
                tabController.historyTable?.reloadData()
            }
            else if let tabController = self.historyTabController as? PackagesTabController{
                tabController.viewDidLoad()
                tabController.packagesTable.reloadData()
            }*/
        }
        else if let editDeliveryDetailsController = unwindSegue.source as? EditDeliveryDetailsController {
            //self.packageDetails = editPackageDetailsController.packageDetails
            self.viewDidLoad()
            /*if let tabController = self.historyTabController as? HistoryTabController{
                tabController.viewDidLoad()
                tabController.historyTable?.reloadData()
            }
            else if let tabController = self.historyTabController as? PackagesTabController{
                tabController.viewDidLoad()
                tabController.packagesTable.reloadData()                
            }*/
        }
    }
}
