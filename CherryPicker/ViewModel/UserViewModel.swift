//
//  UserViewModel.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/01.
//

import SwiftUI
import Combine
import AuthenticationServices

enum UserColorScheme: String {
    case system = "시스템 기본값"
    case light = "라이트 모드"
    case dark = "다크 모드"
}

enum LoginedPlatform: Int {
    case apple
    case kakao
    case google
    case notLogined
}

class UserViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    @AppStorage("이메일") private var userEmail = ""
    
    @AppStorage("화면스타일") var userColorScheme: UserColorScheme = .system
    @AppStorage("로그인플랫폼") var platform: LoginedPlatform = .notLogined
    
    @Published private var token = ""
    @Published private var accessToken = ""
    
    @Published var isAuthenticated = false
    @Published var isUserConfirmed = false
    @Published var error: APIError?
    @Published var showError = false
    @Published var retryAction: (() -> Void)?
    
    
    private var subscriptions = Set<AnyCancellable>()
    private let tokenAccessKey = UIDevice.current.identifierForVendor!.uuidString
    
    var readUserEmail: String {
        get {
            return userEmail
        }
    }
    
    var readToken: String {
        get {
            return token
        }
    }
    
    var readAccessToken: String {
        get {
            return accessToken
        }
    }
    
    override init() {
        super.init()
        
        if let token = self.loadTokenFromKeychain(key: tokenAccessKey) {
            self.token = token
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func loginCallbackHandler(response: HTTPURLResponse, showLoginWebView: inout Bool) throws {
        guard response.statusCode == 200 else {
            switch response.statusCode {
            case 400:
                throw APIError.loginFail
            case 500:
                throw APIError.internalServerError
            default:
                throw APIError.unknown(statusCode: response.statusCode)
            }
        }
        
        guard let token = response.value(forHTTPHeaderField: "Authorization") else {
            return
        }
        
        guard let accessToken = response.value(forHTTPHeaderField: "AccessToken") else {
            return
        }
        
        guard let email = response.value(forHTTPHeaderField: "UserEmail") else {
            return
        }
        
        withAnimation(.easeInOut) {
            isUserConfirmed = true
        }
        
        self.token = token
        isAuthenticated = true
        
        saveTokenToKeychain(key: self.tokenAccessKey, token: token)
        
        self.userEmail = email
        self.accessToken = accessToken
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        showLoginWebView = false
    }
    
    func deleteUserInfo() {
        deleteTokenFromKeychain()
        userEmail = ""
        token = ""
        isAuthenticated = false
        platform = .notLogined
    }
    
    private func saveTokenToKeychain(key: String, token: String) {
        guard let data = token.data(using: String.Encoding.utf8) else {
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            self.deleteTokenFromKeychain()
            self.saveTokenToKeychain(key: key, token: token)
            
            return
        }
    }
    
    private func deleteTokenFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenAccessKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    private func loadTokenFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        guard let retrievedData = dataTypeRef as? Data else {
            return nil
        }
        
        let result = String(data: retrievedData, encoding: .utf8)
        
        return result
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        if let familyName = credential.fullName?.familyName, let givenName = credential.fullName?.givenName, let userEmail = credential.email {
            appleLogin(userEmail: userEmail, userName: familyName + givenName)
            saveAppleCredentialInfo(userIdentifier: credential.user, userEmail: userEmail, userName: familyName + givenName)
        } else {
            guard let userEmail = loadTokenFromKeychain(key: credential.user) else {
                return
            }
            
            guard let userName = loadTokenFromKeychain(key: userEmail) else {
                return
            }
            
            appleLogin(userEmail: userEmail, userName: userName)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        withAnimation(.spring()) {
            APIError.showError(showError: &self.showError, error: &self.error, catchError: APIError.convert(error: error))
        }
    }
    
    private func appleLogin(userEmail: String, userName: String) {
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.doAppleLogin(userEmail: userEmail, nickname: userName, subscriptions: &subscriptions) { token, email in
            DispatchQueue.main.async {
                self.token = token
                self.isAuthenticated = true
                
                self.saveTokenToKeychain(key: self.tokenAccessKey, token: token)
                
                self.userEmail = email
                
                self.platform = .apple
            }
        } errorHandling: { apiError in
            withAnimation(.spring()) {
                APIError.showError(showError: &self.showError, error: &self.error, catchError: apiError)
            }
        }
    }
    
    private func saveAppleCredentialInfo(userIdentifier: String, userEmail: String, userName: String) {
        saveTokenToKeychain(key: userIdentifier, token: userEmail)
        saveTokenToKeychain(key: userEmail, token: userName)
    }
}
