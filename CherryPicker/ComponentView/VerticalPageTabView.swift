//
//  VerticalPageTabView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/19.
//

import SwiftUI
import UIKit

struct VerticalPageTabView<Content: View>: UIViewRepresentable {
    var content: () -> Content
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: content()) // 수정된 부분
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // 업데이트 로직 추가 (선택 사항)
    }
}

