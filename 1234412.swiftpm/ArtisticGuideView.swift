import SwiftUI
import os

// MARK: - Logging System
private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.randy.smiledetector",
    category: "ArtisticGuideView"
)

struct HealingJourneyCard: View {
    let step: Int
    let title: String
    let description: String
    let prompt: String
    let data: String
    @State private var isHovered = false
    @State private var showPrompt = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Step indicator and title area
            HStack(spacing: 16) {
                // Step indicator with animated background
                Text("Step \(step)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.6),
                                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .opacity(isAnimating ? 0.6 : 0.3)
                        }
                    )
                
                Spacer()
                
                // Interactive info button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showPrompt.toggle()
                    }
                }) {
                    Image(systemName: showPrompt ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.15))
                                .scaleEffect(isHovered ? 1.1 : 1.0)
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
            }
            
            // Title with gradient effect
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            .white.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Description with dynamic spacing
            Text(description)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(8)
                .padding(.vertical, 4)
            
            // Data point with animated background
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                
                Text(data)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.15))
                    
                    // Animated gradient overlay
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.2),
                                    Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.05)
                                ],
                                startPoint: isAnimating ? .topLeading : .bottomTrailing,
                                endPoint: isAnimating ? .bottomTrailing : .topLeading
                            )
                        )
                        .blendMode(.plusLighter)
                }
            )
            
            // Prompt section with animated reveal
            if showPrompt {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Helpful Tip")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                    
                    Text(prompt)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.2).opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.7)),
                    removal: .scale(scale: 0.9).combined(with: .opacity).animation(.easeOut(duration: 0.2))
                ))
            }
        }
        .padding(32)
        .background(
            ZStack {
                // Base layer with darker background
                Color(red: 0.08, green: 0.08, blue: 0.15)
                    .opacity(0.95)
                
                // Glass effect with reduced opacity
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                
                // Animated gradient overlay with reduced opacity
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.3 : 0.15),
                        Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.15 : 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.8 : 0.4),
                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.4 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.3 : 0.1),
            radius: isHovered ? 30 : 20,
            x: 0,
            y: 10
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ArtisticGuideView: View {
    @Binding var isShowingGuide: Bool
    let startDrawing: () -> Void
    @State private var showContent = false
    @State private var currentStep = 1
    
    // Healing Journey Steps
    let journeySteps = [
        (
            title: "Art as Medicine",
            description: "Art therapy is a powerful tool for mental health treatment. Through creative expression, we can process emotions and experiences that words alone cannot capture.",
            prompt: "Take a moment to connect with your inner artist - everyone has one.",
            data: "Research shows art therapy reduces anxiety levels by up to 47%"
        ),
        (
            title: "Colors of Healing",
            description: "Color psychology plays a vital role in emotional expression. Each color we choose reflects and influences our emotional state.",
            prompt: "Select colors that resonate with your current feelings.",
            data: "71% of art therapy participants report improved emotional regulation"
        ),
        (
            title: "AI Recognition",
            description: "This planet uses CoreML technology to recognize your drawings. For the best experience, please run on a real device as the simulator has limited AI capabilities.",
            prompt: "Follow the prompts and let AI guide your creative journey.",
            data: "CoreML requires a physical device for optimal performance"
        ),
        (
            title: "Creative Challenge",
            description: "Each step will present you with a theme. Try to draw what you think matches the prompt - the AI will help guide you to create the perfect element for your healing planet.",
            prompt: "Let your imagination flow and see if you can guess what to draw!",
            data: "Your drawings will combine to create a unique artistic planet"
        )
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

            // Particle effect with Venus color filter - 移到最顶层
            EmotionParticleView()
                .opacity(0.6)
                .colorMultiply(Color(red: 1.0, green: 0.8, blue: 0.4))  // 添加金星特有的温暖色调
                .allowsHitTesting(false)  // 确保不会影响下面视图的交互
            
            // 返回按钮 - 移到最顶层并固定在左上角
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            isShowingGuide = false
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            )
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }

    private var titleSection: some View {
        VStack(spacing: 16) {
            Text("Artistic Guide")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.8, blue: 1.0),
                            Color(red: 0.2, green: 0.6, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            
            Text("Healing Through Creative Expression")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
        }
        .padding(.top, 60)
    }

    private var descriptionSection: some View {
        Text("This guide will help you understand the power of art in healing and how to use it effectively. We'll explore different types of art and its impact on your mental health.")
            .font(.system(size: 17, weight: .regular, design: .rounded))
            .foregroundColor(.white.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(8)
            .padding(.vertical, 4)
    }

    private var journeyTitle: some View {
        Text("Healing Journey")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }

    private var stepsSection: some View {
        VStack(spacing: 40) {
            // Current Step Card
            HealingJourneyCard(
                step: currentStep,
                title: journeySteps[currentStep - 1].title,
                description: journeySteps[currentStep - 1].description,
                prompt: journeySteps[currentStep - 1].prompt,
                data: journeySteps[currentStep - 1].data
            )
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            // Navigation Buttons
            HStack(spacing: 20) {
                if currentStep > 1 {
                    Button(action: {
                        withAnimation {
                            currentStep -= 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                
                if currentStep < journeySteps.count {
                    Button(action: {
                        withAnimation {
                            currentStep += 1
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.15))
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                } else {
                    Button(action: {
                        withAnimation {
                            isShowingGuide = false
                            startDrawing()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "paintbrush.fill")
                            Text("Begin Creating")
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.white.opacity(0.3), radius: 10)
                    }
                }
            }
            .opacity(showContent ? 1 : 0)
        }
    }

    private var startButton: some View {
        Button(action: {
            withAnimation {
                isShowingGuide = false
                startDrawing()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "paintbrush.fill")
                Text("Begin Creating")
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.white.opacity(0.3), radius: 10)
        }
    }
}

#Preview {
    ArtisticGuideView(isShowingGuide: .constant(true), startDrawing: {})
} 