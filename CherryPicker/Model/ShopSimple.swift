//
//  ShopSimple.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

struct ShopSimple: Codable {
    let shopId: Int
    let shopName: String
    let shopCategory: String
    let shopAddress: String
    let operatingHours: String
    let mainPhotoUrl: String
}

typealias ShopSimples = [ShopSimple]
