import SwiftUI

struct AnimatedAndromedaView: View {
    let progress: Double
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    
    var body: some View {
        ZStack {
            // Spiral galaxy effect
            ForEach(0..<5) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.8),
                                Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .scaleEffect(CGFloat(1 + Double(index) * 0.2) * scale)
                    .rotationEffect(.degrees(rotation + Double(index) * 15))
            }
            
            // Stars effect
            ForEach(0..<20) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 3, height: 3)
                    .offset(
                        x: CGFloat.random(in: -100...100),
                        y: CGFloat.random(in: -100...100)
                    )
                    .opacity(Double.random(in: 0.3...0.7))
                    .scaleEffect(scale)
            }
        }
        .frame(width: 300, height: 300)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

struct EmotionalAIView: View {
    @State private var pulseScale: CGFloat = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // AI core
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.8),
                            Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(pulseScale)
            
            // Orbiting emotion indicators
            ForEach(0..<6) { index in
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 10, height: 10)
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(index) * 60 + rotation))
            }
            
            // Connection lines
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2, height: 100)
                    .rotationEffect(.degrees(Double(index) * 120 + rotation))
            }
        }
        .frame(width: 300, height: 300)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct EmotionalGalaxyView: View {
    @State private var showRings = false
    @State private var rotation: Double = 0
    @State private var showStars = false
    @State private var showLines = false
    
    // 预定义星点位置，创建一个更自然的星座形状
    private let starPositions: [(CGFloat, CGFloat)] = [
        (-40, -60),  // 顶部星点
        (60, -20),   // 右上星点
        (40, 40),    // 右下星点
        (-60, 20),   // 左边星点
        (0, 0),      // 中心星点
        (-20, 60),   // 底部星点
        (20, -40),   // 右上方星点
        (-40, -20)   // 左上方星点
    ]
    
    var body: some View {
        ZStack {
            // 星座环
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        Color.white.opacity(0.2),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [5, 5]
                        )
                    )
                    .frame(width: CGFloat(100 + index * 70))
                    .rotationEffect(.degrees(rotation))
                    .opacity(showRings ? 1 : 0)
            }
            
            // 星座连线
            Path { path in
                // 创建一个更自然的星座图案
                path.move(to: CGPoint(x: starPositions[0].0, y: starPositions[0].1))
                path.addLine(to: CGPoint(x: starPositions[4].0, y: starPositions[4].1))
                path.addLine(to: CGPoint(x: starPositions[1].0, y: starPositions[1].1))
                path.move(to: CGPoint(x: starPositions[4].0, y: starPositions[4].1))
                path.addLine(to: CGPoint(x: starPositions[2].0, y: starPositions[2].1))
                path.move(to: CGPoint(x: starPositions[4].0, y: starPositions[4].1))
                path.addLine(to: CGPoint(x: starPositions[3].0, y: starPositions[3].1))
                path.move(to: CGPoint(x: starPositions[4].0, y: starPositions[4].1))
                path.addLine(to: CGPoint(x: starPositions[5].0, y: starPositions[5].1))
            }
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
            .opacity(showLines ? 1 : 0)
            
            // 星点
            ForEach(0..<starPositions.count, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: index == 4 ? 8 : 6, height: index == 4 ? 8 : 6) // 中心星点稍大
                    .position(x: 150 + starPositions[index].0, y: 150 + starPositions[index].1)
                    .opacity(showStars ? 1 : 0)
                    .blur(radius: 0.5) // 添加轻微模糊效果
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            .frame(width: index == 4 ? 10 : 8, height: index == 4 ? 10 : 8)
                            .opacity(showStars ? 1 : 0)
                    )
            }
        }
        .frame(width: 300, height: 300)
        .onAppear {
            // 按顺序显示各个元素
            withAnimation(.easeInOut(duration: 1.5)) {
                showRings = true
            }
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                showStars = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).delay(1.0)) {
                showLines = true
            }
            
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct AndromedaGuideView: View {
    @Binding var isShowingGuide: Bool
    let startChat: () -> Void
    
    @State private var currentPage = 0
    @State private var showingStars = false
    
    private let pages = [
        (title: "Journey to Andromeda",
         description: "Welcome to your celestial sanctuary,\nwhere stardust and emotions dance in cosmic harmony"),
        
        (title: "Celestial Companion",
         description: "Like starlight through cosmic winds,\nour advanced CoreML technology understands the whispers of your heart"),
        
        (title: "Your Constellation Story",
         description: "Three heartfelt conversations will illuminate your path,\nlike three bright stars forming your unique celestial signature")
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            if showingStars {
                // 添加粒子效果背景
                EmotionParticleView()
                    .opacity(0.6)
                    .colorMultiply(Color(red: 0.6, green: 0.4, blue: 0.8))  // 添加紫色调
                    .allowsHitTesting(false)  // 确保不会影响下面视图的交互
            }
            
            // Content
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        if currentPage > 0 {
                            withAnimation {
                                currentPage -= 1
                            }
                        } else {
                            isShowingGuide = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(currentPage == 0 ? "Close" : "Back")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // Step indicator
                    HStack(spacing: 4) {
                        Text("Step")
                            .font(.system(size: 15, weight: .medium))
                        Text("\(currentPage + 1)/\(pages.count)")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 0) {
                            Text(pages[index].title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 40)
                                .padding(.bottom, 40)
                            
                            // Dynamic content based on page
                            Group {
                                switch index {
                                case 0:
                                    AnimatedAndromedaView(progress: 1.0)
                                case 1:
                                    EmotionalAIView()
                                case 2:
                                    EmotionalGalaxyView()
                                default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 300)
                            
                            Text(pages[index].description)
                                .font(.system(size: 18, weight: .medium))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 40)
                                .padding(.top, 40)
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                .disabled(true)  // 禁用滑动切换
                
                // Bottom Navigation Area
                VStack(spacing: 20) {
                    // Progress Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: 16) {
                        if currentPage < pages.count - 1 {
                            // Continue Button
                            Button(action: {
                                withAnimation {
                                    currentPage += 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Continue")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 200, height: 50)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .shadow(color: Color.white.opacity(0.3), radius: 10)
                            }
                        } else {
                            // Start Journey Button
                            Button(action: {
                                withAnimation {
                                    isShowingGuide = false
                                    startChat()
                                }
                            }) {
                                Text("Begin Your Journey")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 200, height: 50)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.white.opacity(0.3), radius: 10)
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                showingStars = true
            }
        }
    }
}

#Preview {
    AndromedaGuideView(isShowingGuide: .constant(true), startChat: {})
} 