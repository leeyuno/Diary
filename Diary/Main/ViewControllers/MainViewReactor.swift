//
//  MainViewReactor.swift
//  Diary
//
//  Created by leeyuno on 2021/02/11.
//

import Foundation

import Alamofire
import ReactorKit

class MainViewReactor: Reactor {
    var initialState: State = State()
    
    let provider = TaskService()
    
    enum Action {
        case fetch
    }
    
    enum Mutation {
        case setData([Task])
    }
    
    struct State {
        var isLoadingResult: Bool = false
        var data = [Task]()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return self.provider.fetchTask()
                .map {
                    return .setData($0)
                }
        }
//        case let .fetch(userID):
//            return self.fetch(userID: userID).catchErrorJustReturn([])
//                .map { Mutation.setData($0) }
//        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setData(task):
            state.data = task
            
            return state
        }
    }
    
//    private func fetch(userID: String) -> Observable<[MainEntity]> {
//        var mainEntity = [MainEntity]()
//        return Observable.create { (observer) -> Disposable in
//            AF.request(URL(string: Library.libObject.url + "/myDiary")!, method: .post, parameters: ["userID": userID], encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseJSON { [weak weakSelf = self] (response) in
//                switch response.result {
//                case .success(let value):
//                    if let json = value as? NSDictionary {
//                        if let result = json["result"] as? NSArray {
//                            for item in result {
//                                if let jsonData = try? JSONSerialization.data(withJSONObject: item, options: []) {
//                                    if let decoder = try? JSONDecoder().decode(MainEntity.self, from: jsonData) {
////                                        weakSelf?.mainEntity.append(decoder)
//                                        mainEntity.append(decoder)
//                                    }
//                                }
//                            }
//                        }
//    //                    weakSelf?.collectionView.reloadData()
//    //                    weakSelf?.configureCollectionView()
//                        observer.onNext(mainEntity)
//                        observer.onCompleted()
//                    }
//                case .failure(let error):
//                    print(debug: "Error: \(error.localizedDescription)")
//                    observer.onError(error)
//                }
//            }
//
//            return Disposables.create()
//        }
//    }
}
