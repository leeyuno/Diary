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
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vc = viewController as? UploadViewController {
            vc.upload()
        }
    }
}
