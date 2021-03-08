//
//  Source.swift
//  Diary
//
//  Created by leeyuno on 2021/02/10.
//

import Foundation

import Alamofire

class Source {
    static let httpSource = Source()
    
//    var session = Session()
    
    lazy var sessionManager: Session = {
        let policy = RetryPolicy(retryLimit: 1)
        let interceptors = Interceptor(interceptors: [self, policy])
        let session = Session(configuration: Session.default.session.configuration, interceptor: interceptors)
//        session.sessionConfiguration.headers = Library.LibObject.header ?? []
        
        return session
    }()
}

extension Source: RequestRetrier, RequestAdapter, RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        print(debug: urlRequest)
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print(debug: request.response)
//        print(debug: "\(request.response?.url?.absoluteString ?? "") \(request.response?.statusCode ?? 0) \(request.retryCount)")
        
        guard let statusCode = request.response?.statusCode, request.retryCount < 1 else {
            completion(.doNotRetryWithError(error))
            return
        }
    }
}
