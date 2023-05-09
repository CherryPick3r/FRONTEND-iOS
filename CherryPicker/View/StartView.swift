//
//  StartView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/04/30.
//

import SwiftUI
import AuthenticationServices

struct StartView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isCherryPick: Bool
    
    @State private var showSignInView = false
    @State private var showSignUpView = false
    
    var body: some View {
        NavigationStack {
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
                    .padding(.bottom, 50)
            }
            .navigationTitle("")
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
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(isCherryPick: .constant(false))
            .environmentObject(UserViewModel())
    }
}
