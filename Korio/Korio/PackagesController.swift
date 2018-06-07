//
//  PackagesController.swift
//  Korio
//
//  Created by Student on 2018-04-17.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

//
//  HistoryController.swift
//  Korio
//
//  Created by Student on 2018-02-27.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class PackagesController: UIViewController {
    
    enum TabIndex : Int {
        case packages = 0
        case inTransit = 1
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControl: TabSegmentedControl!
    
    var currentViewController: UIViewController?
    
    lazy var packagesTabVC: UIViewController? = {
        let packagesTabVC = self.storyboard?.instantiateViewController(withIdentifier: "packagesViewController")
        return packagesTabVC
    }()
    
    lazy var inTransitPackTabVC : UIViewController? = {
        let inTransitPackTabVC = self.storyboard?.instantiateViewController(withIdentifier: "inTransitPackViewController")
        
        return inTransitPackTabVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.packages.rawValue
        displayCurrentTab(TabIndex.packages.rawValue)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    
    @IBAction func switchTab(_ sender: UISegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
        }
    }
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.packages.rawValue :
            vc = packagesTabVC
        case TabIndex.inTransit.rawValue :
            vc = inTransitPackTabVC
        default:
            return nil
        }
        
        return vc
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
