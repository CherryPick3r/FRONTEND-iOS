//
//  KeywordTagsView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI

struct KeywordTagsView: View {
    @State private var tagTitle1 = "1"
    @State private var tagTitle2 = "2"
    @State private var tagTitle3 = "3"
    @State private var tagTitle4 = "4"
    @State private var tagTitle5 = "5"
    
    @State private var tagIntegerPart1 = 0
    @State private var tagIntegerPart2 = 0
    @State private var tagIntegerPart3 = 0
    @State private var tagIntegerPart4 = 0
    @State private var tagIntegerPart5 = 0
    
    @State private var tagRealPart1 = 0
    @State private var tagRealPart2 = 0
    @State private var tagRealPart3 = 0
    @State private var tagRealPart4 = 0
    @State private var tagRealPart5 = 0
    
    @State private var tagValue1 = 0.0
    @State private var tagValue2 = 0.0
    @State private var tagValue3 = 0.0
    @State private var tagValue4 = 0.0
    @State private var tagValue5 = 0.0
    
    @Binding var topTags: TopTags
    
    var body: some View {
        VStack(spacing: 10) {
            keywordTagGauge(title: tagTitle1, integerPart: $tagIntegerPart1, realPart: $tagRealPart1, value: tagValue1)
            keywordTagGauge(title: tagTitle2, integerPart: $tagIntegerPart2, realPart: $tagRealPart2, value: tagValue2)
            keywordTagGauge(title: tagTitle3, integerPart: $tagIntegerPart3, realPart: $tagRealPart3, value: tagValue3)
            keywordTagGauge(title: tagTitle4, integerPart: $tagIntegerPart4, realPart: $tagRealPart4, value: tagValue4)
            keywordTagGauge(title: tagTitle5, integerPart: $tagIntegerPart5, realPart: $tagRealPart5, value: tagValue5)
        }
        .frame(maxHeight: 250)
        .onAppear() {
            tagTitle1 = topTags[0].description
            tagTitle2 = topTags[1].description
            tagTitle3 = topTags[2].description
            tagTitle4 = topTags[3].description
            tagTitle5 = topTags[4].description
            
            withAnimation(.spring(response: 1.2)) {
                tagIntegerPart1 = Int(floor(topTags[0].value))
                tagIntegerPart2 = Int(floor(topTags[1].value))
                tagIntegerPart3 = Int(floor(topTags[2].value))
                tagIntegerPart4 = Int(floor(topTags[3].value))
                tagIntegerPart5 = Int(floor(topTags[4].value))
                
                tagRealPart1 = Int((topTags[0].value - Double(tagIntegerPart1)) * 100.0)
                tagRealPart2 = Int((topTags[1].value - Double(tagIntegerPart2)) * 100.0)
                tagRealPart3 = Int((topTags[2].value - Double(tagIntegerPart3)) * 100.0)
                tagRealPart4 = Int((topTags[3].value - Double(tagIntegerPart4)) * 100.0)
                tagRealPart5 = Int((topTags[4].value - Double(tagIntegerPart5)) * 100.0)
                
                tagValue1 = topTags[0].value
                tagValue2 = topTags[1].value
                tagValue3 = topTags[2].value
                tagValue4 = topTags[3].value
                tagValue5 = topTags[4].value
            }
        }
    }
    
    @ViewBuilder
    func keywordTagGauge(title: String, integerPart: Binding<Int>, realPart: Binding<Int>, value: Double) -> some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("main-point-color-weak"))
                    .frame(width: reader.size.width)
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("main-point-color"))
                    .frame(width: reader.size.width * (CGFloat(value) / 100))
                
                HStack {
                    Text(title)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(Color("shape-light-color"))
                    
                    Spacer()
                    
                    
                    HStack(spacing: 0) {
                        RollingTextView(value: integerPart)
                        
                        Text(".")
                        
                        RollingTextView(value: realPart)
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(Color("shape-light-color"))
                }
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

struct KeywordTagsView_Previews: PreviewProvider {
    static var previews: some View {
        KeywordTagsView(topTags: .constant(TagPair.preview))
    }
}
