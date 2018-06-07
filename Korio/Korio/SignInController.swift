//
//  SignInController.swift
//  Korio
//
//  Created by Student on 2018-04-24.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
//import FBSDKLoginKit

class SignInController: UIViewController, GIDSignInUIDelegate {
    
    //let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //loginButton.delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().signIn()
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }
    
    /*func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*@IBAction func LogoutUnwind(unwindSegue: UIStoryboardSegue){
        if let viewController = unwindSegue.source as? ViewController {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                print("logout")
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
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
