//
//  PackageDetailsController.swift
//  Korio
//
//  Created by Student on 2018-02-20.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class PackageDetailsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //var packageDetails: PackageDetails!
    
    @IBOutlet weak var packageImage: UIImageView!
    
    @IBOutlet weak var packageDescription: UITextField!
    
    @IBOutlet weak var packageValue: UITextField!
    
    //@IBOutlet weak var packageSize: UITextField!
    
    @IBOutlet weak var packageWeight: UITextField!
    
    @IBOutlet weak var packSize: UIPickerView!
    
    //var sizeData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.packSize.delegate = self
        self.packSize.dataSource = self
        
        let packDetails = package.packageDetails
        
        if(packDetails != nil){
            packageDescription.text = packDetails?.description
            packageValue.text = packDetails?.value.description
            packageWeight.text = packDetails?.weight.description
            packSize.selectRow((packDetails?.size)!, inComponent: 0, animated: false)
            
            if(packDetails?.url != nil){
                //self.packageImage.image = packageDetails.image
                let imageView: UIImageView = self.packageImage
                
                // Placeholder image
                let placeholderImage = UIImage()
                
                // Load the image using SDWebImage
                imageView.sd_setImage(with: packDetails?.url, placeholderImage: placeholderImage)
            }
        }
        
        //print("PackageDetailsController viewDidLoad called")
        // Do any additional setup after loading the view.
    }   
    
    
    @IBAction func changePackageImage(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            //self.package!.picture = image
            self.packageImage.image = image
        }
    }
    
    func showAlert(title: String, message: String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func packageDetailsNext(_ sender: Any) {
        if !((self.packageDescription.text!).isEmpty){
            if let vFloat = Float(self.packageValue.text!) {
                if let wFloat = Float(self.packageWeight.text!){
                    package.addPackageDetails(packDescription: self.packageDescription.text!, packValue: vFloat, packSize: packSize.selectedRow(inComponent: 0), packWeight: wFloat)
                    package.packageDetails?.image = packageImage.image
                    performSegue(withIdentifier: "startPickupDetails", sender: self)
                }
                else{
                    self.showAlert(title: "Error", message: "Invalid weight!")
                }
            }
            else{
                self.showAlert(title: "Error", message: "Invalid value!")
            }
        }
        else{
            self.showAlert(title: "Error", message: "Description is required!")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SIZE().sizeData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SIZE().sizeData[row]
    }

    

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PickupDetailsController
        {
            let vc = segue.destination as? PickupDetailsController
                vc?.packageDetails = self.packageDetails
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    var jpegRepresentationData: NSData! {
        return UIImageJPEGRepresentation(self, 1.0)! as NSData   // QUALITY min = 0 / max = 1
    }
    var pngRepresentationData: NSData! {
        return UIImagePNGRepresentation(self)! as NSData
    }
}
