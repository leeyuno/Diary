//
//  UserService.swift
//  Diary
//
//  Created by leeyuno on 2021/02/22.
//

import Foundation

import Alamofire
import Firebase
import RxSwift

enum UserEvent {
    case create(String)
}

protocol UserServiceType {
    var event: PublishSubject<UserEvent> { get }
    func create(userID: String) -> Observable<Bool>
}

final class UserService: UserServiceType {
    let event = PublishSubject<UserEvent>()
    
    func create(userID: String) -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            AF.request(URL(string: Library.libObject.url + "/register")!, method: .post, parameters: ["userID": userID], encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    print(debug: value)
                    observer.onNext(true)
                    observer.onCompleted()
                case .failure(let error):
                    print(debug: error)
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
