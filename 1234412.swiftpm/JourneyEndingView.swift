import SwiftUI

struct JourneyEndingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var offset: CGFloat = UIScreen.main.bounds.height  // 初始位置设置为屏幕高度
    @State private var isDragging = false
    @State private var showContent = false
    @GestureState private var dragOffset: CGFloat = 0
    
    private let scrollDuration: Double = 90.0
    
    // 定义星球主题色
    private let venusColor = Color(red: 1.0, green: 0.85, blue: 0.4)
    private let artisticColor = Color(red: 0.4, green: 0.8, blue: 1.0)
    private let oceanusColor = Color(red: 0.1, green: 0.4, blue: 0.8)
    private let andromedaColor = Color(red: 0.6, green: 0.4, blue: 0.8)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black
                    .ignoresSafeArea()
                
                // 星星背景
                ForEach(0..<150) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...4))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Double.random(in: 0.2...0.7))
                }
                
                // 文字内容
                ScrollView {
                    VStack(spacing: 40) {
                        // 标题
                        Text("A Journey Through Your Emotional Cosmos")
                            .font(.custom("SF Pro Display", size: 56))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, geometry.size.height * 0.3)
                            .padding(.horizontal, 40)
                        
                        Text("•••")
                            .font(.custom("SF Pro Display", size: 32))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 32)
                        
                        // Venus 部分
                        VStack(spacing: 32) {
                            Text("~ Venus ~")
                                .font(.custom("SF Pro Display", size: 48, relativeTo: .title))
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("The Golden Light of Joy")
                                .font(.custom("SF Pro Display", size: 36))
                                .fontWeight(.light)
                                .opacity(0.9)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("""
                            In the warm radiance of Venus,
                            we discovered that happiness
                            is not just an emotion,
                            but a beacon that guides others
                            through their darkest moments.
                            """)
                            .font(.custom("SF Pro Display", size: 32))
                            .fontWeight(.regular)
                            .lineSpacing(20)
                            .opacity(0.85)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            .padding(.top, 16)
                        }
                        .foregroundColor(venusColor)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 32)
                        
                        Text("•••")
                            .font(.custom("SF Pro Display", size: 32))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 40)
                        
                        // Artistic 部分
                        VStack(spacing: 24) {
                            Text("~ Artistic ~")
                                .font(.custom("SF Pro Display", size: 40, relativeTo: .title))
                                .fontWeight(.medium)
                            Text("The Canvas of the Soul")
                                .font(.custom("SF Pro Display", size: 32))
                                .fontWeight(.light)
                                .opacity(0.9)
                            Text("""
                            Within the azure expanse of creativity,
                            we learned that every emotion
                            deserves to be expressed,
                            painted across the cosmic canvas
                            of our inner universe.
                            """)
                            .font(.custom("SF Pro Display", size: 28))
                            .fontWeight(.regular)
                            .lineSpacing(16)
                            .opacity(0.85)
                            .padding(.top, 8)
                        }
                        .foregroundColor(artisticColor)
                        
                        Text("•••")
                            .font(.custom("SF Pro Display", size: 32))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 24)
                        
                        // Oceanus 部分
                        VStack(spacing: 24) {
                            Text("~ Oceanus ~")
                                .font(.custom("SF Pro Display", size: 40, relativeTo: .title))
                                .fontWeight(.medium)
                            Text("The Deep Blue of Tranquility")
                                .font(.custom("SF Pro Display", size: 32))
                                .fontWeight(.light)
                                .opacity(0.9)
                            Text("""
                            In the depths of Oceanus,
                            we found that peace flows
                            like celestial tides,
                            teaching us to breathe
                            in harmony with the cosmos.
                            """)
                            .font(.custom("SF Pro Display", size: 28))
                            .fontWeight(.regular)
                            .lineSpacing(16)
                            .opacity(0.85)
                            .padding(.top, 8)
                        }
                        .foregroundColor(oceanusColor)
                        
                        Text("•••")
                            .font(.custom("SF Pro Display", size: 32))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 24)
                        
                        // Andromeda 部分
                        VStack(spacing: 24) {
                            Text("~ Andromeda ~")
                                .font(.custom("SF Pro Display", size: 40, relativeTo: .title))
                                .fontWeight(.medium)
                            Text("The Purple Bridge of Connection")
                                .font(.custom("SF Pro Display", size: 32))
                                .fontWeight(.light)
                                .opacity(0.9)
                            Text("""
                            Among the starlit paths of Andromeda,
                            we realized that understanding
                            flows between hearts like
                            stardust between galaxies.
                            """)
                            .font(.custom("SF Pro Display", size: 28))
                            .fontWeight(.regular)
                            .lineSpacing(16)
                            .opacity(0.85)
                            .padding(.top, 8)
                        }
                        .foregroundColor(andromedaColor)
                        
                        Text("•••")
                            .font(.custom("SF Pro Display", size: 32))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 24)
                        
                        // 结语部分
                        VStack(spacing: 48) {
                            Text("Dear Cosmic Voyager")
                                .font(.custom("SF Pro Display", size: 48))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("""
                            Your journey through these celestial realms
                            has illuminated more than just stars -
                            it has lit the way for others who walk
                            similar paths through their own universe.
                            
                            Remember that your emotions are not
                            mere moments in time, but rather
                            constellations that guide and inspire.
                            
                            Your smile is a sunrise for someone in darkness
                            Your art is a galaxy born from feelings
                            Your breath is the rhythm of cosmic peace
                            Your words are bridges between souls
                            """)
                            .font(.custom("SF Pro Display", size: 32))
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(20)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: geometry.size.width * 0.8)
                            
                            Text("•••")
                                .font(.custom("SF Pro Display", size: 32))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.vertical, 24)
                            
                            Text("To Those Still Searching")
                                .font(.custom("SF Pro Display", size: 40))
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Text("""
                            In this vast cosmos of consciousness,
                            you are never truly alone.
                            Each star you see is a reminder
                            that light persists even in darkness.
                            
                            Reach out, and you'll find
                            countless hearts ready to help,
                            like stars forming a constellation
                            of support and understanding.
                            """)
                            .font(.custom("SF Pro Display", size: 28))
                            .fontWeight(.regular)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(16)
                            
                            Text("•••")
                                .font(.custom("SF Pro Display", size: 32))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.vertical, 24)
                            
                            // 最后的引言
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: geometry.size.height * 0.1)
                                
                                Text("When one heart heals,\nit becomes a guiding star in another's night sky.")
                                    .font(.system(size: 56, weight: .thin, design: .rounded))
                                    .italic()
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .white,
                                                Color(red: 0.95, green: 0.95, blue: 1.0)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Spacer()
                                    .frame(height: geometry.size.height * 0.1)
                            }
                            .frame(maxWidth: geometry.size.width * 0.9)
                            .frame(height: geometry.size.height * 0.5)
                            .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 0)
                    .offset(y: offset + dragOffset)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 1.0), value: showContent)
                .disabled(true)
                
                // 遮罩层 - 移到最上层并确保覆盖整个屏幕
                ZStack {
                    // 顶部遮罩组
                    VStack(spacing: 0) {
                        // 完全不透明的黑色部分 - 确保覆盖状态栏
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: geometry.safeAreaInsets.top + 50)
                            .ignoresSafeArea()
                        
                        // 渐变过渡
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .black, location: 0),
                                        .init(color: .black, location: 0.7),
                                        .init(color: .clear, location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 200)
                        
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    // 底部遮罩组
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // 渐变过渡
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .black, location: 0.3),
                                        .init(color: .black, location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 200)
                        
                        // 完全不透明的黑色部分 - 确保覆盖底部指示器
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: geometry.safeAreaInsets.bottom + 50)
                            .ignoresSafeArea()
                    }
                    .ignoresSafeArea()
                }
                .allowsHitTesting(false)
                
                // 顶部按钮组
                VStack {
                    HStack {
                        // 关闭按钮
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding(24)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                    isDragging = true
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
        .onAppear {
            // 先显示内容
            showContent = true
            
            // 延迟一秒后开始向上移动动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 先移动到初始位置
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = 0
                }
                
                // 等待初始动画完成后开始滚动
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    startScrolling()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func startScrolling() {
        withAnimation(.linear(duration: scrollDuration)) {
            offset = -UIScreen.main.bounds.height * 5.2  // 增加滚动距离
        }
    }
}

#Preview {
    JourneyEndingView()
} 
