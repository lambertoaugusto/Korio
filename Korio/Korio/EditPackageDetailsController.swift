//
//  EditPackageDetailsController.swift
//  Korio
//
//  Created by Student on 2018-03-06.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class EditPackageDetailsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var weight: UITextField!
    
    @IBOutlet weak var value: UITextField!    
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var sizePicker: UIPickerView!
    
    var packageDetails: PackageDetails?
    var id: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sizePicker.delegate = self
        self.sizePicker.dataSource = self

        
        desc.text = self.packageDetails?.description
        //size.text = SIZE().sizeData[(self.packageDetails?.size)!]
        sizePicker.selectRow((packageDetails?.size)!, inComponent: 0, animated: false)
        value.text = self.packageDetails?.value.description
        weight.text = self.packageDetails?.weight.description

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(title: String, message: String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }


    @IBAction func save(_ sender: Any) {
        if !((self.desc.text!).isEmpty){
            if let vFloat = Float(self.value.text!) {
                if let wFloat = Float(self.weight.text!){
                    self.packageDetails?.description = self.desc.text!
                    self.packageDetails?.size = sizePicker.selectedRow(inComponent: 0)
                    self.packageDetails?.value = Float(self.value.text!)!
                    self.packageDetails?.weight = Float(self.weight.text!)!
                    do {
                        try self.packageDetails?.savePackageDetailsFirebase(id: self.id!)
                        FIREBASE().ref.child(userId).child(self.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if snapshot.hasChild("deliveryPerson"){
                                print("exist delivery person")
                                let packageData = ["status": "changed",
                                                   "new": true] as [String : Any]
                                
                                FIREBASE().ref.child(userId).child(self.id!).updateChildValues(packageData)
                                //FIREBASE().ref.child(USER().id).child(self.id!).child("status").setValue()
                                //FIREBASE().ref.child(USER().id).child(self.id!).child("new").setValue(true)
                                print("EditPackageDetailsController")
                            }else{
                                print("delivery person doesn't exist")
                            }
                            
                            
                        })
                        
                        
                        performSegue(withIdentifier: "EditPackageDetailsUnwindSegue", sender: self)
                    } catch let error {
                        self.showAlert(title: "Error", message: "Can not save changes!")
                    }
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
        //performSegue(withIdentifier: "segueSaveEditPackageDetails", sender: self)
        //dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HistoryCellDetailsController
        {
            var vc = segue.destination as? HistoryCellDetailsController
            vc?.package.packageDetails = self.packageDetails
            print("package details changed")
            //vc?.viewDidLoad()
            /*vc?.packageDetails.name = self.desc.text!
            vc?.packageDetails.size = self.size.text!
            vc?.packageDetails.value = Float(self.value.text!)!
            vc?.packageDetails.weight = Float(self.weight.text!)!
            vc?.packageDescription.text = self.desc.text!
            vc?.packageSize.text = self.size.text!
            vc?.packageValue.text = self.value.text!
            vc?.packageWeight.text = self.weight.text!
            */
            //vc?.historyTabController.historyTable?.reloadData()
            //vc?.historyTabController.viewDidLoad()
        }
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
