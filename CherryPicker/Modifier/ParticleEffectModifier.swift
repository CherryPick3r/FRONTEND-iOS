//
//  ParticleEffectModifier.swift
//  CherryPicker
//
//  Created by 김도형 on 2023/05/14.
//

import SwiftUI

struct Particle: Identifiable {
    var id: UUID = .init()
    var randomX: CGFloat = 0
    var randomY: CGFloat = 0
    var scale: CGFloat = 1
    var opacity: CGFloat = 1
    
    mutating func reset() {
        randomX = 0
        randomY = 0
        scale = 1
        opacity = 1
    }
}

struct ParticleModifier: ViewModifier {
    var systemImage: String
    var status: Bool
    
    @State private var particles: [Particle] = []
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                ZStack {
                    ForEach(particles) { particle in
                        Image(systemName: systemImage)
                            .scaleEffect(particle.scale)
                            .offset(x: particle.randomX, y: particle.randomY)
                            .opacity(particle.opacity)
                            .opacity(status ? 1 : 0)
                            .animation(.none, value: status)
                    }
                }
                .onAppear() {
                    if particles.isEmpty {
                        for _ in 1...20 {
                            let particle = Particle()
                            particles.append(particle)
                        }
                    }
                }
                .onChange(of: status) { newValue in
                    if !newValue {
                        for index in particles.indices {
                            particles[index].reset()
                        }
                    } else {
                        for index in particles.indices {
                            let total: CGFloat = CGFloat(particles.count)
                            let progress: CGFloat = CGFloat(index) / total
                            
                            let maxX: CGFloat = (progress > 0.5) ? 70 : -70
                            let maxY: CGFloat = 60
                            
                            let randomX: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxX)
                            let randomY: CGFloat = ((progress > 0.5 ? progress - 0.5 : progress) * maxY)
                            let randomScale: CGFloat = .random(in: 0.35...1)
                            
                            withAnimation(.spring(response: 1.2)) {
                                let extraRandomX: CGFloat = (progress < 0.5) ? .random(in: -5...10) : .random(in: -10...5)
                                let extraRandomY: CGFloat = .random(in: 0...30)
                                particles[index].randomX = randomX + extraRandomX
                                particles[index].randomY = -randomY - 35 - extraRandomY
                            }
                            
                            withAnimation(.easeInOut) {
                                particles[index].scale = randomScale
                            }
                            
                            withAnimation(.spring(response: 1.2).delay(Double(index) * 0.03)) {
                                particles[index].scale = 0.001
                            }
                        }
                    }
                }
            }
    }
}
