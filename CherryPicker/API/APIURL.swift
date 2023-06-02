//
//  APIURL.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

enum APIURL {
    case appleLogin(userEmail: String, nickname: String)
    case kakoLogin
    case googleLogin
    case checkPreferenceGame(userEmail: String)
    case restartPreferenceGame(userEmail: String)
    case preferenceCherryPickStartGame(userEmail: String)
    case preferenceCherryPickSwipeLeft(userEmail: String, preferenceGameId: Int)
    case preferenceCherryPickSwipeRight(userEmail: String, preferenceGameId: Int)
    case cherryPicksStartGame(userEmail: String, gameMode: Int)
    case cherryPickSwipeLeft(gameId: Int, shopId: Int)
    case cherryPickSwipeRight(gameId: Int, shopId: Int)
    case shopCard(shopId: Int, userEmail: String)
    case shopDetail(shopId: Int, userEmail: String)
    case shopResultSimple(userEmail: String, gameCategory: Int)
    case shopClippingSimple(userEmail: String, gameCategory: Int)
    case userAnalyze(userEmail: String)
    case userNickname(userEmail: String, changeUserNickname: String?)
    case userUnregister(userEmail: String)
    case clippingDo(userEmail: String, shopId: Int)
    case clippingUndo(userEmail: String, shopId: Int)
    
    var url: URL {
        var serverURL = URLComponents(string: "https://cherrypick3r.shop")!
        
        switch self {
        case .appleLogin(let userEmail, let nickname):
            serverURL.path = "/api/v1/auth/apple/login"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "nickname", value: nickname)]
            break
        case .kakoLogin:
            serverURL.path = "/api/v1/auth/kakao/login"
            break
        case .googleLogin:
            serverURL.path = "/api/v1/auth/google/login"
            break
        case .checkPreferenceGame(let userEmail):
            serverURL.path = "/api/v1/preference/check-preference-game"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .restartPreferenceGame(let userEmail):
            serverURL.path = "/api/v1/preference/restart-game"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .preferenceCherryPickStartGame(let userEmail):
            serverURL.path = "/api/v1/preference/start-game"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .preferenceCherryPickSwipeLeft(let userEmail, let preferenceGameId):
            serverURL.path = "/api/v1/preference/swipe-left"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "preferenceGameId", value: String(preferenceGameId))]
            break
        case .preferenceCherryPickSwipeRight(let userEmail, let preferenceGameId):
            serverURL.path = "/api/v1/preference/swipe-right"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "preferenceGameId", value: String(preferenceGameId))]
            break
        case .cherryPicksStartGame(let userEmail, let gameMode):
            serverURL.path = "/api/v1/game/start-game"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "gameMode", value: String(gameMode))]
            break
        case .cherryPickSwipeLeft(let gameId, let shopId):
            serverURL.path = "/api/v1/game/swipe-left"
            serverURL.queryItems = [URLQueryItem(name: "gameId", value: String(gameId)), URLQueryItem(name: "shopId", value: String(shopId))]
            break
        case .cherryPickSwipeRight(let gameId, let shopId):
            serverURL.path = "/api/v1/game/swipe-right"
            serverURL.queryItems = [URLQueryItem(name: "gameId", value: String(gameId)), URLQueryItem(name: "shopId", value: String(shopId))]
            break
        case .shopCard(let shopId, let userEmail):
            serverURL.path = "/api/v1/shop/card"
            serverURL.queryItems = [URLQueryItem(name: "shopId", value: String(shopId)), URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .shopDetail(let shopId, let userEmail):
            serverURL.path = "/api/v1/shop/detail"
            serverURL.queryItems = [URLQueryItem(name: "shopId", value: String(shopId)), URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .shopResultSimple(let userEmail, let gameCategory):
            serverURL.path = "/api/v1/shop/results-simple"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "gameCategory", value: String(gameCategory))]
            break
        case .shopClippingSimple(let userEmail, let gameCategory):
            serverURL.path = "/api/v1/shop/clippings-simple"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "gameCategory", value: String(gameCategory))]
            break
        case .userAnalyze(let userEmail):
            serverURL.path = "/api/v1/user/analyze"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .userNickname(let userEmail, let changeUserNickname):
            serverURL.path = "/api/v1/user/nickname"
            if let nickname = changeUserNickname {
                serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "changeUserNickname", value: nickname)]
            } else {
                serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail)]
            }
            break
        case .userUnregister(let userEmail):
            serverURL.path = "/api/v1/user/unregister"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail)]
            break
        case .clippingDo(let userEmail, let shopId):
            serverURL.path = "/api/v1/clipping/do"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "shopId", value: String(shopId))]
            break
        case .clippingUndo(let userEmail, let shopId):
            serverURL.path = "/api/v1/clipping/undo"
            serverURL.queryItems = [URLQueryItem(name: "userEmail", value: userEmail), URLQueryItem(name: "shopId", value: String(shopId))]
            break
        }
        return serverURL.url!
    }
}
