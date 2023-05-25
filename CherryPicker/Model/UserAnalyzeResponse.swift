//
//  UserAnalyzeResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

struct UserAnalyzeResponse: Codable {
    let userNickname: String
    let userPercentile: Double
    let cherrypickClippingTotalCount: Int
    let cherrypickCount: Int
    let clippingCount: Int
    let recentClippingShops: ShopSimples
    let weeklyTags: [String]
}
