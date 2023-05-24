//
//  ResultsSimpleResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct SimpleShopResponse: Codable {
    let shopSimples: ShopSimples
}

struct ShopSimple: Codable {
    let shopId: Int
    let shopName: String
    let shopCategory: String
    let shopAddress: String
    let operatingHours: String
    let mainPhotoUrl: String
}

typealias ShopSimples = [ShopSimple]
