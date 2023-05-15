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
    private let maxOffsetY = CGFloat(250)
    
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
    @State private var showSelectMapDialog = false
    
    //임시
    @State private var imagePage = 0
    @State private var isBookmarked = false
    @State private var isSharing = false
    @State private var restuarantNaverID = 38738686
    @State private var restuarantKakaoID = 861945610
    
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
                                .opacity(isResultView ? 1 : 0)
                                .disabled(!isResultView)
                            
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
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                    if showInformation {
                        information(height: height - (reader.safeAreaInsets.top + reader.safeAreaInsets.bottom + 30))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    if showDetailInformation {
                        Spacer()
                    }
                }
                .offset(y: height == 647 || height == 716 ? 15 : 0)
            }
            .modifier(BackgroundModifier())
            .gesture(
                DragGesture()
                    .onChanged({ drag in
                        closingAction(moveY: drag.translation.height)
                    })
                    .onEnded({ drag in
                        if drag.translation.height > maxOffsetY {
                            closeAction()
                        } else {
                            cancelClosing()
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
            .onTapGesture(perform: showImagesAction)
    }
    
    @ViewBuilder
    func information(height: CGFloat) -> some View {
        let isNoneNotchiPhone = height == 597
        
        VStack(alignment: .leading, spacing: isNoneNotchiPhone ? 10 : 15) {
            informationContent(height: height, detailMenuDisable: isNoneNotchiPhone)
        }
        .padding(isNoneNotchiPhone ? 15 : 20)
        .padding(.bottom, showDetailInformation ? 0 : (isNoneNotchiPhone ? 10 : 15))
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
        .gesture(
            DragGesture()
                .onChanged({ drag in
                    let moveY = drag.translation.height
                    
                    if showDetailInformation {
                        if isDetailInformation && informationOffsetY <= 0 && moveY < 0 {
                            informationOffsetY += moveY / 600
                        } else {
                            informationOffsetY += moveY
                            imageBlurByDragOffset(moveY: moveY)
                        }
                    } else {
                        showingDetailInformation(moveY: moveY)
                    }
                })
                .onEnded({ drag in
                    if showDetailInformation {
                        if informationOffsetY < 300, !isDetailInformation {
                            openDetailInformation()
                        } else if informationOffsetY > 200 {
                            closeDetailInformation()
                        } else {
                            cancelClosingDetailInformation()
                        }
                    } else {
                        withAnimation(.spring()) {
                            informationOffsetY = .zero
                        }
                    }
                })
        )
        .offset(y: informationOffsetY)
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
        
        VStack(alignment: .leading, spacing: showDetailInformation ? 15 : 5) {
            Label("서울 광진구 능동로19길 36 1층", systemImage: "map")
                .font(.footnote)
                .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
            
            if !showDetailInformation {
                HStack {
                    Label("11:50 ~ 22:00", systemImage: "clock")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
                    
                    Text("휴무 : 일요일")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("main-point-color-strong"))
                }
                .transition(.opacity)
            } else {
                detailHours()
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
            }
        }
        
        if showDetailInformation {
            VStack(alignment: .leading) {
                Text("키워드 태그")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                KeywordTagsView()
            }
            .padding(.bottom, 5)
            .transition(.opacity.animation(.easeInOut(duration: 0.5)))
        }
        
        representativeMenu(detailMenuDisable: detailMenuDisable)
    }
    
    @ViewBuilder
    func representativeMenu(detailMenuDisable: Bool) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(showDetailInformation ? "메뉴" : "대표메뉴")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                menu(title: "초밥(11P)", price: 20000)
                
                menu(title: "회덮밥(점심)", price: 13500)
                
                menu(title: "이이요 스페셜 카이센동", price: 35000)
                
                if showDetailInformation && !detailMenuDisable {
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
        Button(action: restartAction) {
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
        Button(action: closeAction) {
            Label("닫기", systemImage: "xmark.circle.fill")
                .labelStyle(.iconOnly)
                .font(.largeTitle)
                .foregroundColor(Color("main-point-color"))
                .shadow(color: .black.opacity(0.25), radius: 5)
        }
        .padding(.vertical, 10)
        .padding(.trailing)
    }
    
    @ViewBuilder
    func toolButtons() -> some View {
        VStack(spacing: 10) {
            Group {
                Button {
                    showSelectMapDialog = true
                } label: {
                    Label("지도", systemImage: "location")
                        .labelStyle(.iconOnly)
                        .modifier(ParticleModifier(systemImage: "location", status: showSelectMapDialog))
                }
                .confirmationDialog("지도 선택", isPresented: $showSelectMapDialog) {
                    Button("네이버 지도") {
                        openMapApplication(urlScheme: "nmap://place?id=\(restuarantNaverID)", websiteURL: "https://m.place.naver.com/restaurant/\(restuarantNaverID)/home")
                    }
                    
                    Button("카카오 지도") {
                        openMapApplication(urlScheme: "kakaomap://place?id=\(restuarantKakaoID)", websiteURL: "https://place.map.kakao.com/\(restuarantKakaoID)")
                    }
                }

                
                Button {
                    isSharing = true
                } label: {
                    Label("공유하기", systemImage: "square.and.arrow.up")
                        .labelStyle(.iconOnly)
                        .modifier(ParticleModifier(systemImage: "square.and.arrow.up", status: isSharing))
                }
                .padding(.bottom, 4)
                
                Button {
                    withAnimation(.easeInOut) {
                        isBookmarked.toggle()
                    }
                } label: {
                    Label("즐겨찾기", systemImage: isBookmarked ? "bookmark.fill" : "bookmark")
                        .labelStyle(.iconOnly)
                        .modifier(ParticleModifier(systemImage: "bookmark.fill", status: isBookmarked))
                }
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
        ZStack {
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
            .offset(y: detailImageOffsetY)
            .gesture(
                DragGesture()
                    .onChanged({ drag in
                        closingImages(moveY: drag.translation.height)
                    })
                    .onEnded({ drag in
                        if !(-150...150).contains(drag.translation.height) {
                            closeImages()
                        } else {
                            cancelClosingImages()
                        }
                        
                        resetImagesProperties()
                    })
            )
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: closeImages) {
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
            }
            
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
        .background(.black)
        .opacity(detailImageBackgroundOpacity)
    }
    
    func imageBlurByDragOffset(moveY: CGFloat) {
        if moveY < 0 {
            imageBlur -= (moveY / 5)
        } else {
            imageBlur -= (moveY / 5)
        }
    }
    
    func showingDetailInformation(moveY: CGFloat) {
        if moveY <= 0 {
            imageBlur += 100
            withAnimation(.spring()) {
                showIndicators = false
            }
            
            showDetailInformation = true
        } else {
            informationOffsetY += moveY / 6 00
        }
    }
    
    func openDetailInformation() {
        withAnimation(.spring()) {
            informationOffsetY = .zero
            showIndicators = false
            isDetailInformation = true
        }
        
        withAnimation(.easeInOut) {
            imageBlur = 100
        }
    }
    
    func closeDetailInformation() {
        withAnimation(.spring()) {
            showIndicators = true
            isDetailInformation = false
            informationOffsetY = .zero
            showDetailInformation = false
        }
        
        withAnimation(.easeInOut) {
            imageBlur = 0
        }
    }
    
    func cancelClosingDetailInformation() {
        withAnimation(.spring()) {
            informationOffsetY = .zero
        }
        
        withAnimation(.easeInOut) {
            if isDetailInformation {
                imageBlur = 100
            } else {
                imageBlur = 0
            }
        }
    }
    
    func restartAction() {
        withAnimation(.easeInOut) {
            showInformation = false
            showIndicators = false
            isCherryPick = true
            isCherryPickDone = false
        }
    }
    
    func closeAction() {
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
    }
    
    func closingAction(moveY: CGFloat) {
        opacity = (maxOffsetY - moveY / 5) / maxOffsetY
        
        topButtonsOffsetY = -moveY / 5
        
        toolButtonsOffsetX = moveY / 5
        
        informationOffsetY = moveY / 5
    }
    
    func cancelClosing() {
        withAnimation(.easeInOut) {
            opacity = 1.0
        }
        
        withAnimation(.spring()) {
            topButtonsOffsetY = .zero
            toolButtonsOffsetX = .zero
            informationOffsetY = .zero
        }
    }
    
    func showImagesAction() {
        if !isDetailInformation {
            withAnimation(.spring()) {
                showInformation = false
                showIndicators = false
                showImages = true
            }
        }
    }
    
    func closingImages(moveY: CGFloat) {
        detailImageOffsetY = moveY
        
        if detailImageOffsetY != .zero {
            detailImageBackgroundOpacity = moveY > 0 ? (500 - moveY) / 500 : (500 + moveY) / 500
            
            withAnimation(.spring()) {
                showInformation = true
                showIndicators = true
            }
        }
    }
    
    func closeImages() {
        withAnimation(.spring()) {
            showImages = false
            showInformation = true
            showIndicators = true
        }
        
        imagePage = 0
    }
    
    func cancelClosingImages() {
        withAnimation(.spring()) {
            showInformation = false
            showIndicators = false
        }
    }
    
    func resetImagesProperties() {
        withAnimation(.spring()) {
            detailImageOffsetY = .zero
        }
        
        withAnimation(.easeInOut) {
            detailImageBackgroundOpacity = 1.0
        }
    }
    
    func openMapApplication(urlScheme: String, websiteURL: String) {
        guard let url = URL(string: urlScheme) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            guard let websiteURL = URL(string: websiteURL) else {
                return
            }
            
            UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)
        }
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(isCherryPick: .constant(false), isCherryPickDone: .constant(true))
    }
}
