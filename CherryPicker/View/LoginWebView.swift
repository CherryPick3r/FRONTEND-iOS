//
//  LoginWebView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/28.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let url: URL
    let onReceivedResponse: (HTTPURLResponse, inout Bool) throws -> Void
    
    @Binding var showError: Bool
    @Binding var error: APIError?
    @Binding var showLoginWebView: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onReceivedResponse: onReceivedResponse, showError: $showError, error: $error, showLoginWebView: $showLoginWebView)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @EnvironmentObject var userViewModel: UserViewModel
        
        let onReceivedResponse: (HTTPURLResponse, inout Bool) throws -> Void
        
        @Binding var showError: Bool
        @Binding var error: APIError?
        @Binding var showLoginWebView: Bool
        
        init(onReceivedResponse: @escaping (HTTPURLResponse, inout Bool) throws -> Void, showError: Binding<Bool>, error: Binding<APIError?>, showLoginWebView: Binding<Bool>) {
            self.onReceivedResponse = onReceivedResponse
            self._showError = showError
            self._error = error
            self._showLoginWebView = showLoginWebView
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            guard let response = navigationResponse.response as? HTTPURLResponse else {
                withAnimation(.spring()) {
                    APIError.showError(showError: &showError, error: &error, catchError: .invalidResponse)
                }
                
                return
            }
            
            decisionHandler(.allow)
            
            do {
                try self.onReceivedResponse(response, &showLoginWebView)
            } catch {
                withAnimation(.spring()) {
                    APIError.showError(showError: &showError, error: &self.error, catchError: APIError.convert(error: error))
                }
            }
        }
    }
}

struct LoginWebView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    let url: String
    let onReceivedResponse: (HTTPURLResponse, inout Bool) throws -> Void
    
    @Binding var showError: Bool
    @Binding var error: APIError?
    @Binding var showLoginWebView: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if let url = URL(string: url.removingPercentEncoding?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                    WebView(url: url, onReceivedResponse: onReceivedResponse, showError: $showError, error: $error, showLoginWebView: $showLoginWebView)
                        .environmentObject(userViewModel)
                } else {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.large)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .modifier(BackgroundModifier())
        }
        .tint(Color("main-point-color"))
    }
}

struct LoginWebView_Previews: PreviewProvider {
    static var previews: some View {
        LoginWebView(url: "https://www.apple.com", onReceivedResponse: { _, _ in
            
        }, showError: .constant(false), error: .constant(nil), showLoginWebView: .constant(true))
        //            .environmentObject(UserViewModel.preivew)
                    .environmentObject(UserViewModel())
    }
}
