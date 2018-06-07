//
//  TermsAcceptedController.swift
//  Korio
//
//  Created by Student on 2018-04-11.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import FirebaseDatabase


class TermsAcceptedController: UIViewController {

    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var accept: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accept.isUserInteractionEnabled = false
        checkBox.buttonLinked = accept
    }
   
   /* override func viewDidLoad() {
        super.viewDidLoad()
        
        accept.isUserInteractionEnabled = false
        checkBox.buttonLinked = accept
        
        if UserDefaults.standard.bool(forKey: "TermsAccepted") {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "mainView") as! ViewController
            self.present(newViewController, animated: true, completion: nil)
            //performSegue(withIdentifier: "startAppSegue", sender: self)
        } else {
            // Terms have not been accepted. Show terms (perhaps using
        }
        // Do any additional setup after loading the view.
    }*/

    @IBAction func accept(_ sender: Any) {
        let id = UIDevice.current.identifierForVendor!.uuidString
        let date = Date()
        Database.database().reference().child("TermsAccepted").child(id).setValue(date.description)
        UserDefaults.standard.set(true, forKey: "TermsAccepted")
        performSegue(withIdentifier: "startAppSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
