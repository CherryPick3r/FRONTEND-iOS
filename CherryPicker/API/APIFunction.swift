//
//  APIFunction.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import SwiftUI
import Combine

enum APIFunction {
    static func completionHandler(completion: Subscribers.Completion<APIError>, errorHandling: @escaping (APIError) -> Void) {
        switch completion {
        case .finished:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            break
        case .failure(let failure):
            switch failure {
            case .authenticationFailure:
                errorHandling(.authenticationFailure)
                break
            case .invalidResponse:
                errorHandling(.invalidResponse)
                break
            case .internalServerError:
                errorHandling(.internalServerError)
                break
            case .loginFail:
                errorHandling(.loginFail)
                break
            case .jsonDecodingError:
                errorHandling(.jsonDecodingError)
                break
            case .jsonEncodingError:
                errorHandling(.jsonEncodingError)
                break
            case .urlError(let error):
                errorHandling(.urlError(error))
                break
            case .unknown(let statusCode):
                errorHandling(.unknown(statusCode: statusCode))
                break
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            
            break
        }
    }
    
    static func doAppleLogin(userEmail: String, nickname: String, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (String, String) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doAppleLogin(userEmail: userEmail, nickname: nickname).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { token, email in
            receiveValue(token, email)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchLoginResponse(platform: LoginPlatform, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (LoginResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchLoginResponse(platform: platform).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func checkPreferenceGame(token: String, userEmail: String, subscriptions: inout Set<AnyCancellable>, receieveValue: @escaping (CheckPreferenceGameResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.checkPreferenceGame(token: token, userEmail: userEmail).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receieveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func restartPreferenceGame(token: String, userEmail: String, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (Data) -> Void, errorHanding: @escaping (APIError) -> Void) {
        APIService.restartPreferenceGame(token: token, userEmail: userEmail).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHanding)
        } receiveValue: { data in
            receiveValue(data)
        }
    }
    
    static func doUserPreferenceStart(token: String, userEmail: String, subscriptions: inout Set<AnyCancellable>, receieveValue: @escaping (UserPreferenceStartResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doUserPreferenceStart(token: token, userEmail: userEmail).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receieveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doUserPreferenceSwipe(token: String, userEmail: String, preferenceGameId: Int, swipeType: UserSelection, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (UserPreferenceResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doUserPreferenceSwipe(token: token, userEmail: userEmail, preferenceGameId: preferenceGameId, swipeType: swipeType).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doStartGame(token: String, userEmail: String, gameMode: Int, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (GameResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doStartGame(token: token, userEmail: userEmail, gameMode: gameMode).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doGameSwipe(token: String, gameId: Int, shopId: Int, swipeType: UserSelection, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (GameResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doGameSwipe(token: token, gameId: gameId, shopId: shopId, swipeType: swipeType).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchShopCard(token: String, shopId: Int, userEmail: String, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (ShopCardResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchShopCard(token: token, shopId: shopId, userEmail: userEmail).subscribe(on: DispatchQueue.global(qos: .userInteractive)).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchShopDetail(token: String, shopId: Int, userEmail: String, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (ShopDetailResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchShopDetail(token: token, shopId: shopId, userEmail: userEmail).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchShopSimples(token: String, userEmail: String, gameCategory: Int, isResultRequest: Bool, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (SimpleShopResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchShopSimples(token: token, userEmail: userEmail, gameCategory: gameCategory, isResultRequest: isResultRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchUserAnalyze(token: String, userEmail: String, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (UserAnalyzeResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchUserAnalyze(token: token, userEmail: userEmail).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchOrChangeUserNickname(token: String, userEmail: String, changeUserNickname: String? = nil, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (Data) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchOrChangeUserNickname(token: token, userEmail: userEmail, changeUserNickname: changeUserNickname).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func deleteUser(token: String, accessToken: String, userEmail: String, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (Data) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.deleteUser(token: token, accessToken: accessToken, userEmail: userEmail).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doOrUndoClipping(token: String, userEmail: String, shopId: Int, isClipped: Bool, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (Data) -> Void, errorHanding: @escaping (APIError) -> Void) {
        APIService.doOrUndoClipping(token: token, userEmail: userEmail, shopId: shopId, isClipped: isClipped).subscribe(on: DispatchQueue.global(qos: .userInteractive)).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHanding)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
}
