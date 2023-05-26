//
//  RollingTextView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/19.
//

import SwiftUI

struct RollingTextView: View {
    @Binding var value: Int
    
    @State var animationRange: [Int] = []
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<animationRange.count, id: \.self) { index in
                Text("0")
                    .opacity(0)
                    .overlay {
                        GeometryReader { reader in
                            let size = reader.size
                            
                            VStack(spacing: 0) {
                                ForEach(0...9, id: \.self) { number in
                                    Text("\(number)")
                                        .frame(width: size.width, height: size.height, alignment: .trailing)
                                }
                            }
                            .offset(y: -CGFloat(animationRange[index]) * size.height)
                        }
                        .clipped()
                    }
            }
        }
        .onAppear() {
            animationRange = Array(repeating: 0, count: "\(value)".count)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                updateText()
            }
        }
        .onChange(of: value) { newValue in
            let extra = "\(value)".count - animationRange.count
            
            if extra > 0 {
                for _ in 0..<extra {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        animationRange.append(0)
                    }
                }
            } else {
                for _ in 0..<(-extra) {
                    animationRange.removeLast()
                }
            }
            
            updateText()
        }
    }
    
    func updateText() {
        let stringValue = "\(value)"
        
        for (index, value) in zip(0..<stringValue.count, stringValue) {
            var fraction = Double(index) * 0.15
            fraction = (fraction > 0.5 ? 0.5 : fraction)
            
            withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 1 + fraction, blendDuration: 1 + fraction)) {
                animationRange[index] = Int("\(value)")!
            }
        }
    }
}

struct RollingTextView_Previews: PreviewProvider {
    static var previews: some View {
        RollingTextView(value: .constant(0))
    }
}
