//
//  KeywordTagsView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI

struct KeywordTagsView: View {
    //임시
    @State private var value1 = CGFloat(0)
    @State private var value2 = CGFloat(0)
    @State private var value3 = CGFloat(0)
    @State private var value4 = CGFloat(0)
    @State private var value5 = CGFloat(0)
    
    var body: some View {
        VStack(spacing: 10) {
            keywordTagGauge(title: "음식이 맛있어요", value: value1)
            
            keywordTagGauge(title: "특별한 메뉴가 있어요", value: value2)
            
            keywordTagGauge(title: "재료가 신선해요", value: value3)
            
            keywordTagGauge(title: "친절해요", value: value4)
            
            keywordTagGauge(title: "혼밥하기 좋아요", value: value5)
        }
        .frame(maxHeight: 230)
        .onAppear() {
            withAnimation(.spring(response: 1.2)) {
                value1 = 935
            }
            
            withAnimation(.spring(response: 1.2).delay(0.1)) {
                value2 = 409
            }
            
            withAnimation(.spring(response: 1.2).delay(0.2)) {
                value3 = 376
            }
            
            withAnimation(.spring(response: 1.2).delay(0.3)) {
                value4 = 348
            }
            
            withAnimation(.spring(response: 1.2).delay(0.4)) {
                value5 = 121
            }
        }
    }
    
    @ViewBuilder
    func keywordTagGauge(title: String, value: CGFloat) -> some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("main-point-color-weak"))
                    .frame(width: reader.size.width)
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("main-point-color"))
                    .frame(width: reader.size.width * (value / 1000))
                
                HStack {
                    Text(title)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("shape-light-color"))
                    
                    Spacer()
                    
                    Text("\(Int(round(value)))")
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("shape-light-color"))
                }
                .padding(10)
            }
        }
    }
}

struct KeywordTagsView_Previews: PreviewProvider {
    static var previews: some View {
        KeywordTagsView()
    }
}
