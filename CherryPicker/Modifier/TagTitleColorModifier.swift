//
//  TagTitleColorModifier.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/26.
//

import SwiftUI

struct TagTitleColorModifier: ViewModifier {
    @Binding var userPreferenceLoad: Bool
    
    private let text: String
    private var font: Font?
    private let colors: [Color]
    private let index: Int
    private var opacity = 0.0
    
    init(userPreferenceLoad: Binding<Bool>, text: String, font: Font? = nil, colors: [Color], index: Int) {
        self._userPreferenceLoad = userPreferenceLoad
        self.text = text
        self.font = font
        self.colors = colors
        self.index = index
        
        switch index {
        case 0:
            self.font = userPreferenceLoad.wrappedValue ? .title2 : nil
            self.opacity = 1
            break
        case 1:
            self.font = userPreferenceLoad.wrappedValue ? .title3 : nil
            self.opacity = 0.9
            break
        case 2:
            self.font = userPreferenceLoad.wrappedValue ? .subheadline : nil
            self.opacity = 0.8
            break
        case 3:
            self.font = userPreferenceLoad.wrappedValue ? .footnote : nil
            self.opacity = 0.7
            break
        case 4:
            self.font = userPreferenceLoad.wrappedValue ? .caption : nil
            self.opacity = 0.6
            break
        default:
            self.font = nil
            break
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.clear)
            .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom))
            .mask(Text(text)
                .font(font)
                .fontWeight(.semibold))
            .opacity(opacity)
    }
}
