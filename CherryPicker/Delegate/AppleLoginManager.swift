//
//  AppleLoginManager.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/30.
//

import UIKit
import AuthenticationServices

class AppleLoginManager: NSObject, ASAuthorizationControllerDelegate, ObservableObject {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
}
