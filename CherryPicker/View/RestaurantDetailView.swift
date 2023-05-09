//
//  RestaurantDetailView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI

struct RestaurantDetailView: View {
    @Namespace var heroEffect
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var isCherryPick: Bool
    @Binding var isCherryPickDone: Bool
    
    private let isResultView: Bool
    
    @State private var isDetailInformation = false
    @State private var showDetailInformation = false
    @State private var showInformation = false
    @State private var showIndicators = false
    @State private var showImages = false
    @State private var informationOffsetY = CGFloat.zero
    @State private var imageBlur = 0.0
    @State private var detailImageOffsetY = CGFloat.zero
    @State private var detailImageBackgroundOpacity = 1.0
    @State private var opacity = 1.0
    @State private var topButtonsOffsetY = CGFloat.zero
    @State private var toolButtonsOffsetX = CGFloat.zero
    
    //임시
    @State private var imagePage = 0
    
    init(isCherryPick: Binding<Bool> = .constant(false), isCherryPickDone: Binding<Bool> = .constant(false), isResultView: Bool = true) {
        self._isCherryPick = isCherryPick
        self._isCherryPickDone = isCherryPickDone
        self.isResultView = isResultView
    }
    
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            
            ZStack {
                if !showImages {
                    backgroundImage()
                        .frame(width: reader.size.width, height: height + reader.safeAreaInsets.top + reader.safeAreaInsets.bottom)
                } else {
                    Color("background-color")
                }
                
                VStack {
                    if showIndicators {
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
                        .offset(y: topButtonsOffsetY)
                        .padding(.top, reader.safeAreaInsets.top)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                    
                    if showIndicators {
                        HStack {
                            Spacer()
                            
                            toolButtons()
                        }
                        .offset(x: toolButtonsOffsetX)
                        .padding(.bottom)
                        .offset(y: informationOffsetY)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                    if showInformation {
                        information(height: height - (reader.safeAreaInsets.top + reader.safeAreaInsets.bottom + 30))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    if isDetailInformation {
                        Spacer()
                    }
                }
                .offset(y: height == 647 || height == 716 ? 15 : 0)
            }
            .modifier(BackgroundModifier())
            .gesture(
                DragGesture()
                    .onChanged({ drag in
                        let moveX = drag.translation.height
                        
                        opacity = (150 - moveX / 10) / 150
                        
                        topButtonsOffsetY = -moveX / 10
                        
                        toolButtonsOffsetX = moveX / 10
                        
                        informationOffsetY = moveX / 10
                    })
                    .onEnded({ drag in
                        if drag.translation.height > 150 {
                            withAnimation(.easeInOut) {
                                showInformation = false
                                showIndicators = false
                                if isResultView {
                                    isCherryPick = false
                                    isCherryPickDone = false
                                } else {
                                    dismiss()
                                }
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                opacity = 1.0
                            }
                            
                            withAnimation(.spring()) {
                                topButtonsOffsetY = .zero
                                toolButtonsOffsetX = .zero
                                informationOffsetY = .zero
                            }
                        }
                    })
            )
            .opacity(opacity)
            .onAppear() {
                withAnimation(.spring()) {
                    showInformation = true
                    showIndicators = true
                }
            }
            .ignoresSafeArea()
            .overlay {
                if showImages {
                    images()
                }
            }
        }
    }
    
    @ViewBuilder
    func imageShadowOverlay() -> some View {
        ZStack {
            if !isDetailInformation {
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
            
            Color("background-color")
                .opacity(0.1 * (imageBlur / 100))
        }
    }
    
    @ViewBuilder
    func backgroundImage() -> some View {
        Image("restaurant-sample1")
            .resizable()
            .scaledToFill()
            .overlay {
                imageShadowOverlay()
            }
            .matchedGeometryEffect(id: "restaurant-sample1", in: heroEffect)
            .blur(radius: 20 * imageBlur / 100)
            .onTapGesture {
                if !isDetailInformation {
                    withAnimation(.spring()) {
                        showInformation = false
                        showIndicators = false
                        showImages = true
                    }
                }
            }
    }
    
    @ViewBuilder
    func information(height: CGFloat) -> some View {
        let isNoneNotchiPhone = height == 597

        VStack(alignment: .leading, spacing: isNoneNotchiPhone ? 10 : 15) {
            informationContent(height: height, detailMenuDisable: isNoneNotchiPhone)
        }
        .onAppear() {
            print(height)
        }
        .padding(isNoneNotchiPhone ? 15 : 20)
        .padding(.bottom, isDetailInformation ? 0 : (isNoneNotchiPhone ? 10 : 15))
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.25), radius: 5)
        }
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
        .frame(maxWidth: 500)
        .padding(.top)
        .offset(y: informationOffsetY)
        .gesture(
            DragGesture()
                .onChanged({ drag in
                    let moveY = drag.translation.height
                    
                    if showDetailInformation {
                        if moveY < 0 {
                            informationOffsetY = moveY / 10
                        } else {
                            informationOffsetY = moveY
                            imageBlur -= imageBlur > 0 ? 1 : 0
                        }
                    } else {
                        if moveY > 0 {
                            if isDetailInformation {
                                informationOffsetY = moveY
                                imageBlur += imageBlur < 100 ? 1 : 0
                            } else {
                                informationOffsetY = moveY / 10
                            }
                        } else {
                            informationOffsetY = moveY
                            
                            if moveY < 0 {
                                withAnimation(.spring()) {
                                    showIndicators = false
                                }
                                
                                isDetailInformation = true
                            } else {
                                if !isDetailInformation {
                                    imageBlur = -moveY
                                }
                            }
                        }
                    }
                })
                .onEnded({ drag in
                    if isDetailInformation {
                        if showDetailInformation {
                            if informationOffsetY > 100 {
                                withAnimation(.spring()) {
                                    showIndicators = true
                                    showDetailInformation = false
                                    informationOffsetY = .zero
                                    isDetailInformation = false
                                }
                                
                                withAnimation(.easeInOut) {
                                    imageBlur = 0
                                }
                            } else {
                                withAnimation(.spring()) {
                                    informationOffsetY = .zero
                                    showIndicators = false
                                    showDetailInformation = true
                                    isDetailInformation = true
                                }
                                
                                withAnimation(.easeInOut) {
                                    imageBlur = 150
                                }
                            }
                        } else {
                            if informationOffsetY < 350 {
                                withAnimation(.spring()) {
                                    showDetailInformation = true
                                }
                                
                                withAnimation(.easeInOut) {
                                    isDetailInformation = true
                                    imageBlur = 150
                                }
                                
                                withAnimation(.spring()) {
                                    informationOffsetY = .zero
                                }
                            } else {
                                withAnimation(.spring()) {
                                    showIndicators = true
                                    informationOffsetY = .zero
                                    isDetailInformation = false
                                }
                                
                                withAnimation(.easeInOut) {
                                    imageBlur = 0
                                }
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            informationOffsetY = .zero
                        }
                    }
                })
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func informationContent(height: CGFloat, detailMenuDisable: Bool) -> some View {
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
        
        Text("식사로도 좋고 간술하기에도 좋은 이자카야 \"이이요\"")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(Color("secondary-text-color-strong"))
        
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
                detailHours()
            }
        }
        
        if isDetailInformation {
            VStack(alignment: .leading) {
                Text("키워드 태그")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                KeywordTagsView()
                    .frame(height: height / 3)
            }
            .padding(.bottom, 5)
        }
        
        representativeMenu(detailMenuDisable: detailMenuDisable)
    }
    
    @ViewBuilder
    func representativeMenu(detailMenuDisable: Bool) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(isDetailInformation ? "메뉴" : "대표메뉴")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                menu(title: "초밥(11P)", price: 20000)
                
                menu(title: "회덮밥(점심)", price: 13500)
                
                menu(title: "이이요 스페셜 카이센동", price: 35000)
                
                if isDetailInformation && !detailMenuDisable {
                    menu(title: "야끼돈부리", price: 16000)
                    
                    menu(title: "도미연어덮밥", price: 16500)
                }
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
    }
    
    @ViewBuilder
    func detailHours() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("영업시간")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
            
            HStack {
                Group {
                    hour(week: "월", startTime: "11:50", endTime: "22:00")
                    
                    Spacer()
                }
                
                Group {
                    hour(week: "화", startTime: "11:50", endTime: "22:00")
                    
                    Spacer()
                }
                
                Group {
                    hour(week: "수", startTime: "11:50", endTime: "22:00")
                    
                    Spacer()
                }
                
                Group {
                    hour(week: "목", startTime: "11:50", endTime: "22:00")
                    
                    Spacer()
                }
                
                Group {
                    hour(week: "금", startTime: "11:50", endTime: "22:00")
                    
                    Spacer()
                }
                
                Group {
                    hour(week: "토", startTime: "11:50", endTime: "22:00")
                    
                    Spacer()
                }
                
                hour(week: "일")
            }
        }
    }
    
    @ViewBuilder
    func hour(week: String, startTime: String? = nil, endTime: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(week)
            
            Text(startTime ?? "정기")
                .foregroundColor(startTime == nil ? Color("main-point-color-strong") : Color("main-text-color"))
            
            Text(endTime ?? "휴무")
                .foregroundColor(endTime == nil ? Color("main-point-color-strong") : Color("main-text-color"))
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(Color("main-text-color"))
    }
    
    @ViewBuilder
    func restartButton() -> some View {
        Button {
            withAnimation(.easeInOut) {
                showInformation = false
                showIndicators = false
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
                showInformation = false
                showIndicators = false
                if isResultView {
                    isCherryPick = false
                    isCherryPickDone = false
                } else {
                    dismiss()
                }
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
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("main-point-color").opacity(0.3))
            }
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
                        showInformation = true
                        showIndicators = true
                    }
                } label: {
                    Label("닫기", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 5)
                }
                .padding()
                .opacity(detailImageBackgroundOpacity)

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
                                .font(.largeTitle)
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
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 5)
                        }
                    }
                }
                .padding()
            }
            .offset(y: detailImageOffsetY)
            .gesture(
                DragGesture()
                    .onChanged({ drag in
                        let moveY = drag.translation.height
                        
                        detailImageOffsetY = moveY
                        
                        if detailImageOffsetY != .zero {
                            detailImageBackgroundOpacity = moveY > 0 ? (500 - moveY) / 500 : (500 + moveY) / 500
                            
                            withAnimation(.spring()) {
                                showInformation = true
                                showIndicators = true
                            }
                        }
                    })
                    .onEnded({ drag in
                        if !(-150...150).contains(drag.translation.height) {
                            withAnimation(.spring()) {
                                showImages = false
                            }
                        } else {
                            withAnimation(.spring()) {
                                showInformation = false
                                showIndicators = false
                            }
                        }
                        
                        withAnimation(.spring()) {
                            detailImageOffsetY = .zero
                        }
                        
                        withAnimation(.easeInOut) {
                            detailImageBackgroundOpacity = 1.0
                        }
                    })
            )
            
            Spacer()
        }
        .background(.black.opacity(detailImageBackgroundOpacity))
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(isCherryPick: .constant(false), isCherryPickDone: .constant(true))
    }
}
