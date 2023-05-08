//
//  RadarChart.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/07.
//

import SwiftUI

struct RadarChartGrid: Shape {
    let categories: Int
    let divisions: Int
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
        let stride = radius / CGFloat(divisions)
        var path = Path()
        
        for category in 1...categories {
            path.addLine(to: CGPoint(x: rect.midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * radius, y: rect.midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * radius))
        }
        
        for step in 1...divisions {
            let rad = CGFloat(step) * stride
            path.move(to: CGPoint(x: rect.midX + cos(-.pi / 2) * rad, y: rect.midY + sin(-.pi / 2) * rad))
            
            for category in 1...categories {
                path.addLine(to: CGPoint(x: rect.midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * rad, y: rect.midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * rad))
            }
        }
        
        return path
    }
}

struct RadarChartPath: Shape {
    let data: [Double]
    let maximum = 1.0
    
    func path(in rect: CGRect) -> Path {
        guard 3 <= data.count, let minimum = data.min(), 0 <= minimum else {
            return Path()
        }
        
        let radius = min(rect.maxX - rect.midX, rect.maxY - rect.midY)
        var path = Path()
        
        for (index, entry) in data.enumerated() {
            switch index {
            case 0:
                path.move(to: CGPoint(x: rect.midX + CGFloat(entry / maximum) * cos(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius, y: rect.midY + CGFloat(entry / maximum) * sin(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius))
            default:
                path.addLine(to: CGPoint(x: rect.midX + CGFloat(entry / maximum) * cos(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius, y: rect.midY + CGFloat(entry / maximum) * sin(CGFloat(index) * 2 * .pi / CGFloat(data.count) - .pi / 2) * radius))
            }
        }
        
        path.closeSubpath()
        
        return path
    }
}

struct RadarChartView: View {
    var data: [Double]
    let gridColor: Color
    let dataColor: Color
    let gridLineWidth: CGFloat
    let dataLineWidth: CGFloat
    let labels: [String]
    let tagColors: [Color] = [
        Color("food-explorer-tag-color"),
        Color("mini-influencer-tag-color"),
        Color("healthy-food-tag-color"),
        Color("etc-tag-color"),
        Color("caffeine-vampire-tag-color"),
        Color("solo-tag-color"),
        Color("drunkard-tag-color")
    ]
    
    @State private var dataLoad = false
    
    init(data: [Double], gridColor: Color, dataColor: Color, gridLineWidth: CGFloat, dataLineWidth: CGFloat, labels: [String]) {
        self.data = data
        self.gridColor = gridColor
        self.dataColor = dataColor
        self.gridLineWidth = gridLineWidth
        self.dataLineWidth = dataLineWidth
        self.labels = labels
    }
    
    var body: some View {
        GeometryReader { geometry in
            let rect: CGRect = CGRect(origin: .zero, size: geometry.size)
            let midX: CGFloat = rect.midX
            let midY: CGFloat = rect.midY
            
            let radius = min(rect.maxX - midX, rect.maxY - midY) + 30
            
            ZStack {
                ForEach(0..<7) { index in
                    let point = CGPoint(x: midX + cos(CGFloat(index) * 2 * .pi / CGFloat(7) - .pi / 2) * radius, y: midY + sin(CGFloat(index) * 2 * .pi / CGFloat(7) - .pi / 2) * radius)
                    let label = labels[index]
                    let isMax = data.max() ?? 0.0 == data[index]
                    
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .position(x: point.x, y: point.y)
                        .foregroundColor(isMax ? tagColors[index] : Color("secondary-text-color-weak"))
                            .shadow(color: .black.opacity(isMax ? 0.25 : 0), radius: 5)
                }
                
                RadarChartGrid(categories: data.count, divisions: 6)
                    .stroke(style: StrokeStyle(lineWidth: gridLineWidth, dash: [5]))
                    .foregroundColor(gridColor)
                
                RadarChartPath(data: data)
                    .fill(dataColor.opacity(0.5))
                    .frame(height: dataLoad ? nil : 0)
                    .onAppear() {
                        withAnimation(.spring(response: 1.5)) {
                            dataLoad = true
                        }
                    }
                
                RadarChartPath(data: data)
                    .stroke(dataColor, lineWidth: dataLineWidth)
                    .frame(height: dataLoad ? nil : 0)
                    .onAppear() {
                        withAnimation(.spring(response: 1.5)) {
                            dataLoad = true
                        }
                    }
            }
        }
        
    }
}

struct RadarChartView_Previews: PreviewProvider {
    static var previews: some View {
        RadarChartView(data: [0.2, 0.5, 0.8, 0.6, 0.4, 0.2, 0.1], gridColor: Color("main-point-color-weak"), dataColor: Color("main-point-color").opacity(0.5), gridLineWidth: 0.5, dataLineWidth: 2, labels: ["맛집탐방러", "미니인플루언서", "건강식", "기타", "카페인 뱀파이어", "혼밥러", "술고래"])
    }
}
