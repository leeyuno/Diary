//
//  MainTabBarViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        
        tabBar.isTranslucent = false
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = UIColor.black
        tabBar.backgroundColor = UIColor.darkGray
        tabBar.backgroundImage = UIImage()
        
        for view in viewControllers! {
            if let vc = view as? MainViewController {
                vc.reactor = MainViewReactor()
            }
            
            if let vc = view as? UploadViewController {
                vc.reactor = UploadViewReactor()
            }
        }
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            if let vc = viewController as? UploadViewController {
                vc.selectedImage()
            }
        }
    }
}
