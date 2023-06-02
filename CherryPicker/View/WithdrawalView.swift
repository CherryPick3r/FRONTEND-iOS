//
//  WithdrawView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/09.
//

import SwiftUI
import Combine
import AuthenticationServices

struct WithdrawalView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var path: [NavigationPath]
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var showSignInView = false
    @State private var showLoginWebView = false
    @State private var error: APIError?
    @State private var showError = false
    @State private var retryAction: (() -> Void)?
    @State private var loginURL = ""
    
    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("정말 탈퇴하시겠어요?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-text-color"))
                        .padding(.top)
                        .padding(.bottom, 40)
                    
                    notice()
                        .padding(.bottom, 40)
                    
                    confirmUserButton()
                        .padding(.bottom, 40)
                    
                    Spacer()
                    
                    withdrawalButton()
                    
                    Spacer()
                }
                .frame(maxWidth: 400)
                .padding(.horizontal)
                
                Spacer()
            }
            .modifier(BackgroundModifier())
            .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
            .navigationTitle("회원탈퇴")
            .toolbar {
                ToolbarItem {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        
                        dismiss()
                    } label: {
                        Text("닫기")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                    }
                }
            }
        }
        .sheet(isPresented: $showSignInView) {
            confirmUser()
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
        }
        .onChange(of: showLoginWebView) { newValue in
            if !newValue {
                loginURL = ""
            }
        }
    }
    
    @ViewBuilder
    func notice() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("탈퇴 전 확인하세요!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color-strong"))
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top) {
                        Text("· ")
                            .fontWeight(.bold)
                        Text("탈퇴하시면 회원님의 모든 기록이 즉시 삭제되며, 삭제된 데이터는 복구가 불가능합니다.")
                    }
                    
                    HStack(alignment: .top) {
                        Text("· ")
                            .fontWeight(.bold)
                        Text("초기 취향 선택 기록, 추천받은 음식점 목록, 취향 분석 기록이 삭제됩니다.")
                    }
                    
                    HStack(alignment: .top) {
                        Text("· ")
                            .fontWeight(.bold)
                        Text("음식점에 대한 통계 정보는 바뀌지 않습니다.")
                    }
                }
                .font(.footnote)
                .foregroundColor(Color("main-point-color"))
                .padding(.leading, 5)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func confirmUserButton() -> some View {
        VStack(alignment: .leading) {
            if userViewModel.platform == .apple {
                Text("Apple계정으로 로그인을 하셨어요.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                    .padding(.bottom, 5)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("기기의 설정 어플 실행 후,")
                    
                    Text("설정 - Apple ID - 암호 및 보안 - Apple로 로그인 - CherryPicker 항목으로 가셔서,")
                    
                    Text("Apple ID 사용 중단을 클릭하여 탈퇴를 진행해 주세요.")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color("secondary-text-color-strong"))
                .padding(.leading, 5)
                .padding(.bottom)
                
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    UIApplication.shared.open(settingsURL)
                } label: {
                    HStack {
                        Spacer()
                        
                        Text("설정 열기")
                            .font(.subheadline)
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
            } else {
                Text("사용자 확인")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                    .padding(.bottom)
                
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    
                    showSignInView = true
                } label: {
                    HStack {
                        Spacer()
                        
                        if userViewModel.isUserConfirmed {
                            Label("확인완료", systemImage: "checkmark.circle")
                                .labelStyle(.iconOnly)
                                .fontWeight(.bold)
                                .foregroundColor(Color("main-point-color"))
                                .padding(.vertical)
                            
                        } else {
                            Text("로그인 하러 가기")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("main-point-color"))
                                .padding(.vertical)
                        }
                        
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
            }
        }
    }
    
    @ViewBuilder
    func withdrawalButton() -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            
            deleteUser()
        } label: {
            HStack {
                Spacer()
                
                Text("탈퇴하기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(userViewModel.isUserConfirmed ? Color("main-point-color") : Color("secondary-text-color-weak"))
                    .padding(.vertical)
                
                Spacer()
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("background-shape-color"))
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(userViewModel.isUserConfirmed ? Color("main-point-color") : Color("secondary-text-color-weak"), lineWidth: 2)
                        .shadow(radius: 10)
                }
            }
        }
        .padding(.horizontal, 70)
        .padding(.vertical, 40)
        .disabled(!userViewModel.isUserConfirmed)
    }
    
    @ViewBuilder
    func confirmUser() -> some View {
        VStack {
            HStack {
                Text("사용자 확인")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            .padding()
            .padding(.top)
            
            switch userViewModel.platform {
            case .kakao:
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
            case .google:
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
            default:
                EmptyView()
            }
            
            Spacer()
        }
        .background(Color("background-shape-color"))
    }
    
    func kakaoLogin() {
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        showSignInView = false
        
        APIFunction.fetchLoginResponse(platform: .kakao, subscriptions: &subscriptions) { loginResponse in
            loginURL = loginResponse.loginURL
            
            DispatchQueue.main.async {
                userViewModel.platform = .kakao
            }
        } errorHandling: { apiError in
            retryAction = kakaoLogin
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func googleLogin() {
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        showSignInView = false
        
        APIFunction.fetchLoginResponse(platform: .google, subscriptions: &subscriptions) { loginResponse in
            loginURL = loginResponse.loginURL
            
            DispatchQueue.main.async {
                userViewModel.platform = .google
            }
        } errorHandling: { apiError in
            retryAction = kakaoLogin
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func deleteUser() {
        switch userViewModel.platform {
        case .apple:
            break
        case .kakao, .google:
            APIFunction.deleteUser(token: userViewModel.readToken, accessToken: userViewModel.readAccessToken, userEmail: userViewModel.readUserEmail, subscriptions: &subscriptions) { _ in
                userViewModel.deleteUserInfo()
                
                dismiss()
                
                path.removeLast()
            } errorHandling: { apiError in
                retryAction = deleteUser
                
                withAnimation(.spring()) {
                    APIError.showError(showError: &showError, error: &error, catchError: apiError)
                }
            }
            break
        case .notLogined:
            break
        }
    }
}

struct WithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalView(path: .constant([.menuView]))
        //            .environmentObject(UserViewModel.preivew)
                    .environmentObject(UserViewModel())
    }
}
