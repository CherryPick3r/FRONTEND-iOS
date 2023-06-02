//
//  MenuView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/01.
//

import SwiftUI
import Combine

struct MenuView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @FocusState private var isUserNameFocused: Bool
    
    @Binding var path: [NavigationPath]
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var userName = ""
    @State private var isUserNameEditing = false
    @State private var showDisplayStyleDialog = false
    @State private var showWithdrawalView = false
    @State private var isLoading = false
    @State private var error: APIError?
    @State private var showError = false
    @State private var retryAction: (() -> Void)?
    @State private var showLogoutDialog = false
    
    var body: some View {
        ViewThatFits(in: .vertical) {
            VStack {
                menu()
                
                Spacer()
            }
            
            ScrollView {
                menu()
            }
        }
        .modifier(BackgroundModifier())
        .navigationTitle("메뉴")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            isUserNameFocused = false
            isUserNameEditing = false
        }
        .tint(Color("main-point-color"))
        .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
        .fullScreenCover(isPresented: $showWithdrawalView) {
            WithdrawalView(path: $path)
        }
        .task {
            fetchUserNickname()
        }
        .sheet(isPresented: $isUserNameEditing) {
            VStack {
                HStack {
                    Text("변경할 닉네임을 입력해주세요!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-text-color"))
                    
                    Spacer()
                }
                .padding([.horizontal, .top])
                .padding(.top)
                
                TextField("닉네임", text: $userName, prompt: Text("닉네임"))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isUserNameFocused)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("background-shape-color"))
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    }
                    .onSubmit {
                        isUserNameFocused = false
                        isUserNameEditing = false

                        changeUserNickname()
                    }
                    .padding()
                
                Spacer()
            }
            .presentationDetents([.medium])
        }
        .onChange(of: isUserNameEditing) { newValue in
            if !newValue {
                fetchUserNickname()
            }
        }
    }
    
    @ViewBuilder
    func menu() -> some View {
        HStack {
            Spacer()
            
            VStack {
                userMenu()
                
                settingMenu()
                
                helpMenu()
                
                logoutButton()
                
                withdrawalButton()
            }
            .frame(maxWidth: 500)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func menuBackground() -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color("background-shape-color"))
            .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    @ViewBuilder
    func userMenu() -> some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.mini)
                    } else {
                        Text(userName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                    }
                }
                
                Text("님")
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    isUserNameEditing = true
                } label: {
                    Label("수정", systemImage: "pencil.line")
                        .labelStyle(.iconOnly)
                }
                .padding(.leading, 5)
                .disabled(showError || isLoading)
                
                Spacer()
            }
            
            NavigationLink(value: NavigationPath.userAnalyzeView) {
                HStack {
                    Text("취향분석")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .font(.title3)
                }
            }
        }
        .padding(20)
        .background {
            menuBackground()
        }
        .padding()
    }
    
    @ViewBuilder
    func settingMenu() -> some View {
        VStack(spacing: 20) {
            HStack {
                Text("화면 스타일")
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
                
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    showDisplayStyleDialog = true
                } label: {
                    Text(userViewModel.userColorScheme.rawValue)
                        .foregroundColor(Color("secondary-text-color-strong"))
                }
                .confirmationDialog("화면 스타일 선택", isPresented: $showDisplayStyleDialog) {
                    Button("시스템 기본값") {
                        UISelectionFeedbackGenerator().selectionChanged()
                        userViewModel.userColorScheme = .system
                    }
                    
                    Button("라이트 모드") {
                        UISelectionFeedbackGenerator().selectionChanged()
                        userViewModel.userColorScheme = .light
                    }
                    
                    Button("다크 모드") {
                        UISelectionFeedbackGenerator().selectionChanged()
                        userViewModel.userColorScheme = .dark
                    }
                }
            }
        }
        .padding(20)
        .background {
            menuBackground()
        }
        .padding()
    }
    
    @ViewBuilder
    func helpMenu() -> some View {
        VStack(spacing: 20) {
            HStack {
                Text("버전")
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
                
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    .foregroundColor(Color("secondary-text-color-strong"))
            }
            
            NavigationLink {
                
            } label: {
                HStack {
                    Text("공지사항")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .font(.title3)
                }
            }
            
            NavigationLink {
                
            } label: {
                HStack {
                    Text("서비스 이용약관")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .font(.title3)
                }
            }
            
            NavigationLink {
                
            } label: {
                HStack {
                    Text("개인정보 처리방침")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .font(.title3)
                }
            }
        }
        .padding(20)
        .background {
            menuBackground()
        }
        .padding()
    }
    
    @ViewBuilder
    func logoutButton() -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            showLogoutDialog = true
        } label: {
            HStack {
                Spacer()
                
                Text("로그아웃")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("background-shape-color"))
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color("main-point-color-weak"), lineWidth: 2)
                }
                .shadow(color: .black.opacity(0.1), radius: 2)
            }
        }
        .padding()
        .confirmationDialog("로그아웃", isPresented: $showLogoutDialog) {
            Button("로그아웃", role: .destructive) {
                UISelectionFeedbackGenerator().selectionChanged()
                userViewModel.deleteUserInfo()
                
                path.removeLast()
            }
            
            Button("취소", role: .cancel) {
                UISelectionFeedbackGenerator().selectionChanged()
            }
        } message: {
            Text("로그아웃 하시겠아요?")
        }
    }
    
    @ViewBuilder
    func withdrawalButton() -> some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            
            showWithdrawalView = true
        } label: {
            HStack {
                Spacer()
                
                Text("회원탈퇴")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("background-shape-color"))
                
                Spacer()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("main-point-color"))
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
        }
        .padding()
    }
    
    func fetchUserNickname() {
        isLoading = true
        
        withAnimation(.spring()) {
            retryAction = nil
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.fetchOrChangeUserNickname(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, subscriptions: &subscriptions) { userNicknameResponse in
            if let nickname = try? JSONDecoder().decode(UserNicknameResponse.self, from: userNicknameResponse).userNickname {
                userName = nickname
            }
            
            isLoading = false
        } errorHandling: { apiError in
            withAnimation(.spring()) {
                retryAction = fetchUserNickname
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func changeUserNickname() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        withAnimation(.spring()) {
            retryAction = nil
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.fetchOrChangeUserNickname(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, changeUserNickname: userName, subscriptions: &subscriptions) { _ in
            withAnimation(.easeInOut) {
                isLoading = false
            }
        } errorHandling: { apiError in
            withAnimation(.spring()) {
                retryAction = changeUserNickname
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MenuView(path: .constant([.menuView]))
                .environmentObject(UserViewModel.preivew)
        }
        .tint(Color("main-point-color"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
