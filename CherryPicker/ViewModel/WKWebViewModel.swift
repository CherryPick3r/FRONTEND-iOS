//
//  WKWebViewModel.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/30.
//

import SwiftUI
import WebKit

class WKWebViewModel: WKWebView, WKNavigationDelegate, ObservableObject {
    @Published var publishedCanGoBack = false
    @Published var publishedCanForward = false
    @Published var publishedIsLoading = false
    @Published var publishedProgress = 0.0
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        initViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViewModel()
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    private func initViewModel() {
        self.navigationDelegate = self
        self.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func removeObservers() {
        removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        publishedCanGoBack = webView.canGoBack
        publishedCanForward = webView.canGoForward
        publishedIsLoading = webView.isLoading
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        publishedIsLoading = webView.isLoading
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async {
            self.publishedProgress = self.estimatedProgress
        }
    }
}

