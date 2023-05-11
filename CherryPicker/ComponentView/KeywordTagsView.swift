//
//  KeywordTagsView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI

struct KeywordTagsView: View {
    var body: some View {
        VStack(spacing: 10) {
            keywordTagGauge(title: "음식이 맛있어요", value: 935)
            
            keywordTagGauge(title: "특별한 메뉴가 있어요", value: 409)
            
            keywordTagGauge(title: "재료가 신선해요", value: 376)
            
            keywordTagGauge(title: "친절해요", value: 348)
            
            keywordTagGauge(title: "혼밥하기 좋아요", value: 121)
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
//                        .padding(5)
//                        .background {
//                            RoundedRectangle(cornerRadius: 20, style: .continuous)
//                                .fill(Color("shape-light-color"))
//                                .shadow(color: .black.opacity(0.1), radius: 1)
//                        }
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
