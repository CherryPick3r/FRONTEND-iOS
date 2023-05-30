//
//  ShopSimple.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import Foundation

struct ShopSimple: Codable, Identifiable {
    let id: Int
    let shopName: String
    let shopCategory: String
    let shopAddress: String
    let operatingHours: String
    let mainPhotoUrl: String
    
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
            return hour == today || hour == "매일" || hour == (today + "요일")
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
    
    enum CodingKeys: String, CodingKey {
        case id = "shopId"
        case shopName, shopCategory, shopAddress, operatingHours, mainPhotoUrl
    }
}

typealias ShopSimples = [ShopSimple]
