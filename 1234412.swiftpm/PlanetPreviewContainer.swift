import SwiftUI
import SceneKit

// 流式文字组件
private struct TypewriterTextView: View {
    let text: String
    let messageId: UUID
    @State private var displayedText: String = ""
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Text(displayedText)
            .font(.system(size: isAnimating ? 17 : 15, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
            .multilineTextAlignment(.center)
            .onAppear {
                startTyping()
            }
    }
    
    private func startTyping() {
        displayedText = ""
        isAnimating = true
        
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08 * Double(index)) {
                displayedText += String(character)
                if index == text.count - 1 {
                    isAnimating = false
                }
            }
        }
    }
}

struct PlanetPreviewContainer: View {
    @EnvironmentObject var artisticViewModel: ArtisticPlanetViewModel
    @EnvironmentObject var progressViewModel: PlanetProgressViewModel
    @StateObject private var venusViewModel = ArtisticPlanetViewModel()
    @StateObject private var oceanusViewModel = ArtisticPlanetViewModel()
    @StateObject private var andromedaViewModel = ArtisticPlanetViewModel()
    @State private var showSecondLine = false
    @State private var firstLineId = UUID()
    @State private var secondLineId = UUID()
    
    var body: some View {
        // 外层装饰矩形
        ZStack {
            // 背景和装饰
            ZStack {
                // 毛玻璃背景
                Color.clear
                    .background(.ultraThinMaterial.opacity(0.7))
                
                // 渐变装饰
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 星星装饰
                ForEach(0..<20) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...600),
                            y: CGFloat.random(in: 0...190)
                        )
                        .opacity(Double.random(in: 0.3...0.6))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            
            // 边框
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            
            // 内容
            VStack(spacing: 0) {
                // 标题
                Text("Journey Logs")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(0.5)  // 字间距
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(.top, 22)
                    .padding(.bottom, 15)
                
                Spacer()
                
                if progressViewModel.unlockedPlanets.count == 1 && progressViewModel.unlockedPlanets.contains(.venus) {
                    // 显示初始提示文本
                    VStack(spacing: 10) {
                        TypewriterTextView(text: "You haven't explored any planets yet.", messageId: firstLineId)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    showSecondLine = true
                                }
                            }
                        
                        if showSecondLine {
                            TypewriterTextView(text: "Start your journey, and your explored planets will be recorded here.", messageId: secondLineId)
                                .font(.system(size: 15, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(2)
                        }
                    }
                    .frame(maxWidth: .infinity)  // 让 VStack 占满宽度以实现居中
                    .padding(.horizontal, 40)
                    .padding(.bottom, 25)
                } else {
                    // 星球预览内容
                    HStack(spacing: 35) {
                        // Venus Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            if !progressViewModel.isPlanetCompleted(.venus) {
                                // 锁定状态显示
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Locked")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            } else {
                                VStack(spacing: 2) {
                                    Planet3DSceneView(viewModel: venusViewModel)
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(1.2)
                                        .offset(y: -6)
                                    
                                    Text("Venus")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(width: 120, height: 120)
                        
                        // Artistic Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            if !progressViewModel.isPlanetCompleted(.artistic) {
                                // 锁定状态显示
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Locked")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            } else {
                                VStack(spacing: 2) {
                                    Planet3DSceneView(viewModel: artisticViewModel)
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(1.2)
                                        .offset(y: -6)
                                    
                                    Text("Artistic")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(width: 120, height: 120)
                        
                        // Oceanus Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            if !progressViewModel.isPlanetCompleted(.oceanus) {
                                // 锁定状态显示
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Locked")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            } else {
                                VStack(spacing: 2) {
                                    Planet3DSceneView(viewModel: oceanusViewModel)
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(1.2)
                                        .offset(y: -6)
                                    
                                    Text("Oceanus")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(width: 120, height: 120)
                        
                        // Andromeda Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            if !progressViewModel.isPlanetCompleted(.andromeda) {
                                // 锁定状态显示
                                VStack(spacing: 8) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Locked")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            } else {
                                VStack(spacing: 2) {
                                    Planet3DSceneView(viewModel: andromedaViewModel)
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(1.2)
                                        .offset(y: -6)
                                    
                                    Text("Andromeda")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 50)
        .frame(maxWidth: 600)
        .frame(height: 190)
        .onAppear {
            setupPlanets()
        }
    }
    
    private func setupPlanets() {
        // 设置 Venus 星球
        if let texture = UIImage(named: "venus") {
            venusViewModel.setupInitialTexture(texture)
        }
        
        // 设置 Oceanus 星球
        if let texture = UIImage(named: "2kneptune") {
            oceanusViewModel.setupInitialTexture(texture)
        }
        
        // 设置 Andromeda 星球
        if let texture = UIImage(named: "Andromedaplanet") {
            andromedaViewModel.setupInitialTexture(texture)
        }
    }
} 