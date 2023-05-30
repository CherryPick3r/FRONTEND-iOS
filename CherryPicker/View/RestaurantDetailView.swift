//
//  RestaurantDetailView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/03.
//

import SwiftUI
import Combine

struct RestaurantDetailView: View {
    @Namespace var heroEffect
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isCherryPick: Bool
    @Binding var isCherryPickDone: Bool
    
    private let isResultView: Bool
    private let maxOffsetY = CGFloat(250)
    
    @State private var subscriptions = Set<AnyCancellable>()
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
    @State private var showDetailMenu = false
    @State private var showDetailHours = false
    @State private var maxVelocity = CGFloat.zero
    @State private var isLoading = true
    @State private var subMenus = MenuSimples()
    @State private var error: APIError?
    @State private var showError = false
    @State private var retryAction: (() -> Void)?
    @State private var imagePage = 0
    @State private var isClipped = false
    @State private var restaurant = ShopDetailResponse.preview
    
    private let restaurantId: Int
    
    //임시
    @State private var isSharing = false
    
    init(isCherryPick: Binding<Bool> = .constant(false), isCherryPickDone: Binding<Bool> = .constant(false), isResultView: Bool = true, restaurantId: Int) {
        self._isCherryPick = isCherryPick
        self._isCherryPickDone = isCherryPickDone
        self.isResultView = isResultView
        self.restaurantId = restaurantId
    }
    
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            let topSafeArea = reader.safeAreaInsets.top
            let bottomSafeArea = reader.safeAreaInsets.bottom
            
            ZStack {
                if !showImages {
                    backgroundImage()
                        .frame(width: reader.size.width, height: height + topSafeArea + bottomSafeArea)
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
                        .padding(.top, topSafeArea)
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
                        information(height: height - (topSafeArea + bottomSafeArea + 30))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .redacted(reason: isLoading ? [.placeholder] : [])
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
            .ignoresSafeArea()
            .overlay(alignment: .top) {
                if showImages {
                    images()
                }
            }
            .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
            .task {
                fetchRestaurant()
                
                print(restaurantId)
            }
            .onAppear() {
                withAnimation(.spring()) {
                    showInformation = true
                    showIndicators = true
                }
            }
            
        }
    }
    
    @ViewBuilder
    func imageShadowOverlay() -> some View {
        ZStack {
            if !showDetailInformation {
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
        Group {
            if let mainPhotoURL = restaurant.shopMainPhotoURLs.first {
                AsyncImage(url: URL(string: mainPhotoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .matchedGeometryEffect(id: mainPhotoURL, in: heroEffect)
                } placeholder: {
                    imageLoading()
                }
            } else {
                ZStack {
                    Color("background-color")
                    
                    Text("제공되는 이미지가 존재하지 않아요.")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("main-point-color"))
                        .padding(.bottom, 250)
                }
            }
        }
        .overlay {
            imageShadowOverlay()
        }
        .blur(radius: 20 * imageBlur / 100)
        .onTapGesture(perform: showImagesAction)
    }
    
    @ViewBuilder
    func information(height: CGFloat) -> some View {
        let isNoneNotchiPhone = height == 597
        
        VStack(alignment: .leading, spacing: isNoneNotchiPhone ? 10 : 15) {
            informationContent(detailSubMenuDisable: isNoneNotchiPhone)
        }
        .padding(isNoneNotchiPhone ? 15 : 20)
        .padding(.bottom, showDetailInformation ? 0 : (isNoneNotchiPhone ? 10 : 15))
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.25), radius: 5)
                .background {
                    if showDetailMenu || showDetailHours {
                        cherryPickCountInformation()
                    }
                }
        }
        .overlay {
            if !showDetailMenu && !showDetailHours {
                cherryPickCountInformation()
            }
        }
        .overlay(alignment: .top) {
            if showDetailMenu {
                detailMenu()
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
                    .opacity(showDetailMenu ? 1 : 0)
                    .padding([.horizontal, .top], isNoneNotchiPhone ? 15 : 20)
            }
            
            if showDetailHours {
                detailHours()
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 0, y: 1, z: 0))
                    .opacity(showDetailHours ? 1 : 0)
                    .padding([.horizontal, .top], isNoneNotchiPhone ? 15 : 20)
            }
        }
        .rotation3DEffect(Angle(degrees: (showDetailMenu || showDetailHours) ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.8)
        .offset(y: informationOffsetY)
        .frame(maxWidth: 500)
        .padding(.top)
        .gesture(
            DragGesture()
                .onChanged({ drag in
                    DispatchQueue.global(qos: .userInteractive).async {
                        let moveY = drag.translation.height
                        let velocity = informationOffsetY - moveY
                        
                        if showDetailMenu || isLoading {
                            informationOffsetY = moveY / 3
                        } else {
                            calculateMaxVelocity(velocity: velocity)
                            
                            imageBlurByDragOffset(velocity: velocity)
                            
                            if showDetailInformation {
                                informationOffsetY = (informationOffsetY <= 0 && velocity >= 0) ? moveY / 3 : moveY
                            } else {
                                showingDetailInformation(moveY: moveY)
                            }
                        }
                    }
                })
                .onEnded({ drag in
                    DispatchQueue.global(qos: .userInteractive).async {
                        if showDetailMenu {
                            withAnimation(.spring()) {
                                informationOffsetY = .zero
                            }
                        } else {
                            if showDetailInformation {
                                if (informationOffsetY < 400 && maxVelocity >= 0) || maxVelocity >= 30 {
                                    openDetailInformation()
                                } else if (informationOffsetY > 150 && maxVelocity <= 0) || maxVelocity <= -30 {
                                    closeDetailInformation()
                                } else {
                                    cancelClosingDetailInformation()
                                }
                            } else {
                                withAnimation(.spring()) {
                                    informationOffsetY = .zero
                                }
                            }
                        }
                        
                        maxVelocity = CGFloat.zero
                    }
                })
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func cherryPickCountInformation() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Text("총 \(restaurant.totalCherryPickCount)명이 체리픽 받았어요!")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("shape-light-color"))
                    .opacity(showDetailMenu || showDetailHours ? 0 : 1)
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
    
    @ViewBuilder
    func informationContent(detailSubMenuDisable: Bool) -> some View {
        Group {
            HStack(alignment: .bottom) {
                Text(restaurant.shopName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-text-color"))
                
                Text(restaurant.shopCategory)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-point-color-weak"))
                    .padding(.bottom, 5)
                
                Spacer()
            }
            
            Text(restaurant.oneLineReview)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("secondary-text-color-strong"))
            
            VStack(alignment: .leading, spacing: showDetailInformation ? 15 : 5) {
                Label(restaurant.shopAddress, systemImage: "map")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
                
                HStack {
                    Label("오늘 : \(restaurant.todayHour ?? "정보가 없어요.")", systemImage: "clock")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
                    
                    if let regularHoliday = restaurant.regularHoliday {
                        Text(regularHoliday)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("main-point-color-strong"))
                    }
                    
                    Spacer()
                    
                    if showDetailInformation && restaurant.operatingHoursArray != nil {
                        moreButton {
                            withAnimation(.spring()) {
                                showDetailHours = true
                            }
                        }
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                
                if showDetailInformation {
                    VStack(alignment: .leading) {
                        Text("키워드 태그")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                        
                        KeywordTagsView(topTags: .constant(restaurant.topTags))
                    }
                    .padding(.bottom, 5)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                }
            }
            
            representativeMenu(detailSubMenuDisable: detailSubMenuDisable)
        }
        .opacity(showDetailMenu || showDetailHours ? 0 : 1)
    }
    
    @ViewBuilder
    func representativeMenu(detailSubMenuDisable: Bool) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(showDetailInformation ? "메뉴" : "대표메뉴")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
                
                if showDetailInformation && restaurant.shopMenus.count > 5 {
                    moreButton {
                        withAnimation(.spring()) {
                            showDetailMenu = true
                        }
                    }
                }
            }
            
            VStack(spacing: 10) {
                ForEach(subMenus, id: \.name) { menuSimple in
                    menu(title: menuSimple.name, price: menuSimple.price)
                }
            }
        }
        .onAppear() {
            updateSubMenus(detailSubMenuDisable: detailSubMenuDisable)
        }
        .onChange(of: showDetailInformation) { newValue in
            updateSubMenus(detailSubMenuDisable: detailSubMenuDisable)
        }
    }
    
    @ViewBuilder
    func moreButton(action: @escaping () -> Void) -> some View {
        Button("더보기", action: action)
            .font(.footnote)
            .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
    }
    
    @ViewBuilder
    func detailHours() -> some View {
        VStack {
            HStack {
                Text("영업시간")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        showDetailHours = false
                    }
                } label: {
                    Label("닫기", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .foregroundColor(Color("main-point-color"))
                        .shadow(color: .black.opacity(0.25), radius: 5)
                }

            }
            
            if let hours = restaurant.operatingHoursArray {
                ViewThatFits(in: .vertical) {
                    LazyVStack(spacing: 10) {
                        ForEach(hours.indices) { index in
                            HStack {
                                Text(hours[index])
                                
                                Spacer()
                            }
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-text-color"))
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(hours.indices) { index in
                                HStack {
                                    Text(hours[index])
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-text-color"))
                }
            }
        }
    }
    
    @ViewBuilder
    func detailMenu() -> some View {
        VStack {
            HStack {
                Text("메뉴")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        showDetailMenu = false
                    }
                } label: {
                    Label("닫기", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.largeTitle)
                        .foregroundColor(Color("main-point-color"))
                        .shadow(color: .black.opacity(0.25), radius: 5)
                }

            }
            
            ViewThatFits(in: .vertical) {
                LazyVStack(spacing: 10) {
                    ForEach(restaurant.shopMenus, id: \.name) { menuSimple in
                        menu(title: menuSimple.name, price: menuSimple.price)
                    }
                }
                .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-text-color"))
                
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(restaurant.shopMenus, id: \.name) { menuSimple in
                            menu(title: menuSimple.name, price: menuSimple.price)
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-text-color"))
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
                }
                .confirmationDialog("지도 선택", isPresented: $showSelectMapDialog) {
                    Button("네이버 지도") {
                        openMapApplication(urlScheme: "nmap://place?id=\(restaurant.shopNaverId)", websiteURL: "https://m.place.naver.com/restaurant/\(restaurant.shopNaverId)/home")
                    }
                    
                    Button("카카오 지도") {
                        openMapApplication(urlScheme: "kakaomap://place?id=\(restaurant.shopKakaoId)", websiteURL: "https://place.map.kakao.com/\(restaurant.shopKakaoId)")
                    }
                }
                
                
                Button {
                    let activityViewController = UIActivityViewController(activityItems: ["https://m.place.naver.com/restaurant/\(restaurant.shopNaverId)/home"], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                } label: {
                    Label("공유하기", systemImage: "square.and.arrow.up")
                        .labelStyle(.iconOnly)
                }
                .padding(.bottom, 4)
                
                Button {
                    clippingAction()
                } label: {
                    Label("즐겨찾기", systemImage: isClipped ? "bookmark.fill" : "bookmark")
                        .labelStyle(.iconOnly)
                        .modifier(ParticleModifier(systemImage: "bookmark.fill", status: isClipped))
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
        .disabled(isLoading || showError)
    }
    
    @ViewBuilder
    func images() -> some View {
        ZStack {
            TabView(selection: $imagePage) {
                ForEach(restaurant.shopMainPhotoURLs, id: \.hashValue) { photoURL in
                    AsyncImage(url: URL(string: photoURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: photoURL, in: heroEffect)
                    } placeholder: {
                        imageLoading()
                    }
                    .tag(restaurant.shopMainPhotoURLs.firstIndex(of: photoURL) ?? 0)
                }
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
                if imagePage != 0 {
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
                
                if imagePage != restaurant.shopMainPhotoURLs.endIndex - 1 {
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
    
    @ViewBuilder
    func imageLoading() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                    .tint(Color("main-point-color"))
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    func calculateMaxVelocity(velocity: CGFloat) {
        if velocity < 0 {
            maxVelocity = velocity < maxVelocity ? velocity : maxVelocity
        } else {
            maxVelocity = velocity > maxVelocity ? velocity : maxVelocity
        }
    }
    
    func imageBlurByDragOffset(velocity: CGFloat) {
        if showDetailInformation {
            if velocity >= 0 {
                imageBlur += imageBlur < 100 ? velocity / 5 : 0
            } else {
                imageBlur += imageBlur > 0 ? velocity / 5 : 0
            }
        } else {
            imageBlur = 0
        }
    }
    
    func showingDetailInformation(moveY: CGFloat) {
        if maxVelocity >= 0 {
            withAnimation(.spring()) {
                showIndicators = false
            }
            
            showDetailInformation = true
        } else {
            informationOffsetY = moveY / 3
        }
    }
    
    func openDetailInformation() {
        withAnimation(.spring()) {
            informationOffsetY = .zero
            showIndicators = false
        }
        
        withAnimation(.easeInOut) {
            imageBlur = 100
        }
    }
    
    func closeDetailInformation() {
        withAnimation(.easeInOut) {
            imageBlur = 0
        }
        withAnimation(.spring()) {
            showIndicators = true
            informationOffsetY = .zero
            showDetailInformation = false
        }
    }
    
    func cancelClosingDetailInformation() {
        withAnimation(.spring()) {
            informationOffsetY = .zero
        }
        
        withAnimation(.easeInOut) {
            imageBlur = showDetailInformation ? 100 : 0
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
        let reduceMoveY = moveY / 5
        
        opacity = (maxOffsetY - reduceMoveY) / maxOffsetY
        
        topButtonsOffsetY = -reduceMoveY
        
        toolButtonsOffsetX = reduceMoveY
        
        informationOffsetY = reduceMoveY
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
        guard !showError || !restaurant.shopMainPhotoURLs.isEmpty else {
            return
        }
        
        if !showDetailInformation {
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
    
    func updateSubMenus(detailSubMenuDisable: Bool) {
        subMenus.removeAll()
        
        for (index, menuSimple) in restaurant.shopMenus.enumerated() {
            if index <= (showDetailInformation ? (detailSubMenuDisable ? 2 : 4) : 2) {
                subMenus.append(menuSimple)
            } else {
                break
            }
        }
    }
    
    func fetchRestaurant() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        retryAction = nil
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        print(userViewModel.readToken)
        print(restaurantId)
        print(userViewModel.readUserEmail)
        
        APIFunction.fetchShopDetail(token: userViewModel.readToken, shopId: restaurantId, userEmail: userViewModel.readUserEmail, subscriptions: &subscriptions) { shopDetailResponse in
            restaurant = shopDetailResponse
            
            isClipped = restaurant.shopClipping == .isClipped
            
            withAnimation(.easeInOut) {
                isLoading = false
            }
        } errorHandling: { apiError in
            retryAction = fetchRestaurant
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
    
    func clippingAction() {
        retryAction = nil
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.doOrUndoClipping(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, shopId: restaurant.shopId, isClipped: isClipped, subscriptions: &subscriptions) { _ in
            isClipped = !isClipped
        } errorHanding: { apiError in
            retryAction = clippingAction
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailView(isCherryPick: .constant(false), isCherryPickDone: .constant(true), restaurantId: 3)
            .environmentObject(UserViewModel())
    }
}
