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

enum DragDirection {
    case left
    case right
    case none
}

struct CherryPickView: View {
    @Namespace var heroEffect
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isCherryPick: Bool
    @Binding var isCherryPickDone: Bool
    @Binding var restaurantId: Int?
    @Binding var gameCategory: GameCategory?
    @Binding var isFirstCherryPick: Bool
    
    @State var cherryPickMode: CherryPickMode
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var showRestaurantCard = false
    @State private var showIndicators = false
    @State private var likeAndHateButtonsScale = CGFloat(1.2)
    @State private var likeAndHateButtonsSubScale = CGFloat(1.1)
    @State private var likeThumbOffset = CGFloat(15)
    @State private var hateThumbOffset = CGFloat(-15)
    @State private var cardOffsetX = CGFloat.zero
    @State private var cardOffsetY = CGFloat.zero
    @State private var cardDgree = 0.0
    @State private var userSelection = UserSelection.none
    @State private var indicatorsOpacity = 1.0
    @State private var gameResponse: GameResponse?
    @State private var shopCardResponse: ShopCardResponse?
    @State private var preferenceGameResponse: UserPreferenceStartResponse?
    @State private var preferencCardResponse: PreferenceCard?
    @State private var error: APIError?
    @State private var showError = false
    @State private var isClipped = false
    @State private var isLoading = true
    @State private var retryAction: (() -> Void)?
    @State private var tutorialIsDone = false
    @State private var dragDirection = DragDirection.none
    @State private var progressIndicatorScale = CGFloat(1.2)
    @State private var thumbScale = 1.0
    
    var body: some View {
            GeometryReader { reader in
                let width = reader.size.width
                let height = reader.size.height
                let cardHeight = height == 551 ?  height / 11 * 10 : height / 6 * 5
                let cardImageWidth = width / 4 * 2.8
                
                if tutorialIsDone {
                    tutorialDone()
                        .tint(Color("main-point-color"))
                        .frame(width: width)
                } else {
                    VStack(spacing: 0) {
                        navigationTitle(width: width, height: height)
                        
                        Spacer()
                        
                        if !isLoading {
                            if showIndicators {
                                if let game = gameResponse {
                                    progressBar(progress: width * CGFloat((game.curRound / game.totalRound)))
                                } else if let game = preferenceGameResponse {
                                    progressBar(progress: width * CGFloat((game.curRound / game.totalRound)))
                                }
                                else {
                                    progressBar(progress: 0)
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    if showIndicators {
                                        likeAndHateIndicators()
                                            .frame(maxWidth: 630)
                                    }
                                    
                                    if let shopCard = shopCardResponse, showRestaurantCard {
                                        restaurantCard(width: cardImageWidth, height: cardHeight, shopCard: shopCard)
                                    }
                                }
                                .frame(maxHeight: 800)
                                .frame(height: cardHeight)
                                
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
                    .tint(Color("main-point-color"))
                    .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.spring(response: 1.1)) {
                                cardOffsetX = 30
                                cardDgree = 3
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.spring(response: 0.5)) {
                                cardOffsetX = 0
                                cardDgree = 0
                            }
                        }
                    }
                    .task {
                        switch cherryPickMode {
                        case .tutorial:
                            fetchPreferenceGame()
                        case .cherryPick:
                            fetchGame()
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    func navigationTitle(width: CGFloat, height: CGFloat) -> some View {
        HStack {
            Image("cherry-picker-title")
                .resizable()
                .scaledToFill()
                .frame(width: 250)
                .padding(.bottom, 15)
            
            Spacer()
            
            closeButton()
        }
        .padding(.top, 10)
        .padding(.horizontal)
        .frame(width: width, height: height / 20 * 2 / 3)
        .fixedSize(horizontal: true, vertical: true)
        .padding(.top)
    }
    
    @ViewBuilder
    func progressBar(progress: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color("main-point-color-weak"))
                .frame(width: progress, height: 2)
            
            HStack {
                Circle()
                    .fill(Color("main-point-color"))
                    .frame(width: 12, height: 12)
                    .padding(5)
                    .background {
                        Circle()
                            .fill(Color("main-point-color-weak"))
                    }
                    .scaleEffect(progressIndicatorScale)
                    .animation(Animation.spring(dampingFraction: 2).repeatForever(autoreverses: true), value: progressIndicatorScale)
                    .onAppear {
                        progressIndicatorScale = 1.0
                    }
                    .offset(x: -10 + progress)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func tutorialDone() -> some View {
        VStack {
            Spacer()
            
            Text("초기 취향 선택 완료!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut.delay(0.5), value: tutorialIsDone)
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("이제 체리픽 할 준비가 되었어요!")
                
                Text("여러분이 선택한 초기 취향을 바탕으로,")
                
                Text("체리픽 해드릴게요!")
            }
            .fontWeight(.bold)
            .foregroundColor(Color("secondary-text-color-strong"))
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut.delay(1.0), value: tutorialIsDone)
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut) {
                    isCherryPick = false
                }
            } label: {
                HStack {
                    Spacer()
                    
                    Text("홈 화면으로 가기")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color"))
                        .padding(.vertical)
                    
                    Spacer()
                }
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("background-shape-color"))
                        
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color("main-point-color"), lineWidth: 2)
                            .shadow(radius: 10)
                    }
                }
            }
            .frame(maxWidth: 400)
            .padding(.horizontal, 70)
            .padding(.vertical, 80)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut.delay(1.0), value: tutorialIsDone)
        }
        .modifier(BackgroundModifier())
    }
    
    @ViewBuilder
    func closeButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                isCherryPick = false
            }
        } label: {
            Label("닫기", systemImage: "xmark.circle.fill")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .foregroundStyle(Color("background-shape-color"), Color("main-point-color"))
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
                .matchedGeometryEffect(id: thumb, in: heroEffect)
                .padding(isLikeButton ? .leading : .trailing, 15)
                .offset(x: isLikeButton ? likeThumbOffset : hateThumbOffset)
                .animation(Animation.spring(dampingFraction: 0.9785).repeatForever(autoreverses: true), value: isLikeButton ? likeThumbOffset : hateThumbOffset)
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
                if dragDirection == .left {
                    Spacer()
                    
                    Image(systemName: "hand.thumbsdown.fill")
                        .scaledToFill()
                        .frame(width: 100)
                        .foregroundColor(Color("main-point-color"))
                        .scaleEffect(thumbScale)
                        .matchedGeometryEffect(id: "hand.thumbsdown.fill", in: heroEffect)
                }
                
                if dragDirection == .none {
                    likeOrHateIndicator(thumb: "hand.thumbsdown.fill")
                }
            }
            
            if dragDirection == .none {
                Spacer()
            }
            
            if showIndicators {
                if dragDirection == .none {
                    likeOrHateIndicator(thumb: "hand.thumbsup.fill")
                }
                
                if dragDirection == .right {
                    Image(systemName: "hand.thumbsup.fill")
                        .scaledToFill()
                        .frame(width: 100)
                        .foregroundColor(Color("main-point-color"))
                        .scaleEffect(thumbScale)
                        .matchedGeometryEffect(id: "hand.thumbsup.fill", in: heroEffect)
                    
                    Spacer()
                }
            }
        }
        .opacity(indicatorsOpacity)
    }
    
    @ViewBuilder
    func restaurantCard(width: CGFloat, height: CGFloat, shopCard: ShopCardResponse) -> some View {
        let isTutorial = cherryPickMode == .tutorial
        let maxOffset = CGFloat(150)
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                AsyncImage(url: URL(string: shopCard.shopMainPhoto1)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width / 2)
                        .frame(maxWidth: 250)
                        .clipped()
                } placeholder: {
                    ZStack {
                        Color("main-point-color-weak")
                            .opacity(0.5)
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
                
                AsyncImage(url: URL(string: shopCard.shopMainPhoto2)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width / 2)
                        .frame(maxWidth: 250)
                        .clipped()
                } placeholder: {
                    ZStack {
                        Color("main-point-color-weak")
                            .opacity(0.5)
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
            .frame(width: width)
            .frame(maxWidth: 500)
            .frame(height: height / 3)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 5)
            .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(shopCard.shopName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-text-color"))
                    
                    Text(shopCard.shopCategory)
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
                            .font(.title)
                    }
                }
                
                Text(shopCard.oneLineReview)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("secondary-text-color-strong"))
            }
            .padding(.bottom)
            
            KeywordTagsView(topTags: .constant(shopCard.topTags))
                .opacity(isTutorial ? 0 : 1)
        }
        .blur(radius: isTutorial ? 10 : 0)
        .padding()
        .overlay(alignment: .top) {
            if let preferenceCard = preferencCardResponse, isTutorial {
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
                        
                        KeywordTagsView(topTags: .constant(preferenceCard.topTags))
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
                        
                        if moveX > -maxOffset && moveX < maxOffset {
                            thumbScale =  1 + ((moveX >= 0 ? moveX : -moveX) / (maxOffset / 3))
                        }
                        
                        swipingCard(moveX: moveX, moveY: drag.translation.height, maxOffset: maxOffset)
                        
                        decisionUserSelection(moveX: moveX, maxOffset: maxOffset)
                    }
                })
                .onEnded({ drag in
                    DispatchQueue.global(qos: .userInteractive).async {
                        switch cherryPickMode {
                        case .tutorial:
                            userSelection != .none ? doPreferenceSwipped() : cancelDecisionUserSelection()
                        case .cherryPick:
                            userSelection != .none ? doSwipped() : cancelDecisionUserSelection()
                            break
                        }
                        
                        withAnimation(.spring()) {
                            cardDgree = 0
                            thumbScale = 1
                        }
                    }
                })
        )
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: userSelection == .like ? .trailing : .leading).combined(with: .opacity)))
        .onDisappear() {
            withAnimation(.easeInOut) {
                isLoading = false
                isClipped = false
            }
            
            cardDgree = 0
            
            switch cherryPickMode {
            case .tutorial:
                showPreferencCard()
            case .cherryPick:
                showShopCard()
            }
        }
    }
    
    func swipingCard(moveX: CGFloat, moveY: CGFloat, maxOffset: CGFloat) {
        cardOffsetX = moveX
        cardOffsetY = moveY / 10
        
        if cardOffsetX < 0 {
            withAnimation(.spring()) {
                dragDirection = .left
            }
        } else if cardOffsetX > 0 {
            withAnimation(.spring()) {
                dragDirection = .right
            }
        } else {
            withAnimation(.spring()) {
                dragDirection = .none
            }
        }
        
        cardDgree = moveX / 50
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
            likeThumbOffset = 15.0
            hateThumbOffset = -15.0
            
            showRestaurantCard = false
        }
        
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            cardOffsetX = .zero
            cardOffsetY = .zero
        }
    }
    
    func cancelDecisionUserSelection() {
        userSelection = .none
        
        withAnimation(.spring()) {
            cardOffsetX = .zero
            cardOffsetY = .zero
            dragDirection = .none
        }
        
        withAnimation(.easeInOut) {
            indicatorsOpacity = 1.0
        }
        
        likeAndHateButtonsScale = 1.0
        likeAndHateButtonsSubScale = 1.0
        likeThumbOffset = 0
        hateThumbOffset = 0
    }
    
    func showShopCard() {
        if let shopCard = gameResponse?.recommendShops?.popLast() {
            dragDirection = .none
            withAnimation(.spring()) {
                shopCardResponse = shopCard
                isLoading = false
                isClipped = shopCard.shopClipping == .isClipped
                showRestaurantCard = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut) {
                    indicatorsOpacity = 1
                    showIndicators = true
                }
            }
        } else {
            withAnimation(.easeInOut) {
                isLoading = true
            }
        }
    }
    
    func showPreferencCard() {
        if let preferencCard = preferenceGameResponse?.preferenceCards.popLast() {
            dragDirection = .none
            withAnimation(.spring()) {
                preferencCardResponse = preferencCard
                isLoading = false
                
                showRestaurantCard = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut) {
                    indicatorsOpacity = 1
                    showIndicators = true
                }
            }
        } else {
            withAnimation(.easeInOut) {
                isLoading = true
            }
        }
    }
    
    func fetchGame() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
            retryAction = nil
        }
        
        APIFunction.doStartGame(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, gameMode: gameCategory?.rawValue ?? 0, subscriptions: &subscriptions) { game in
            withAnimation(.spring()) {
                gameResponse = game
            }
            
            showShopCard()
        } errorHandling: { apiError in
            retryAction = fetchGame
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func fetchPreferenceGame() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
            retryAction = nil
        }
        
        APIFunction.doUserPreferenceStart(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, subscriptions: &subscriptions) { game in
            withAnimation(.spring()) {
                preferenceGameResponse = game
            }
            
            showPreferencCard()
        } errorHandling: { apiError in
            retryAction = fetchPreferenceGame
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func doSwipped() {
        if let game = gameResponse {
            withAnimation(.easeInOut) {
                indicatorsOpacity = 0
            }
            
            withAnimation(.spring()) {
                APIError.closeError(showError: &showError, error: &error)
                retryAction = nil
            }
            
            guard let shopCard = shopCardResponse else {
                cancelDecisionUserSelection()
                return
            }
            
            APIFunction.doGameSwipe(token: userViewModel.readToken, gameId: game.gameId, shopId: shopCard.shopId, swipeType: userSelection, subscriptions: &subscriptions) { data in
                if data.recommendShopIds != nil || data.recommendShops != nil {
                    disappearingCard()
                    
                    withAnimation(.spring()) {
                        gameResponse = data
                    }
                } else if let shopId = data.recommendedShopId {
                    withAnimation(.spring()) {
                        gameResponse?.curRound = data.curRound
                        gameResponse?.totalRound = data.totalRound
                    }
                    
                    disappearingCard()
                    
                    restaurantId = shopId
                    
                    withAnimation(.easeInOut) {
                        isCherryPick = false
                        isCherryPickDone = true
                    }
                } else {
                    withAnimation(.spring()) {
                        gameResponse?.curRound = data.curRound
                        gameResponse?.totalRound = data.totalRound
                    }
                    
                    disappearingCard()
                }
            } errorHandling: { apiError in
                retryAction = doSwipped
                cancelDecisionUserSelection()
                
                withAnimation(.spring()) {
                    APIError.showError(showError: &showError, error: &error, catchError: apiError)
                }
            }
        }
    }
    
    func doPreferenceSwipped() {
        if let game = preferenceGameResponse {
            withAnimation(.easeInOut) {
                indicatorsOpacity = 0
            }
            
            withAnimation(.spring()) {
                APIError.closeError(showError: &showError, error: &error)
                retryAction = nil
            }
            
            guard preferencCardResponse != nil else {
                cancelDecisionUserSelection()
                return
            }
            
            APIFunction.doUserPreferenceSwipe(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, preferenceGameId: game.preferenceGameId, swipeType: userSelection, subscriptions: &subscriptions) { data in
                if game.preferenceCards.isEmpty {
                    withAnimation(.spring()) {
                        preferenceGameResponse?.curRound = data.curRound
                        preferenceGameResponse?.totalRound = data.totalRound
                    }
                    
                    disappearingCard()
                    
                    isFirstCherryPick = false
                    
                    withAnimation(.easeInOut) {
                        tutorialIsDone = true
                    }
                } else {
                    disappearingCard()
                }
            } errorHandling: { apiError in
                retryAction = doPreferenceSwipped
                cancelDecisionUserSelection()
                
                withAnimation(.spring()) {
                    APIError.showError(showError: &showError, error: &error, catchError: apiError)
                }
            }
        }
    }
    
    func clippingAction() {
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
            retryAction = nil
        }
        
        guard let shopCard = shopCardResponse else {
            return
        }
        
        APIFunction.doOrUndoClipping(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, shopId: shopCard.shopId, isClipped: isClipped, subscriptions: &subscriptions) { _ in
            isClipped = !isClipped
        } errorHanding: { apiError in
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
}

struct CherryPickView_Previews: PreviewProvider {
    static var previews: some View {
        CherryPickView(isCherryPick: .constant(true), isCherryPickDone: .constant(false), restaurantId: .constant(0), gameCategory: .constant(.group), isFirstCherryPick: .constant(false), cherryPickMode: .cherryPick)
            .tint(Color("main-point-color"))
        //            .environmentObject(UserViewModel.preivew)
                    .environmentObject(UserViewModel())
    }
}
