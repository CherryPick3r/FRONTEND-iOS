//
//  CherryPickView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/01.
//

import SwiftUI
import Combine

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
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isCherryPick: Bool
    @Binding var isCherryPickDone: Bool
    @Binding var restaurantId: Int?
    
    @State var cherryPickMode: CherryPickMode
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var showRestaurantCard = false
    @State private var showIndicators = false
    @State private var likeAndHateButtonsScale = CGFloat(1.2)
    @State private var likeAndHateButtonsSubScale = CGFloat(1.1)
    @State private var likeThumbOffset = CGFloat(10)
    @State private var hateThumbOffset = CGFloat(-10)
    @State private var cardOffsetX = CGFloat.zero
    @State private var cardOffsetY = CGFloat.zero
    @State private var cardDgree = 0.0
    @State private var userSelection = UserSelection.none
    @State private var indicatorsOpacity = 1.0
    @State private var gameResponse: GameResponse?
    @State private var shopCardResponse: ShopCardResponse = ShopCardResponse.preview
    @State private var error: APIError?
    @State private var showError = false
    @State private var isClipped = false
    
    //임시용
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                let height = reader.size.height == 551 ?  reader.size.height / 11 * 10 : reader.size.height / 6 * 5
                let width = reader.size.width
                let cardImageWidth = width / 4 * 2.8
                
                VStack {
                    Spacer()
                    
                    if !isLoading {
                        HStack {
                            Spacer()
                            
                            ZStack {
                                if showIndicators {
                                    likeAndHateIndicators()
                                        .frame(maxWidth: 630)
                                }
                                
                                if showRestaurantCard {
                                    restaurantCard(width: cardImageWidth, height: height)
                                }
                            }
                            .frame(maxHeight: 800)
                            .frame(height: height)
                            
                            Spacer()
                        }
                        .frame(width: width)
                        
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
                .task {
                    appearingView()
                }
            }
        }
        .tint(Color("main-point-color"))
        .modifier(ErrorViewModifier(showError: $showError, error: $error))
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
    }
    
    @ViewBuilder
    func restaurantCard(width: CGFloat, height: CGFloat) -> some View {
        let isTutorial = cherryPickMode == .tutorial
        let maxOffset = CGFloat(150)
        
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
            .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(shopCardResponse.shopName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-text-color"))
                    
                    Text(shopCardResponse.shopCategory)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("main-point-color-weak"))
                    
                    Spacer()
                    
                    Button {
                        clippingAction()
                    } label: {
                        Label("즐겨찾기", systemImage: isClipped ? "bookmark.fill" : "bookmark")
                            .labelStyle(.iconOnly)
                            .modifier(ParticleModifier(systemImage: "bookmark.fill", status: isClipped))
                    }
                }
                
                Text(shopCardResponse.oneLineReview)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("secondary-text-color-strong"))
            }
            .padding(.bottom)
            
            KeywordTagsView(topTags: .constant(TagPair.preview))
                .opacity(isTutorial ? 0 : 1)
        }
        .blur(radius: isTutorial ? 10 : 0)
        .padding()
        .overlay(alignment: .top) {
            if isTutorial {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("background-shape-color"))
                        .opacity(0.8)
                    
                    VStack {
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
                        
                        KeywordTagsView(topTags: .constant(TagPair.preview))
                            .padding()
                    }
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.15), radius: 5)
        }
        .frame(maxWidth: 500)
        .frame(width: width)
        .offset(x: cardOffsetX, y: cardOffsetY)
        .rotationEffect(.degrees(cardDgree))
        .gesture(
            DragGesture()
                .onChanged({ drag in
                    DispatchQueue.global(qos: .userInteractive).async {
                        let moveX = drag.translation.width
                        
                        swipingCard(moveX: moveX, moveY: drag.translation.height, maxOffset: maxOffset)
                        
                        decisionUserSelection(moveX: moveX, maxOffset: maxOffset)
                    }
                })
                .onEnded({ drag in
                    DispatchQueue.global(qos: .userInteractive).async {
                        userSelection != .none ? disappearingCard() : cancelDecisionUserSelection()
                        
                        withAnimation(.spring()) {
                            cardDgree = 0
                        }
                    }
                })
        )
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: userSelection == .like ? .trailing : .leading).combined(with: .opacity)))
        .onDisappear() {
            withAnimation(.easeInOut) {
                indicatorsOpacity = 1.0
                isLoading = false
                isClipped = false
            }
            
            cardDgree = 0
            
            showShopCard()
        }
    }
    
    func swipingCard(moveX: CGFloat, moveY: CGFloat, maxOffset: CGFloat) {
        cardOffsetX = moveX
        cardOffsetY = moveY / 10
        
        cardDgree = moveX / 50
        
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
        
        doSwipped()
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
    
    func showShopCard() {
        if let shopCard = gameResponse?.recommendShops?.popLast() {
            withAnimation(.spring()) {
                shopCardResponse = shopCard
                isClipped = shopCardResponse.shopClipping == .isClipped
                isLoading = false
                showRestaurantCard = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut) {
                    showIndicators = true
                }
            }
        } else {
            withAnimation(.easeInOut) {
                isLoading = true
            }
        }
    }
    
    func appearingView() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        APIFunction.doStartGame(token: userViewModel.readToken, gameStartRequest: GameStartRequest(userEmail: userViewModel.readUserEmail, gameMode: 0), subscriptions: &subscriptions) { game in
            APIError.closeError(showError: &showError, error: &error)
            
            gameResponse = game
            
            showShopCard()
        } errorHandling: { apiError in
            APIError.showError(showError: &showError, error: &error, catchError: apiError)
        }
    }
    
    func doSwipped() {
        if let game = gameResponse {
            APIError.closeError(showError: &showError, error: &error)
            
            APIFunction.doGameSwipe(token: userViewModel.readToken, gameRequest: GameRequest(gameId: game.gameId, shopId: shopCardResponse.shopId), swipeType: userSelection, subscriptions: &subscriptions) { data in
                APIError.closeError(showError: &showError, error: &error)
                
                if let game = try? JSONDecoder().decode(GameResponse.self, from: data) {
                    if game.recommendShopIds != nil || game.recommendShops != nil {
                        gameResponse = game
                    }
                } else if let game = try? JSONDecoder().decode(GameEndResponse.self, from: data) {
                    restaurantId = game.recommendedShopId
                    
                    withAnimation(.easeInOut) {
                        isCherryPick = false
                        isCherryPickDone = true
                    }
                }
            } errorHandling: { apiError in
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func clippingAction() {
        withAnimation(.spring()) {
            showError = false
            error = nil
        }
        
        let clippingRequset = ShopOrClippingRequest(shopId: shopCardResponse.shopId, userEmail: userViewModel.readUserEmail)
        
        if isClipped {
            APIFunction.deleteClipping(token: userViewModel.readToken, clippingUndoRequest: clippingRequset, subscriptions: &subscriptions) { clippingUndoResponse in
                APIError.closeError(showError: &showError, error: &error)
                
                withAnimation(.spring()) {
                    isClipped = false
                }
            } errorHanding: { apiError in
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        } else {
            APIFunction.doClipping(token: userViewModel.readToken, clippingDoRequest: clippingRequset, subscriptions: &subscriptions) { clippingDoResponse in
                APIError.closeError(showError: &showError, error: &error)
                
                withAnimation(.spring()) {
                    isClipped = true
                }
            } errorHanding: { apiError in
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
}

struct CherryPickView_Previews: PreviewProvider {
    static var previews: some View {
        CherryPickView(isCherryPick: .constant(true), isCherryPickDone: .constant(false), restaurantId: .constant(0), cherryPickMode: .cherryPick)
            .tint(Color("main-point-color"))
            .environmentObject(UserViewModel())
    }
}
