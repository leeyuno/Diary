//
//  UploadViewReactor.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import Firebase

import Alamofire
import ReactorKit

final class UploadViewReactor: Reactor {
    enum Action {
        case upload([String: Any])
    }
    
    enum Mutation {
        case result(Bool?)
    }
    
    struct State {
        var isLoadingResult: Bool?
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .upload(data):
            return self.upload(data).catchErrorJustReturn(false)
                .map { Mutation.result($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .result(success):
            
            newState.isLoadingResult = success
            
            return newState
        }
    }
    
    private func upload(_ with: [String: Any]) -> (Observable<Bool?>) {
//        var result = false
        
        let uid = Auth.auth().currentUser?.uid
        
        return Observable.create { (observer) -> Disposable in
            AF.upload(multipartFormData: { (multipartFormData) in
                if let images = with["image"] as? [UIImage] {
                    for image in images {
                        let imageData = image.jpegData(compressionQuality: 1.0)
                        multipartFormData.append(imageData!, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
                    }
                    
                    for tag in (with["tags"] as! [String]) {
                        multipartFormData.append(tag.data(using: .utf8)!, withName: "tags")
                    }
                    multipartFormData.append((uid ?? "").data(using: .utf8)!, withName: "userID")
    //                multipartFormData.append(("\(uid ?? "")\(with["date"] as! String).png").data(using: .utf8)!, withName: "image")
                    multipartFormData.append((with["date"] as! String).data(using: .utf8)!, withName: "date")
                    multipartFormData.append(("\(with["feel"] ?? 0)").data(using: .utf8)!, withName: "feel")
                }
            }, to: Library.libObject.url + "/uploadPhoto", method: .post, headers: nil).uploadProgress(queue: .main, closure: { (progress) in
                print(debug: "Upload Progress: \(progress.fractionCompleted)")
            }).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    print(debug: value)
                    observer.onNext(true)
                    
                    observer.onCompleted()
                case .failure(let error):
                    print(debug: "Error: \(error.localizedDescription)")
                    
                    
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
}
