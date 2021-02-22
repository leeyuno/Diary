//
//  UploadViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import CircleMenu
import Gallery
import ReactorKit
import RxSwift
import RxCocoa
//import Kingfisher
import Toaster

class UploadViewController: UIViewController {
    
    var tasks: Task?
    var contents = [String]()
    var feels = [Int]()
    
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    //    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagTextView: UITextView!
    //    @IBOutlet weak var tagTextField: CustomTextFIeld!
    var gallery: GalleryController!
    
    @IBOutlet weak var circleButton: CircleMenu!
    let items: [(icon: String, color: UIColor)] = [
        ("sun.max", .systemGreen),
        ("cloud.sun", .systemYellow),
        ("cloud", .systemGray),
        ("cloud.rain", .systemBlue),
        ("cloud.bolt.rain", .systemRed)
    ]
    
    var feel: Int = 0
    var tempHashTag = ""
    
    let rightItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var tagList: [String] = [""]
    var imageList: [UIImage] = [UIImage]()
    var imageNameList: [String] = [String]()
    
    var isKeyboardShow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.textColor = UIColor.white
        dateLabel.layer.masksToBounds = true
        dateLabel.isHidden = true
        
        let nib = UINib(nibName: "ImageCCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Library.libObject.update = true
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.M.d"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        dateLabel.text = dateFormatter.string(from: date)
        
        if !Library.libObject.todo {
            tabBarController?.navigationItem.rightBarButtonItem = rightItem
        }
        
        if let mainData = tasks {
            collectionView.layoutIfNeeded()
            
            dateLabel.text = mainData.date
            
            for image in mainData.image ?? [] {
                imageNameList.append(image)
            }
            
            collectionView.reloadData()
            dateLabel.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //    @objc private func upload() {
    
    func selectedImage() {
        gallery = GalleryController()
        gallery.delegate = self
        Config.Camera.recordLocation = false
        Config.tabsToShow = [.imageTab]
        Config.Camera.imageLimit = 4
        present(gallery, animated: true, completion: nil)
    }
    
    private func viewInitialize() {
        Toast(text: "오늘 일기쓰기 끝!").show()
        imageList.removeAll()
        dateLabel.isHidden = true
        tagTextView.text = ""
        tagTextView.isHidden = true
        
        circleButton.isHidden = true
        circleButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        circleButton.setImage(UIImage(systemName: "smiley"), for: .selected)
        circleButton.backgroundColor = UIColor.white
        
        collectionView.reloadData()
        
        Library.libObject.update = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func convertHashtags(text:String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: text)
        attrString.beginEditing()
        // match all hashtags
        do {
            // Find all the hashtags in our string
            let regex = try NSRegularExpression(pattern: "(?:\\s|^)(#(?:[a-zA-Z].*?|\\d+[a-zA-Z]+.*?))\\b", options: NSRegularExpression.Options.anchorsMatchLines)
            let results = regex.matches(in: text,
                                        options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds, range: NSMakeRange(0, text.count))
            let array = results.map { (text as NSString).substring(with: $0.range) }
            for hashtag in array {
                // get range of the hashtag in the main string
                let range = (attrString.string as NSString).range(of: hashtag)
                // add a colour to the hashtag
                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red , range: range)
            }
            attrString.endEditing()
        }
        catch {
            attrString.endEditing()
        }
        return attrString
    }
}

extension UploadViewController: ImageCCellDelegate {
    func textViewEndEditing(_ text: String, tag: Int) {
        contents[tag] = text
    }
    
    func selectedCircleButton(_ index: Int, tag: Int) {
        feels[tag] = index
    }
}

extension UploadViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension UploadViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tasks == nil {
            return imageList.count
        } else {
            return imageNameList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCCell", for: indexPath) as! ImageCCell
        
        if tasks == nil {
            cell.imageView.image = imageList[indexPath.row]
        } else {
//            let item = FeelImages.sharedInstance.items[Int(tasks?.feels?[indexPath.row] ?? "0")!]
            let item = FeelImages.sharedInstance.items[tasks?.feels?[indexPath.row] ?? 0]
            print(debug: item)
            cell.circleButton.setImage(UIImage(systemName: item.icon), for: .normal)
            cell.circleButton.backgroundColor = item.color
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 3.5
            
            cell.imageView.kf.setImage(with: URL(string: Library.libObject.url + "/images/\(tasks?.image?[indexPath.row] ?? "")"))
            cell.textView.attributedText = NSAttributedString(string: tasks?.contents?[indexPath.row] ?? "", attributes: [.font: UIFont.systemFont(ofSize: 15.0, weight: .regular), .paragraphStyle: paragraphStyle, .foregroundColor: UIColor.white, .kern: 1.1])
            cell.textViewHeight.constant = (tasks?.contents?[indexPath.row] ?? "").textViewHeight(collectionView.frame.width - 50, font: UIFont.systemFont(ofSize: 15.0, weight: .regular), lineSpacing: 3.5)
        }
        
        cell.tag = indexPath.row
        
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        cell.imageCCellDelegate = self
        
        cell.setGradient()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.height - 16)
    }
}

extension UploadViewController: StoryboardView {
    func bind(reactor: UploadViewReactor) {
        //action
        rightItem.rx.tap.map { [self, weak weakSelf = self] in
            weakSelf?.view.endEditing(true)
            
//            return Reactor.Action.upload
            return Reactor.Action.upload(["date": weakSelf?.dateLabel.text ?? "", "feels": feels, "image": weakSelf?.imageList ?? [], "contents": contents])
        }
        .bind(to: reactor.action)
        .disposed(by: disposeBag)
        
        
        //state
        reactor.state.map {
            $0.isLoadingResult
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak weakSelf = self] (state) in
            if let state = state {
                if state {
                    Library.libObject.todo = true
                    weakSelf?.viewInitialize()
                } else {
                    Toast(text: "오늘 일기는 벌써 썼어요", delay: 0.0, duration: 5.0).show()
                }
            } else {
                print(debug: "초기")
            }
            
        }).disposed(by: disposeBag)
    }
}

extension UploadViewController: GalleryControllerDelegate {
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        imageList.removeAll()
        gallery = nil
        controller.dismiss(animated: true, completion: nil)
        
        Image.resolve(images: images) { [weak weakSelf = self] (images) in
            for image in images {
                if let image = image {
                    weakSelf?.imageList.append(image)
                }
            }
            self.contents = Array(repeating: "", count: images.count)
            self.feels = Array(repeating: 0, count: images.count)
            weakSelf?.collectionView.reloadData()
        }
        
        if images.count > 0 {
            dateLabel.isHidden = false
//            tagTextView.isHidden = false
//            circleButton.isHidden = false
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
    }
}

extension UploadViewController: CircleMenuDelegate {
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = items[atIndex].color
        
        button.contentMode = .scaleToFill
        button.setImage(UIImage(systemName: items[atIndex].icon), for: .normal)
        
        // set highlited image
        //        let highlightedImage = UIImage(systemName: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(UIImage(systemName: items[atIndex].icon), for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        circleMenu.setImage(nil, for: .normal)
        circleMenu.setImage(nil, for: .selected)
        
        feel = atIndex
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        circleMenu.setImage(UIImage(systemName: items[atIndex].icon), for: .normal)
        circleMenu.setImage(UIImage(systemName: items[atIndex].icon), for: .selected)
        circleMenu.backgroundColor = items[atIndex].color.withAlphaComponent(0.8)
    }
    
    func menuOpened(_ circleMenu: CircleMenu) {
    }
}
