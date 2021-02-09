//
//  SignInViewController.swift
//  Diary
//
//  Created by leeyuno on 2021/02/09.
//

import AuthenticationServices
import CoreData
import UIKit

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
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
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = credential.user
            let fullName = credential.fullName
            let email = credential.email
            
            let token = credential.identityToken?.base64EncodedString()
            
            let provider = ASAuthorizationAppleIDProvider()
            provider.getCredentialState(forUserID: userIdentifier) { [weak weakSelf = self] (credentialState, error) in
                switch credentialState {
                case .authorized:
                    print(debug: "id: \(userIdentifier), name: \(fullName?.familyName ?? "") \(fullName?.givenName ?? ""), email: \(email ?? ""), token: \(token ?? "")")
                    let coreData = CoreData(newId: userIdentifier)
                    
                    CoreDataStore.dataStore.setCoreData(data: coreData)
                    
                    DispatchQueue.main.async {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
//                    UIApplication.shared.windows.first?.rootViewController = vc
//                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                case .revoked:
                    print(debug: "만료")
                case .notFound:
                    print(debug: "찾을 수 없음")
                case .transferred:
                    print(debug: "변경")
                default:
                    break
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(debug: error.localizedDescription)
    }
}
