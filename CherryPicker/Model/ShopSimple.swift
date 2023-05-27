//
//  ShopSimple.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

struct ShopSimple: Codable, Identifiable {
    let id: Int
    let shopName: String
    let shopCategory: String
    let shopAddress: String
    let operatingHours: String
    let mainPhotoUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id = "shopId"
        case shopName, shopCategory, shopAddress, operatingHours, mainPhotoUrl
    }
}

typealias ShopSimples = [ShopSimple]
