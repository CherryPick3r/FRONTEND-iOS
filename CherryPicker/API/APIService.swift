//
//  APIService.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import Foundation
import Combine

enum LoginPlatform {
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
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
    
    static func doUserPreferenceStart(token: String, userPreferenceStartRequset: UserRequest) -> AnyPublisher<UserPreferenceStartResponse, APIError> {
        let request = request(apiURL: .preferenceCherryPickStartGame, httpMethod: "POST", bearerToken: token, bodyData: userPreferenceStartRequset)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserPreferenceStartResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doUserPreferenceSwipe(token: String, userPreferenceRequest: UserPreferenceRequest, swipeType: UserSelection) -> AnyPublisher<UserPreferenceResponse, APIError> {
        let request = request(apiURL: swipeType == .like ? .preferenceCherryPickSwipeRight : .preferenceCherryPickSwipeLeft, httpMethod: "POST", bearerToken: token, bodyData: userPreferenceRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserPreferenceResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doStartGame(token: String, gameStartRequest: GameStartRequest) -> AnyPublisher<GameResponse, APIError> {
        let request = request(apiURL: .cherryPicksStartGame, httpMethod: "POST", bearerToken: token, bodyData: gameStartRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: GameResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doGameSwipe(token: String, gameRequest: GameRequest, swipeType: UserSelection) -> AnyPublisher<Data, APIError> {
        let request = request(apiURL: swipeType == .like ? .cherryPickSwipeRight : .cherryPickSwipeLeft, httpMethod: "POST", bearerToken: token, bodyData: gameRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchShopCard(token: String, shopCardRequest: ShopOrClippingRequest) -> AnyPublisher<ShopCardResponse, APIError> {
        let request = request(apiURL: .shopCard, bearerToken: token, bodyData: shopCardRequest)
    
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: ShopCardResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchShopDetail(token: String, shopDetailRequest: ShopOrClippingRequest) -> AnyPublisher<ShopDetailResponse, APIError> {
        let request = request(apiURL: .shopDetail, bearerToken: token, bodyData: shopDetailRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: ShopDetailResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchShopSimples(token: String, simpleShopRequest: SimpleShopRequest, isResultRequest: Bool) -> AnyPublisher<SimpleShopResponse, APIError> {
        let request = request(apiURL: isResultRequest ? .shopResultSimple : .shopClippingSimple, bearerToken: token, bodyData: simpleShopRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: SimpleShopResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchUserAnalyze(token: String, userAnalyzeRequest: UserRequest) -> AnyPublisher<UserAnalyzeResponse, APIError> {
        let request = request(apiURL: .userAnalyze, bearerToken: token, bodyData: userAnalyzeRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserAnalyzeResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func fetchUserNickname(token: String, userNicknameRequest: UserRequest) -> AnyPublisher<UserNicknameResponse, APIError> {
        let request = request(apiURL: .userNickname, bearerToken: token, bodyData: userNicknameRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserNicknameResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func changeUserNickname(token: String, userNicknameChangeRequest: UserNicknameChangeRequest) -> AnyPublisher<UserNicknameChangeResponse, APIError> {
        let request = request(apiURL: .userNickname, httpMethod: "PATCH", bearerToken: token, bodyData: userNicknameChangeRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: UserNicknameChangeResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func deleteUser(token: String, userDeleteRequest: UserRequest) -> AnyPublisher<LoginResponse, APIError> {
        let request = request(apiURL: .userUnregister, httpMethod: "DELETE", bearerToken: token, bodyData: userDeleteRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: LoginResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func doClipping(token: String, clippingDoRequest: ShopOrClippingRequest) -> AnyPublisher<ClippingDoResponse, APIError> {
        let request = request(apiURL: .clippingDo, httpMethod: "POST", bearerToken: token, bodyData: clippingDoRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: ClippingDoResponse.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    static func deleteClipping(token: String, clippingUndoRequest: ShopOrClippingRequest) -> AnyPublisher<ShopOrClippingRequest, APIError> {
        let request = request(apiURL: .clippingUndo, httpMethod: "DELETE", bearerToken: token, bodyData: clippingUndoRequest)
        
        return URLSession.shared.dataTaskPublisher(for: request).tryMap { data, response in
            try urlSessionHandling(data: data, response: response, error400: .authenticationFailure)
        }
        .decode(type: ShopOrClippingRequest.self, decoder: JSONDecoder())
        .mapError { error in
            APIError.convert(error: error)
        }
        .eraseToAnyPublisher()
    }
}
