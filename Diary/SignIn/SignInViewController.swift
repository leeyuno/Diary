//
//  SignInViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import AuthenticationServices
import CryptoKit
import CoreData
import UIKit

import Alamofire
import ReactorKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
//        reAuth()
    }
    
    private func configureView() {
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.cornerRadius = 8
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(appleSignIn), for: .touchUpInside)
        view.addSubview(appleButton)
        
        appleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        appleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        appleButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        appleButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
    }
    
    @objc private func appleSignIn() {
        startSignInWithAppleFlow()
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func register() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.M.d"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let startDate = dateFormatter.string(from: date)

        Source.httpSource.sessionManager.request(URL(string: Library.libObject.url + "/register")!, method: .post, parameters: ["userID": Auth.auth().currentUser?.uid ?? "", "startDate": startDate], encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).validate().responseJSON { [weak weakSelf = self] (response) in
            switch response.result {
            case .success(let value):
                if let json = value as? NSDictionary {
                    let code = json["code"] as! Int

                    if code == 200 {
                        weakSelf?.moveToMain()
                    } else {

                    }
                }
            case .failure(let error):
                print(debug: error.localizedDescription)
            }
        }
    }
    
    private func moveToMain() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController
            let nav = UINavigationController(rootViewController: vc)
            
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}

extension SignInViewController: StoryboardView {
    func bind(reactor: SignInViewReactor) {
        //action
        
        //state
        reactor.state.asObservable().map { $0.regist }
            .bind { [weak weakSelf = self] (status) in
                if status {
                    weakSelf?.moveToMain()
                }
            }.disposed(by: disposeBag)
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print(debug: "Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print(debug: "Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            Auth.auth().signIn(with: credential) { [weak weakSelf = self] (authResult, error) in
                if let error = error {
                    print(debug: error.localizedDescription)
                    return
                } else {
                    let userIdentifier = appleIDCredential.user
//                    Reactor.Action.register
                    weakSelf?.register()
                    
//                    weakSelf?.moveToMain()
                }
            }
            
//            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { [weak weakSelf = self] (authResult, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    weakSelf?.moveToMain()
//                }
//            })
            // Sign in with Firebase.
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(debug: error.localizedDescription)
    }
}
