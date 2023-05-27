//
//  TagPair.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct TagPair: Codable {
    var description: String
    var value: Double
}

typealias TopTags = [TagPair]
