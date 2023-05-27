//
//  ErrorViewModifier.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/26.
//

import SwiftUI

struct ErrorViewModifier: ViewModifier {
    @Binding var showError: Bool
    @Binding var error: APIError?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if showError {
                    ErrorView(error: $error)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(), value: showError)
                }
            }
    }
}
