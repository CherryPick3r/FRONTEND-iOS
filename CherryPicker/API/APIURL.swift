//
//  APIURL.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation

enum APIURL {
    case appleLogin
    case kakoLogin
    case googleLogin
    case appleLoginCallback
    case kakoLoginCallback
    case googleLogincCallback
    case preferenceCherryPickStartGame
    case preferenceCherryPickSwipeLeft
    case preferenceCherryPickSwipeRight
    case cherryPicksStartGame
    case cherryPickSwipeLeft
    case cherryPickSwipeRight
    case shopCard
    case shopDetail
    case shopResultSimple
    case shopClippingSimple
    case userAnalyze
    case userNickname
    case userUnregister
    case clippingDo
    case clippingUndo
    
    var url: URL {
        var serverURL = URLComponents(string: "http://43.202.25.158:8080")!
        
        switch self {
        case .appleLogin:
            serverURL.path = "/api/v1/auth/apple/login"
            break
        case .kakoLogin:
            serverURL.path = "/api/v1/auth/kakao/login"
            break
        case .googleLogin:
            serverURL.path = "/api/v1/auth/google/login"
            break
        case .appleLoginCallback:
            serverURL.path = "/api/v1/auth/apple/callback"
            break
        case .kakoLoginCallback:
            serverURL.path = "/api/v1/auth/kakao/callback"
            break
        case .googleLogincCallback:
            serverURL.path = "/api/v1/auth/google/callback"
            break
        case .preferenceCherryPickStartGame:
            serverURL.path = "/api/v1/preference/start-game"
            break
        case .preferenceCherryPickSwipeLeft:
            serverURL.path = "/api/v1/preference/swipe-left"
            break
        case .preferenceCherryPickSwipeRight:
            serverURL.path = "/api/v1/preference/swipe-right"
            break
        case .cherryPicksStartGame:
            serverURL.path = "/api/v1/game/start-game"
            break
        case .cherryPickSwipeLeft:
            serverURL.path = "/api/v1/game/swipe-left"
            break
        case .cherryPickSwipeRight:
            serverURL.path = "/api/v1/game/swipe-right"
            break
        case .shopCard:
            serverURL.path = "/api/v1/shop/card"
            break
        case .shopDetail:
            serverURL.path = "/api/v1/shop/detail"
            break
        case .shopResultSimple:
            serverURL.path = "/api/v1/shop/results-simple"
            break
        case .shopClippingSimple:
            serverURL.path = "/api/v1/shop/clippings-simple"
            break
        case .userAnalyze:
            serverURL.path = "/api/v1/user/analyze"
            break
        case .userNickname:
            serverURL.path = "/api/v1/user/nickname"
            break
        case .userUnregister:
            serverURL.path = "/api/v1/user/unregister"
            break
        case .clippingDo:
            serverURL.path = "/api/v1/clipping/do"
            break
        case .clippingUndo:
            serverURL.path = "/api/v1/clipping/undo"
            break
        }
        
        return serverURL.url!
    }
}
