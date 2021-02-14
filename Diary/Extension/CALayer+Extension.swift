//
//  CALayer+Extension.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.width)!, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: (UIApplication.shared.keyWindow?.frame.size.width)! - width, y: 0, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: frame.height)
                break
            default:
                break
            }
            
//            border.backgroundColor = UIColor.white.cgColor
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
    
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat, lineWidth: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: (frame.width - lineWidth) * 0.5, y: 0, width: lineWidth, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: (frame.width - lineWidth) * 0.5, y: frame.height - width, width: lineWidth, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.width)!, height: bounds.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: (UIApplication.shared.keyWindow?.frame.size.width)! - width, y: 0, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: frame.height)
                break
            default:
                break
            }
            
            //            border.backgroundColor = UIColor.white.cgColor
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}

