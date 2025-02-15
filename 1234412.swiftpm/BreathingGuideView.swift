import SwiftUI

struct BreathingGuideView: View {
    @StateObject private var viewModel = BreathingViewModel()
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @State private var textScale: CGFloat = 0.8
    @State private var blurRadius: CGFloat = 0
    
    private let baseCircleSize: CGFloat = 180
    
    var body: some View {
        ZStack {
            if viewModel.showTranscendence {
                // 显示升华效果
                TranscendenceView()
                    .transition(.opacity)
            } else {
                // 原有的呼吸引导视图
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Breathing animation view
                    ZStack {
                        // Decorative outer circles
                        ForEach(0..<8) { index in
                            Circle()
                                .stroke(
                                    viewModel.currentPhase.color.opacity(0.15),
                                    lineWidth: 0.5
                                )
                                .frame(width: baseCircleSize + CGFloat(index * 25))
                                .rotationEffect(.degrees(rotation + Double(index) * 8))
                                .blur(radius: blurRadius)
                        }
                        
                        // Main breathing circle
                        ZStack {
                            // Outer glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            viewModel.currentPhase.color.opacity(0.3),
                                            viewModel.currentPhase.color.opacity(0.05)
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: baseCircleSize/1.5
                                    )
                                )
                                .frame(width: baseCircleSize * 1.2, height: baseCircleSize * 1.2)
                                .scaleEffect(scale)
                                .blur(radius: 15)
                            
                            // Main breathing circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            viewModel.currentPhase.color.opacity(0.6),
                                            viewModel.currentPhase.color.opacity(0.2)
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: baseCircleSize/2
                                    )
                                )
                                .frame(width: baseCircleSize, height: baseCircleSize)
                                .scaleEffect(scale)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            viewModel.currentPhase.color.opacity(0.8),
                                            lineWidth: 1.5
                                        )
                                        .scaleEffect(scale)
                                )
                                .shadow(color: viewModel.currentPhase.color.opacity(0.3), radius: 20, x: 0, y: 0)
                        }
                        
                        // Breathing guide text
                        VStack(spacing: 12) {
                            Text(viewModel.currentPhase.description)
                                .font(.system(size: 32, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                                .scaleEffect(textScale)
                            
                            Text(viewModel.currentPhase.guideText)
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .scaleEffect(textScale)
                            
                            if viewModel.currentCycleCount > 0 {
                                Text("Round \(viewModel.currentCycleCount) of 3")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.top, 8)
                            }
                        }
                        .blur(radius: blurRadius * 0.3)
                    }
                    .opacity(opacity)
                    
                    Spacer()
                    
                    // 进度条容器
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 30)
                        
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(
                                ModernProgressViewStyle(
                                    color: viewModel.currentPhase.color,
                                    height: 4
                                )
                            )
                            .frame(width: 200)
                    }
                    .opacity(opacity)
                    .padding(.bottom, 80)
                }
            }
        }
        .animation(.easeInOut(duration: 0.8), value: viewModel.showTranscendence)
        .onChange(of: viewModel.currentPhase) { oldValue, newValue in
            switch newValue {
            case .inhale:
                withAnimation(.easeInOut(duration: newValue.duration)) {
                    scale = newValue.scale
                    blurRadius = 5
                }
                
            case .hold:
                scale = oldValue.scale
                withAnimation(.easeInOut(duration: 1.0)) {
                    blurRadius = 2
                }
                
            case .exhale:
                withAnimation(.easeInOut(duration: newValue.duration)) {
                    scale = newValue.scale
                    blurRadius = 0
                }
            }
            
            // 文字动画
            withAnimation(.spring(duration: 0.6)) {
                textScale = 0.8
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(duration: 0.6)) {
                        textScale = 1.0
                    }
                }
            }
        }
        .onAppear {
            scale = 1.0
            opacity = 0
            blurRadius = 0
            
            withAnimation(.easeIn(duration: 1.2)) {
                opacity = 1.0
            }
            
            withAnimation(
                .linear(duration: 25)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.startBreathing()
            }
        }
        .onDisappear {
            viewModel.stopBreathing()
        }
    }
}

// Modern progress bar style
struct ModernProgressViewStyle: ProgressViewStyle {
    var color: Color
    var height: CGFloat = 4
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .frame(height: height)
                    .foregroundColor(color.opacity(0.15))
                
                // Progress bar
                Capsule()
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: height)
                    .foregroundColor(color.opacity(0.8))
                    .shadow(color: color.opacity(0.3), radius: 3, x: 0, y: 0)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        BreathingGuideView()
    }
} 