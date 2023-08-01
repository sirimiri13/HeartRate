//
//  MainViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 01/08/2023.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGradient(colors: [AppColor.colorTheme, UIColor.white, UIColor.systemPink],locations: [0.0,0.5,1])
        
    }
    

   

}
