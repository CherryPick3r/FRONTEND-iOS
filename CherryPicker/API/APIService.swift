//
//  APIService.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation
import Combine

enum LoginPlatform: Int {
    case apple
    case kakao
    case google
    
    var loginURL: APIURL {
        switch self {
        case .apple:
            return APIURL.appleLogin
        case .kakao:
            return APIURL.kakoLogin
        case .google:
            return APIURL.googleLogin
        }
    }
    
    var callBackURL: APIURL {
        switch self {
        case .apple:
            return APIURL.appleLoginCallback
        case .kakao:
            return APIURL.kakoLoginCallback
        case .google:
            return APIURL.googleLogincCallback
        }
    }
}

enum APIService {
    static func request(apiURL: APIURL, httpMethod: String? = nil, bearerToken: String? = nil, bodyData: Encodable? = nil) -> URLRequest {
        var request = URLRequest(url: apiURL.url)
        request.httpMethod = httpMethod
        
        if let body = bodyData {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        if let token = bearerToken {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    static func urlSessionHandling(data: Data, response: URLResponse, error400: APIError) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            switch httpResponse.statusCode {
            case 400:
                throw error400
            case 500:
                throw APIError.internalServerError
            default:
                throw APIError.unknown(statusCode: httpResponse.statusCode)
            }
        }
        
        return data
    }
    
    static func fetchLoginResponse(platform: LoginPlatform) -> AnyPublisher<LoginResponse, APIError> {
        let request = request(apiURL: platform.loginURL)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: LoginResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchLoginCallback(platform: LoginPlatform) -> AnyPublisher<String, APIError> {
        let request = request(apiURL: platform.callBackURL)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                switch httpResponse.statusCode {
                case 400:
                    throw APIError.authenticationFailure
                default:
                    throw APIError.unknown(statusCode: httpResponse.statusCode)
                }
            }
            
            guard let token = httpResponse.value(forHTTPHeaderField: "Authorization") else {
                throw APIError.invalidResponse
            }
            
            return token
        }
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func checkPreferenceGame(token: String, userEmail: String) -> AnyPublisher<CheckPreferenceGameResponse, APIError> {
        let request = request(apiURL: .checkPreferenceGame(userEmail: userEmail), bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: CheckPreferenceGameResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doUserPreferenceStart(token: String, userEmail: String) -> AnyPublisher<UserPreferenceStartResponse, APIError> {
        let request = request(apiURL: .preferenceCherryPickStartGame(userEmail: userEmail), httpMethod: "POST", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserPreferenceStartResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doUserPreferenceSwipe(token: String, userEmail: String, preferenceGameId: Int, swipeType: UserSelection) -> AnyPublisher<UserPreferenceResponse, APIError> {
        let request = request(apiURL: swipeType == .like ? .preferenceCherryPickSwipeRight(userEmail: userEmail, preferenceGameId: preferenceGameId) : .preferenceCherryPickSwipeLeft(userEmail: userEmail, preferenceGameId: preferenceGameId), httpMethod: "POST", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserPreferenceResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doStartGame(token: String, userEmail: String, gameMode: Int) -> AnyPublisher<GameResponse, APIError> {
        let request = request(apiURL: .cherryPicksStartGame(userEmail: userEmail, gameMode: gameMode), httpMethod: "POST", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: GameResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doGameSwipe(token: String, gameId: Int, shopId: Int, swipeType: UserSelection) -> AnyPublisher<GameResponse, APIError> {
        let request = request(apiURL: swipeType == .like ? .cherryPickSwipeRight(gameId: gameId, shopId: shopId) : .cherryPickSwipeLeft(gameId: gameId, shopId: shopId), httpMethod: "POST", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: GameResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchShopCard(token: String, shopId: Int, userEmail: String) -> AnyPublisher<ShopCardResponse, APIError> {
        let request = request(apiURL: .shopCard(shopId: shopId, userEmail: userEmail), bearerToken: token)
    
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: ShopCardResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchShopDetail(token: String, shopId: Int, userEmail: String) -> AnyPublisher<ShopDetailResponse, APIError> {
        let request = request(apiURL: .shopDetail(shopId: shopId, userEmail: userEmail), bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: ShopDetailResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchShopSimples(token: String, userEmail: String, gameCategory: Int, isResultRequest: Bool) -> AnyPublisher<SimpleShopResponse, APIError> {
        let request = request(apiURL: isResultRequest ? .shopResultSimple(userEmail: userEmail, gameCategory: gameCategory) : .shopClippingSimple(userEmail: userEmail, gameCategory: gameCategory), bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: SimpleShopResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchUserAnalyze(token: String, userEmail: String) -> AnyPublisher<UserAnalyzeResponse, APIError> {
        let request = request(apiURL: .userAnalyze(userEmail: userEmail), bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserAnalyzeResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchOrChangeUserNickname(token: String, userEmail: String, changeUserNickname: String?) -> AnyPublisher<Data, APIError> {
        let request = request(apiURL: .userNickname(userEmail: userEmail, changeUserNickname: changeUserNickname), httpMethod: changeUserNickname == nil ? "GET" : "PATCH", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func deleteUser(token: String, userEmail: String) -> AnyPublisher<LoginResponse, APIError> {
        let request = request(apiURL: .userUnregister(userEmail: userEmail), httpMethod: "DELETE", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: LoginResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doOrUndoClipping(token: String, userEmail: String, shopId: Int, isClipped: Bool) -> AnyPublisher<Data, APIError> {
        let request = isClipped ? request(apiURL: .clippingUndo(userEmail: userEmail, shopId: shopId), httpMethod: "DELETE", bearerToken: token) : request(apiURL: .clippingDo(userEmail: userEmail, shopId: shopId), httpMethod: "POST", bearerToken: token)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
}
