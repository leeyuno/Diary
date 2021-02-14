//
//  MainViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import Alamofire
import Firebase
import ReactorKit
import Kingfisher

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    //    var ref: DatabaseReference!
    
    var mainEntity = [MainEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
//        configureCollectionView()
        //Simulator Test
//        configureView()
    }
    
    private func configureView() {
        let data1: [String: Any] = ["date": "2012-03-12", "tags": ["여행", "행복", "친구"], "feel": 1]
        let data2: [String: Any] = ["date": "2012-03-11", "tags": ["불합격", "우울", "소주한잔"], "feel": 3]
    }
    
    private func fetchData() {
        let userID = Auth.auth().currentUser?.uid
        
        AF.request(URL(string: Library.libObject.url + "/myDiary")!, method: .post, parameters: ["userID": userID ?? ""], encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseJSON { [weak weakSelf = self] (response) in
            switch response.result {
            case .success(let value):
                if let json = value as? NSDictionary {
                    if let result = json["result"] as? NSArray {
                        for item in result {
                            if let jsonData = try? JSONSerialization.data(withJSONObject: item, options: []) {
                                if let decoder = try? JSONDecoder().decode(MainEntity.self, from: jsonData) {
                                    weakSelf?.mainEntity.append(decoder)
                                }
                            }
                        }
                    }
//                    weakSelf?.collectionView.reloadData()
                    weakSelf?.configureCollectionView()
                }
            case .failure(let error):
                print(debug: "Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.layoutIfNeeded()
        let nib = UINib(nibName: "MainViewImageCCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MainViewImageCCell")
        
        let headerNib = UINib(nibName: "MainReusableView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainReusableView")
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension MainViewController: StoryboardView {
    func bind(reactor: MainViewReactor) {
        
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mainEntity.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MainReusableView", for: indexPath) as! MainReusableView

//            headerView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 40)
//            headerView.dateLabel.text = mainEntity[indexPath.row].date
            headerView.dateLabel.attributedText = NSAttributedString(string: mainEntity[indexPath.section].date ?? "", attributes: [.font: UIFont.systemFont(ofSize: 14.0, weight: .regular)])

            return headerView
        default:
            assert(false, "응 아니야")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3 - 10, height: collectionView.bounds.width / 3 - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  mainEntity[section].image?.count ?? 0
//        return mainEntity[section].data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "UploadViewController") as? UploadViewController {
            vc.mainEntity = mainEntity[indexPath.section]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewImageCCell", for: indexPath) as! MainViewImageCCell
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.kf.setImage(with: URL(string: Library.libObject.url + "/images/\(mainEntity[indexPath.section].image?[indexPath.row] ?? "")"))
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
}
