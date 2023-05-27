//
//  TagTitleColorModifier.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/26.
//

import SwiftUI

struct TagTitleColorModifier: ViewModifier {
    private let text: String
    private let font: Font?
    private let colors: [Color]
    
    init(text: String, font: Font?, colors: [Color]) {
        self.text = text
        self.font = font
        self.colors = colors
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
    }
}
