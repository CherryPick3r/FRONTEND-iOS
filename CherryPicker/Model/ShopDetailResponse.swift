//
//  ShopDetailResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct ShopDetailResponse: Codable {
    let shopId: Int
    let shopName: String
    let shopCategory: String
    let oneLineReview: String
    let totalCherryPickCount: Int
    let operatingHours: String
    let topTags: TopTags
    let shopClipping: Int
    let shopMenus: MenuSimples
    let shopMainPhotoURLs: [String]
    let shopNaverId: Int
    let shopKakaoId: Int
}

struct MenuSimple: Codable {
    let name: String
    let price: Int
}

typealias MenuSimples = [MenuSimple]
