//
//  ErrorView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/25.
//

import SwiftUI

struct ErrorView: View {
    @Binding var error: APIError?
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(error?.errorMessage ?? "")
                .fontWeight(.semibold)
                .foregroundColor(Color("main-point-color-strong"))
            
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("background-shape-color"))
                .shadow(color: .black.opacity(0.1), radius: 10)
        }
        .padding(.horizontal)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: .constant(.unknown(statusCode: nil)))
    }
}
