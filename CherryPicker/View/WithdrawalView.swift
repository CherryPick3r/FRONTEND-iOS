//
//  WithdrawView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/09.
//

import SwiftUI
import AuthenticationServices

struct WithdrawalView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showSignInView = false
    @State private var isUserConfirmed = false
    
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
            .navigationTitle("회원탈퇴")
            .toolbar {
                ToolbarItem {
                    Button {
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
            Text("사용자 확인")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom)
            
            Button {
                showSignInView = true
            } label: {
                HStack {
                    Spacer()
                    
                    if isUserConfirmed {
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
    
    @ViewBuilder
    func confirmUser() -> some View {
        VStack(alignment: .leading) {
            Text("사용자 확인")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding()
                .padding(.top)
            
            SignInWithAppleButton(
                onRequest: { request in
                    // 로그인 요청 시 처리할 코드
                    
                    //서버 연결되면 삭제 예정
                    withAnimation(.easeInOut) {
                        showSignInView = false
                        isUserConfirmed = true
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
        }
        .background(Color("background-shape-color"))
    }
    
    @ViewBuilder
    func withdrawalButton() -> some View {
        Button {
            
        } label: {
            HStack {
                Spacer()
                
                Text("탈퇴하기")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isUserConfirmed ? Color("main-point-color") : Color("secondary-text-color-weak"))
                    .padding(.vertical)
                
                Spacer()
            }
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color("background-shape-color"))
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(isUserConfirmed ? Color("main-point-color") : Color("secondary-text-color-weak"), lineWidth: 2)
                        .shadow(radius: 10)
                }
            }
        }
        .padding(.horizontal, 70)
        .padding(.vertical, 40)
        .disabled(!isUserConfirmed)
    }
}

struct WithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalView()
    }
}
