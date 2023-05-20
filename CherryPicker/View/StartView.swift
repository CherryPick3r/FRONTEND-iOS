//
//  StartView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/04/30.
//

import SwiftUI
import AuthenticationServices

struct StartView: View {
    @Namespace var heroEffect
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isCherryPick: Bool
    
    @State private var showSignInView = false
    @State private var showSignUpView = false
    @State private var categoryIndicatorOffsetY = CGFloat.zero
    @State private var contentID = 0
    @State private var contentOffsetY = CGFloat.zero
    @State private var isCategoryContent = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { reader in
                let height = reader.size.height
                let width = reader.size.width
                
                VStack {
                    startContents(height: height)
                        .frame(width: reader.size.width, height: reader.size.height)
                        .gesture(
                            DragGesture()
                                .onChanged({ drag in
                                    showingCategoryContent(moveY: drag.translation.height)
                                })
                                .onEnded({ drag in
                                    showCategoryContent(height: height)
                                })
                        )
                        .offset(y: contentOffsetY)
                    
                    categoryContents(height: height)
                        .frame(width: width, height: height)
                        .gesture(
                            DragGesture()
                                .onChanged({ drag in
                                    showingStartContent(moveY: drag.translation.height, height: height)
                                })
                                .onEnded({ drag in
                                    showStartContent(height: height)
                                })
                        )
                        .offset(y: contentOffsetY)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .modifier(BackgroundModifier())
                .toolbar {
                    ToolbarItem {
                        NavigationLink {
                            MenuView()
                        } label: {
                            Label("메뉴", systemImage: "line.3.horizontal")
                                .foregroundColor(Color("main-point-color"))
                        }
                    }
                }
                .sheet(isPresented: $showSignInView) {
                    signIn()
                        .presentationDetents([.medium])
                }
                .sheet(isPresented: $showSignUpView) {
                    signUp()
                        .presentationDetents([.medium])
                }
            }
        }
        .tint(Color("main-point-color"))
    }
    
    @ViewBuilder
    func startButton() -> some View {
        Button {
            showSignInView = true
        } label: {
            HStack {
                Spacer()
                
                Text("시작하기")
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
        .matchedGeometryEffect(id: "indicator", in: heroEffect)
        .offset(y: categoryIndicatorOffsetY)
        .animation(Animation.interactiveSpring(response: 1.2, dampingFraction: 1.2, blendDuration: 1.2).repeatForever(autoreverses: true), value: categoryIndicatorOffsetY)
        .onAppear {
            categoryIndicatorOffsetY = isCategoryContent ? 0 : 15
        }
        .padding(.bottom, isCategoryContent ? 0 : nil)
    }
    
    @ViewBuilder
    func startContents(height: CGFloat) -> some View {
        VStack {
            Text("🍒")
                .font(.system(size: 100))
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
                .padding(.bottom, isCategoryContent ? 150 : 80)
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
        VStack(spacing: 40) {
            categoryButton(title: "\"\("단체모임")\"으로 시작하기", tags: ["쾌적한 공간", "푸짐해요", "단체모임", "가성비 맛집"])
            
            categoryButton(title: "\"\("카페/공부")\"로 시작하기", tags: ["카페", "커피맛집", "오래 있기 좋아요", "맛있는 음료"])
            
            categoryButton(title: "\"\("사진맛집")\"으로 시작하기", tags: ["컨셉이 독특해요", "감성사진"])
            
            categoryButton(title: "\"\("혼밥")\"으로 시작하기", tags: ["가성비 맛집", "혼밥하기 좋아요"])
        }
    }
    
    @ViewBuilder
    func categoryButton(title: String, tags: [String]) -> some View {
        Button {
            showSignInView = true
        } label: {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color"))
                    
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Spacer()
                    
                    ForEach(tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("secondary-text-color-weak"))
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("background-shape-color"))
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color("main-point-color"), lineWidth: 2)
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
            
            SignInWithAppleButton(
                onRequest: { request in
                    // 로그인 요청 시 처리할 코드
                    
                    //서버 연결되면 삭제 예정
                    withAnimation(.easeInOut) {
                        showSignInView = false
                        isCherryPick = true
                    }
                },
                onCompletion: { result in
                    // 로그인 결과 처리할 코드
                    switch result {
                    case .success(let authResults):
                        // 인증 결과 처리
                        break
                    case .failure(let error):
                        // 인증 실패 처리
                        break
                    }
                }
            )
            .padding(.horizontal, 30)
            .padding(.vertical)
            .frame(height: 80)
            .cornerRadius(10)
            
            Spacer()
            
            Text("혹시 회원이 아니신가요?")
                .fontWeight(.bold)
                .foregroundColor(Color("main-text-color"))
                .padding()
            
            Button {
                showSignInView = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showSignUpView = true
                }
            } label: {
                Text("회원가입 하러 가기")
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color-weak"))
            }
            .padding()
            
        }
        .background(Color("background-shape-color"))
    }
    
    @ViewBuilder
    func signUp() -> some View {
        VStack {
            VStack {
                HStack {
                    Text("환영합니다!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color"))
                    
                    Spacer()
                }
                .padding()
                .padding(.top)
                
                SignInWithAppleButton(
                    onRequest: { request in
                        // 로그인 요청 시 처리할 코드
                        
                        //서버 연결되면 삭제 예정
                        withAnimation(.easeInOut) {
                            showSignUpView = false
                            isCherryPick = true
                        }
                    },
                    onCompletion: { result in
                        // 로그인 결과 처리할 코드
                        switch result {
                        case .success(let authResults):
                            // 인증 결과 처리
                            break
                        case .failure(let error):
                            // 인증 실패 처리
                            break
                        }
                    }
                )
                .padding(.horizontal, 30)
                .padding(.vertical)
                .frame(height: 80)
                .cornerRadius(10)
                
                Spacer()
                
                Text("혹시 회원이신가요?")
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-text-color"))
                    .padding()
                
                Button {
                    showSignUpView = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showSignInView = true
                    }
                } label: {
                    Text("로그인 하러 가기")
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color-weak"))
                }
                .padding()
                
            }
            .background(Color("background-shape-color"))
        }
    }
    
    func showingStartContent(moveY: CGFloat, height: CGFloat) {
        contentOffsetY += (contentOffsetY < -height && moveY < 0) ? (moveY / 500) : moveY
        print(contentOffsetY)
        print(height)
    }
    
    func showingCategoryContent(moveY: CGFloat) {
        contentOffsetY += (contentOffsetY < 0) ? moveY : (moveY / 500)
    }
    
    func showCategoryContent(height: CGFloat) {
        withAnimation(.easeInOut) {
            isCategoryContent = contentOffsetY < -150
            
            contentOffsetY = isCategoryContent ? -height : 0
        }
        
        categoryIndicatorOffsetY = 0
    }
    
    func showStartContent(height: CGFloat) {
        withAnimation(.easeInOut) {
            isCategoryContent = contentOffsetY < -550
            
            contentOffsetY = isCategoryContent ? -height : 0
        }
        
        categoryIndicatorOffsetY = 15
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(isCherryPick: .constant(false))
            .environmentObject(UserViewModel())
    }
}
