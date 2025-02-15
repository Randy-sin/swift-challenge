import SwiftUI

struct TranscendenceView: View {
    @StateObject private var effect = OceanusTranscendenceEffect()
    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @State private var rippleScale: CGFloat = 1.0
    @State private var baseRotation: Double = 0
    @State private var showFinishButton: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    private let baseSize: CGFloat = 180
    
    var body: some View {
        ZStack {
            // 主要内容
            GeometryReader { geometry in
                ZStack {
                    // 背景光效
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(hue: 0.6, saturation: 0.8, brightness: 0.3).opacity(0.3),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: geometry.size.width/2
                    )
                    .scaleEffect(scale)
                    .opacity(glowOpacity)
                    
                    // 水波纹效果
                    if effect.currentState == .rippling {
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    Color(
                                        hue: 0.6,
                                        saturation: 0.8,
                                        brightness: 1.0
                                    ).opacity(0.3 - Double(index) * 0.1),
                                    lineWidth: 1.5
                                )
                                .frame(width: baseSize)
                                .scaleEffect(rippleScale + CGFloat(index) * 0.5)
                                .opacity((1.0 - effect.progress) * 0.8)
                        }
                    }
                    
                    // 中心光球
                    ZStack {
                        // 外部光晕
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hue: 0.6, saturation: 0.8, brightness: 1.0).opacity(0.5),
                                        Color(hue: 0.6, saturation: 0.7, brightness: 0.9).opacity(0.0)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: baseSize/1.5
                                )
                            )
                            .frame(width: baseSize * 1.2)
                            .scaleEffect(scale)
                            .blur(radius: 15)
                        
                        // 核心光球
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hue: 0.6, saturation: 0.8, brightness: 1.0),
                                        Color(hue: 0.6, saturation: 0.7, brightness: 0.9).opacity(0.5)
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: baseSize/2
                                )
                            )
                            .frame(width: baseSize)
                            .scaleEffect(scale)
                            .shadow(color: Color(hue: 0.6, saturation: 0.8, brightness: 1.0).opacity(0.5), radius: 20)
                    }
                    
                    // 装饰性光环
                    ForEach(0..<5) { index in
                        Circle()
                            .stroke(
                                Color(
                                    hue: 0.6,
                                    saturation: 0.8,
                                    brightness: 1.0
                                ).opacity(0.15),
                                lineWidth: 0.5
                            )
                            .frame(width: baseSize + CGFloat(index * 40))
                            .rotationEffect(.degrees(baseRotation + Double(index) * 15))
                    }
                    
                    // 粒子效果
                    if effect.currentState == .ascending || effect.currentState == .resonating {
                        ParticleEffect(progress: effect.progress, baseSize: baseSize)
                            .transition(.opacity)
                    }
                }
            }
            
            // 完成按钮
            if showFinishButton {
                VStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.8)) {
                            dismiss()
                        }
                    }) {
                        Text("Journey Complete")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .fill(Color(hue: 0.6, saturation: 0.8, brightness: 0.8))
                                    .shadow(color: Color(hue: 0.6, saturation: 0.8, brightness: 1.0).opacity(0.5), radius: 10)
                            )
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 50)
                }
            }
        }
        .onChange(of: effect.currentState) { oldState, newState in
            if newState == .finished {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showFinishButton = true
                }
            }
        }
        .onAppear {
            startAnimations()
            effect.start()
        }
        .onDisappear {
            effect.stop()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 1.2)) {
            glowOpacity = 1
            scale = 1.2
        }
        
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            baseRotation = 360
        }
        
        withAnimation(
            .easeInOut(duration: 2)
            .repeatForever(autoreverses: true)
        ) {
            rippleScale = 1.5
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .edgesIgnoringSafeArea(.all)
        TranscendenceView()
    }
} 