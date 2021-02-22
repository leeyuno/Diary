//
//  SignInViewReactor.swift
//  Diary
//
//  Created by leeyuno on 2021/02/22.
//

import Alamofire
import Firebase
import ReactorKit
import RxCocoa
import RxSwift

final class SignInViewReactor: Reactor {
    
    enum Action {
        case register
    }
    
    enum Mutation {
        case result(Bool)
    }
    
    struct State {
        var regist: Bool = false
    }
    
    let initialState = State(regist: false)
    let provider = UserService()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .register:
            return provider.create(userID: Auth.auth().currentUser?.uid ?? "").map { .result($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .result(status):
            newState.regist = status
            
            return newState
        }
    }
}
