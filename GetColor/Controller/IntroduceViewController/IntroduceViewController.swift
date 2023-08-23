//
//  IntroduceViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 13/07/2023.
//

import UIKit

class IntroduceViewController: UIViewController {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signinButton?.bringSubviewToFront(self.view)

    }
    override func viewWillLayoutSubviews() {
        setUpView()
    }
  
    
    
    func setUpView(){
        self.view.backgroundColor = AppColor.colorTheme
        self.signinButton?.tintColor = AppColor.pinkBackground
        self.signupButton?.titleLabel?.textColor = UIColor.white
        
    }

}
