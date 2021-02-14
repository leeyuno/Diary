//
//  MainViewReactor.swift
//  Diary
//
//  Created by leeyuno on 2021/02/11.
//

import Foundation

import ReactorKit

class MainViewReactor: Reactor {
    var initialState: State = State()
    
    enum Action {
        case Fetch(Codable)
    }
    
    enum Mutation {
        case Fetch
        case Result(Bool?)
    }
    
    struct State {
        var isLoadingResult: Bool = false
    }
}
