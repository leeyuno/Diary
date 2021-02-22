//
//  String+Extension.swift
//  Diary
//
//  Created by leeyuno on 2021/02/16.
//

import UIKit

extension String {
    func textViewHeight(_ width: CGFloat, font: UIFont, lineSpacing: CGFloat) -> CGFloat {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        textView.text = self
        textView.attributedText = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphStyle, .kern: 1.1])
//        textView.textContainerInset = .zero
        
        textView.sizeToFit()
        
        return textView.contentSize.height
    }
}
