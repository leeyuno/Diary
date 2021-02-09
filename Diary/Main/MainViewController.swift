//
//  MainViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        configureCollectionView()
    }
    
    private func fetchData() {
        
    }
    
    private func configureCollectionView() {
        let nib = UINib(nibName: "MainViewImageCCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MainViewImageCCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewImageCCell", for: indexPath) as! MainViewImageCCell
        
        return cell
    }
}
