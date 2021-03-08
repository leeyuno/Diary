//
//  MainViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import Alamofire
import Firebase
import RxCocoa
import RxViewController
import ReactorKit
import RxSwift
import Kingfisher
import Toaster

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var tasks = [Task]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.4)
    }
    
    private func configureView() {
        let data1: [String: Any] = ["date": "2012-03-12", "tags": ["여행", "행복", "친구"], "feel": 1]
        let data2: [String: Any] = ["date": "2012-03-11", "tags": ["불합격", "우울", "소주한잔"], "feel": 3]
    }
    
//    private func todoCheck() {
//        let date = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYY.M.d"
//        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR") as Locale
//        
//        
//        let filter = tasks.filter { $0.date == dateFormatter.string(from: date)}
//        
//        if filter.count > 0 {
//            Library.libObject.todo = true
//        } else {
//            Library.libObject.todo = false
//        }
//        
//        refreshControl.endRefreshing()
//    }
    
    private func configureCollectionView() {
        collectionView.layoutIfNeeded()
        let nib = UINib(nibName: "MainViewImageCCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MainViewImageCCell")
        
        let headerNib = UINib(nibName: "MainReusableView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MainReusableView")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.addSubview(refreshControl)
    }
}

extension MainViewController: StoryboardView {
    func bind(reactor: MainViewReactor) {
        //action
        Observable.just(Void())
            .map{ Reactor.Action.fetch }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent([.valueChanged]).map {
            return Reactor.Action.fetch
        }.bind(to: reactor.action).disposed(by: disposeBag)
        
        //state
        reactor.state.asObservable().map { $0.data }
            .bind { (task) in
                self.tasks.append(contentsOf: task)
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
//                self.todoCheck()
                print(debug: self.tasks)
            }.disposed(by: disposeBag)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 50, height: collectionView.frame.height * 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "UploadViewController") as? UploadViewController {
            vc.tasks = tasks[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewImageCCell", for: indexPath) as! MainViewImageCCell
        
        cell.imageView.kf.setImage(with: URL(string: Library.libObject.url + "/images/\(tasks[indexPath.row].image?[0] ?? "")"))
        cell.circleButton.tintColor = UIColor.black
        let item = FeelImages.sharedInstance.items[tasks[indexPath.row].feels?[0] ?? 0]
        
        cell.circleButton.setImage(UIImage(systemName: item.icon), for: .normal)
        cell.circleButton.backgroundColor = item.color
        cell.circleButton.isSelected = false
        cell.circleButton.buttonsCount = 0
        
        cell.dateLabel.textColor = UIColor.white
        cell.dateLabel.attributedText = NSAttributedString(string: tasks[indexPath.row].date ?? "", attributes: [.font: UIFont.systemFont(ofSize: 18.0, weight: .semibold), .foregroundColor: UIColor.white])
        
        cell.tagLabel.attributedText = NSAttributedString(string: tasks[indexPath.row].contents?[0] ?? "", attributes: [.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)])
        cell.tagLabel.textColor = UIColor.white
        
        cell.layoutIfNeeded()
        cell.setGradient()
        
        return cell
    }
}
