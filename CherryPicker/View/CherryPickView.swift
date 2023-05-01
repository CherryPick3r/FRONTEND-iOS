//
//  CherryPickView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/01.
//

import SwiftUI

enum CherryPickMode {
    case tutorial
    case cherryPick
}

struct CherryPickView: View {
    @Binding var isCherryPick: Bool
    
    @State var cherryPickMode: CherryPickMode
    @State private var showRestaurantCard = false
    @State private var showIndicators = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    likeAndHateButtons()
                    
                    if showRestaurantCard {
                        restaurantCard()
                            .transition(.move(edge: .bottom))
                    }
                }
                
                Spacer()
                
                if showIndicators {
                    Text("스와이프로 취향을 알려주세요!")
                        .fontWeight(.bold)
                        .foregroundColor(Color("secondary-text-color-strong"))
                }
                
                Spacer()
            }
            .modifier(BackgroundModifier())
            .navigationTitle(cherryPickMode == .cherryPick ? "CherryPicker" : "초기취향 선택")
            .toolbar {
                ToolbarItem {
                    Button {
                        withAnimation(.easeInOut) {
                            isCherryPick = false
                        }
                    } label: {
                        Label("닫기", systemImage: "xmark.circle.fill")
                    }
                    
                }
            }
            .onAppear() {
                withAnimation(.spring()) {
                    showRestaurantCard = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut) {
                        showIndicators = true
                    }
                }
            }
        }
        .tint(Color("main-point-color"))
    }
    
    @ViewBuilder
    func likeOrHateButton(thumb: String) -> some View {
        let isLikeButton = thumb == "hand.thumbsup.fill"
        
        Button {
            
        } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [
                        Color("main-point-color"),
                        Color("main-point-color"),
                        Color("main-point-color"),
                        Color("main-point-color-weak"),
                        Color("main-point-color-weak"),
                        Color("main-point-color-weak")
                    ], startPoint: isLikeButton ? .top : .bottom, endPoint: isLikeButton ? .bottom : .top)
                        .opacity(0.7))
                
                Circle()
                    .fill(Color("background-shape-color"))
                    .padding(7)
                
                Image(systemName: thumb)
                    .padding(isLikeButton ? .leading : .trailing, 15)
            }
            .frame(maxWidth: 80)
            .padding(5)
        }
    }
    
    @ViewBuilder
    func likeAndHateButtons() -> some View {
        HStack {
            if showIndicators {
                likeOrHateButton(thumb: "hand.thumbsdown.fill")
            }
            
            Spacer()
            
            if showIndicators {
                likeOrHateButton(thumb: "hand.thumbsup.fill")
            }
        }
    }
    
    @ViewBuilder
    func restaurantCard() -> some View {
        ZStack {
            VStack {
                Spacer()
            }
            .blur(radius: cherryPickMode == .tutorial ? 30 : 0)
            
            if cherryPickMode == .tutorial {
                VStack(spacing: 15) {
                    Text("지금은 초기취향 선택 중 이에요")
                    
                    Text("아래 키워드 태그에 집중하여,")
                    
                    Text("여러분의 평소 취향을")
                    
                    Text("스와이프로 알려주세요!")
                    
                    Spacer()
                }
                .fontWeight(.bold)
                .foregroundColor(Color("secondary-text-color-strong"))
                .padding(40)
            }
            
            VStack {
                Spacer()
                
                keywordTags()
                    .frame(height: 240)
            }
            .padding()
        }
        .frame(width: 290, height: 510)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.15), radius: 5)
        }
    }
    
    @ViewBuilder
    func keywordTagGauge(title: String, value: CGFloat) -> some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("main-point-color-weak"))
                    .frame(width: reader.size.width)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("main-point-color"))
                    .frame(width: reader.size.width * (value / 1200))
                
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("background-shape-color"))
                    
                    Spacer()
                    
                    Text("\(Int(round(value)))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color"))
                }
                .padding(10)
            }
        }
    }
    
    @ViewBuilder
    func keywordTags() -> some View {
        VStack(spacing: 10) {
            
            keywordTagGauge(title: "음식이 맛있어요", value: 935)
            
            keywordTagGauge(title: "특별한 메뉴가 있어요", value: 409)
            
            keywordTagGauge(title: "재료가 신선해요", value: 376)
            
            keywordTagGauge(title: "친절해요", value: 348)
            
            keywordTagGauge(title: "혼밥하기 좋아요", value: 121)
        }
    }
}

struct CherryPickView_Previews: PreviewProvider {
    static var previews: some View {
        CherryPickView(isCherryPick: .constant(true), cherryPickMode: .tutorial)
            .tint(Color("main-point-color"))
    }
}
