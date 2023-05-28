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
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if showError, let action = retryAction {
                    ErrorView(error: $error)
                        .offset(y: offsetY)
                        .gesture(
                            DragGesture()
                                .onChanged({ drag in
                                    offsetY = drag.translation.height
                                })
                                .onEnded({ drag in
                                    if offsetY < -50 {
                                        action()
                                    } else {
                                        offsetY = .zero
                                    }
                                })
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
    }
}
