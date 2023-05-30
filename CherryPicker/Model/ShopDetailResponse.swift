//
//  ShopDetailResponse.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

struct ShopDetailResponse: Codable {
    let shopId: Int
    let shopName: String
    let shopCategory: String
    let oneLineReview: String
    let shopAddress: String
    let totalCherryPickCount: Int
    let operatingHours: String
    let topTags: TopTags
    let shopClipping: ShopClipping
    let shopMenus: MenuSimples
    let shopMainPhotoURLs: [String]
    let shopNaverId: Int
    let shopKakaoId: Int
    
    var operatingHoursArray: [String]? {
        let hoursArray = operatingHours.split(separator: "\n").map { hour in
            String(hour)
        }
        
        var hours = [String]()
        
        hoursArray.forEach { hour in
            hours += hour.split(separator: "/").map({ str in
                String(str)
            })
        }
        
        return hours.count == 0 ? nil : hours
    }
    
    var todayHour: String? {
        guard let hours = operatingHoursArray else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEEE"
        formatter.locale = Locale(identifier:"ko_KR")
        
        let today = formatter.string(from: .now)
        
        guard let todayIndex = hours.firstIndex(where: { hour in
            return hour.contains(today) || hour == "매일"
        }) else {
            return nil
        }
        
        return hours[index: todayIndex + 1]
    }
    
    var regularHoliday: String? {
        guard let hours = operatingHoursArray else {
            return nil
        }
        
        guard let regularHolidayIndex = hours.firstIndex(where: { hour in
            return hour.contains("휴무")
        }) else {
            return nil
        }
        
        return hours[regularHolidayIndex]
    }
}

struct MenuSimple: Codable {
    let name: String
    let price: Int
}

typealias MenuSimples = [MenuSimple]

extension Array {
    subscript(index index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
