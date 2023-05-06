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

enum UserSelection {
    case none
    case like
    case hate
}

struct CherryPickView: View {
    @Binding var isCherryPick: Bool
    @Binding var isCherryPickDone: Bool
    
    @State var cherryPickMode: CherryPickMode
    
    @State private var showRestaurantCard = false
    @State private var showIndicators = false
    @State private var likeAndHateButtonsScale: CGFloat = 1.2
    @State private var likeAndHateButtonsSubScale: CGFloat = 1.1
    @State private var likeThumbOffset: CGFloat = 10
    @State private var hateThumbOffset: CGFloat = -10
    @State private var cardOffsetX: CGFloat = .zero
    @State private var cardOffsetY: CGFloat = .zero
    @State private var cardSize = 1.0
    @State private var userSelection: UserSelection = .none
    @State private var indicatorsOpacity = 1.0
    
    //임시용
    @State private var isBookmarked = false
    @State private var cardCount = 3
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                let height = reader.size.height == 551 ?  reader.size.height / 11 * 10 : reader.size.height / 6 * 5
                let width = reader.size.width / 4 * 2.8
                
                VStack {
                    Spacer()
                    
                    if !isLoading {
                        //                    HStack {
                        //                        Spacer()
                        //
                        ZStack {
                            likeAndHateButtons()
                                .opacity(indicatorsOpacity)
                            
                            if showRestaurantCard {
                                restaurantCard(width: width, height: height)
                                    .frame(width: width)
                                    .transition(.move(edge: .bottom))
                            }
                        }
                        .frame(height: height)
                        
                        //                        Spacer()
                        //                    }
                        
                        Spacer()
                        
                        if showIndicators {
                            Text("스와이프로 취향을 알려주세요!")
                                .fontWeight(.bold)
                                .foregroundColor(Color("secondary-text-color-strong"))
                                .opacity(indicatorsOpacity)
                        }
                    } else {
                        HStack {
                            Spacer()
                            
                            ProgressView()
                                .progressViewStyle(.circular)
                                .controlSize(.large)
                            
                            Spacer()
                        }
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
                                .font(.title2)
                                .shadow(color: .black.opacity(0.15), radius: 5)
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
                .onChange(of: cardCount) { newValue in
                    if newValue == 0 {
                        withAnimation(.easeInOut) {
                            isCherryPick = false
                            isCherryPickDone = true
                        }
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
                    .scaleEffect(likeAndHateButtonsSubScale)
                    .animation(Animation.spring(dampingFraction: 1.5).repeatForever(autoreverses: true), value: likeAndHateButtonsSubScale)
                    .onAppear {
                        self.likeAndHateButtonsSubScale = 1.0
                    }
                
                Circle()
                    .fill(Color("background-shape-color"))
                    .padding(7)
                    .scaleEffect(likeAndHateButtonsScale)
                    .animation(Animation.spring(dampingFraction: 1.5).repeatForever(autoreverses: true), value: likeAndHateButtonsScale)
                    .onAppear {
                        self.likeAndHateButtonsScale = 1.0
                    }
                
                Image(systemName: thumb)
                    .padding(isLikeButton ? .leading : .trailing, 15)
                    .offset(x: isLikeButton ? likeThumbOffset : hateThumbOffset)
                    .animation(Animation.spring(dampingFraction: 0.991).repeatForever(autoreverses: true), value: isLikeButton ? likeThumbOffset : hateThumbOffset)
                    .onAppear {
                        if isLikeButton {
                            likeThumbOffset = 0
                        }
                        
                        if !isLikeButton {
                            hateThumbOffset = 0
                        }
                    }
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
    func restaurantCard(width: CGFloat, height: CGFloat) -> some View {
        let isTutorial = cherryPickMode == .tutorial
        
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Image("restaurant-sample1")
                        .resizable()
                        .scaledToFill()
                    
                    Image("restaurant-sample2")
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: width)
                .frame(height: height / 3)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 5)
                .padding()
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("이이요")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Text("일식당")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("main-point-color-weak"))
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut) {
                                isBookmarked.toggle()
                            }
                        } label: {
                            Label("즐겨찾기", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                                .labelStyle(.iconOnly)
                                .font(.title2)
                        }
                    }
                    
                    Text("식사로도 좋고 간술하기에도 좋은 이자카야 \"이이요\"")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("secondary-text-color-strong"))
                    
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .blur(radius: isTutorial ? 10 : 0)
            .overlay {
                if isTutorial {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("background-shape-color"))
                        .opacity(0.8)
                }
            }
            
            if isTutorial {
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
                
                KeywordTagsView()
                    .frame(height: height / 2 - 50)
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.15), radius: 5)
        }
        .padding(.horizontal, 45)
        .offset(x: cardOffsetX, y: cardOffsetY)
        .scaleEffect(cardSize)
        .gesture(
            DragGesture()
                .onChanged({ drag in
                    let moveX = drag.translation.width
                    
                    print(moveX)
                    
                    cardOffsetX = moveX
                    cardOffsetY = drag.translation.height / 10
                    
                    withAnimation(.spring()) {
                        cardSize = 0.9
                    }
                    
                    indicatorsOpacity = moveX > 0 ? (200 - moveX) / 200 : (-200 - moveX) / -200
                    
                    if drag.translation.width > 200 {
                        userSelection = .like
                    } else if drag.translation.width < -200 {
                        userSelection = .hate
                    } else {
                        userSelection = .none
                    }
                })
                .onEnded({ drag in
                    withAnimation(.spring()) {
                        if userSelection != .none {
                            cardOffsetX = userSelection == .like ? 500 : -500
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring()) {
                                    showRestaurantCard = false
                                }
                                
                                withAnimation(.easeInOut) {
                                    isLoading = true
                                }
                                
                                cardOffsetX = .zero
                                cardOffsetY = .zero
                            }
                            
                            cardCount -= 1
                        } else {
                            cardOffsetX = .zero
                            cardOffsetY = .zero
                            
                            withAnimation(.easeInOut) {
                                indicatorsOpacity = 1.0
                            }
                        }
                        
                        cardSize = 1.0
                    }
                })
        )
        .onDisappear() {
            withAnimation(.easeInOut) {
                indicatorsOpacity = 1.0
                
                //임시용
                isLoading = false
                isBookmarked = false
            }
            
            withAnimation(.spring()) {
                showRestaurantCard = true
            }
        }
    }
}

struct CherryPickView_Previews: PreviewProvider {
    static var previews: some View {
        CherryPickView(isCherryPick: .constant(true), isCherryPickDone: .constant(false), cherryPickMode: .cherryPick)
            .tint(Color("main-point-color"))
    }
}
