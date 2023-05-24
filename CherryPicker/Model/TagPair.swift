//
//  TagPair.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct TagPair: Codable {
    let description: String
    let value: Double
}

typealias TopTags = [TagPair]
