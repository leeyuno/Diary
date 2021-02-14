//
//  CustomTextFIeld.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

class CustomTextFIeld: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.attributedPlaceholder = NSAttributedString(string: "#해시태그 #띄어쓰기로 #구분", attributes: [.foregroundColor : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)])
    }
}
