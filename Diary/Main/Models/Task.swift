//
//  Task.swift
//  Diary
//
//  Created by leeyuno on 2021/02/22.
//

import Foundation

struct Task: Codable {
    var date: String?
    var image: [String]?
    var feels: [Int]?
    var contents: [String]?
    
    enum codingKeys: String, CodingKey {
        case date, image, contents, feels
    }
}
