import SwiftUI

struct VenusGuideStepView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // 图标容器
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .symbolEffect(.bounce, options: .repeating)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .cornerRadius(16)
    }
}

struct VenusGuideView: View {
    @Binding var isShowingGuide: Bool
    let startSmileDetection: () -> Void
    @State private var showContent = false
    
    let steps = [
        (icon: "camera.fill", title: "Align with Venus", description: "Like Venus rising in the morning sky, position yourself to face the light", color: Color.yellow),
        (icon: "mouth.fill", title: "Share Your Radiance", description: "Let your smile shine bright like Venus, the brightest star in our sky", color: Color(red: 1.0, green: 0.7, blue: 0.3)),
        (icon: "sun.max.fill", title: "Embrace the Warmth", description: "Feel the golden warmth of Venus fill your heart with joy", color: Color(red: 1.0, green: 0.5, blue: 0.2))
    ]
    
    var body: some View {
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
            
            // 星星粒子效果
            EmotionParticleView()
                .opacity(0.6)
            
            // 内容
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 左侧内容
                    VStack(alignment: .leading, spacing: 36) {
                        // 标题区域
                        VStack(alignment: .leading, spacing: 16) {
                            Text("The Light of Venus")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.85, blue: 0.4),  // 明亮的金色
                                            Color(red: 1.0, green: 0.7, blue: 0.2)    // 深金色
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.5), radius: 10)
                            
                            Text("Your Guide to Inner Radiance")
                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.3))
                        }
                        .padding(.top, 50)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // 心理学描述
                        VStack(alignment: .leading, spacing: 24) {
                            descriptionSection(
                                title: "Venus's Embrace",
                                content: "Like Venus's warm glow in the morning sky, a smile can illuminate your entire being. This celestial light triggers the release of your body's natural joy - dopamine, endorphins, and serotonin.",
                                icon: "sparkles.tv.fill",
                                color: Color(red: 1.0, green: 0.7, blue: 0.3)
                            )
                            
                            descriptionSection(
                                title: "Mirror of Light",
                                content: "Just as Venus reflects the sun's light, your smile reflects your inner warmth. Even a gentle smile can transform your emotional landscape, creating ripples of positivity.",
                                icon: "rays",
                                color: Color(red: 1.0, green: 0.6, blue: 0.2)
                            )
                            
                            descriptionSection(
                                title: "Celestial Connection",
                                content: "Like Venus's eternal dance in our sky, your smile creates bonds that transcend the moment. It builds bridges of light between hearts, fostering warmth and understanding.",
                                icon: "sparkles",
                                color: Color(red: 1.0, green: 0.5, blue: 0.2)
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 32)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(Color.white.opacity(0.05))
                                
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.5)
                                
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.2),
                                                .white.opacity(0.1),
                                                .clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    .blur(radius: 2)
                                    .offset(y: 2)
                                    .mask(RoundedRectangle(cornerRadius: 32).fill(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)))
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .shadow(color: .white.opacity(0.05), radius: 20, x: 0, y: 10)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    }
                    .frame(width: geometry.size.width * 0.5)
                    .padding(.horizontal, 24)
                    
                    // 右侧内容
                    VStack {
                        Text("Journey to Venus")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.85, blue: 0.4),  // 明亮的金色
                                        Color(red: 1.0, green: 0.7, blue: 0.2)    // 深金色
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.5), radius: 10)
                            .padding(.top, 50)
                            .padding(.bottom, 20)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // 步骤说明
                        VStack(spacing: 12) {
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                VenusGuideStepView(
                                    icon: step.icon,
                                    title: step.title,
                                    description: step.description,
                                    color: step.color
                                )
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeOut.delay(Double(index) * 0.2), value: showContent)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        
                        // 开始按钮
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isShowingGuide = false
                                startSmileDetection()
                            }
                        } label: {
                            Text("Begin Your Celestial Journey")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .frame(height: 58)
                                .frame(width: 320)
                                .background(
                                    Capsule()
                                        .fill(Color.white)
                                        .shadow(color: .white.opacity(0.3), radius: 15)
                                )
                        }
                        .padding(.bottom, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    }
                    .frame(width: geometry.size.width * 0.45)
                }
            }
        }
        .transition(.opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }
    
    private func descriptionSection(title: String, content: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .symbolEffect(.pulse)
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(5)
        }
    }
} 