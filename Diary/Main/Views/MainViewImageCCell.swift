//
//  MainViewImageCCell.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import UIKit

import CircleMenu

class MainViewImageCCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var circleButton: CircleMenu!
    
//    var gradientLayer: CAGradientLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        circleButton.isEnabled = false
        
        circleButton.isSelected = false
        
        imageView.contentMode = .scaleAspectFill
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        circleButton.layer.masksToBounds = true
        circleButton.layer.cornerRadius = 25
        
//        setGradient()
    }
    
    func setGradient() {
        var gradient = CAGradientLayer()
        gradient = CAGradientLayer()
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        gradient.colors = [UIColor.lightGray.withAlphaComponent(0.4).cgColor, UIColor.clear.cgColor, UIColor.lightGray.withAlphaComponent(0.4).cgColor]
        
        imageView.layer.addSublayer(gradient)
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
}
