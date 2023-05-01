//
//  BackgroundModifier.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/04/30.
//

import SwiftUI

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    Color("background-color")
                    
                    LinearGradient(colors: [
                        Color("main-point-color").opacity(0),
                        Color("main-point-color").opacity(0.1),
                        Color("main-point-color").opacity(0.3),
                        Color("main-point-color").opacity(0.5),
                        Color("main-point-color").opacity(0.8),
                        Color("main-point-color").opacity(1)
                    ], startPoint: .top, endPoint: .bottom)
                    .opacity(0.05)
                }
                .ignoresSafeArea()
            }
    }
}
