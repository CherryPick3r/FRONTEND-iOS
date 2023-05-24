//
//  ShopCardResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct ShopCardResponse: Codable {
    let shopId: Int
    let shopMainPhotoURL1: String
    let shopMainPhotoURL2: String
    let shopName: String
    let shopCategory: String
    let oneLineReview: String
    let topTags: TopTags
    let shopClipping: Int
}

typealias ShopCardResponses = [ShopCardResponse]
