//
//  FeelsImage.swift
//  Diary
//
//  Created by leeyuno on 2021/02/17.
//

import UIKit

struct FeelImages {
    static let sharedInstance = FeelImages()
    let items: [(icon: String, color: UIColor)] = [
        ("sun.max", .systemGreen),
        ("cloud.sun", .systemYellow),
        ("cloud", .systemGray),
        ("cloud.rain", .systemBlue),
        ("cloud.bolt.rain", .systemRed)
    ]
}
