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
        let midX = rect.midX
        let midY = rect.midY
        let radius = min(rect.maxX - midX, rect.maxY - midY)
        let stride = radius / CGFloat(divisions)
        var path = Path()
        
        for category in 1...categories {
            path.move(to: CGPoint(x: midX, y: midY))
            path.addLine(to: CGPoint(x: midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * radius, y: midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * radius))
        }
        
        for step in 1...divisions {
            let rad = CGFloat(step) * stride
            
            path.move(to: CGPoint(x: midX + cos(-.pi / 2) * rad, y: midY + sin(-.pi / 2) * rad))
            
            for category in 1...categories {
                path.addLine(to: CGPoint(x: midX + cos(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * rad, y: midY + sin(CGFloat(category) * 2 * .pi / CGFloat(categories) - .pi / 2) * rad))
            }
        }
        
        return path
    }
}

struct RadarChartPath: Shape {
    let data: [Double]
    let maximum: Double
    
    init(data: [Double], maximum: Double) {
        self.data = data
        self.maximum = maximum
    }
    
    func path(in rect: CGRect) -> Path {
        let dataCount = data.count
        let midX = rect.midX
        let midY = rect.midY
        
        guard 3 <= dataCount, let minimum = data.min(), 0 <= minimum else {
            return Path()
        }
        
        let radius = min(rect.maxX - midX, rect.maxY - midY)
        var path = Path()
        
        for (index, entry) in data.enumerated() {
            switch index {
            case 0:
                path.move(to: CGPoint(x: midX + CGFloat(entry / maximum) * cos(CGFloat(index) * 2 * .pi / CGFloat(dataCount) - .pi / 2) * radius, y: midY + CGFloat(entry / maximum) * sin(CGFloat(index) * 2 * .pi / CGFloat(dataCount) - .pi / 2) * radius))
            default:
                path.addLine(to: CGPoint(x: midX + CGFloat(entry / maximum) * cos(CGFloat(index) * 2 * .pi / CGFloat(dataCount) - .pi / 2) * radius, y: midY + CGFloat(entry / maximum) * sin(CGFloat(index) * 2 * .pi / CGFloat(dataCount) - .pi / 2) * radius))
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
    let labels: [UserClass]
    
    @State private var dataLoad = false
    
    init(data: [Double], gridColor: Color, dataColor: Color, gridLineWidth: CGFloat, dataLineWidth: CGFloat, labels: [UserClass]) {
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
                    let label = labels[index].rawValue
                    let isMax = data.max() ?? 1.0 == data[index]
                    
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .position(x: point.x, y: point.y)
                        .foregroundColor(isMax ? labels[index].color : Color("secondary-text-color-weak"))
                            .shadow(color: .black.opacity(isMax ? 0.25 : 0), radius: 5)
                }
                
                RadarChartGrid(categories: data.count, divisions: 6)
                    .stroke(style: StrokeStyle(lineWidth: gridLineWidth, dash: [5]))
                    .foregroundColor(gridColor)
                
                RadarChartPath(data: data, maximum: (data.max() ?? 1.0))
                    .fill(dataColor.opacity(0.5))
                    .frame(height: dataLoad ? nil : 0)
                    .onAppear() {
                        withAnimation(.spring(response: 1.5)) {
                            dataLoad = true
                        }
                    }
                
                RadarChartPath(data: data, maximum: (data.max() ?? 1.0))
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
        RadarChartView(data: [0.2, 0.5, 0.8, 0.6, 0.4, 0.2, 0.1], gridColor: Color("main-point-color-weak"), dataColor: Color("main-point-color").opacity(0.5), gridLineWidth: 0.5, dataLineWidth: 2, labels: UserClass.allCases)
    }
}
