//
//  GetSignatureController.swift
//  Korio
//
//  Created by Student on 2018-04-18.
//  Copyright © 2018 Korio. All rights reserved.
//
import MBRateApp
import UIKit

class GetSignatureController: UIViewController , YPSignatureDelegate {
    
    // Connect this Outlet to the Signature View
    @IBOutlet weak var signatureView: YPDrawSignatureView!
    var package: Package?
    var owner: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setting this view controller as the signature view delegate, so the didStart() and
        // didFinish() methods below in the delegate section are called.
        signatureView.delegate = self
    }
    
    // Function for clearing the content of signature view
    @IBAction func clearSignature(_ sender: UIButton) {
        // This is how the signature gets cleared
        self.signatureView.clear()
    }
    
    // Function for saving signature
    @IBAction func saveSignature(_ sender: UIButton) {
        // Getting the Signature Image from self.drawSignatureView using the method getSignature().
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            
            // Saving signatureImage from the line above to the Photo Roll.
            // The first time you do this, the app asks for access to your pictures.
            UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            
            // Points to Database package-images/"user_id"/"item_id".jpg
            let packageRef = FIREBASE().signatureRef.child(owner!).child("\((package?.id)!).jpg")
            
            // Data in memory
            let data = signatureImage.jpegRepresentationData
            
            // Upload the file to the path
            let uploadTask = packageRef.putData(data as! Data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                //self.url = metadata.downloadURL()
                //print(self.url?.absoluteString)
                //FIREBASE().ref.child(USER().id).child(id).child("url").setValue(self.url?.absoluteString)
            }
            
            // Since the Signature is now saved to the Photo Roll, the View can be cleared anyway.
            self.signatureView.clear()
            
            //change status to delivered
            //FIREBASE().ref.child(self.owner!).child((package?.id)!).child("status").setValue("delivered")
           // FIREBASE().ref.child(self.owner!).child((package?.id)!).child("new").setValue(true)
            openRateScreen(descript: (self.package?.packageDetails?.description)!, id: (self.package?.id!)!)
            //performSegue(withIdentifier: "unwindToDeliveriesTab", sender: self)
        }
    }
    
    func openRateScreen(descript: String, id: String){
        var rateUsInfo = MBRateUsInfo()
        //pack?.value(forKey: "description")
        rateUsInfo.title = "\(descript) was Delivered!"
        rateUsInfo.titleImage = UIImage(named: "icon")
        rateUsInfo.subtitle = "Please rate the sender"
        rateUsInfo.negative = "Darn. The sender should have been better."
        rateUsInfo.itunesId = "0"
        MBRateUs.sharedInstance.rateUsInfo = rateUsInfo
        
        MBRateUs.sharedInstance.showRateUs(base: self
            , positiveBlock: { (rate) -> Void in
                let packageData = ["senderRate": rate,
                                   "status": "delivered",
                                   "new": true] as [String : Any]
                
                FIREBASE().ref.child(self.owner!).child(id).updateChildValues(packageData)
                self.performSegue(withIdentifier: "unwindToDeliveriesTab", sender: self)
                //print(rate)
                
        }, negativeBlock: { (rate) -> Void in
            let packageData = ["senderRate": rate,
                               "status": "delivered",
                               "new": true] as [String : Any]
            
            FIREBASE().ref.child(self.owner!).child(id).updateChildValues(packageData)
            self.performSegue(withIdentifier: "unwindToDeliveriesTab", sender: self)
            //print(rate)
            
        }) { () -> Void in
            
        }
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MyDeliveriesTabController
        {
            let vc = segue.destination as? MyDeliveriesTabController
            vc?.view.showToast(toastMessage: "Delivery Completed and signature saved", duration: 4)
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK: - Delegate Methods
    
    // The delegate functions gives feedback to the instanciating class. All functions are optional,
    // meaning you just implement the one you need.
    
    // didStart() is called right after the first touch is registered in the view.
    // For example, this can be used if the view is embedded in a scroll view, temporary
    // stopping it from scrolling while signing.
    func didStart() {
        print("Started Drawing")
    }
    
    // didFinish() is called rigth after the last touch of a gesture is registered in the view.
    // Can be used to enabe scrolling in a scroll view if it has previous been disabled.
    func didFinish() {
        print("Finished Drawing")
    }
}
