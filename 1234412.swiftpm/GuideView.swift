import SwiftUI

struct GuideView: View {
    @Binding var isShowingGuide: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // 背景使用模糊效果
            Color.black
                .opacity(colorScheme == .dark ? 0.9 : 0.8)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 0.5)
            
            VStack(spacing: 40) {
                // 标题区域
                VStack(spacing: 16) {
                    Text("Perfect Smile")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Follow these steps to capture your best smile")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // 示例图片
                ZStack {
                    Image("GuideImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                }
                .frame(width: 260, height: 260)
                
                // 指导步骤
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(guideSteps.indices, id: \.self) { index in
                        GuideStep(number: index + 1, text: guideSteps[index])
                            .transition(.slide)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.1))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                )
                
                // 关闭按钮
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowingGuide = false
                    }
                }) {
                    Text("Got it!")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(30)
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private let guideSteps = [
        "Face the camera directly",
        "Keep your head straight",
        "Show your teeth naturally",
        "Make a genuine smile"
    ]
}

// 引导步骤组件
struct GuideStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            // 数字指示器
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Text("\(number)")
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .lineSpacing(4)
        }
        .opacity(0.95)
    }
}

// 按钮动画样式
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
} 