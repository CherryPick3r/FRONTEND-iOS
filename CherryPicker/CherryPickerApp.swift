//
//  CherryPickerApp.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/03/21.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct CherryPickerApp: App {
    @StateObject var userViewModel = UserViewModel()
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color("main-point-color"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("main-point-color"))]
        UINavigationBar.appearance().standardAppearance = appearance
        
        guard let kakaoNativeAppKey = ProcessInfo.processInfo.environment["KAKAO_NATIVE_APP_KEY"] else {
            fatalError("API key not found")
        }
        
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(userViewModel)
                .preferredColorScheme(colorScheme)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
    
    var colorScheme: ColorScheme? {
        switch userViewModel.userColorScheme {
        case .system:
            return nil
        case .light:
            return ColorScheme.light
        case .dark:
            return ColorScheme.dark
        }
    }
}
