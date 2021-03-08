//
//  Library.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import Foundation

public func print(debug: Any, function: String = #function, file: String = #file, line: Int = #line) {
    #if DEBUG
    var filename: NSString = file as NSString
    filename = filename.lastPathComponent as NSString
    Swift.print("파일: \(filename), 라인: \(line), 함수: \(function), 메시지: \(debug)")
    #endif
}

class Library {
    static let libObject = Library()
    
    var app_id: String?
//    var todo: Bool!
    var update: Bool = false
    
    let url = "http://192.168.0.2:3000"
//    let url = "http://192.168.1.21:3000"
//    let url = "https://localhost:3000"
}
