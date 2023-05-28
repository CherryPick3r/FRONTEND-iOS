//
//  RestaurantListView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/09.
//

import SwiftUI
import Combine

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
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @FocusState private var searchFocus: Bool
    
    @State var listMode: ListMode
    @State private var subscriptions = Set<AnyCancellable>()
    @State private var seletedFilterTypes = Set<FilterType>()
    @State private var selectedSortType = ListSortType.newest
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showRestaurantDetailView = false
    @State private var shopSimpleList = SimpleShopResponse(shopSimples: ShopSimples())
    @State private var restaurantId: Int?
    @State private var isLoading = true
    @State private var error: APIError?
    @State private var showError = false
    @State private var retryAction: (() -> Void)?
    
    private let columns = [
        GridItem(.adaptive(minimum: 350, maximum: .infinity), spacing: nil, alignment: .top)
    ]
    
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
        .onTapGesture(perform: closeSearching)
        .toolbar {
            if !isSearching {
                ToolbarItem {
                    Button(action: openSearching) {
                        Label("검색", systemImage: "magnifyingglass")
                            .foregroundColor(Color("main-point-color"))
                    }
                }
            }
        }
        .modifier(ErrorViewModifier(showError: $showError, error: $error, retryAction: $retryAction))
        .fullScreenCover(isPresented: $showRestaurantDetailView) {
            if let shopId = restaurantId {
                RestaurantDetailView(isResultView: false, restaurantId: shopId)
            }
        }
        .task {
            fetchList()
        }
        .onChange(of: restaurantId) { newValue in
            showRestaurantDetailView = restaurantId != nil
        }
        .onChange(of: showRestaurantDetailView) { newValue in
            if !newValue {
                restaurantId = nil
            }
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
    func subRestaurant(shop: ShopSimple) -> some View {
        Button {
            restaurantId = shop.id
            
//            showRestaurantDetailView = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .bottom) {
                        Text(shop.shopName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-text-color"))
                        
                        Text(shop.shopCategory)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("secondary-text-color-weak"))
                    }
                    
                    Label(shop.shopAddress, systemImage: "map")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
                    
                    HStack(spacing: 15) {
                        Label("17:30 ~ 24:00", systemImage: "clock")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .light ? Color("main-point-color-weak") : Color("main-point-color"))
                        
                        Text("휴무 : 없음")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color("main-point-color-strong"))
                    }
                }
                
                Spacer()
                
                AsyncImage(url: URL(string: shop.mainPhotoUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Color("main-point-color-weak")
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .clipped()
                .shadow(color: .black.opacity(0.1), radius: 5)
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
        if isLoading {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
                .tint(Color("main-point-color"))
        } else if shopSimpleList.shopSimples.isEmpty {
            Group {
                Spacer()
                
                switch listMode {
                case .cherryPick:
                    Text("아직 체리픽을 이용하지 않으셨나요?")
                        .padding(.bottom)
                    
                    Text("체리픽으로 매장을 추가해보세요!")
                case .bookmark:
                    Text("아직 즐겨찾기한 매장이 없어요.")
                        .padding(.bottom)
                    
                    Text("매장에 책갈피 모양 버튼을 눌러,")
                        .padding(.bottom)
                    
                    Text("즐겨찾기에 추가해보세요!")
                }
            }
            .font(.title3)
            .fontWeight(.bold)
            .foregroundColor(Color("main-point-color"))
        } else {
            LazyVGrid(columns: columns) {
                ForEach(shopSimpleList.shopSimples) { shop in
                    subRestaurant(shop: shop)
                }
            }
            .padding([.horizontal])
        }
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
            
            Button("취소", action: closeSearching)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color("main-point-color"))
                .padding(.trailing)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    func openSearching() {
        withAnimation(.spring()) {
            isSearching = true
        }
        
        searchFocus = true
    }
    
    func closeSearching() {
        searchFocus = false
        
        withAnimation(.spring()) {
            isSearching = false
            searchText = ""
        }
    }
    
    func fetchList() {
        withAnimation(.easeInOut) {
            isLoading = true
        }
        
        retryAction = nil
        
        withAnimation(.spring()) {
            APIError.closeError(showError: &showError, error: &error)
        }
        
        APIFunction.fetchShopSimples(token: userViewModel.readToken, userEmail: userViewModel.readUserEmail, gameCategory: 0 , isResultRequest: listMode == .cherryPick, subscriptions: &subscriptions) { simpleShopResponse in
            shopSimpleList = simpleShopResponse
            
            withAnimation(.easeInOut) {
                isLoading = false
            }
        } errorHandling: { apiError in
            retryAction = fetchList
            withAnimation(.spring()) {
                APIError.showError(showError: &showError, error: &error, catchError: apiError)
            }
        }

    }
}

struct RestaurantListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RestaurantListView(listMode: .cherryPick)
                .navigationBarTitleDisplayMode(.inline)
                .environmentObject(UserViewModel())
        }
    }
}
