//
//  GameStartRequest.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct GameStartRequest: Codable {
    let userEmail: String
    let gameMode: Int
}
