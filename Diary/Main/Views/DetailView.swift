//
//  DetailView.swift
//  Diary
//
//  Created by leeyuno on 2021/02/15.
//

import UIKit

class DetailView: UIView {

    @IBOutlet weak var textView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineSpacing = 4.0
        
        textView.typingAttributes = [.font: UIFont.systemFont(ofSize: 14.0, weight: .regular), .foregroundColor: UIColor.black, .paragraphStyle: paragraphStyle]
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
