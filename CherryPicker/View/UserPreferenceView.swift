//
//  UserPreferenceView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/07.
//

import SwiftUI

struct UserPreferenceView: View {
    private let columns = [
        GridItem(.adaptive(minimum: 350, maximum: .infinity), spacing: nil, alignment: .top)
    ]
    
    //임시
    let tagColors = [
        "caffeine-vampire-tag-color",
        "drunkard-tag-color",
        "etc-tag-color",
        "food-explorer-tag-color",
        "healthy-food-tag-color",
        "mini-influencer-tag-color",
        "solo-tag-color"
    ]
    @State private var userPreferenceLoad = false
    @State private var tagsOffsetX = CGFloat.zero
    
    var body: some View {
        ViewThatFits(in: .vertical) {
            content()
            
            ScrollView {
                content()
            }
        }
        .background(Color("background-color"))
        .navigationTitle("취향분석")
    }
    
    @ViewBuilder
    func content() -> some View {
        VStack {
            HStack {
                Text("체리체리1q2w3e님은,")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("main-point-color"))
                
                Spacer()
            }
            .padding(.vertical)
            
            LazyVGrid(columns: columns) {
                userInitialPreference()
                
                userType()
                
                weeklyStats()
                
                weeklyTag()
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
        VStack(alignment: .leading) {
            Text("상위 1%의 취향이에요!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom, 5)
                .padding(.leading, 5)
            
            VStack(alignment: .center, spacing: 15) {
                HStack {
                    Text("체리체리1q2w3e님의 취향태그")
                        .font(.caption)
                        .foregroundColor(Color("secondary-text-color-weak"))
                    
                    Spacer()
                }
                
                Group {
                    Text("음식이 맛있어요")
                        .font(userPreferenceLoad ? .title2 : nil)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("solo-tag-color"))
                    
                    Text("특별한 메뉴가 있어요")
                        .font(userPreferenceLoad ? .title3 : nil)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("food-explorer-tag-color"))
                        .opacity(0.9)
                    
                    Text("재료가 신선해요")
                        .font(userPreferenceLoad ? .headline : nil)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("mini-influencer-tag-color"))
                        .opacity(0.8)
                    
                    Text("친절해요")
                        .font(userPreferenceLoad ? .footnote : nil)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("food-explorer-tag-color"))
                        .opacity(0.7)
                    
                    Text("혼밥하기 좋아요")
                        .font(userPreferenceLoad ? .caption : nil)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("solo-tag-color"))
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
        VStack(alignment: .leading) {
            Text("총 130개의 음식점을 알게 되었어요")
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
                        + Text("30")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                        + Text("번의 체리픽을 받았어요")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Spacer()
                        
                        NavigationLink {
                            RestaurantListView(listMode: .cherryPick)
                        } label: {
                            Text("더보기")
                                .font(.footnote)
                                .foregroundColor(Color("main-point-color"))
                        }
                    }
                    
                    restaurantListElement(title: "이이요", date: "23/04/13")
                    
                    restaurantListElement(title: "하루", date: "23/04/13")
                    
                    restaurantListElement(title: "멕시칼리", date: "23/04/13")
                }
                .padding(.bottom)
                
                VStack {
                    HStack {
                        Text("총 ")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        + Text("100")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color"))
                        + Text("개의 음식점을 즐겨찾기 했어요")
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Spacer()
                        
                        NavigationLink {
                            RestaurantListView(listMode: .bookmark)
                        } label: {
                            Text("더보기")
                                .font(.footnote)
                                .foregroundColor(Color("main-point-color"))
                        }
                    }
                    
                    restaurantListElement(title: "이이요", date: "23/04/13")
                    
                    restaurantListElement(title: "하루", date: "23/04/13")
                    
                    restaurantListElement(title: "멕시칼리", date: "23/04/13")
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
    func tag(title: String, type: String) -> some View {
        Text(title)
            .fontWeight(.bold)
            .padding(.vertical, 10)
            .padding(.horizontal)
            .foregroundColor(.white)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(type))
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
    }
    
    @ViewBuilder
    func weeklyTag() -> some View {
        VStack(alignment: .leading) {
            Text("이번주에 이런 키워드를 찾았어요")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom, 5)
                .padding(.leading, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading) {
                    tags(tagList: ["음식이 빨리 나와요", "신선해요", "술집", "이색맛집", "코스요리 맛집"])
                    
                    tags(tagList: ["혼술 맛집", "감성사진", "로컬맛집", "특별한 날 가기 좋아요", "친절해요"])
                    
                    tags(tagList: ["컨셉이 독특해요", "쾌적한 공간", "술집", "혼밥하기 좋아요", "아늑한 분위기"])
                }
                .padding()
//                .offset(x: tagsOffsetX)
//                .animation(.easeInOut(duration: 30).repeatForever(), value: tagsOffsetX)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                GeometryReader { reader in
                    Color.clear
                        .onAppear {
                            tagsOffsetX = -reader.size.width + reader.safeAreaInsets.top + reader.safeAreaInsets.bottom
                        }
                }
            }
            .background {
                contentBackground()
            }
//            .scrollDisabled(true)
        }
    }
    
    @ViewBuilder
    func tags(tagList: [String]) -> some View {
        LazyHStack {
            ForEach(tagList, id: \.self) { title in
                tag(title: title, type: tagColors.randomElement() ?? "")
            }
        }
    }
}

struct UserPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserPreferenceView()
                .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color("main-point-color"))
    }
}
