//
//  ProfileViewReactor.swift
//  Diary
//
//  Created by leeyuno on 2021/02/21.
//

import Foundation

import Alamofire
import ReactorKit

class ProfileViewReactor: Reactor {
    let initialState = State()
    
    enum Action {
        case fetch(String)
    }
    
    enum Mutation {
        case setData([String: [String]])
    }
    
    struct State {
        var isLoadingResult: Bool = false
        var list = [String]()
        var startDate = ""
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetch(data):
            return self.fetch(userID: data).catchErrorJustReturn([:])
                .map { Mutation.setData($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setData(data):
            state.list = data.values.first!
            state.startDate = data.keys.first!
            state.isLoadingResult = true
            
            return state
        }
    }
    
    private func fetch(userID: String) -> Observable<[String: [String]]> {
        var array = [String]()
        return Observable.create { (observer) -> Disposable in
            Source.httpSource.sessionManager.request(URL(string: Library.libObject.url + "/writeList")!, method: .post, parameters: ["userID": userID], encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).validate().responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    if let json = value as? NSDictionary {
                        let code = json["code"] as! Int
                        
                        if code == 200 {
                            let result = json["result"] as! NSDictionary
                            let date = result["startDate"] as! String
                            
                            let list = result["list"] as! NSArray
                            for l in list {
                                let temp = l as! [String: Any]
//                                list.append(r)
                                array.append(temp["date"] as! String)
                            }
                            observer.onNext([date: array])
                            observer.onCompleted()
                        }
                    }
                case .failure(let error):
                    print(debug: "Error: \(error.localizedDescription)")
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
