import SwiftUI

/// 横屏提示视图
struct LandscapePromptView: View {
    @Binding var isPortrait: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color(red: 0.1, green: 0.1, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // 星空粒子效果
                EmotionParticleView()
                    .opacity(0.6)
                
                // 主要内容
                VStack(spacing: geometry.size.height * 0.05) {
                    // 旋转图标
                    Image(systemName: "rotate.right")
                        .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.12))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isPortrait ? 0 : 90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isPortrait)
                    
                    VStack(spacing: geometry.size.height * 0.02) {
                        Text("Align with the Stars")
                            .font(.system(
                                size: min(geometry.size.width, geometry.size.height) * 0.05,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundColor(.white)
                        
                        Text("Rotate your device to landscape mode\nto begin your healing journey through the cosmos")
                            .font(.system(
                                size: min(geometry.size.width, geometry.size.height) * 0.03,
                                weight: .regular,
                                design: .rounded
                            ))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                    }
                }
                .frame(maxWidth: min(geometry.size.width * 0.8, 600)) // 限制最大宽度
                .frame(maxHeight: min(geometry.size.height * 0.6, 400)) // 限制最大高度
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // 使用 position 确保完全居中
            }
        }
    }
}

/// Main Interface
struct ContentView: View {
    @State private var showLaunchScreen = true
    @State private var isShowingGuide = true
    @State private var showGuideButton = false
    @State private var showCompletion = false
    @StateObject private var visionProcessor = VisionProcessor()
    @State private var isPortrait = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if geometry.size.width < geometry.size.height {
                    // 竖屏状态显示提示
                    LandscapePromptView(isPortrait: $isPortrait)
                        .onAppear { isPortrait = true }
                        .onDisappear { isPortrait = false }
                } else {
                    // 横屏状态显示主要内容
                    if showLaunchScreen {
                        LaunchView(showLaunchScreen: $showLaunchScreen)
                            .transition(.opacity)
                    } else {
                        SceneMenuView()
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
