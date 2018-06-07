//
//  CheckBox.swift
//  Korio
//
//  Created by Student on 2018-03-09.
//  Copyright © 2018 Korio. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_outline_blank")! as UIImage
    
    var buttonLinked: UIButton?
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                if(buttonLinked != nil){
                    buttonLinked?.isUserInteractionEnabled = true
                }
                //addObserver(self, forKeyPath: "checked", options: [], context: nil)
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                if(buttonLinked != nil){
                    buttonLinked?.isUserInteractionEnabled = false
                }
                //addObserver(self, forKeyPath: "unchecked", options: [], context: nil)
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
