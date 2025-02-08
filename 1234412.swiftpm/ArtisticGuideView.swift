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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Step indicator and title
            HStack {
                Text("Step \(step)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.2))
                    )
                
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Description
            Text(description)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)
            
            // Data point
            Text(data)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.15))
                )
            
            // Prompt
            Text(prompt)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
                .padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(30)
        .background(
            ZStack {
                Color.white.opacity(0.08)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.6 : 0.3),
                        Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.3 : 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.overlay)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.6 : 0.3),
                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(isHovered ? 0.3 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.1), radius: isHovered ? 20 : 10)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
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
            title: "Freedom of Expression",
            description: "In art therapy, there are no rules or judgments. Your artistic expression is a unique reflection of your inner world and healing journey.",
            prompt: "Let your emotions guide your hand - there's no right or wrong way to create.",
            data: "Studies show 15-20 minutes of creative activity significantly reduces stress"
        ),
        (
            title: "Creating Hope",
            description: "As you create, you're not just making art - you're building a bridge to hope and healing. This is your story, told through colors and shapes.",
            prompt: "Add elements that represent hope and strength in your journey.",
            data: "89% of patients report improved mood after art therapy sessions"
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
            
            // Particle Effect
            EmotionParticleView()
                .opacity(0.6)
            
            VStack(spacing: 40) {
                // Title Area
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
                
                Spacer()
            }
            .padding(.horizontal, 40)
            
            // Back Button
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
}

#Preview {
    ArtisticGuideView(isShowingGuide: .constant(true), startDrawing: {})
} 