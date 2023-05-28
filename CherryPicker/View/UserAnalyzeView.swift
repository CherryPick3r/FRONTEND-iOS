//
//  UserPreferenceView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/07.
//

import SwiftUI
import Combine

struct UserAnalyzeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var userPreferenceLoad = false
    @State private var tagsOffsetX = CGFloat.zero
    @State private var userAnalyze = UserAnalyzeResponse.preview
    @State private var isLoading = true
    @State private var error: APIError?
    @State private var showError = false
    @State private var retryAction: (() -> Void)?
    
    private let columns = [
        GridItem(.adaptive(minimum: 350, maximum: .infinity), spacing: nil, alignment: .top)
    ]
    
    var body: some View {
        ViewThatFits(in: .vertical) {
            content()
            
            ScrollView {
                content()
            }
        }
        .background(Color("background-color"))
        .navigationTitle("취향분석")
        .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
        .task {
            fetchUserAnalyze()
        }
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack {
            HStack {
                Text("\(userAnalyze.userNickname)님은,")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            .padding(.vertical)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                    .tint(Color("main-point-color"))
            } else {
                LazyVGrid(columns: columns) {
                    userInitialPreference()
                    
                    userType()
                    
                    weeklyStats()
                    
                    if !userAnalyze.weeklyTags.isEmpty {
                        weeklyTag()
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func contentBackground() -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color("background-shape-color"))
            .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    @ViewBuilder
    func userInitialPreference() -> some View {
        let tag1 = TagTitle.allCases.randomElement() ?? .comfortableSpace
        let tag2 = TagTitle.allCases.randomElement() ?? .comfortableSpace
        let tag3 = TagTitle.allCases.randomElement() ?? .comfortableSpace
        let tag4 = TagTitle.allCases.randomElement() ?? .comfortableSpace
        let tag5 = TagTitle.allCases.randomElement() ?? .comfortableSpace
        
        VStack(alignment: .leading) {
            Text("상위 \(userAnalyze.userPercentile)%의 취향이에요!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom, 5)
                .padding(.leading, 5)
            
            VStack(alignment: .center, spacing: 15) {
                HStack {
                    Text("\(userAnalyze.userNickname)님의 취향태그")
                        .font(.caption)
                        .foregroundColor(Color("secondary-text-color-weak"))
                    
                    Spacer()
                }
                
                Group {
                    Text(tag1.rawValue)
                        .modifier(TagTitleColorModifier(text: tag1.rawValue, font: userPreferenceLoad ? .title2 : nil, colors: tag1.tagColor))
                    
                    Text(tag2.rawValue)
                        .modifier(TagTitleColorModifier(text: tag2.rawValue, font: userPreferenceLoad ? .title3 : nil, colors: tag2.tagColor))
                        .opacity(0.9)
                    
                    Text(tag3.rawValue)
                        .modifier(TagTitleColorModifier(text: tag3.rawValue, font: userPreferenceLoad ? .subheadline : nil, colors: tag3.tagColor))
                        .opacity(0.8)
                    
                    Text(tag4.rawValue)
                        .modifier(TagTitleColorModifier(text: tag4.rawValue, font: userPreferenceLoad ? .footnote : nil, colors: tag4.tagColor))
                        .opacity(0.7)
                    
                    Text(tag5.rawValue)
                        .modifier(TagTitleColorModifier(text: tag5.rawValue, font: userPreferenceLoad ? .caption : nil, colors: tag5.tagColor))
                        .opacity(0.6)
                }
                .shadow(color: .black.opacity(0.1), radius: 10)
            }
            .padding()
            .background {
                contentBackground()
            }
            .padding(.bottom, 20)
            .onAppear() {
                withAnimation(.spring(response: 1.5)) {
                    userPreferenceLoad = true
                }
            }
        }
    }
    
    @ViewBuilder
    func userType() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text("혹시...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Text(" 맛집탐방러")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("food-explorer-tag-color"))
                
                Text("이신가요?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            .padding(.bottom, 5)
            .padding(.leading, 5)
            
            VStack(alignment: .leading) {
                Text("체리체리1q2w3e님의 즐겨찾기 목록 분석 결과, ")
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-text-color"))
                + Text("맛집탐방러")
                    .fontWeight(.bold)
                    .foregroundColor(Color("food-explorer-tag-color"))
                + Text(" 유형과 비슷해요!")
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-text-color"))
                
                VStack {
                    RadarChartView(data: [0.8, 0.2, 0.1, 0.15, 0.4, 0.3, 0.5], gridColor: Color("main-point-color-weak").opacity(0.8), dataColor: Color("main-point-color"), gridLineWidth: 0.5, dataLineWidth: 1, labels: ["맛집탐방러", "미니인플루언서", "건강식", "기타", "카페인 뱀파이어", "혼밥러", "술고래"])
                        .frame(height: 150)
                }
                .padding(.vertical, 40)
            }
            .padding()
            .background {
                contentBackground()
            }
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    func weeklyStats() -> some View {
        let subCherryPicks = userAnalyze.cherrypickCount < 3 ? userAnalyze.recentCherrypickShops[0..<userAnalyze.cherrypickCount] : userAnalyze.recentCherrypickShops[0..<3]
        
        let subClippingShops = userAnalyze.clippingCount < 3 ? userAnalyze.recentClippingShops[0..<userAnalyze.clippingCount] : userAnalyze.recentClippingShops[0..<3]
        
        VStack(alignment: .leading) {
            Text("총 \(userAnalyze.cherrypickClippingTotalCount)개의 음식점을 알게 되었어요")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom, 5)
                .padding(.leading, 5)
            
            VStack {
                VStack {
                    HStack {
                        Text("총 ")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        + Text("\(userAnalyze.cherrypickCount)")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                        + Text("번의 체리픽을 받았어요")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Spacer()
                        
                        if userAnalyze.recentCherrypickShops.count > 0 {
                            NavigationLink {
                                RestaurantListView(listMode: .cherryPick)
                            } label: {
                                Text("더보기")
                                    .font(.footnote)
                                    .foregroundColor(Color("main-point-color"))
                            }
                        }
                    }
                    
                    ForEach(Array(subCherryPicks)) { cherrypick in
                        restaurantListElement(title: cherrypick.shopName, date: "23/04/13")
                    }
                }
                .padding(.bottom)
                
                VStack {
                    HStack {
                        Text("총 ")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        + Text("\(userAnalyze.clippingCount)")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                        + Text("개의 음식점을 즐겨찾기 했어요")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Spacer()
                        
                        if userAnalyze.recentClippingShops.count > 0 {
                            NavigationLink {
                                RestaurantListView(listMode: .bookmark)
                            } label: {
                                Text("더보기")
                                    .font(.footnote)
                                    .foregroundColor(Color("main-point-color"))
                            }
                        }
                    }
                    
                    ForEach(Array(subClippingShops)) { clippingShop in
                        restaurantListElement(title: clippingShop.shopName, date: "23/04/13")
                    }
                }
            }
            .padding()
            .background {
                contentBackground()
            }
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    func restaurantListElement(title: String, date: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
            
            Spacer()
            
            Text(date)
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundColor(Color("secondary-text-color-strong"))
        }
        .padding(5)
        .background(alignment: .bottom) {
            Rectangle()
                .fill(Color("secondary-text-color-weak"))
                .frame(height: 0.5)
        }
    }
    
    @ViewBuilder
    func tag(tag: TagTitle) -> some View {
        Text(tag.rawValue)
            .fontWeight(.bold)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .foregroundColor(.white)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(gradient: Gradient(colors: tag.tagColor), startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
    }
    
    @ViewBuilder
    func weeklyTag() -> some View {
        let weeklyTagsCount = userAnalyze.weeklyTags.count
        let count = Int(floor(Double(weeklyTagsCount) / 3.0))
        let firstLineeTags = count == 0 ? userAnalyze.weeklyTags : Array(userAnalyze.weeklyTags[0..<count])
        let secondeLineTags = count == 0 ? nil : userAnalyze.weeklyTags[count..<count * 2]
        let thirdLineTags = count == 0 ? nil : userAnalyze.weeklyTags[count * 2..<weeklyTagsCount]
        
        VStack(alignment: .leading) {
            Text("이번주에 이런 키워드를 찾았어요")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom, 5)
                .padding(.leading, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading) {
                    tags(tags: firstLineeTags)
                    
                    if let sceond = secondeLineTags {
                        tags(tags: Array(sceond))
                    }
                    
                    if let third = thirdLineTags {
                        tags(tags: Array(third))
                    }
                }
                .padding()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .background {
                contentBackground()
            }
        }
    }
    
    @ViewBuilder
    func tags(tags: [TagTitle]) -> some View {
        LazyHStack {
            ForEach(tags, id: \.self) { tagTitle in
                tag(tag: tagTitle)
            }
        }
    }
    
    func fetchUserAnalyze() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        retryAction = nil
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.fetchUserAnalyze(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, subscriptions: &subscriptions) { userAnalyzeResponse in
            userAnalyze = userAnalyzeResponse
            
            withAnimation(.easeInOut) {
                isLoading = false
            }
        } errorHandling: { apiError in
            retryAction = fetchUserAnalyze
            
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }

    }
}

struct UserAnalyzeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserAnalyzeView()
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(UserViewModel())
        }
        .tint(Color("main-point-color"))
    }
}
