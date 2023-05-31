//
//  TagTitle.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import SwiftUI

enum TagTitle: String, CaseIterable, Codable {
    case foodComesOutFast = "음식이 빨리 나와요"
    case suitableForEationAlone = "혼밥하기 좋아요"
    case itsHearty = "푸짐해요"
    case valueForMoneyRestaurant = "가성비 맛집"
    case fresh = "신선해요"
    case bar = "좋은 술집"
    case goodToDrinkAlone = "혼술 맛집"
    case goodForGroups = "단체모임"
    case exoticRestaurant = "이색맛집"
    case theConceptIsUnique = "컨셉이 독특해요"
    case courseMealRestaurant = "코스요리 맛집"
    case localFood = "로컬맛집"
    case perfectForASpecialOccasion = "특별한 날"
    case specialMenu = "특별메뉴"
    case beKind = "친절해요"
    case emotionalPhoto = "감성사진"
    case comfortableSpace = "쾌적한 공간"
    case calmAtmosphere = "차분한 분위기"
    case cozyAtmosphere = "아늑한 분위기"
    case niceToStayLong = "오래 있기 좋아요"
    case cafeGoodPlaceToStudy = "카공맛집"
    case cafe = "카페"
    case goodCoffeePlace = "커피맛집"
    case deliciousDessert = "맛있는 디저트"
    case deliciousDrink = "맛있는 음료"
    case easyToPark = "주차하기 편해요"
    case wordOfMouth = "입소문"
    case goodMusic = "좋은 음악"
    
    var tagColor: [Color] {
        switch self {
        case .foodComesOutFast:
            return [Color("solo-tag-color")]
        case .suitableForEationAlone:
            return [Color("solo-tag-color")]
        case .itsHearty:
            return [Color("solo-tag-color")]
        case .valueForMoneyRestaurant:
            return [Color("solo-tag-color")]
        case .fresh:
            return [Color("healthy-food-tag-color")]
        case .bar:
            return [Color("drunkard-tag-color")]
        case .goodToDrinkAlone:
            return [Color("drunkard-tag-color")]
        case .goodForGroups:
            return [Color("drunkard-tag-color")]
        case .exoticRestaurant:
            return [Color("food-explorer-tag-color")]
        case .theConceptIsUnique:
            return [Color("food-explorer-tag-color")]
        case .courseMealRestaurant:
            return [Color("food-explorer-tag-color")]
        case .localFood:
            return [Color("food-explorer-tag-color")]
        case .perfectForASpecialOccasion:
            return [Color("food-explorer-tag-color")]
        case .specialMenu:
            return [Color("food-explorer-tag-color")]
        case .beKind:
            return [Color("food-explorer-tag-color")]
        case .emotionalPhoto:
            return [Color("mini-influencer-tag-color")]
        case .comfortableSpace:
            return [Color("mini-influencer-tag-color"), Color("caffeine-vampire-tag-color")]
        case .calmAtmosphere:
            return [Color("caffeine-vampire-tag-color")]
        case .cozyAtmosphere:
            return [Color("caffeine-vampire-tag-color")]
        case .niceToStayLong:
            return [Color("caffeine-vampire-tag-color")]
        case .cafeGoodPlaceToStudy:
            return [Color("caffeine-vampire-tag-color")]
        case .cafe:
            return [Color("caffeine-vampire-tag-color")]
        case .goodCoffeePlace:
            return [Color("caffeine-vampire-tag-color")]
        case .deliciousDessert:
            return [Color("caffeine-vampire-tag-color"), Color("mini-influencer-tag-color"), Color("food-explorer-tag-color")]
        case .deliciousDrink:
            return [Color("caffeine-vampire-tag-color"), Color("mini-influencer-tag-color"), Color("food-explorer-tag-color")]
        case .easyToPark:
            return [Color("etc-tag-color")]
        case .wordOfMouth:
            return [Color("mini-influencer-tag-color"), Color("food-explorer-tag-color")]
        case .goodMusic:
            return [Color("caffeine-vampire-tag-color")]
        }
    }
}
