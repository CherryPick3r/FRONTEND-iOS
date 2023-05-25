//
//  UserNicknameChangeRequest.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

struct UserNicknameChangeRequest: Codable {
    let userEmail: String
    let changeUserNickname: String
}
