//
//  UserViewModelPreview.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/06/02.
//

import SwiftUI

extension UserViewModel {
    static var preivew: UserViewModel {
        var showLoginView = false
        
        let userViewModel = UserViewModel()
        let _ = try? userViewModel.loginCallbackHandler(response: HTTPURLResponse(url: URL(string: "https://cherrypick3r.shop")!, statusCode: 200, httpVersion: nil, headerFields: ["Authorization" : "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIycnJobXdtcWdqQHByaXZhdGVyZWxheS5hcHBsZWlkLmNvbSIsInJvbGVzIjpbIlVTRVIiXSwiaWF0IjoxNjg1NTExMTI3LCJleHAiOjE2ODU1MTI5Mjd9.RCWHPtNrGE_ZMvlb8SVMgB_XKwubz4TD3sBE7luGJFk", "AccessToken" : "", "UserEmail" : "kakao_rlaehgud33@naver.com"])!, showLoginWebView: &showLoginView)
        
        return userViewModel
    }
}
