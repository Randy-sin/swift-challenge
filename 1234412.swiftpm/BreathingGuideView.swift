import SwiftUI

struct BreathingGuideView: View {
    @StateObject private var viewModel = BreathingViewModel()
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    private let baseCircleSize: CGFloat = 150
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 呼吸动画视图
            ZStack {
                // 外层装饰圆环
                ForEach(0..<6) { index in
                    Circle()
                        .stroke(
                            viewModel.currentPhase.color.opacity(0.2),
                            lineWidth: 1
                        )
                        .frame(width: baseCircleSize + CGFloat(index * 20))
                        .rotationEffect(.degrees(rotation + Double(index) * 10))
                }
                
                // 主呼吸圆圈
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                viewModel.currentPhase.color.opacity(0.5),
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
                            .stroke(viewModel.currentPhase.color, lineWidth: 2)
                            .scaleEffect(scale)
                    )
                    .animation(viewModel.currentPhase.animation, value: scale)
                
                // 呼吸提示文字
                VStack(spacing: 8) {
                    Text(viewModel.currentPhase.description)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                    if viewModel.currentCycleCount > 0 {
                        Text("第 \(viewModel.currentCycleCount) 组")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .onChange(of: viewModel.currentPhase) { oldValue, newValue in
                updateAnimation(for: newValue)
            }
            
            Spacer()
            
            // 进度指示器
            VStack(spacing: 15) {
                // 当前阶段进度
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(
                        CustomProgressViewStyle(
                            color: viewModel.currentPhase.color
                        )
                    )
                    .frame(width: 250)
                
                // 总体进度
                ProgressView(value: viewModel.totalProgress)
                    .progressViewStyle(
                        CustomProgressViewStyle(
                            color: .white,
                            height: 2
                        )
                    )
                    .frame(width: 200)
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            viewModel.startBreathing()
            // 开始旋转动画
            withAnimation(
                .linear(duration: 20)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
        .onDisappear {
            viewModel.stopBreathing()
        }
    }
    
    private func updateAnimation(for phase: BreathingPhase) {
        withAnimation(phase.animation) {
            scale = phase.scale
        }
    }
}

// 自定义进度条样式
struct CustomProgressViewStyle: ProgressViewStyle {
    var color: Color
    var height: CGFloat = 4
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height/2)
                    .frame(height: height)
                    .foregroundColor(color.opacity(0.2))
                
                RoundedRectangle(cornerRadius: height/2)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: height)
                    .foregroundColor(color)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        BreathingGuideView()
    }
} 