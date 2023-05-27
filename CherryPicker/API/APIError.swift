//
//  APIError.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/24.
//

import SwiftUI

enum APIError: Error {
    case authenticationFailure
    case invalidResponse
    case jsonDecodingError
    case jsonEncodingError
    case urlError(URLError)
    case unknown(statusCode: Int?)
    
    var errorMessage: String {
        switch self {
        case .authenticationFailure:
            return "사용자 인증에 실패했어요."
        case .invalidResponse:
            return "서버에 문제가 생겼어요."
        case .jsonDecodingError:
            return "데이터 디코딩 에러"
        case .jsonEncodingError:
            return "데이터 인코딩 에러"
        case .urlError(let error):
            switch error.code {
            case .badServerResponse:
                return "서버와 제대로 통신하지 못했어요."
            case .cannotFindHost:
                return "서버를 찾지 못했어요."
            case .cannotConnectToHost:
                return "서버에 연결하지 못했어요."
            case .backgroundSessionWasDisconnected:
                return "서버와의 통신이 알 수 없는 이유로 잠시 중단 되었어요."
            case .cancelled:
                return "서버와의 통신이 알 수 없는 이유로 취소 되었어요."
            case .networkConnectionLost:
                return "서버와의 통신이 알 수 없는 이유로 끊어졌어요."
            case .timedOut:
                return "서버와의 통신이 너무 오래걸려 중단되었어요."
            default:
                return "서버와의 통신중에 알 수 없는 오류가 발생했어요."
            }
        case .unknown(let statusCode):
            if let code = statusCode {
                return "알 수 없는 오류가 발생 했어요. (\(code))"
            } else {
                return "알 수 없는 오류가 발생 했어요."
            }
        }
    }
    
    static func convert(error: Error) -> APIError {
        switch error {
        case is APIError:
            return error as! APIError
        case is DecodingError:
            return .jsonDecodingError
        case is EncodingError:
            return .jsonEncodingError
        case is URLError:
            return .urlError(error as! URLError)
        default:
            return .unknown(statusCode: nil)
        }
    }
    
    static func showError(showError: inout Bool, error: inout APIError?, catchError: APIError) {
        error = catchError
        showError = true
    }
    
    static func closeError(showError: inout Bool, error: inout APIError?) {
        showError = false
        error = nil
    }
}
