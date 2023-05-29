//
//  UserViewModel.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/01.
//

import SwiftUI
import Combine

enum UserColorScheme: String {
    case system = "시스템 기본값"
    case light = "라이트 모드"
    case dark = "다크 모드"
}

class UserViewModel: ObservableObject {
    @AppStorage("화면스타일") var userColorScheme: UserColorScheme = .system
    @AppStorage("이메일") private var userEmail = "kakao_test@naver.com"
    
    @Published private var token = ""
    @Published var isAuthenticated = false
    
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
    
    init() {
        if let token = self.loadTokenFromKeychain() {
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
        
        guard let email = response.value(forHTTPHeaderField: "UserEmail") else {
            return
        }
        
        self.token = token
        isAuthenticated = true
        
        saveTokenToKeychain(token: token)
        
        self.userEmail = email
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        showLoginWebView = false
    }
    
    func deleteUserInfo() {
        deleteTokenFromKeychain()
        userEmail = ""
        token = ""
        isAuthenticated = false
    }
    
    private func saveTokenToKeychain(token: String) {
        guard let data = token.data(using: String.Encoding.utf8) else {
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenAccessKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            self.deleteTokenFromKeychain()
            self.saveTokenToKeychain(token: token)
            
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
    
    private func loadTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenAccessKey,
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
}
