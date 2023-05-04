//
//  CherryPickerApp.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/03/21.
//

import SwiftUI

@main
struct CherryPickerApp: App {
    @StateObject var userViewModel = UserViewModel()
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color("main-point-color"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color("main-point-color"))]
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(userViewModel)
                .preferredColorScheme(colorScheme())
        }
    }
    
    func colorScheme() -> ColorScheme? {
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
