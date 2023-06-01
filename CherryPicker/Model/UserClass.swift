//
//  UserClass.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/06/01.
//

import SwiftUI

enum UserClass: String, CaseIterable, Codable {
    case foodExplorer = "맛집탐방러"
    case miniInfluencer = "미니인플루언서"
    case healtyFood = "건강식"
    case etc = "기타"
    case caffeineVampire = "카페인 뱀파이어"
    case solo = "혼밥러"
    case drunkard = "술고래"
    
    var color: Color {
        switch self {
        case .foodExplorer:
            return Color("food-explorer-tag-color")
        case .miniInfluencer:
            return Color("mini-influencer-tag-color")
        case .healtyFood:
            return Color("healthy-food-tag-color")
        case .etc:
            return Color("etc-tag-color")
        case .caffeineVampire:
            return Color("caffeine-vampire-tag-color")
        case .solo:
            return Color("solo-tag-color")
        case .drunkard:
            return Color("drunkard-tag-color")
        }
    }
}
