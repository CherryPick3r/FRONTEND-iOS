//
//  UserViewModel.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/01.
//

import SwiftUI

enum UserColorScheme: String {
    case system = "시스템 기본값"
    case light = "라이트 모드"
    case dark = "다크 모드"
}

class UserViewModel: ObservableObject {
    @AppStorage("화면스타일") var userColorScheme: UserColorScheme = .system
    
    @Published private var userEmail = "kakao_test@naver.com"
    @Published private var token = ""
    
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
}
