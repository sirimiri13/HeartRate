//
//  CheckUserInfoViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 31/07/2023.
//

import UIKit
import JGProgressHUD

class CheckUserInfoViewController: UIViewController {
    
    @IBOutlet weak var contentTextView: UITextView!
    var phoneNumber: String = ""
    let hud = JGProgressHUD(style: .dark)
    var isUser = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        checkUserInfo()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.navigationBar.topItem?.title = "Login"
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
    }
    
    func setView(){
        contentTextView.text = "With LifeGuard SmartCarer, now you can stay connected with your loved ones as well as monitor their healthy and well-being"
        contentTextView.backgroundColor = UIColor.clear
        contentTextView.textColor = UIColor.white
        contentTextView.font = UIFont.systemFont(ofSize: 18,weight: .medium)
        self.view.addGradient(colors: [AppColor.colorTheme, UIColor.white, UIColor.systemPink],locations: [0.0,0.5,1])
    }
    
    func checkUserInfo(){
        hud.show(in: self.view)
        
//        AccountService().fetchUserInfo(completionHandler: { [self] (userInfo) in
//            if (userInfo != nil){
//                self.hud.dismiss()
//                let story = UIStoryboard(name: "Main", bundle:nil)
//                let vc = story.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//                UIApplication.shared.windows.first?.rootViewController = vc
//                UIApplication.shared.windows.first?.makeKeyAndVisible()
//            }
//            else {
//                self.hud.dismiss()
//                let vc = (self.storyboard?.instantiateViewController(withIdentifier: "LoginFailedViewController"))! as!
//                    LoginFailedViewController
//                vc.isNoInternet = false
//                vc.phoneNumber = self.phoneNumber
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        })
    }
    

}
