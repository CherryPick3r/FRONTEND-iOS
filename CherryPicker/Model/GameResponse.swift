//
//  GameStartResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct GameResponse: Codable {
    let gameId: Int
    let totalRound: Int
    let curRound: Int
    let gameStatus: Int
    var recommendShopIds: [Int]?
    var recommendShops: ShopCardResponses?
}
