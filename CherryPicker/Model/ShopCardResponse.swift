//
//  ShopCardResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct ShopCardResponse: Codable {
    let shopId: Int
    let shopMainPhoto1: String
    let shopMainPhoto2: String
    let shopName: String
    let shopCategory: String
    let oneLineReview: String
    let topTags: TopTags
    let shopClipping: ShopClipping
}

typealias ShopCardResponses = [ShopCardResponse]
