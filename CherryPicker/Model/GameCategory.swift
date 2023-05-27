//
//  GameCategory.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/27.
//

import Foundation

enum GameCategory: Int, CaseIterable {
    case group = 1
    case cafeOrStudy = 2
    case goodPhoto = 3
    case solo = 4
    
    var name: String {
        switch self {
        case .group:
            return "단체모임"
        case .cafeOrStudy:
            return "카페/공부"
        case .goodPhoto:
            return "사진맛집"
        case .solo:
            return "혼밥"
        }
    }
    
    var tags: [TagTitle] {
        switch self {
        case .group:
            return [.comfortableSpace, .itsHearty, .goodForGroups, .valueForMoneyRestaurant]
        case .cafeOrStudy:
            return [.cafe, .goodCoffeePlace, .niceToStayLong, .cafeGoodPlaceToStudy, .deliciousDrink]
        case .goodPhoto:
            return [.theConceptIsUnique, .emotionalPhoto]
        case .solo:
            return [.valueForMoneyRestaurant, .suitableForEationAlone]
        }
    }
}
