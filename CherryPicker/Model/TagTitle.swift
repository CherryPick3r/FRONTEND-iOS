//
//  TagTitle.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

enum TagTitle: String, CaseIterable, Codable {
    case foodComesOutFast = "음식이 빨리 나와요"
    case suitableForEationAlone = "혼밥하기 좋아요"
    case itsHearty = "푸짐해요"
    case valueForMoneyRestaurant = "가성비 맛집"
    case fresh = "신선해요"
    case bar = "술집"
    case goodToDrinkAlone = "혼술 맛집"
    case goodForGroups = "단체모임"
    case exoticRestaurant = "이색맛집"
    case theConceptIsUnique = "컨셉이 독특해요"
    case CourseMealRestaurant = "코스요리 맛집"
    case localFood = "로컬맛집"
    case perfectForASpecialOccasion = "특별한 날 가기 좋아요"
    case specialMenu = "특별메뉴"
    case beKind = "친절해요"
    case EmotionalPhoto = "감성사진"
    case comfortableSpace = "쾌적한 공간"
    case calmAtmosphere = "차분한 분위기"
    case cozyAtmosphere = "아늑한 분위기"
    case niceToStayLong = "오래 있기 좋아요"
    case cafeGoodPlaceToStudy = "카공맛집"
    case cafe = "카페"
    case goodCoffeePlace = "커피맛집"
    case deliciousDessert = "맛있는 디저트"
    case deliciousDrink = "맛있는 음료"
}
