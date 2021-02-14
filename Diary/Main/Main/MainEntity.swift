//
//  MainEntity.swift
//  Diary
//
//  Created by leeyuno on 2021/02/11.
//

import Foundation

struct MainEntity: Codable {
    var date: String?
    var image: [String]?
    var tags: [String]?
    var feel: String?
    
    enum codingKeys: String, CodingKey {
        case date, image, tags, feel
    }
}
