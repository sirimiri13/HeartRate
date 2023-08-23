//
//  MainViewController.swift
//  GetColor
//
//  Created by Hương Lâm Quỳnh on 01/08/2023.
//

import UIKit

class MainViewController: UIViewController,UIScrollViewDelegate {
    @IBOutlet weak var sliderPageControl: UIPageControl!
    @IBOutlet weak var SliderScrollView: UIScrollView!
    @IBOutlet weak var measureButton: UIButton!
//    var pages : [NewsView] {
//        get {
//            let page1 = Bundle.main.loadNibNamed("NewsView", owner: self, options: nil)?.first as! NewsView
//            page1.backgroundColor = .brown
//            let page2 = Bundle.main.loadNibNamed("NewsView", owner: self, options: nil)?.first as! NewsView
//            page1.backgroundColor = .red
//            let page3 = Bundle.main.loadNibNamed("NewsView", owner: self, options: nil)?.first as! NewsView
//            page1.backgroundColor = .yellow
//
//            return [page1,page2,page3]
//        }
//    }
    
    var pages : [UIView] {
        get {
            let page1 = UIView()
            page1.backgroundColor = .yellow
            let page2 = UIView()
            page2.backgroundColor = .red
            return [page1, page2]
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("===> page: ",pages)
        self.view.bringSubviewToFront(sliderPageControl)
        setupScrollView(pages: pages)
        sliderPageControl.numberOfPages = pages.count
        sliderPageControl.currentPage = 0
        self.view.backgroundColor = AppColor.colorTheme
        self.navigationController?.isNavigationBarHidden = true
      
    }
    
    
    override func viewDidLayoutSubviews() {
        measureButton.tintColor = AppColor.pinkBackground
        measureButton.setShadow()
     
    }
    
    
    
    
    
    func setupScrollView (pages: [UIView]){
        SliderScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2 + 100)
        SliderScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(pages.count), height: view.frame.height/2 + 100)
        SliderScrollView.isPagingEnabled = true
               
               for i in 0 ..< pages.count {
                   pages[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height/2 + 100)
                   SliderScrollView.addSubview(pages[i])
               }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        sliderPageControl.numberOfPages = pages.count
        sliderPageControl.currentPage = Int(pageIndex)
    }
}

