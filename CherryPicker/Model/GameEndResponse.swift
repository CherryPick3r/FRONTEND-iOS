//
//  GameEndResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct GameEndResponse: Codable {
    let gameId: Int
    let totalRound: Int
    let curRound: Int
    let gameStatus: Int
    let recommendedShopId: Int
    let reconmendedShopDetail: ShopDetailResponse
}
