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
            break
        case .failure(let failure):
            switch failure {
            case .authenticationFailure:
                errorHandling(.authenticationFailure)
                break
            case .invalidResponse:
                errorHandling(.invalidResponse)
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
        }
    }
    
    static func fetchLoginResponse(platform: LoginPlatform, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (LoginResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchLoginResponse(platform: platform).subscribe(on: DispatchQueue.main).retry(1).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchLoginCallback(platform: LoginPlatform, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (String) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchLoginCallback(platform: platform).subscribe(on: DispatchQueue.main).retry(1).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doUserPreferenceStart(token: String, userPreferenceStartRequest: UserRequest, subscriptions: inout Set<AnyCancellable>, receieveValue: @escaping (UserPreferenceStartResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doUserPreferenceStart(token: token, userPreferenceStartRequset: userPreferenceStartRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receieveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doUserPreferenceSwipe(token: String, userPreferenceRequest: UserPreferenceRequest, swipeType: UserSelection, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (UserPreferenceResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doUserPreferenceSwipe(token: token, userPreferenceRequest: userPreferenceRequest, swipeType: swipeType).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doStartGame(token: String, gameStartRequest: GameStartRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (GameResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doStartGame(token: token, gameStartRequest: gameStartRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doGameSwipe(token: String, gameRequest: GameRequest, swipeType: UserSelection, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (Data) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.doGameSwipe(token: token, gameRequest: gameRequest, swipeType: swipeType).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchShopCard(token: String, shopCardRequest: ShopOrClippingRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (ShopCardResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchShopCard(token: token, shopCardRequest: shopCardRequest).subscribe(on: DispatchQueue.global(qos: .userInteractive)).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchShopDetail(token: String, shopDetailRequest: ShopOrClippingRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (ShopDetailResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchShopDetail(token: token, shopDetailRequest: shopDetailRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchShopSimples(token: String, simpleShopRequest: SimpleShopRequest, isResultRequest: Bool, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (SimpleShopResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchShopSimples(token: token, simpleShopRequest: simpleShopRequest, isResultRequest: isResultRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchUserAnalyze(token: String, userAnalyzeReqeust: UserRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (UserAnalyzeResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchUserAnalyze(token: token, userAnalyzeRequest: userAnalyzeReqeust).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func fetchUserNickname(token: String, userNicknameRequest: UserRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (UserNicknameResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.fetchUserNickname(token: token, userNicknameRequest: userNicknameRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func changeUserNickname(token: String, userNickNameChangeRequest: UserNicknameChangeRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (UserNicknameChangeResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.changeUserNickname(token: token, userNicknameChangeRequest: userNickNameChangeRequest).subscribe(on: DispatchQueue.global(qos: .background)).sink { completion in
            completionHandler(completion: completion) { apiError in
                DispatchQueue.main.async {
                    errorHandling(apiError)
                }
            }
        } receiveValue: { data in
            DispatchQueue.main.async {
                receiveValue(data)
            }
        }
        .store(in: &subscriptions)
    }
    
    static func deleteUser(token: String, userDeleteRequest: UserRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (LoginResponse) -> Void, errorHandling: @escaping (APIError) -> Void) {
        APIService.deleteUser(token: token, userDeleteRequest: userDeleteRequest).subscribe(on: DispatchQueue.main).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHandling)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func doClipping(token: String, clippingDoRequest: ShopOrClippingRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (ClippingDoResponse) -> Void, errorHanding: @escaping (APIError) -> Void) {
        APIService.doClipping(token: token, clippingDoRequest: clippingDoRequest).subscribe(on: DispatchQueue.global(qos: .userInteractive)).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHanding)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
    
    static func deleteClipping(token: String, clippingUndoRequest: ShopOrClippingRequest, subscriptions: inout Set<AnyCancellable>, receiveValue: @escaping (ShopOrClippingRequest) -> Void, errorHanding: @escaping (APIError) -> Void) {
        APIService.deleteClipping(token: token, clippingUndoRequest: clippingUndoRequest).subscribe(on: DispatchQueue.global(qos: .userInteractive)).sink { completion in
            completionHandler(completion: completion, errorHandling: errorHanding)
        } receiveValue: { data in
            receiveValue(data)
        }
        .store(in: &subscriptions)
    }
}
