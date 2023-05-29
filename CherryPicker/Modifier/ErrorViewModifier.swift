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
    @Binding var retryAction: (() -> Void)?
    
    @State private var offsetY = CGFloat.zero
    @State private var opacity = 50.0
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if showError, let action = retryAction {
                    ErrorView(error: $error)
                        .opacity(opacity / 50)
                        .offset(y: offsetY)
                        .gesture(
                            DragGesture()
                                .onChanged({ drag in
                                    let moveY = drag.translation.height
                                    offsetY = moveY
                                    opacity = 50 + moveY
                                })
                                .onEnded({ drag in
                                    if offsetY < -50 {
                                        action()
                                    }
                                    
                                    withAnimation(.spring()) {
                                        offsetY = .zero
                                        opacity = 50.0
                                    }
                                })
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
    }
}
