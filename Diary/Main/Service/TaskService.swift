//
//  DiaryService.swift
//  Diary
//
//  Created by leeyuno on 2021/02/22.
//
import Foundation

import Alamofire
import Firebase
import RxSwift

enum TaskEvent {
    case create(Task)
    case update(Task)
}

protocol TaskserviceType {
    var event: PublishSubject<TaskEvent> { get }
    func fetchTask() -> Observable<[Task]>
    
    @discardableResult
//    func saveTask(_ tasks: [Task]) -> Observable<Void>
    
    func create(date: String, contents: [String], images: [UIImage], feels: [Int]) -> Observable<Bool>
//    func update(taskID: String, date: String, contents: [String], images: [UIImage], feels: [Int]) -> Observable<Task>
}

final class TaskService: TaskserviceType {
    let event = PublishSubject<TaskEvent>()
    
    func fetchTask() -> Observable<[Task]> {
        var tasks = [Task]()
        return Observable.create { (observer) -> Disposable in
            Source.httpSource.sessionManager.request(URL(string: Library.libObject.url + "/myDiary")!, method: .post, parameters: ["userID": Auth.auth().currentUser?.uid ?? ""], encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).validate(statusCode: 200 ..< 400).responseJSON { [weak weakSelf = self] (response) in
                switch response.result {
                case .success(let value):
                    if let json = value as? NSDictionary {
                        if let result = json["result"] as? NSArray {
                            for item in result {
                                if let jsonData = try? JSONSerialization.data(withJSONObject: item, options: []) {
                                    if let decoder = try? JSONDecoder().decode(Task.self, from: jsonData) {
                                        tasks.append(decoder)
                                    }
                                }
                            }
                        }
                        observer.onNext(tasks)
                        observer.onCompleted()
                    }
                case .failure(let error):
                    print(debug: "Error: \(error.localizedDescription)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    @discardableResult
    func saveTask(_ tasks: [String: Any]) -> Observable<Bool> {
        let uid = Auth.auth().currentUser?.uid
        print(debug: tasks)
        return Observable.create { (observer) -> Disposable in
            AF.upload(multipartFormData: { (multipartFormData) in
                if let images = tasks["image"] as? [UIImage] {
                    for image in images {
                        let imageData = image.jpegData(compressionQuality: 1.0)
                        multipartFormData.append(imageData!, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                    }
                    
                    for content in tasks["contents"] as! [String] {
                        multipartFormData.append(content.data(using: .utf8)!, withName: "contents")
                    }
                    
                    for feel in tasks["feels"] as! [Int] {
                        multipartFormData.append(("\(feel)").data(using: .utf8)!, withName: "feels")
                    }
                    
                    //                    for tag in (with["tags"] as! [String]) {
                    //                        multipartFormData.append(tag.data(using: .utf8)!, withName: "tags")
                    //                    }
                    multipartFormData.append((uid ?? "").data(using: .utf8)!, withName: "userID")
                    //                multipartFormData.append(("\(uid ?? "")\(with["date"] as! String).png").data(using: .utf8)!, withName: "image")
                    multipartFormData.append((tasks["date"] as! String).data(using: .utf8)!, withName: "date")
                    //                    multipartFormData.append(("\(with["feels"] ?? 0)").data(using: .utf8)!, withName: "feels")
                }
            }, to: Library.libObject.url + "/uploadPhoto", method: .post, headers: nil).uploadProgress(queue: .main, closure: { (progress) in
                print(debug: "Upload Progress: \(progress.fractionCompleted)")
            }).responseJSON(completionHandler: { (response) in
                print(debug: response)
                switch response.result {
                case .success(let value):
                    if let json = value as? NSDictionary {
                        //                        let result = json["result"] as! NSArray
                        let code = json["code"] as! Int
                        if code == 200 {
                            observer.onNext(true)
                        } else if code == 500 {
                            observer.onNext(false)
                        }
                    }
                        
                    observer.onCompleted()
                case .failure(let error):
                    print(debug: "Error: \(error.localizedDescription)")
                    
                    
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func create(date: String, contents: [String], images: [UIImage], feels: [Int]) -> Observable<Bool> {
        let uid = Auth.auth().currentUser?.uid
        return Observable.create { (observer) -> Disposable in
            AF.upload(multipartFormData: { (multipartFormData) in
                for image in images {
                    let imageData = image.jpegData(compressionQuality: 1.0)
                    multipartFormData.append(imageData!, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                }
                
                for content in contents {
                    multipartFormData.append(content.data(using: .utf8)!, withName: "contents")
                }
                
                for feel in feels {
                    multipartFormData.append(("\(feel)").data(using: .utf8)!, withName: "feels")
                }
                multipartFormData.append((uid ?? "").data(using: .utf8)!, withName: "userID")
                multipartFormData.append(date.data(using: .utf8)!, withName: "date")
            }, to: Library.libObject.url + "/uploadPhoto", method: .post, headers: nil).uploadProgress(queue: .main, closure: { (progress) in
                print(debug: "Upload Progress: \(progress.fractionCompleted)")
            }).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    if let json = value as? NSDictionary {
//                        let result = json["result"] as! NSArray
                        let code = json["code"] as! Int
                        if code == 200 {
                            observer.onNext(true)
//                            observer.onNext(Task(date: date, image: [], feels: feels, contents: contents))
                        } else if code == 500 {
                            observer.onNext(false)
                            
                        }
                    }
                    
                    observer.onCompleted()
                case .failure(let error):
                    print(debug: "Error: \(error.localizedDescription)")
                    
                    
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
    
//    func update(taskID: String, date: String, contents: [String], images: [UIImage], feels: [Int]) -> Observable<Task> {
//
//    }
}
