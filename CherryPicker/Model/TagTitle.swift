//
//  TagTitle.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import SwiftUI

enum TagTitle: String, CaseIterable, Codable {
    case foodComesOutFast = "음식이 빨리 나와요"
    case suitableForEationAlone = "혼밥"
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
    case niceRestaurant = "맛있는 식당"
    case withFriend = "친구랑 가기 좋아요"
    
    var tagColor: [Color] {
        switch self {
        case .foodComesOutFast:
            return [UserClass.solo.color]
        case .suitableForEationAlone:
            return [UserClass.solo.color]
        case .itsHearty:
            return [UserClass.solo.color]
        case .valueForMoneyRestaurant:
            return [UserClass.solo.color]
        case .fresh:
            return [UserClass.healtyFood.color]
        case .bar:
            return [UserClass.drunkard.color]
        case .goodToDrinkAlone:
            return [UserClass.drunkard.color]
        case .goodForGroups:
            return [UserClass.drunkard.color]
        case .exoticRestaurant:
            return [UserClass.foodExplorer.color]
        case .theConceptIsUnique:
            return [UserClass.foodExplorer.color]
        case .courseMealRestaurant:
            return [UserClass.foodExplorer.color]
        case .localFood:
            return [UserClass.foodExplorer.color]
        case .perfectForASpecialOccasion:
            return [UserClass.foodExplorer.color]
        case .specialMenu:
            return [UserClass.foodExplorer.color]
        case .beKind:
            return [UserClass.foodExplorer.color]
        case .emotionalPhoto:
            return [UserClass.miniInfluencer.color]
        case .comfortableSpace:
            return [UserClass.miniInfluencer.color, UserClass.caffeineVampire.color]
        case .calmAtmosphere:
            return [UserClass.caffeineVampire.color]
        case .cozyAtmosphere:
            return [UserClass.caffeineVampire.color]
        case .niceToStayLong:
            return [UserClass.caffeineVampire.color]
        case .cafeGoodPlaceToStudy:
            return [UserClass.caffeineVampire.color]
        case .cafe:
            return [UserClass.caffeineVampire.color]
        case .goodCoffeePlace:
            return [UserClass.caffeineVampire.color]
        case .deliciousDessert:
            return [UserClass.caffeineVampire.color, UserClass.miniInfluencer.color, UserClass.foodExplorer.color]
        case .deliciousDrink:
            return [UserClass.caffeineVampire.color, UserClass.miniInfluencer.color, UserClass.foodExplorer.color]
        case .easyToPark:
            return [UserClass.etc.color]
        case .wordOfMouth:
            return [UserClass.miniInfluencer.color, UserClass.foodExplorer.color]
        case .goodMusic:
            return [UserClass.caffeineVampire.color]
        case .niceRestaurant:
            return [UserClass.drunkard.color]
        case .withFriend:
            return [UserClass.drunkard.color]
        }
    }
}
