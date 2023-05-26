//
//  KeywordTagsView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI

struct KeywordTagsView: View {
    //임시
    @State private var tagTitle1 = "1"
    @State private var tagTitle2 = "2"
    @State private var tagTitle3 = "3"
    @State private var tagTitle4 = "4"
    @State private var tagTitle5 = "5"
    
    @State private var tagValue1 = 0
    @State private var tagValue2 = 0
    @State private var tagValue3 = 0
    @State private var tagValue4 = 0
    @State private var tagValue5 = 0
    
    @Binding var topTags: TopTags
    
    var body: some View {
        VStack(spacing: 10) {
            keywordTagGauge(title: tagTitle1, value: $tagValue1)
            keywordTagGauge(title: tagTitle2, value: $tagValue2)
            keywordTagGauge(title: tagTitle3, value: $tagValue3)
            keywordTagGauge(title: tagTitle4, value: $tagValue4)
            keywordTagGauge(title: tagTitle5, value: $tagValue5)
        }
        .frame(height: 200)
        .onAppear() {
            tagTitle1 = topTags[0].description
            tagTitle2 = topTags[1].description
            tagTitle3 = topTags[2].description
            tagTitle4 = topTags[3].description
            tagTitle5 = topTags[4].description
            
            withAnimation(.spring(response: 1.2)) {
                tagValue1 = Int(topTags[0].value)
                tagValue2 = Int(topTags[1].value)
                tagValue3 = Int(topTags[2].value)
                tagValue4 = Int(topTags[3].value)
                tagValue5 = Int(topTags[4].value)
            }
        }
    }
    
    @ViewBuilder
    func keywordTagGauge(title: String, value: Binding<Int>) -> some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("main-point-color-weak"))
                    .frame(width: reader.size.width)
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("main-point-color"))
                    .frame(width: reader.size.width * (CGFloat(value.wrappedValue) / 100))
                
                HStack {
                    Text(title)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("shape-light-color"))
                    
                    Spacer()
                    
                    
                    RollingTextView(value: value)
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
        KeywordTagsView(topTags: .constant(TagPair.preview))
    }
}
