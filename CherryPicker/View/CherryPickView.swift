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
                        HStack {
                            Spacer()
                            
                            ZStack {
                                likeAndHateIndicators()
                                
                                if showRestaurantCard {
                                    restaurantCard(width: width, height: height)
                                }
                            }
                            .frame(height: height)
                            
                            Spacer()
                        }
                        
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
                        closeButton()
                    }
                }
                .onAppear(perform: showContentActions)
                .onChange(of: cardCount) { newValue in
                    //임시
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
    func closeButton() -> some View {
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
    
    @ViewBuilder
    func likeOrHateIndicator(thumb: String) -> some View {
        let isLikeButton = thumb == "hand.thumbsup.fill"
        
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
        .foregroundColor(Color("main-point-color"))
        .frame(maxWidth: 80)
    }
    
    @ViewBuilder
    func likeAndHateIndicators() -> some View {
        HStack {
            if showIndicators {
                likeOrHateIndicator(thumb: "hand.thumbsdown.fill")
            }
            
            Spacer()
            
            if showIndicators {
                likeOrHateIndicator(thumb: "hand.thumbsup.fill")
            }
        }
        .opacity(indicatorsOpacity)
        .frame(maxWidth: 630)
    }
    
    @ViewBuilder
    func restaurantCard(width: CGFloat, height: CGFloat) -> some View {
        let isTutorial = cherryPickMode == .tutorial
        let maxOffset = CGFloat(150)
        
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
                .frame(maxWidth: 500)
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
        .frame(width: width)
        .frame(maxWidth: 500)
        .padding(.horizontal, 45)
        .offset(x: cardOffsetX, y: cardOffsetY)
        .scaleEffect(cardSize)
        .gesture(
            DragGesture()
                .onChanged({ drag in
                    let moveX = drag.translation.width
                    
                    swipingCard(moveX: moveX, moveY: drag.translation.height, maxOffset: maxOffset)
                    
                    decisionUserSelection(moveX: moveX, maxOffset: maxOffset)
                })
                .onEnded({ drag in
                    if userSelection != .none {
                        disappearingCard()
                    } else {
                        cancelDecisionUserSelection()
                    }
                    
                    cardSize = 1.0
                })
        )
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: userSelection == .like ? .trailing : .leading).combined(with: .opacity)))
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
    
    func showContentActions() {
        withAnimation(.spring()) {
            showRestaurantCard = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut) {
                showIndicators = true
            }
        }
    }
    
    func swipingCard(moveX: CGFloat, moveY: CGFloat, maxOffset: CGFloat) {
        cardOffsetX = moveX
        cardOffsetY = moveY / 10
        
        withAnimation(.spring()) {
            cardSize = 0.9
        }
        
        indicatorsOpacity = moveX > 0 ? (maxOffset - moveX) / maxOffset : (maxOffset + moveX) / maxOffset
    }
    
    func decisionUserSelection(moveX: CGFloat, maxOffset: CGFloat) {
        if moveX > maxOffset {
            userSelection = .like
        } else if moveX < -maxOffset {
            userSelection = .hate
        } else {
            userSelection = .none
        }
    }
    
    func disappearingCard() {
        withAnimation(.spring()) {
            likeAndHateButtonsScale = 1.2
            likeAndHateButtonsSubScale = 1.1
            likeThumbOffset = 10.0
            hateThumbOffset = -10.0
            
            showRestaurantCard = false
        }
        
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            cardOffsetX = .zero
            cardOffsetY = .zero
        }
        
        cardCount -= 1
    }
    
    func cancelDecisionUserSelection() {
        withAnimation(.spring()) {
            cardOffsetX = .zero
            cardOffsetY = .zero
        }
        
        withAnimation(.easeInOut) {
            indicatorsOpacity = 1.0
        }
    }
}

struct CherryPickView_Previews: PreviewProvider {
    static var previews: some View {
        CherryPickView(isCherryPick: .constant(true), isCherryPickDone: .constant(false), cherryPickMode: .cherryPick)
            .tint(Color("main-point-color"))
    }
}
