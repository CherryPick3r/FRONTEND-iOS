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
    let userClass: UserClass
    let userAnalyzeValues: [Double]
    let cherrypickClippingTotalCount: Int
    let cherrypickCount: Int
    let recentCherrypickShops: ShopSimples
    let clippingCount: Int
    let recentClippingShops: ShopSimples
    let userTags: [TagTitle]
}
