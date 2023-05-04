//
//  RestaurantDetailView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI

struct RestaurantDetailView: View {
    @Namespace var heroEffect
    
    @Binding var isCherryPick: Bool
    @Binding var isCherryPickDone: Bool
    
    @State private var isDetailInformation = false
    @State private var showContents = false
    @State private var showImages = false
    
    //임시
    @State private var imagePage = 0
    
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            
            ZStack {
                Image("restaurant-sample1")
                    .resizable()
                    .scaledToFill()
                    .matchedGeometryEffect(id: "restaurant-sample1", in: heroEffect)
                    .frame(width: reader.size.width)
                    .overlay {
                        ZStack {
                            LinearGradient(colors: [
                                Color("main-point-color").opacity(0),
                                Color("main-point-color").opacity(0.1),
                                Color("main-point-color").opacity(0.3),
                                Color("main-point-color").opacity(0.5),
                                Color("main-point-color").opacity(0.8),
                                Color("main-point-color").opacity(1)
                            ], startPoint: .top, endPoint: .bottom)
                            .opacity(0.10)
                            
                            VStack {
                                LinearGradient(colors: [
                                    Color.black.opacity(1),
                                    Color.black.opacity(0)
                                ], startPoint: .top, endPoint: .bottom)
                                .opacity(0.3)
                                .frame(height: 100)
                                
                                Spacer()
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showImages = true
                            showContents = false
                        }
                    }

                
                VStack {
                    if showContents {
                        HStack {
                            Spacer()
                            
                            restartButton()
                            
                            Spacer()
                        }
                        .overlay {
                            HStack {
                                Spacer()
                                
                                closeButton()
                            }
                        }
                        .padding(.top, reader.safeAreaInsets.top)
                        .transition(.move(edge: .top))
                    }
                    
                    Spacer()
                    
                    if showContents {
                        information()
                            .transition(.move(edge: .bottom))
                    }
                }
                .offset(y: height == 647 || height == 716 ? 15 : 0)
                .overlay {
                    if showContents {
                        HStack {
                            Spacer()
                            
                            toolButtons()
                        }
                        .transition(.move(edge: .trailing))
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear() {
                withAnimation(.spring()) {
                    showContents = true
                }
            }
            .overlay {
                if showImages {
                    images()
                }
            }
        }
    }
    
    @ViewBuilder
    func information() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                Text("이이요")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-text-color"))
                
                Text("일식당")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-point-color-weak"))
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding([.horizontal, .top], 20)
            
            Text("식사로도 좋고 간술하기에도 좋은 이자카야 \"이이요\"")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("secondary-text-color-strong"))
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: isDetailInformation ? 15 : 5) {
                Label("서울 광진구 능동로19길 36 1층", systemImage: "map")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-point-color-weak"))
                
                if !isDetailInformation {
                    HStack {
                        Label("11:50 ~ 22:00", systemImage: "clock")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("main-point-color-weak"))
                        
                        Text("휴무 : 일요일")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("main-point-color-strong"))
                    }
                    
                    
                } else {
                    
                }
            }
            .padding(.horizontal, 20)
            
            if !isDetailInformation {
                representativeMenu()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
            } else {
                
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.25), radius: 5)
                .overlay {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Text("총 1093명이 체리픽 받았어요!")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(Color("shape-light-color"))
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color("main-point-color"))
                                        .shadow(color: .black.opacity(0.25), radius: 5)
                                }
                                .padding(.trailing)
                        }
                        
                        Spacer()
                    }
                    .offset(y: -20)
                }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func representativeMenu() -> some View {
        VStack(spacing: 15) {
            HStack {
                Text("대표메뉴")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                menu(title: "초밥(11P)", price: 20000)
                
                menu(title: "회덮밥(점심)", price: 13500)
                
                menu(title: "이이요 스페셜 카이센동", price: 35000)
            }
        }
    }
    
    @ViewBuilder
    func menu(title: String, price: Int) -> some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Text("\(price)원")
        }
        .font(.footnote)
        .fontWeight(.semibold)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    func restartButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                isCherryPick = true
                isCherryPickDone = false
            }
        } label: {
            HStack {
                Image(systemName: "gobackward")
                    .padding(.trailing, 10)
                
                Text("다시하기")
            }
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(Color("main-point-color"))
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("background-shape-color"))
                    .shadow(color: .black.opacity(0.25), radius: 5)
            }
        }

    }
    
    @ViewBuilder
    func closeButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                showContents = false
                isCherryPick = false
                isCherryPickDone = false
            }
        } label: {
            Label("닫기", systemImage: "xmark.circle.fill")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .foregroundColor(Color("main-point-color"))
                .shadow(color: .black.opacity(0.25), radius: 5)
        }
        .padding(.trailing)
    }
    
    @ViewBuilder
    func toolButtons() -> some View {
        VStack(spacing: 10) {
            Button {
                
            } label: {
                Label("지도", systemImage: "location")
                    .labelStyle(.iconOnly)
            }

            Button {
                
            } label: {
                Label("공유하기", systemImage: "square.and.arrow.up")
                    .labelStyle(.iconOnly)
            }

            Button {
                
            } label: {
                Label("즐겨찾기", systemImage: "bookmark")
                    .labelStyle(.iconOnly)
            }
        }
        .font(.title2)
        .foregroundColor(Color("shape-light-color"))
        .padding(.vertical)
        .padding(.horizontal, 10)
        .background {
            Color("main-point-color").opacity(0.3)
                .shadow(color: .black.opacity(0.25), radius: 3)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding()
    }
    
    @ViewBuilder
    func images() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        showImages = false
                        showContents = true
                    }
                } label: {
                    Label("닫기", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 5)
                }
                .padding()

            }
            Spacer()
            
            TabView(selection: $imagePage) {
                Image("restaurant-sample1")
                    .resizable()
                    .scaledToFit()
                    .matchedGeometryEffect(id: "restaurant-sample1", in: heroEffect)
                    .tag(0)
                
                Image("restaurant-sample2")
                    .resizable()
                    .scaledToFit()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay {
                HStack {
                    if imagePage == 1 {
                        Button {
                            withAnimation(.easeInOut) {
                                imagePage -= 1
                            }
                        } label: {
                            Label("이전", systemImage: "chevron.backward.circle.fill")
                                .labelStyle(.iconOnly)
                                .font(.title)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 5)
                        }
                    }

                    Spacer()
                    
                    if imagePage == 0 {
                        Button {
                            withAnimation(.easeInOut) {
                                imagePage += 1
                            }
                        } label: {
                            Label("다음", systemImage: "chevron.forward.circle.fill")
                                .labelStyle(.iconOnly)
                                .font(.title)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 5)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .background(.black)
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(isCherryPick: .constant(false), isCherryPickDone: .constant(true))
    }
}
