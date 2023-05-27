//
//  UserNicknameChangeResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

struct UserNicknameChangeResponse: Codable {
    let originalUserNickname: String
    let changedUserNickname: String
}
