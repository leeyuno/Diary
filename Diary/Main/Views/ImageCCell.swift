//
//  ImageCCell.swift
//  Diary
//
//  Created by leeyuno on 2021/02/12.
//

import UIKit

import CircleMenu
import RxCocoa
import RxSwift

protocol ImageCCellDelegate: class {
    func textViewEndEditing(_ text: String, tag: Int)
    func selectedCircleButton(_ index: Int, tag: Int)
}

class ImageCCell: UICollectionViewCell {

    weak var imageCCellDelegate: ImageCCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var circleButton: CircleMenu!
    @IBOutlet weak var textView: UITextView!
    var disposeBag = DisposeBag()
    var isKeyboardShow: Bool = false
    
    var feel: Int = 0
    
    func cellInit() {
        circleButton.isHidden = true
        circleButton.delegate = self
        circleButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        circleButton.setImage(UIImage(systemName: "smiley"), for: .selected)
        circleButton.layer.cornerRadius = circleButton.frame.width / 2
        circleButton.backgroundColor = UIColor.white
        
        textView.backgroundColor = UIColor.clear
        textView.delegate = self
        textView.isHidden = true
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.layoutIfNeeded()
        textView.textColor = UIColor.white
        textView.tintColor = UIColor.white
        textView.typingAttributes = [.font: UIFont.systemFont(ofSize: 15.0, weight: .regular), .foregroundColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), .kern: 1.1]
        textView.attributedText = NSAttributedString(string: "#해시태그는 #을 붙여주세요", attributes: [.font: UIFont.systemFont(ofSize: 15.0, weight: .regular), .foregroundColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), .kern: 1.1])
        
        imageView.rx.observe(UIImage.self, "image").map { $0 == nil }
            .subscribe { (isEmpty) in
                if let isEmpty = isEmpty.element, !isEmpty {
                    self.circleButton.isHidden = false
                    self.textView.isHidden = false
                }
            }.disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellInit()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isKeyboardShow {
                textViewBottomConstraint.constant = (keyboardFrame.height - 30)
                isKeyboardShow = true
                UIView.animate(withDuration: 1.0) { [weak weakSelf = self] in
                    weakSelf?.layoutIfNeeded()
                }
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        if isKeyboardShow {
            textViewBottomConstraint.constant = 15
            isKeyboardShow = false
            UIView.animate(withDuration: 1.0) { [weak weakSelf = self] in
                weakSelf?.layoutIfNeeded()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        self.layoutIfNeeded()
        for layers in imageView.layer.sublayers ?? [] {
            if let layer = layers as? CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func setGradient() {
        var gradient = CAGradientLayer()
        gradient = CAGradientLayer()
//        gradient.locations = [0.0, 0.8, 1.0]
//        gradient.startPoint = CGPoint(x: 0, y: 0)
//        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
//        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.yellow.cgColor]
        gradient.colors = [UIColor.lightGray.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor, UIColor.lightGray.withAlphaComponent(0.2).cgColor]
        
        imageView.layer.addSublayer(gradient)
    }
}

extension ImageCCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) {
            textView.text = ""
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4.0
            textView.typingAttributes = [.font: UIFont.systemFont(ofSize: 15.0, weight: .regular), .foregroundColor: UIColor.white, .paragraphStyle: paragraphStyle]
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        imageCCellDelegate?.textViewEndEditing(textView.text, tag: tag)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text == "" else { return }
        
        //        textView.textColor = UIColor.lightGray
        textView.attributedText = NSAttributedString(string: "#해시태그는 #을 붙여주세요", attributes: [.font: UIFont.systemFont(ofSize: 15.0, weight: .regular), .foregroundColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), .kern: 1.1])
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: textView.bounds.size.width, height: CGFloat(MAXFLOAT))
        let newSize = textView.sizeThatFits(sizeToFitIn)
        guard textViewHeight.constant != newSize.height else { return }
        textViewHeight.constant = newSize.height //+ 2
        textView.frame.size.height = newSize.height //+ 2
        
    }
}

extension ImageCCell: CircleMenuDelegate {
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        button.backgroundColor = FeelImages.sharedInstance.items[atIndex].color
        
        button.contentMode = .scaleToFill
        button.setImage(UIImage(systemName: FeelImages.sharedInstance.items[atIndex].icon), for: .normal)
        
        // set highlited image
        //        let highlightedImage = UIImage(systemName: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(UIImage(systemName: FeelImages.sharedInstance.items[atIndex].icon), for: .highlighted)
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        circleMenu.setImage(nil, for: .normal)
        circleMenu.setImage(nil, for: .selected)
        
        feel = atIndex
        
        imageCCellDelegate?.selectedCircleButton(atIndex, tag: tag)
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        circleMenu.setImage(UIImage(systemName: FeelImages.sharedInstance.items[atIndex].icon), for: .normal)
        circleMenu.setImage(UIImage(systemName: FeelImages.sharedInstance.items[atIndex].icon), for: .selected)
        circleMenu.backgroundColor = FeelImages.sharedInstance.items[atIndex].color.withAlphaComponent(0.8)
    }
    
    func menuOpened(_ circleMenu: CircleMenu) {
    }
}
