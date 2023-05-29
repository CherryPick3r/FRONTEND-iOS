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
    weak var webView: WKWebViewModel?
    
    @Binding var showError: Bool
    @Binding var error: APIError?
    @Binding var showLoginWebView: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
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
    @StateObject private var wKWebViewModel: WKWebViewModel = WKWebViewModel()
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    let url: String
    let onReceivedResponse: (HTTPURLResponse, inout Bool) throws -> Void
    
    @Binding var showError: Bool
    @Binding var error: APIError?
    @Binding var showLoginWebView: Bool
    
    var body: some View {
        VStack {
            if wKWebViewModel.publishedIsLoading {
                ProgressView(value: wKWebViewModel.publishedProgress)
            }
            
            if let url = URL(string: url) {
                WebView(url: url, onReceivedResponse: onReceivedResponse, showError: $showError, error: $error, showLoginWebView: $showLoginWebView)
                    .environmentObject(userViewModel)
            } else {
                Spacer()
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                backButton()
                
                Spacer()
                
                forwardButton()
                
                Spacer()
                
                reloadButton()
                
                Spacer()
            }
            .padding()
        }
        .tint(Color("main-point-color"))
        .modifier(BackgroundModifier())
    }
    
    @ViewBuilder
    func backButton() -> some View {
        Button{
            if wKWebViewModel.publishedCanGoBack {
                self.wKWebViewModel.goBack()
            }
        } label: {
            Image(systemName: "chevron.backward")
                .font(.title3)
        }
        .disabled(!wKWebViewModel.publishedCanGoBack)
    }
    
    @ViewBuilder
    func forwardButton() -> some View {
        Button {
            if wKWebViewModel.publishedCanForward {
                self.wKWebViewModel.goForward()
            }
        } label: {
            Image(systemName: "chevron.forward")
                .font(.title3)
        }
        .disabled(!wKWebViewModel.publishedCanForward)
    }
    
    @ViewBuilder
    func reloadButton() -> some View {
        Button {
            self.wKWebViewModel.reload()
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.title3)
        }
    }
}

