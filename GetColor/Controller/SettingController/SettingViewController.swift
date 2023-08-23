//
//  SettingViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 10/08/2023.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var torchSlider: UISlider!
    @IBOutlet weak var cropX: UITextField!
    @IBOutlet weak var cropY: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        cropX.styleTextField(color: AppColor.pinkBackground)
        cropY.styleTextField(color: AppColor.pinkBackground)
        self.navigationController?.title = "Settings"
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Do you want to logout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title:
                                        "OK", style: .default) { [unowned self] (alert) in
            DataManager.shared.cleanUp()
            UserDefaults.standard.set("logout",forKey:"userStatus")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "IntroduceViewController") as! IntroduceViewController
            self.navigationController?.setViewControllers([vc], animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert,animated: true)
    }
    
}
