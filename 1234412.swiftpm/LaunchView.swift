import SwiftUI

struct LaunchView: View {
    @Binding var showLaunchScreen: Bool
    @State private var textOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var particleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 50
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // 情绪粒子系统
            EmotionParticleView()
                .opacity(particleOpacity)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                // 主标题区域
                VStack(spacing: 16) {
                    Text("EmotionGalaxy")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                    
                    Text("Where Emotions Find Their Light")
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)
                }
                
                Spacer()
                    .frame(height: 100)
                
                // 内容区域
                VStack(spacing: 32) {
                    // 主要信息
                    VStack(spacing: 12) {
                        Text("In the darkest nights of depression")
                            .font(.system(size: 34, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)
                        
                        Text("each star represents")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)
                        
                        Text("a reason to hold on")
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .opacity(textOpacity)
                    }
                    
                    // 支持信息
                    Text("Let's find your light together")
                        .font(.system(size: 22, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .padding(.top, 8)
                }
                .frame(maxWidth: 600)  // 限制内容宽度
                
                Spacer()
                
                // 按钮区域
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showMenu = true
                        showLaunchScreen = false
                    }
                }) {
                    Text("Begin Healing Journey")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                        .blur(radius: 4)
                                )
                        )
                        .shadow(color: .white.opacity(0.1), radius: 10)
                }
                .opacity(buttonOpacity)
                .scaleEffect(buttonOpacity)
                
                Spacer()
                    .frame(height: 60)
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            // 动画序列
            withAnimation(.easeOut(duration: 2)) {
                particleOpacity = 1
            }
            
            withAnimation(.spring(response: 1, dampingFraction: 0.8).delay(0.5)) {
                titleOpacity = 1
                titleOffset = 0
            }
            
            withAnimation(.easeOut(duration: 2).delay(1.5)) {
                textOpacity = 1
            }
            
            withAnimation(.spring(response: 1, dampingFraction: 0.8).delay(2.5)) {
                buttonOpacity = 1
            }
        }
    }
} 