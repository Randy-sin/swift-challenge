import SwiftUI
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.randy.smiledetector",
    category: "OceanusGuideView"
)

struct OceanusStepView: View {
    let icon: String
    let title: String
    let description: String
    let data: String
    let dataIcon: String
    @State private var isHovered = false
    @State private var showDetail = false
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and Title Area
            HStack(spacing: 12) {
                // Animated Icon Container
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.6),
                                            Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                        .symbolEffect(.bounce, options: .repeating)
                }
                
                Spacer()
                
                // Info Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showDetail.toggle()
                    }
                }) {
                    Image(systemName: showDetail ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                        .frame(width: 32, height: 32)
                }
            }
            
            // Title
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.9),
                            Color(red: 0.2, green: 0.4, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Description
            Text(description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
            
            // Data Point
            if showDetail {
                HStack {
                    Image(systemName: dataIcon)
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                    
                    Text(data)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.9))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.15))
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                Color(red: 0.05, green: 0.1, blue: 0.2)
                    .opacity(0.95)
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.9).opacity(isHovered ? 0.8 : 0.4),
                            Color(red: 0.2, green: 0.6, blue: 0.9).opacity(isHovered ? 0.4 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color(red: 0.2, green: 0.6, blue: 0.9).opacity(isHovered ? 0.3 : 0.1),
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

struct OceanusGuideView: View {
    @Binding var isShowingGuide: Bool
    let startBreathing: () -> Void
    @State private var showContent = false
    @State private var currentStep = 1
    
    let steps = [
        (
            icon: "water.waves",
            title: "Ocean of Tranquility",
            description: "Welcome to Oceanus, where the depths of the ocean meet the depths of your consciousness. Experience a unique journey of emotional regulation through the power of breath.",
            data: "Deep breathing can reduce stress levels by up to 40%",
            dataIcon: "chart.line.downtrend.xyaxis"
        ),
        (
            icon: "lungs.fill",
            title: "Breath of the Sea",
            description: "Like the gentle rhythm of ocean waves, your breath has the power to calm your mind and soothe your soul. Follow the guided breathing patterns to find your inner peace.",
            data: "Controlled breathing activates the parasympathetic nervous system",
            dataIcon: "waveform.path"
        ),
        (
            icon: "globe.desk",
            title: "Ocean Planet Experience",
            description: "Watch as your breathing rhythm brings a magical ocean planet to life. The planet pulses and glows with each breath, creating a mesmerizing visualization of your inner calm.",
            data: "Visualization enhances mindfulness practice by 45%",
            dataIcon: "chart.bar.fill"
        ),
        (
            icon: "brain.head.profile",
            title: "Immersive Breathing",
            description: "Experience a revolutionary breathing exercise where your breath controls the ocean waves. Perfect for finding your inner peace through the rhythm of the sea.",
            data: "95% of users report improved focus with guided breathing",
            dataIcon: "person.fill"
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
            
            VStack(spacing: 40) {
                // Title
                VStack(spacing: 16) {
                    Text("Journey to Oceanus")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.6, blue: 0.9),
                                    Color(red: 0.2, green: 0.4, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.5), radius: 10)
                    
                    Text("Discover the Healing Power of Ocean Depths")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 50)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Steps Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        OceanusStepView(
                            icon: step.icon,
                            title: step.title,
                            description: step.description,
                            data: step.data,
                            dataIcon: step.dataIcon
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut.delay(Double(index) * 0.2), value: showContent)
                    }
                }
                .padding(.horizontal, 24)
                
                // Start Button
                Button(action: {
                    withAnimation {
                        isShowingGuide = false
                        startBreathing()
                    }
                }) {
                    Text("Begin Your Ocean Journey")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(height: 46)
                        .frame(width: 240)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .white.opacity(0.3), radius: 10)
                        )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .padding(.bottom, 40)
            }
            
            // Particle effect
            EmotionParticleView()
                .opacity(0.6)
                .allowsHitTesting(false)
            
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
    OceanusGuideView(isShowingGuide: .constant(true), startBreathing: {})
} 