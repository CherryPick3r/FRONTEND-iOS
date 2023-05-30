//
//  StartView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/04/30.
//

import SwiftUI
import Combine
import AuthenticationServices

enum NavigationPath {
    case menuView
}

struct StartView: View {
    @Namespace var heroEffect
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isCherryPick: Bool
    @Binding var gameCategory: GameCategory?
    @Binding var isFirstCherryPick: Bool
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var path = [NavigationPath]()
    @State private var showSignInView = false
    @State private var categoryIndicatorOffsetY = CGFloat.zero
    @State private var contentID = 0
    @State private var contentOffsetY = CGFloat.zero
    @State private var dragOffsetY = CGFloat.zero
    @State private var isCategoryContent = false
    @State private var maxVelocity = CGFloat.zero
    @State private var showLoginWebView = false
    @State private var isLoading = false
    @State private var error: APIError?
    @State private var showError = false
    @State private var retryAction: (() -> Void)?
    @State private var loginURL = ""
    
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { reader in
                let height = reader.size.height
                let width = reader.size.width
                
                LazyVStack {
                    startContents(height: height)
                        .frame(width: width, height: height)
                    
                    categoryContents(height: height)
                        .frame(width: width, height: height)
                }
                .offset(y: contentOffsetY)
                .gesture(
                    DragGesture()
                        .onChanged({ drag in
                            DispatchQueue.global(qos: .userInteractive).async {
                                guard !isFirstCherryPick else {
                                    return
                                }
                                
                                let moveY = drag.translation.height
                                let velocity = moveY - (contentOffsetY - dragOffsetY)
                                
                                calculateMaxVelocity(velocity: velocity)
                                
                                isCategoryContent ? showingStartContent(moveY: moveY, height: height) : showingCategoryContent(moveY: moveY)
                            }
                        })
                        .onEnded({ drag in
                            DispatchQueue.global(qos: .userInteractive).async {
                                isCategoryContent ? showStartContent(height: height) : showCategoryContent(height: height)
                                
                                maxVelocity = CGFloat.zero
                            }
                        })
                )
                .modifier(BackgroundModifier())
                .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        NavigationLink(value: NavigationPath.menuView) {
                            Label("메뉴", systemImage: "line.3.horizontal")
                                .foregroundColor(Color("main-point-color"))
                        }
                        .disabled(!userViewModel.isAuthenticated)
                    }
                }
                .onAppear() {
                    gameCategory = nil
                }
                .task {
                    if userViewModel.isAuthenticated {
                        checkPreferenceGame()
                    }
                }
                .sheet(isPresented: $showSignInView) {
                    signIn()
                        .presentationDetents([.medium])
                }
                .sheet(isPresented: $showLoginWebView) {
                    LoginWebView(url: loginURL, onReceivedResponse: userViewModel.loginCallbackHandler(response:showLoginWebView:), showError: $showError, error: $error, showLoginWebView: $showLoginWebView)
                        .environmentObject(userViewModel)
                }
                .onChange(of: loginURL) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showLoginWebView = loginURL != "" ? true : false
                    }
                    
                    print(newValue)
                }
                .onChange(of: showLoginWebView) { newValue in
                    if !newValue {
                        loginURL = ""
                        
                        if !userViewModel.isAuthenticated {
                            userViewModel.platform = .notLogined
                        }
                    }
                }
                .onChange(of: userViewModel.isAuthenticated) { newValue in
                    if userViewModel.isAuthenticated {
                        checkPreferenceGame()
                    }
                }
                .navigationDestination(for: NavigationPath.self) { navigationPath in
                    MenuView(path: $path)
                }
            }
        }
        .tint(Color("main-point-color"))
    }
    
    @ViewBuilder
    func startButton() -> some View {
        Button {
            startGame()
        } label: {
            HStack {
                Spacer()
                
                Text(isFirstCherryPick ? "튜토리얼 시작하기" : "시작하기")
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
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    func categoryIndicator(height: CGFloat) -> some View {
        HStack {
            Spacer()
            
            VStack(alignment: .center) {
                ZStack {
                    Text("카테고리로 시작하기")
                        .opacity(isCategoryContent ? 0 : 1)
                    
                    Text("카테고리 없이 시작하기")
                        .opacity(isCategoryContent ? 1 : 0)
                }
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color-weak"))
                .padding(.bottom)
                
                Label("내리기", systemImage: "chevron.compact.up")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .foregroundColor(Color("main-point-color-weak"))
                    .rotationEffect(.degrees(isCategoryContent ? 180 : 0))
            }
            
            Spacer()
        }
        .offset(y: categoryIndicatorOffsetY)
        .matchedGeometryEffect(id: "indicator", in: heroEffect)
        .animation(Animation.interactiveSpring(response: 1.2, dampingFraction: 1.2, blendDuration: 1.2).repeatForever(autoreverses: true), value: categoryIndicatorOffsetY)
        .onAppear {
            categoryIndicatorOffsetY = isCategoryContent ? 0 : 15
        }
        .padding(.bottom, isCategoryContent ? 0 : nil)
        
    }
    
    @ViewBuilder
    func startContents(height: CGFloat) -> some View {
        VStack {
            Image("cherry-picker-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.top, 50)
            
            Spacer()
            
            Text("맛있는 음식점을 찾고\n 싶으신가요?")
                .multilineTextAlignment(.center)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.horizontal)
            
            HStack {
                Spacer()
                
                startButton()
                
                Spacer()
            }
            
            Text("지겨운 메뉴 고민은 그만! 이제는 음식도 \n재미있게 Cherry Picker.")
                .multilineTextAlignment(.center)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("secondary-text-color-strong"))
                .padding(.bottom, isCategoryContent ? 140 : 80)
        }
        .overlay(alignment: .bottom) {
            if !isCategoryContent {
                categoryIndicator(height: height)
            }
        }
    }
    
    @ViewBuilder
    func categoryContents(height: CGFloat) -> some View {
        VStack(spacing: 30) {
            Text("따로 원하시는 카테고리가 있으신가요?")
                .multilineTextAlignment(.center)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.horizontal)
                .padding(.top, 70)
            
            Text("카테고리를 선택해 주세요!\n해당 카테고리의 태그들을 가진 음식점만\n추천해 드릴게요!")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("secondary-text-color-strong"))
                .padding(.horizontal)
            
            ViewThatFits {
                VStack(spacing: 0) {
                    categoryList()
                    
                    Spacer()
                }
                
                ScrollView {
                    categoryList()
                        .padding(.bottom)
                }
            }
        }
        .overlay(alignment: .top) {
            if isCategoryContent {
                categoryIndicator(height: height)
            }
        }
    }
    
    @ViewBuilder
    func categoryList() -> some View {
        LazyVStack(spacing: 40) {
            ForEach(GameCategory.allCases, id: \.self) { category in
                categoryButton(category: category, tags: category.tags)
            }
        }
    }
    
    @ViewBuilder
    func categoryButton(category: GameCategory, tags: [TagTitle]) -> some View {
        Button {
            gameCategory = category
            
            startGame()
        } label: {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Text("\"\(category.name)\"")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color"))
                    
                    Spacer()
                }
                .padding(.bottom)
                
                ViewThatFits(in: .horizontal) {
                    HStack {
                        Spacer()
                        
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag.rawValue)")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("secondary-text-color-weak"))
                        }
                        
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text("#\(tag.rawValue)")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("secondary-text-color-weak"))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("background-shape-color"))
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color("main-point-color-weak"), lineWidth: 2)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                }
            }
        }
        .frame(maxWidth: 500)
        .padding(.horizontal, 30)
    }
    
    @ViewBuilder
    func signIn() -> some View {
        VStack {
            HStack {
                Text("로그인이 필요해요")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            .padding()
            .padding(.top)
            
            Button {
                appleLogin()
            } label: {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "apple.logo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(width: 15)
                        
                        Text("Apple로 로그인")
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(colorScheme == .dark ? .white : .black)
                }
                .frame(width: 280, height: 60)
                .padding(.top)
            }
            
            Button {
                kakaoLogin()
            } label: {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image("kakao-symbol")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .foregroundColor(Color("kakao-label-color"))
                            .frame(width: 15)
                        
                        Text("카카오 로그인")
                            .foregroundColor(Color("kakao-label-color").opacity(0.85))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("kakao-color"))
                }
                .frame(width: 280, height: 60)
                .padding(.top)
            }
            
            Button {
                googleLogin()
            } label: {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image("google-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                        
                        Text("Google로 로그인")
                            .font(.custom("Roboto-Medium", size: 16, relativeTo: .headline))
                            .foregroundColor(.black.opacity(0.54))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.1), radius: 3)
                }
                .frame(width: 280, height: 60)
                .padding(.vertical)
            }

            
            Spacer()
        }
        .background(Color("background-shape-color"))
    }
    
    func calculateMaxVelocity(velocity: CGFloat) {
        if velocity < 0 {
            maxVelocity = velocity < maxVelocity ? velocity : maxVelocity
        } else {
            maxVelocity = velocity > maxVelocity ? velocity : maxVelocity
        }
    }
    
    func showingStartContent(moveY: CGFloat, height: CGFloat) {
        contentOffsetY = ((contentOffsetY < -height && moveY < 0) ? (moveY / 3) : moveY) + dragOffsetY
    }
    
    func showingCategoryContent(moveY: CGFloat) {
        contentOffsetY = ((contentOffsetY < 0) ? moveY : (moveY / 3)) + dragOffsetY
    }
    
    func showCategoryContent(height: CGFloat) {
        withAnimation(.spring()) {
            isCategoryContent = (contentOffsetY < -150 || maxVelocity <= -30) && maxVelocity < 0
            
            contentOffsetY = isCategoryContent ? -height : 0
        }
        
        dragOffsetY += contentOffsetY
        
        categoryIndicatorOffsetY = 0
    }
    
    func showStartContent(height: CGFloat) {
        withAnimation(.spring()) {
            isCategoryContent = (contentOffsetY < -550 && maxVelocity <= 30) || maxVelocity < 0
            
            contentOffsetY = isCategoryContent ? -height : 0
        }
        
        dragOffsetY = contentOffsetY
        
        categoryIndicatorOffsetY = 15
    }
    
    func startGame() {
        if userViewModel.isAuthenticated {
            withAnimation(.easeInOut) {
                isCherryPick = true
            }
        } else {
            showSignInView = true
        }
    }
    
    func appleLogin() {
        showSignInView = false
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = userViewModel
        controller.performRequests()
    }
    
    func kakaoLogin() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        showSignInView = false
        
        APIFunction.fetchLoginResponse(platform: .kakao, subscriptions: &subscriptions) { loginResponse in
            loginURL = loginResponse.loginURL
            
            DispatchQueue.main.async {
                userViewModel.platform = .kakao
            }
            
            withAnimation(.easeInOut) {
                isLoading = false
            }
        } errorHandling: { apiError in
            retryAction = kakaoLogin
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func googleLogin() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        showSignInView = false
        
        APIFunction.fetchLoginResponse(platform: .google, subscriptions: &subscriptions) { loginResponse in
            loginURL = loginResponse.loginURL
            
            DispatchQueue.main.async {
                userViewModel.platform = .google
            }
            
            withAnimation(.easeInOut) {
                isLoading = false
            }
        } errorHandling: { apiError in
            retryAction = kakaoLogin
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func checkPreferenceGame() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.checkPreferenceGame(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, subscriptions: &subscriptions) { checkPreferenceGame in
            withAnimation(.easeInOut) {
                isFirstCherryPick = checkPreferenceGame.isPlayed == 0 ? true : false
            }
        } errorHandling: { apiError in
            retryAction = checkPreferenceGame
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(isCherryPick: .constant(false), gameCategory: .constant(nil), isFirstCherryPick: .constant(false))
            .environmentObject(UserViewModel())
    }
}
