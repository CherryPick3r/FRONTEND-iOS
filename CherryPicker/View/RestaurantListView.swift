//
//  RestaurantListView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/09.
//

import SwiftUI

enum ListMode: String {
    case cherryPick = "체리픽"
    case bookmark = "즐겨찾기"
}

enum FilterType: String {
    case open = "영업중"
    case restaurant = "음식점"
    case cafe = "카페/디저트"
    case bar = "술집"
}

enum ListSortType: String {
    case newest = "최신순"
    case oldest = "오래된순"
    case ascendingName = "이름순"
    case byDistance = "거리순"
}

struct RestaurantListView: View {
    private let columns = [
        GridItem(.adaptive(minimum: 350, maximum: .infinity), spacing: nil, alignment: .top)
    ]
    
    @FocusState private var searchFocus: Bool
    
    @State private var listMode: ListMode
    @State private var seletedFilterTypes = Set<FilterType>()
    @State private var selectedSortType = ListSortType.newest
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showRestaurantDetailView = false
    
    init(listMode: ListMode) {
        self.listMode = listMode
    }
    
    var body: some View {
        VStack {
            if isSearching {
                searchBar()
            }
            
            filterButtonsBar()
            
            listSortMenu()
            
            ViewThatFits(in: .vertical) {
                VStack {
                    list()
                    
                    Spacer()
                }
                
                ScrollView {
                    list()
                }
            }
        }
        .modifier(BackgroundModifier())
        .navigationTitle(listMode.rawValue)
        .toolbar {
            if !isSearching {
                ToolbarItem {
                    Button {
                        withAnimation(.spring()) {
                            isSearching = true
                        }
                        
                        searchFocus = true
                    } label: {
                        Label("검색", systemImage: "magnifyingglass")
                            .foregroundColor(Color("main-point-color"))
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showRestaurantDetailView) {
            RestaurantDetailView(isResultView: false)
        }
    }
    
    @ViewBuilder
    func filterButton(filterType: FilterType) -> some View {
        let isSelected = seletedFilterTypes.contains(filterType)
        
        Button {
            withAnimation(.easeInOut) {
                if isSelected {
                    seletedFilterTypes.remove(filterType)
                } else {
                    seletedFilterTypes.insert(filterType)
                }
            }
        } label: {
            Text(filterType.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? Color("background-shape-color") : Color("main-point-color"))
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("main-point-color"))
                            .shadow(color: .black.opacity(0.1), radius: 3)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("background-shape-color"))
                            
                            
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color("main-point-color"), lineWidth: 2)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 3)
                    }
                }
        }
    }
    
    @ViewBuilder
    func filterButtonsBar() -> some View {
        HStack(spacing: 20) {
            filterButton(filterType: .open)
            
            filterButton(filterType: .restaurant)
            
            filterButton(filterType: .cafe)
            
            filterButton(filterType: .bar)
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    func listSortMenu() -> some View {
        HStack {
            Spacer()
            
            Menu {
                Picker(selection: $selectedSortType, label: Text(selectedSortType.rawValue)) {
                    listSortElement(listSortType: .newest)
                    
                    listSortElement(listSortType: .oldest)
                    
                    listSortElement(listSortType: .ascendingName)
                    
                    listSortElement(listSortType: .byDistance)
                }
            } label: {
                HStack(spacing: 5) {
                    Text(selectedSortType.rawValue)
                    
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
            .font(.subheadline)
            .tint(Color("main-point-color"))
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func listSortElement(listSortType: ListSortType) -> some View {
        HStack {
            Text(listSortType.rawValue)
        }
        .tag(listSortType)
    }
    
    @ViewBuilder
    func subRestaurant() -> some View {
        Button {
            showRestaurantDetailView = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .bottom) {
                        Text("하루")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Text("이자카야")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("secondary-text-color-weak"))
                    }
                    
                    Label("서울 광진구 면목로 53 1층", systemImage: "map")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("main-point-color-weak"))
                    
                    HStack(spacing: 15) {
                        Label("17:30 ~ 24:00", systemImage: "clock")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("main-point-color-weak"))
                        
                        Text("휴무 : 없음")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color-strong"))
                    }
                }
                
                Spacer()
                
                Image("restaurant-sample3")
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .frame(width: 100, height: 100)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("background-shape-color"))
                    .shadow(color: .black.opacity(0.1), radius: 5)
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    func list() -> some View {
        LazyVGrid(columns: columns) {
            ForEach(0..<12, id: \.self) { index in
                subRestaurant()
            }
        }
        .padding([.horizontal])
    }
    
    @ViewBuilder
    func searchBar() -> some View {
        HStack(spacing: 0) {
            TextField("검색", text: $searchText, prompt: Text("검색하기"))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($searchFocus)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color("background-shape-color"))
                        .shadow(color: .black.opacity(0.1), radius: 2)
                }
                .onSubmit {
                    withAnimation(.spring()) {
                        searchFocus = false
                    }
                }
                .overlay(alignment: .trailing) {
                    if searchText != "" {
                        Button {
                            withAnimation(.easeInOut) {
                                searchText = ""
                            }
                        } label: {
                            Label("삭제", systemImage: "xmark.circle.fill")
                                .labelStyle(.iconOnly)
                                .foregroundColor(Color("secondary-text-color-weak"))
                        }
                        .padding(.trailing, 10)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .tint(Color("main-point-color"))
            
            Button("취소") {
                searchFocus = false
                
                withAnimation(.spring()) {
                    isSearching = false
                    searchText = ""
                }
            }
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(Color("main-point-color"))
            .padding(.trailing)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RestaurantListView(listMode: .cherryPick)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
