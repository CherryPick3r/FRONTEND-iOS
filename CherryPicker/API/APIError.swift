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
        default:
            return .unknown(statusCode: nil)
        }
    }
    
    static func showError(showError: inout Bool, error: inout APIError?, catchError: APIError) {
        withAnimation(.spring()) {
            withAnimation(.spring()) {
                error = catchError
                showError = true
            }
        }
    }
    
    static func closeError(showError: inout Bool, error: inout APIError?) {
        withAnimation(.spring()) {
            withAnimation(.spring()) {
                showError = false
                error = nil
            }
        }
    }
}
