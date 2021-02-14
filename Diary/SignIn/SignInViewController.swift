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

import FirebaseAuth

class SignInViewController: UIViewController {
    
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
    
    private func moveToMain() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController
            let nav = UINavigationController(rootViewController: vc)
            
            UIApplication.shared.windows.first?.rootViewController = nav
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let userIdentifier = credential.user
//            let fullName = credential.fullName
//            let email = credential.email
//
//            let token = credential.identityToken?.base64EncodedString()
//
//            let provider = ASAuthorizationAppleIDProvider()
//            provider.getCredentialState(forUserID: userIdentifier) { [weak weakSelf = self] (credentialState, error) in
//                switch credentialState {
//                case .authorized:
//                    print(debug: "id: \(userIdentifier), name: \(fullName?.familyName ?? "") \(fullName?.givenName ?? ""), email: \(email ?? ""), token: \(token ?? "")")
////                    let coreData = CoreData(newId: userIdentifier)
////                    CoreDataStore.dataStore.setCoreData(data: coreData)
//
//                    weakSelf?.moveToMain()
//
//
//                //                    UIApplication.shared.windows.first?.rootViewController = vc
//                //                    UIApplication.shared.windows.first?.makeKeyAndVisible()
//                case .revoked:
//                    print(debug: "만료")
//                case .notFound:
//                    print(debug: "찾을 수 없음")
//                case .transferred:
//                    print(debug: "변경")
//                default:
//                    break
//                }
//            }
//        }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [weak weakSelf = self] (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(debug: error.localizedDescription)
                    return
                } else {
                    let userIdentifier = appleIDCredential.user
                    UserDefaults.standard.setValue(userIdentifier, forKey: "userId")
//                    let coreData = CoreData(newId: userIdentifier)
//                    CoreDataStore.dataStore.setCoreData(data: coreData)
                    weakSelf?.moveToMain()
                }
                // User is signed in to Firebase with Apple.
                // ...
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(debug: error.localizedDescription)
    }
}
