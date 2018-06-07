//
//  HistoryController.swift
//  Korio
//
//  Created by Student on 2018-02-27.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class HistoryController: UIViewController {
    
    enum TabIndex : Int {
        case history = 0
        case inTransit = 1
    }

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentedControl: TabSegmentedControl!
    
    var currentViewController: UIViewController?
    
    lazy var historyTabVC: UIViewController? = {
        let historyTabVC = self.storyboard?.instantiateViewController(withIdentifier: "historyViewController")
        return historyTabVC
    }()
    
    lazy var inTransitTabVC : UIViewController? = {
        let inTransitTabVC = self.storyboard?.instantiateViewController(withIdentifier: "inTransitViewController")
        
        return inTransitTabVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        segmentedControl.initUI()
        segmentedControl.selectedSegmentIndex = TabIndex.history.rawValue
        displayCurrentTab(TabIndex.history.rawValue)
        
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
        case TabIndex.history.rawValue :
            vc = historyTabVC
        case TabIndex.inTransit.rawValue :
            vc = inTransitTabVC
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
