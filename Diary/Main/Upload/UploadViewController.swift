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
import Toaster

class UploadViewController: UIViewController {
    
    var mainEntity: MainEntity?
    
//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagTextField: CustomTextFIeld!
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
    
    let rightItem = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var tagList: [String] = [""]
    var imageList: [UIImage] = [UIImage]()
    
    var isKeyboardShow: Bool = false
    
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(debug: mainEntity)
        dateLabel.textColor = UIColor.white
        dateLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        dateLabel.layer.cornerRadius = 6
        dateLabel.layer.masksToBounds = true
        dateLabel.isHidden = true

        circleButton.isHidden = true
        circleButton.delegate = self
        circleButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        circleButton.setImage(UIImage(systemName: "smiley"), for: .selected)
        circleButton.layer.cornerRadius = circleButton.frame.width / 2
        circleButton.backgroundColor = UIColor.white
        
        let nib = UINib(nibName: "ImageCCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        
        tagTextField.isHidden = true
        tagTextField.layoutIfNeeded()
        tagTextField.textColor = UIColor.white
        tagTextField.tintColor = UIColor.white
        tagTextField.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        tagTextField.layer.addBorder([.bottom], color: UIColor.white.withAlphaComponent(0.6), width: 1.2, lineWidth: tagTextField.frame.width - 12)
        tagTextField.layer.cornerRadius = 8
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isKeyboardShow {
                textFieldBottomConstraint.constant = (keyboardFrame.height - 30)
                isKeyboardShow = true
                UIView.animate(withDuration: 1.0) { [weak weakSelf = self] in
                    weakSelf?.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if isKeyboardShow {
            textFieldBottomConstraint.constant = 15
            isKeyboardShow = false
            UIView.animate(withDuration: 1.0) { [weak weakSelf = self] in
                weakSelf?.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR") as Locale
        
        dateLabel.text = dateFormatter.string(from: date)
        
        tabBarController?.navigationItem.rightBarButtonItem = rightItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
    
    //    @objc private func upload() {
    //
    //    }
    
    func selectedImage() {
//        self.present(imagePicker, animated: true, completion: nil)
        gallery = GalleryController()
        gallery.delegate = self
//        Config.Permission.image = UIImage(named: ImageList.Gallery.cameraIcon)
//        Config.Font.Text.bold = UIFont(name: FontList.OpenSans.bold, size: 14)!
        Config.Camera.recordLocation = false
        Config.tabsToShow = [.imageTab]
        Config.Camera.imageLimit = 4
        present(gallery, animated: true, completion: nil)
    }
    
    private func viewInitialize() {
        Toast(text: "오늘 일기쓰기 끝!").show()
        imageList.removeAll() 
        dateLabel.isHidden = true
        tagTextField.text = ""
        tagTextField.isHidden = true
        
        circleButton.isHidden = true
        circleButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        circleButton.setImage(UIImage(systemName: "smiley"), for: .selected)
        circleButton.backgroundColor = UIColor.white
        
        collectionView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension UploadViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension UploadViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCCell", for: indexPath) as! ImageCCell
        
        cell.imageView.image = imageList[indexPath.row]
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.height - 16)
    }
}

extension UploadViewController: StoryboardView {
    func bind(reactor: UploadViewReactor) {
        let subject = BehaviorSubject(value: mainEntity).subscribe { (data) in
            print(debug: data)
        }.disposed(by: disposeBag)

        
        reactor.state.map {
            $0.isLoadingResult
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak weakSelf = self] (state) in
            if let state = state {
                if state {
                    weakSelf?.viewInitialize()
                } else {
                    Toast(text: "실패 ㅠㅠ").show()
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
        collectionView.reloadData()
        
        Image.resolve(images: images) { [weak weakSelf = self] (images) in
            for image in images {
                if let image = image {
                    weakSelf?.imageList.append(image)
                }
            }
            weakSelf?.collectionView.reloadData()
        }
        
        if images.count > 0 {
            dateLabel.isHidden = false
            tagTextField.isHidden = false
            circleButton.isHidden = false
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
        let highlightedImage = UIImage(systemName: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
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

//extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//
//            imageView.image = selectedImage
//        }
//
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
