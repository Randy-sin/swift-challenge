import SwiftUI
import os

// MARK: - 日志系统
private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.randy.smiledetector",
    category: "VenusGuideView"
)

// MARK: - 错误处理
private struct ViewError: LocalizedError {
    let description: String
    var errorDescription: String? { description }
}

struct VenusGuideStepView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    @State private var isIconLoaded = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {  // 改为顶部对齐
            // 图标容器
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                
                if isIconLoaded {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                        .symbolEffect(.bounce, options: .repeating)
                } else {
                    // 加载中状态
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: color))
                        .scaleEffect(0.8)
                }
            }
            .onAppear {
                print("⚠️ Debug: Creating icon container for \(title)")
                print("🔍 Icon name: \(icon)")
                
                // 验证系统图标是否存在
                if UIImage(systemName: icon) != nil {
                    print("✅ Icon loaded successfully: \(icon)")
                    isIconLoaded = true
                } else {
                    print("❌ Error: System icon not found: \(icon)")
                    isIconLoaded = true
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {  // 增加垂直间距
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)  // 确保文字完整显示
                    .lineSpacing(4)
            }
            .padding(.trailing, 16)  // 添加右侧边距
        }
        .padding(20)  // 增加整体内边距
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

// MARK: - 主视图
struct VenusGuideView: View {
    @Binding var isShowingGuide: Bool
    let startSmileDetection: () -> Void
    @State private var showContent = false
    @State private var showError = false
    @State private var error: Error?
    
    let steps = [
        (icon: "camera.fill", title: "Align with Venus", description: "Like Venus rising in the morning sky, position yourself to face the light", color: Color.yellow),
        (icon: "mouth.fill", title: "Share Your Radiance", description: "Let your smile shine bright like Venus, the brightest star in our sky", color: Color(red: 1.0, green: 0.7, blue: 0.3)),
        (icon: "sun.max.fill", title: "Embrace the Warmth", description: "Feel the golden warmth of Venus fill your heart with joy", color: Color(red: 1.0, green: 0.5, blue: 0.2))
    ]
    
    public var body: some View {
        ZStack {
            backgroundView
            
            if showContent {
                EmotionParticleView()
                    .opacity(0.6)
            }
            
            ScrollView {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 36) {
                            titleSection
                            descriptionSection
                            Spacer(minLength: 60)  // 添加底部间距
                        }
                        .frame(width: geometry.size.width * 0.5)
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 32) {
                            journeyTitle
                            stepsSection
                            Spacer()  // 让内容靠上
                            startButton  // 将按钮移到这里
                                .padding(.bottom, 40)
                        }
                        .frame(width: geometry.size.width * 0.45)
                    }
                }
            }
        }
        .transition(.opacity)
        .onAppear {
            logger.debug("VenusGuideView appeared")
            startViewInitialization()
        }
        .onDisappear {
            logger.debug("VenusGuideView disappeared")
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(error?.localizedDescription ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - 私有视图组件
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),
                Color(red: 0.1, green: 0.1, blue: 0.25)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The Light of Venus")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.85, blue: 0.4),
                            Color(red: 1.0, green: 0.7, blue: 0.2)
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
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 32) {  // 增加描述卡片之间的间距
            descriptionItem(
                title: "Venus's Embrace",
                content: "Like Venus's warm glow in the morning sky, a smile can illuminate your entire being. This celestial light triggers the release of your body's natural joy - dopamine, endorphins, and serotonin.",
                icon: "sparkles.tv.fill",
                color: Color(red: 1.0, green: 0.7, blue: 0.3)
            )
            
            descriptionItem(
                title: "Mirror of Light",
                content: "Just as Venus reflects the sun's light, your smile reflects your inner warmth. Even a gentle smile can transform your emotional landscape, creating ripples of positivity.",
                icon: "rays",
                color: Color(red: 1.0, green: 0.6, blue: 0.2)
            )
            
            descriptionItem(
                title: "Celestial Connection",
                content: "Like Venus's eternal dance in our sky, your smile creates bonds that transcend the moment. It builds bridges of light between hearts, fostering warmth and understanding.",
                icon: "sparkles",
                color: Color(red: 1.0, green: 0.5, blue: 0.2)
            )
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 32)
        .background(descriptionBackground)
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    private var descriptionBackground: some View {
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
        }
    }
    
    private var journeyTitle: some View {
        Text("Journey to Venus")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.4),
                        Color(red: 1.0, green: 0.7, blue: 0.2)
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
    }
    
    private var stepsSection: some View {
        VStack(spacing: 32) {  // 增加卡片之间的间距
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                VStack(spacing: 16) {  // 增加箭头和卡片之间的间距
                    VenusGuideStepView(
                        icon: step.icon,
                        title: step.title,
                        description: step.description,
                        color: step.color
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut.delay(Double(index) * 0.2), value: showContent)
                    
                    // 在每个卡片下方添加箭头，除了最后一个
                    if index < steps.count - 1 {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.85, blue: 0.4),
                                        Color(red: 1.0, green: 0.7, blue: 0.2)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(showContent ? 0.6 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut.delay(Double(index) * 0.2 + 0.1), value: showContent)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var startButton: some View {
        Button {
            logger.debug("Start button tapped")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isShowingGuide = false
                startSmileDetection()
            }
        } label: {
            Text("Begin Your Celestial Journey")  // 恢复完整文字
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .frame(height: 46)
                .frame(width: 240)  // 稍微增加宽度以适应更长的文字
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: .white.opacity(0.3), radius: 10)
                )
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
    }
    
    // MARK: - 私有方法
    private func startViewInitialization() {
        logger.debug("Starting view initialization")
        let start = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            
            let end = CFAbsoluteTimeGetCurrent()
            logger.debug("View initialized in \(end - start) seconds")
        }
    }
    
    private func descriptionItem(title: String, content: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {  // 增加间距
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
                .fixedSize(horizontal: false, vertical: true)  // 确保文字完整显示
                .lineSpacing(5)
        }
        .padding(.horizontal, 20)  // 增加水平内边距
        .padding(.vertical, 16)    // 增加垂直内边距
    }
}

// MARK: - 预览
#Preview {
    VenusGuideView(isShowingGuide: .constant(true), startSmileDetection: {})
} 