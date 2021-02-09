//
//  LauchViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import CoreData

class LaunchViewController: UIViewController {
    
    private let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCoreData()
        
        //시뮬레이터 애플아이디 강제 세팅
//        CoreDataStore.dataStore.setCoreData(data: CoreData(newId: "001766.28fa916e365c484f8fb8d971716c0579.0655"))
    }
    
    private func fetchCoreData() {
        if let coreData = CoreDataStore.dataStore.loadCoreData(), coreData.id != "" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        } else {
            let vc = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
