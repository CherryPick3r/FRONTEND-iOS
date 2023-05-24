//
//  UserPreferenceRequest.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct UserPreferenceRequest: Codable {
    let userEmail: String
    let preferenceGameId: Int
}
