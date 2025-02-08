import SwiftUI
import SceneKit

struct ArtisticCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var viewModel: ArtisticPlanetViewModel
    @State private var showShareSheet = false
    @State private var planetRotation: Double = 0
    @State private var showAnalysis = false
    @State private var showGuideText = false
    @State private var guideArrowOffset: CGFloat = -10
    @State private var shouldReturnToMenu = false
    
    // 添加文字动画状态
    @State private var textOpacity1: Double = 0
    @State private var textOpacity2: Double = 0
    @State private var textOpacity3: Double = 0
    @State private var finalTextScale: CGFloat = 0.8
    @State private var finalTextOpacity: Double = 0
    @State private var analysisOpacity: Double = 0
    
    // 引导文字动画
    @State private var guideTextOpacity: Double = 0
    @State private var guideArrowOpacity: Double = 0

    // 新增：分析文本内容
    private let analysisContent = [
        (
            title: "Creative Expression",
            content: "Your artistic journey shows exceptional emotional strength. Creative activities boost brain plasticity and enhance emotional well-being.",
            icon: "brain.head.profile",
            color: Color(red: 0.98, green: 0.36, blue: 0.35)  // SF Symbols 红色
        ),
        (
            title: "Emotional Growth",
            content: "Art therapy has helped reduce depressive symptoms by 62% through mindful creative engagement and emotional awareness.",
            icon: "heart.circle.fill",
            color: Color(red: 0.29, green: 0.85, blue: 0.42)  // SF Symbols 绿色
        ),
        (
            title: "Mental Clarity",
            content: "Scientific studies show that artistic expression reduces anxiety levels by 43%, promoting a state of flow and mental balance.",
            icon: "sparkles.square.filled.on.square",
            color: Color(red: 0.32, green: 0.59, blue: 0.95)  // SF Symbols 蓝色
        ),
        (
            title: "Healing Progress",
            content: "78% of participants report significant improvement in overall well-being through continued artistic practice.",
            icon: "chart.line.uptrend.xyaxis",
            color: Color(red: 1.0, green: 0.84, blue: 0.04)  // SF Symbols 黄色
        )
    ]

    // 添加星球移动动画状态
    @State private var planetOffset: CGFloat = 0
    @State private var planetScale: CGFloat = 1.0
    @State private var planetOpacity: Double = 1.0

    // 新增：背景文字数组
    private let backgroundTexts = [
        (text: "Art Heals the Soul", color: Color(red: 1.0, green: 0.85, blue: 0.4), scale: 1.15, rotation: -5, position: CGPoint(x: 0.15, y: 0.08)),
        (text: "Creative Therapy 2023", color: Color(red: 0.4, green: 0.8, blue: 1.0), scale: 1.1, rotation: -15, position: CGPoint(x: 0.4, y: 0.15)),
        (text: "Art Therapy Research", color: Color(red: 0.7, green: 0.4, blue: 1.0), scale: 0.9, rotation: 10, position: CGPoint(x: 0.85, y: 0.10)),
        (text: "81% Anxiety Reduction", color: Color(red: 1.0, green: 0.7, blue: 0.3), scale: 1.2, rotation: -8, position: CGPoint(x: 0.2, y: 0.85)),
        (text: "Healing Through Colors", color: Color(red: 0.3, green: 0.7, blue: 0.9), scale: 0.95, rotation: 12, position: CGPoint(x: 0.9, y: 0.75)),
        (text: "Express to Heal", color: Color(red: 0.8, green: 0.5, blue: 1.0), scale: 1.0, rotation: 15, position: CGPoint(x: 0.8, y: 0.5)),
        (text: "Global Art Movement", color: Color(red: 0.5, green: 0.8, blue: 0.9), scale: 1.05, rotation: -12, position: CGPoint(x: 0.25, y: 0.65)),
        (text: "Create Your Universe", color: Color(red: 1.0, green: 0.8, blue: 0.3), scale: 1.1, rotation: 8, position: CGPoint(x: 0.75, y: 0.9))
    ]
    
    // 添加动画状态
    @State private var backgroundTextScales: [CGFloat] = Array(repeating: 1.0, count: 8)
    @State private var backgroundTextOpacities: [Double] = Array(repeating: 0.0, count: 8)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.edgesIgnoringSafeArea(.all)
                
                // 星空效果
                EmotionParticleView()
                    .opacity(0.6)
                
                // 添加背景说明文字
                ForEach(backgroundTexts.indices, id: \.self) { index in
                    let text = backgroundTexts[index]
                    Text(text.text)
                        .font(.system(size: index % 2 == 0 ? 16 : 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    text.color,
                                    text.color.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: text.color.opacity(0.8), radius: 15, x: 0, y: 0)
                        .shadow(color: text.color.opacity(0.4), radius: 5, x: 0, y: 0)
                        .opacity(backgroundTextOpacities[index])
                        .scaleEffect(backgroundTextScales[index] * text.scale)
                        .position(
                            x: geometry.size.width * text.position.x,
                            y: geometry.size.height * text.position.y
                        )
                        .rotationEffect(.degrees(Double(text.rotation)))
                        .blur(radius: 0.6)
                }

                // 内容容器
                HStack(spacing: 0) {
                    // 左侧：3D星球场景
                    ZStack {
                        // 发光效果
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: geometry.size.width * 0.3
                                )
                            )
                            .frame(width: 600, height: 600)
                            .blur(radius: 30)
                        
                        // 3D场景
                        Planet3DSceneView(viewModel: viewModel)
                            .frame(width: 500, height: 500)
                            .rotationEffect(.degrees(planetRotation))
                            .offset(x: planetOffset)
                            .scaleEffect(planetScale)
                            .opacity(planetOpacity)
                            .onTapGesture {
                                // 添加星球移动动画
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    planetOffset = geometry.size.width * 0.5
                                    planetScale = 0.8
                                    planetOpacity = 0
                                }
                                
                                // 延迟返回以等待动画完成
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    // 获取所有呈现的视图控制器
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let window = windowScene.windows.first,
                                       let rootViewController = window.rootViewController {
                                        // 关闭所有呈现的视图控制器
                                        rootViewController.dismiss(animated: true)
                                    }
                                }
                            }
                        
                        // 引导文字和箭头
                        if showGuideText {
                            VStack(spacing: 15) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                                    .offset(y: guideArrowOffset)
                                    .opacity(guideArrowOpacity)
                                
                                Text("Tap planet to return menu")
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                                    .opacity(guideTextOpacity)
                            }
                            .offset(y: 280)
                            .opacity(planetOpacity) // 让引导文字跟随星球一起淡出
                        }
                    }
                    .frame(width: geometry.size.width * 0.5)
                    
                    // 右侧：文字内容
                    VStack(alignment: .leading, spacing: 0) {
                        if !showAnalysis {
                            Spacer()
                                .frame(height: 100)
                            
                            Text("In the depths of healing")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.8, blue: 1.0),
                                            Color(red: 0.2, green: 0.6, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(textOpacity1)
                                .padding(.bottom, 40)
                            
                            Text("art becomes medicine")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.7, green: 0.4, blue: 1.0),
                                            Color(red: 0.5, green: 0.2, blue: 0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(textOpacity2)
                                .padding(.bottom, 40)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("81% of patients")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.8, blue: 1.0),
                                                Color(red: 0.2, green: 0.6, blue: 0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("reported reduced anxiety")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.8, blue: 1.0),
                                                Color(red: 0.2, green: 0.6, blue: 0.8)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                HStack(spacing: 12) {
                                    Text("through")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("art therapy")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.4, green: 0.8, blue: 1.0),
                                                    Color(red: 0.2, green: 0.6, blue: 0.8)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .scaleEffect(finalTextScale)
                                        .opacity(finalTextOpacity)
                                    
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 20))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.8, blue: 0.3),
                                                    Color(red: 1.0, green: 0.6, blue: 0.2)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .opacity(finalTextOpacity)
                                        .symbolEffect(.bounce, options: .repeating)
                                }
                            }
                            .opacity(textOpacity3)
                        } else {
                            // 分析内容视图
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach(analysisContent, id: \.title) { analysis in
                                        VStack(alignment: .leading, spacing: 14) {
                                            HStack(spacing: 12) {
                                                Image(systemName: analysis.icon)
                                                    .font(.system(size: 24, weight: .medium))
                                                    .foregroundColor(analysis.color)
                                                    .frame(width: 32, height: 32)
                                                
                                                Text(analysis.title)
                                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(analysis.content)
                                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                                .foregroundColor(.white.opacity(0.9))
                                                .lineSpacing(6)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .padding(.leading, 44)  // 对齐图标
                                        }
                                        .padding(20)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    .ultraThinMaterial.opacity(0.7)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(analysis.color.opacity(0.08))
                                                )
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                                    }
                                }
                                .padding(.top, 80)
                                .opacity(analysisOpacity)
                            }
                            .scrollIndicators(.hidden)
                        }

                        // 分析按钮
                        if textOpacity3 == 1 && finalTextOpacity == 1 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    showAnalysis.toggle()
                                    if showAnalysis {
                                        analysisOpacity = 1
                                    } else {
                                        textOpacity1 = 1
                                        textOpacity2 = 1
                                        textOpacity3 = 1
                                        finalTextOpacity = 1
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: showAnalysis ? "chevron.left" : "chart.bar.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .imageScale(.medium)
                                    Text(showAnalysis ? "Back" : "View Insights")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, 30)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(width: geometry.size.width * 0.5)
                }
            }
        }
        .onAppear {
            // 星球旋转动画
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                planetRotation = 360
            }
            
            // 文字动画序列
            withAnimation(.easeIn(duration: 1.2).delay(1.5)) {
                textOpacity1 = 1
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(3.0)) {
                textOpacity2 = 1
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(4.5)) {
                textOpacity3 = 1
            }
            
            // 最后一行文字的特殊动画
            withAnimation(.spring(response: 1, dampingFraction: 0.8).delay(5.0)) {
                finalTextScale = 1.0
                finalTextOpacity = 1
            }
            
            // 如果显示分析内容，添加渐入动画
            if showAnalysis {
                withAnimation(.easeIn(duration: 1.2)) {
                    analysisOpacity = 1
                }
            }
            
            // 背景文字动画
            for index in backgroundTexts.indices {
                // 延迟显示每个文字
                withAnimation(.easeIn(duration: 1.5).delay(Double(index) * 0.3 + 2.0)) {
                    backgroundTextOpacities[index] = 0.7
                }
                
                // 添加呼吸动画
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.5)
                ) {
                    backgroundTextScales[index] = 1.1
                }
            }
            
            // 延迟显示引导文字和箭头
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                showGuideText = true
                withAnimation(.easeInOut(duration: 1.0)) {
                    guideTextOpacity = 1
                    guideArrowOpacity = 1
                }
                
                // 箭头上下浮动动画
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    guideArrowOffset = -20
                }
            }
        }
    }
}

// 分享功能
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 