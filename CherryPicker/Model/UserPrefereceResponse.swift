//
//  UserPrefereceResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct UserPreferenceResponse: Codable {
    let preferenceGameId: Int
    let totalRound: Int
    let curRound: Int
    let gameStatus: Int
}
