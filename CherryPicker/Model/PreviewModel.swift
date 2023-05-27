//
//  PreviewModel.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

extension TagPair {
    static var preview: TopTags {
        var tags = TopTags()
        var totalPercentile = 100.0
        var currentPercentile = 0.0
        
        for _ in 0..<5 {
            currentPercentile = Double.random(in: 0.0...totalPercentile)
            tags.append(TagPair(description: TagTitle.allCases.randomElement()?.rawValue ?? "", value: currentPercentile))
            totalPercentile -= currentPercentile
        }
        
        return tags.sorted { lhs, rhs in
            return lhs.value > rhs.value
        }
    }
}

extension ShopCardResponse {
    static var preview: ShopCardResponse {
        return ShopCardResponse(shopId: 1, shopMainPhoto1: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyMzA1MjRfMzAw%2FMDAxNjg0ODg3NTUyMjgx.Qn57svOeG3hKWKnZ_KhwHmt4dtEM1tt249C9hY1bGIog.KIDM7JD12qAIoGzdTkEqkFat0uIGJZvkK_14lCWZd50g.JPEG%2FIMG_7106.jpeg", shopMainPhoto2: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyMzA1MjFfMTQ3%2FMDAxNjg0NjUwOTY2NDg5.fxWxtx6LQ8GYxlLuUw5w1fOFU-GwK6qrBU1n9WrPm5gg.txLdPEFPBXxkMNw7Nk-dFx1FiyrTxZwKk1Pa1Rbzl7Ig.JPEG%2F474CB7D3-B7A6-4AC6-A2DC-458B927E31D6.jpeg", shopName: "이이요", shopCategory: "일식당", oneLineReview: "식사로도 좋고 간술하기에도 좋은 이자카야 \"이이요\"", topTags: TagPair.preview, shopClipping: .isNotClipped)
    }
}

extension ShopCardResponses {
    static var preview: ShopCardResponses {
        var shopCards = ShopCardResponses()
        
        for _ in 0..<3 {
            shopCards.append(ShopCardResponse(shopId: 1, shopMainPhoto1: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyMzA1MjRfMzAw%2FMDAxNjg0ODg3NTUyMjgx.Qn57svOeG3hKWKnZ_KhwHmt4dtEM1tt249C9hY1bGIog.KIDM7JD12qAIoGzdTkEqkFat0uIGJZvkK_14lCWZd50g.JPEG%2FIMG_7106.jpeg", shopMainPhoto2: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyMzA1MjFfMTQ3%2FMDAxNjg0NjUwOTY2NDg5.fxWxtx6LQ8GYxlLuUw5w1fOFU-GwK6qrBU1n9WrPm5gg.txLdPEFPBXxkMNw7Nk-dFx1FiyrTxZwKk1Pa1Rbzl7Ig.JPEG%2F474CB7D3-B7A6-4AC6-A2DC-458B927E31D6.jpeg", shopName: "이이요", shopCategory: "일식당", oneLineReview: "식사로도 좋고 간술하기에도 좋은 이자카야 \"이이요\"", topTags: TagPair.preview, shopClipping: .isNotClipped))
        }
        
        return shopCards
    }
}

extension GameResponse {
    static var preview: GameResponse {
        return GameResponse(gameId: 1, totalRound: 1, curRound: 1, gameStatus: 1, recommendShopIds: [1, 1, 1], recommendShops: ShopCardResponses.preview)
    }
}

extension MenuSimple {
    static var preview: MenuSimples {
        return [
            MenuSimple(name: "초밥(11P)", price: 20000),
            MenuSimple(name: "회덮밥(점심)", price: 13500),
            MenuSimple(name: "이이요 스페셜 카이센동", price: 35000),
            MenuSimple(name: "야끼돈부리", price: 16000),
            MenuSimple(name: "도미연어덮밥", price: 16500),
            MenuSimple(name: "모둠사시미(저녁)", price: 39000),
            MenuSimple(name: "스끼야끼나베(저녁))", price: 25000),
            MenuSimple(name: "연어샐러드", price: 22000),
            MenuSimple(name: "타코와사비", price: 8000),
            MenuSimple(name: "가지와아게다시도후", price: 10000),
            MenuSimple(name: "간장새우(5pcs)", price: 12000),
            MenuSimple(name: "모듬낫또", price: 18000),
            MenuSimple(name: "모듬사시미 3~4인", price: 56000),
            MenuSimple(name: "모듬사시미 2~3", price: 39000),
            MenuSimple(name: "흰살생선삼합", price: 35000),
            MenuSimple(name: "흰살생선사시미", price: 35000),
            MenuSimple(name: "흰살생선과 연어사시미", price: 35000),
            MenuSimple(name: "연어사시미", price: 35000),
            MenuSimple(name: "이이요초밥 10P", price: 20000),
            MenuSimple(name: "이이요초밥 7P", price: 15000),
            MenuSimple(name: "묵은지광어초밥 6P", price: 16000),
            MenuSimple(name: "광어초밥 6P", price: 16000),
            MenuSimple(name: "광어와 연어초밥 6P", price: 16000),
            MenuSimple(name: "묵은지광어와 연어초밥 6P", price: 15000),
            MenuSimple(name: "새우장초밥 4P", price: 12000)
        ]
    }
}

extension ShopDetailResponse {
    static var preview: ShopDetailResponse {
        return ShopDetailResponse(shopId: 1, shopName: "이이요", shopCategory: "일식당", oneLineReview: "식사로도 좋고 간술하기에도 좋은 이자카야 \"이이요\"", shopAddress: "서울 광진구 능동로19길 36 1층", totalCherryPickCount: Int.random(in: 10...1000), operatingHours: "", topTags: TagPair.preview, shopClipping: .isNotClipped, shopMenus: MenuSimple.preview, shopMainPhotoURLs: ["", "", ""], shopNaverId: 38738686, shopKakaoId: 861945610)
    }
}

extension ShopSimple {
    static var preview: ShopSimples {
        var shops = ShopSimples()
        
        for i in 0..<20 {
            shops.append(ShopSimple(id: i, shopName: "이이요", shopCategory: "일식장", shopAddress: "서울 광진구 능동로19길 36 1층", operatingHours: "", mainPhotoUrl: "https://search.pstatic.net/common/?src=https%3A%2F%2Fpup-review-phinf.pstatic.net%2FMjAyMzA1MjFfMTQ3%2FMDAxNjg0NjUwOTY2NDg5.fxWxtx6LQ8GYxlLuUw5w1fOFU-GwK6qrBU1n9WrPm5gg.txLdPEFPBXxkMNw7Nk-dFx1FiyrTxZwKk1Pa1Rbzl7Ig.JPEG%2F474CB7D3-B7A6-4AC6-A2DC-458B927E31D6.jpeg"))
        }
        
        return shops
    }
}

extension UserAnalyzeResponse {
    static var preview: UserAnalyzeResponse {
        let cherrypickCount = Int.random(in: 0...100)
        let clippingCount = Int.random(in: 0...100)
        
        return UserAnalyzeResponse(userNickname: "체리체리1q2w3e", userPercentile: Double.random(in: 0.0...100.0), cherrypickClippingTotalCount: cherrypickCount + clippingCount, cherrypickCount: cherrypickCount, recentCherrypickShops: ShopSimple.preview, clippingCount: clippingCount, recentClippingShops: ShopSimple.preview, weeklyTags: TagTitle.allCases)
    }
}
