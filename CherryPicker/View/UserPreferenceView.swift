//
//  UserPreferenceView.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/07.
//

import SwiftUI

struct UserPreferenceView: View {
    private let columns = [
        GridItem(.adaptive(minimum: 350, maximum: .infinity), spacing: nil, alignment: .top)
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("체리체리1q2w3e님은,")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("main-point-color"))
                    
                    Spacer()
                }
                .padding(.vertical)
                
                LazyVGrid(columns: columns) {
                    userInitialPreference()
                    
                    userType()
                }
            }
            .padding(.horizontal)
        }
        .background(Color("background-color"))
        .navigationTitle("취향분석")
    }
    
    @ViewBuilder
    func contentBackground() -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color("background-shape-color"))
            .shadow(color: .black.opacity(0.1), radius: 2)
    }
    
    @ViewBuilder
    func userInitialPreference() -> some View {
        VStack(alignment: .leading) {
            Text("상위 1%의 취향이에요!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("main-point-color"))
                .padding(.bottom)
            
            VStack(alignment: .center, spacing: 15) {
                HStack {
                    Text("체리체리1q2w3e님의 취향태그")
                        .font(.caption)
                        .foregroundColor(Color("secondary-text-color-weak"))
                    
                    Spacer()
                }
                
                Group {
                    Text("음식이 맛있어요")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("특별한 메뉴가 있어요")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .opacity(0.9)
                    
                    Text("재료가 신선해요")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .opacity(0.8)
                    
                    Text("친절해요")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .opacity(0.7)
                    
                    Text("혼밥하기 좋아요")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .opacity(0.6)
                }
                .foregroundColor(Color("main-point-color"))
                .shadow(color: .black.opacity(0.1), radius: 10)
            }
            .padding()
            .background {
                contentBackground()
            }
            .padding(.bottom, 20)
        }
    }
    
    @ViewBuilder
    func userType() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                Text("혹시...")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-point-color"))
                    .padding(.bottom)
                
                Text(" 맛집탐방러")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("food-explorer-tag-color"))
                    .padding(.bottom)
                
                Text("이신가요?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-point-color"))
                    .padding(.bottom)
                
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text("체리체리1q2w3e님의 즐겨찾기 목록 분석 결과, ")
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-text-color"))
                + Text("맛집탐방러")
                    .fontWeight(.semibold)
                    .foregroundColor(Color("food-explorer-tag-color"))
                + Text(" 유형과 비슷해요!")
                    .fontWeight(.semibold)
                    .foregroundColor(Color("main-text-color"))
                
                VStack {
                    RadarChartView(data: [0.8, 0.2, 0.1, 0.15, 0.4, 0.3, 0.5], gridColor: Color("main-point-color-weak"), dataColor: Color("main-point-color").opacity(0.4), gridLineWidth: 0.5, dataLineWidth: 2, labels: ["맛집탐방러", "미니인플루언서", "건강식", "기타", "카페인 뱀파이어", "혼밥러", "술고래"])
                        .frame(height: 150)
                }
                .padding(.vertical, 40)
            }
            .padding()
            .background {
                contentBackground()
            }
        }
    }
}

struct UserPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UserPreferenceView()
                .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color("main-point-color"))
    }
}
