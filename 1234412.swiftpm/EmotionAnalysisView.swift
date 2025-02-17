import SwiftUI
import Charts

struct EmotionAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userInput: String = ""
    @State private var currentEmotion: EmotionType?
    @State private var isAnalyzing: Bool = false
    @State private var showingHistory: Bool = false
    @State private var emotionDistribution: [EmotionCategory: Double] = [:]
    @State private var showingStars = false
    @State private var planetRotation: Double = 0
    
    private let categories: [EmotionCategory] = [.positive, .neutral, .negative]
    
    var body: some View {
        ZStack {
            // Background with stars
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .edgesIgnoringSafeArea(.all)
            
            if showingStars {
                StarfieldView()
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Main content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Emotion Galaxy")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingHistory = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color.black.opacity(0.3))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Emotion Solar System
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Emotional Universe")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ZStack {
                                // 中心太阳
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [.yellow, .orange],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 50
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .orange.opacity(0.5), radius: 10)
                                
                                // 情感轨道和行星
                                ForEach(Array(emotionDistribution.keys.enumerated()), id: \.element) { index, category in
                                    let distance = CGFloat(100 + index * 60)
                                    let percentage = emotionDistribution[category] ?? 0
                                    
                                    // 轨道
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        .frame(width: distance * 2, height: distance * 2)
                                    
                                    // 行星
                                    EmotionPlanet(category: category, percentage: percentage)
                                        .offset(x: distance * cos(planetRotation + Double(index) * .pi * 2/3),
                                                y: distance * sin(planetRotation + Double(index) * .pi * 2/3))
                                }
                            }
                            .frame(height: 400)
                            .padding(20)
                            .onAppear {
                                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                                    planetRotation = .pi * 2
                                }
                            }
                            
                            // Legend with planet descriptions
                            VStack(spacing: 16) {
                                ForEach(categories, id: \.self) { category in
                                    HStack(spacing: 12) {
                                        EmotionPlanet(category: category, percentage: emotionDistribution[category] ?? 0)
                                            .frame(width: 40, height: 40)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(planetName(for: category))
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text(planetDescription(for: category))
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(Int((emotionDistribution[category] ?? 0) * 100))%")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        
                        // Recent Emotions List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Emotions")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(EmotionHistoryManager.shared.getEmotionHistory().prefix(5), id: \.timestamp) { result in
                                        EmotionHistoryRow(result: result)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                showingStars = true
            }
            updateEmotionDistribution()
        }
        .sheet(isPresented: $showingHistory) {
            EmotionHistoryDetailView()
        }
    }
    
    private func updateEmotionDistribution() {
        Task {
            emotionDistribution = await EmotionHistoryManager.shared.getEmotionDistribution()
        }
    }
    
    private func planetName(for category: EmotionCategory) -> String {
        switch category {
        case .positive: return "Joy Planet"
        case .neutral: return "Balance World"
        case .negative: return "Shadow Sphere"
        }
    }
    
    private func planetDescription(for category: EmotionCategory) -> String {
        switch category {
        case .positive: return "A warm, radiant world of happiness and hope"
        case .neutral: return "A peaceful realm of calm and clarity"
        case .negative: return "A place where darker emotions find expression"
        }
    }
}

struct EmotionHistoryRow: View {
    let result: EmotionAnalysisResult
    
    var body: some View {
        HStack {
            Image(systemName: emotionIcon(result.emotion))
                .font(.system(size: 20))
                .foregroundColor(emotionColor(result.emotion))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(emotionColor(result.emotion).opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.emotion.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(result.formattedTimestamp)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private func emotionColor(_ emotion: EmotionType) -> Color {
        switch emotion.category {
        case .positive: return .green
        case .neutral: return .blue
        case .negative: return .red
        }
    }
    
    private func emotionIcon(_ emotion: EmotionType) -> String {
        switch emotion {
        case .happy: return "sun.max.fill"
        case .hopeful: return "sunrise.fill"
        case .confident: return "star.fill"
        case .neutral: return "cloud.fill"
        case .confused: return "questionmark.circle.fill"
        case .depression: return "cloud.rain.fill"
        case .anxiety: return "tornado"
        case .anger: return "flame.fill"
        case .stress: return "bolt.fill"
        case .loneliness: return "moon.fill"
        }
    }
}

struct EmotionHistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var histories: [EmotionAnalysisResult] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(histories, id: \.timestamp) { result in
                            EmotionHistoryRow(result: result)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Emotion History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            loadHistory()
        }
    }
    
    private func loadHistory() {
        Task {
            histories = await EmotionHistoryManager.shared.getEmotionHistory()
        }
    }
}

struct EmotionPlanet: View {
    let category: EmotionCategory
    let percentage: Double
    @State private var isGlowing = false
    
    var body: some View {
        ZStack {
            // 行星光晕
            Circle()
                .fill(planetGradient)
                .frame(width: planetSize, height: planetSize)
                .opacity(isGlowing ? 0.8 : 0.6)
                .shadow(color: planetColor.opacity(0.5), radius: isGlowing ? 15 : 10)
            
            // 行星表面
            Circle()
                .fill(planetGradient)
                .frame(width: planetSize * 0.8, height: planetSize * 0.8)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            // 行星环（仅用于中性情绪）
            if category == .neutral {
                Circle()
                    .trim(from: 0.3, to: 0.7)
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: planetSize * 1.2, height: planetSize * 0.8)
                    .rotationEffect(.degrees(45))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isGlowing.toggle()
            }
        }
    }
    
    private var planetSize: CGFloat {
        40 + CGFloat(percentage * 30)
    }
    
    private var planetColor: Color {
        switch category {
        case .positive: return Color(red: 0.3, green: 0.8, blue: 0.4)
        case .neutral: return Color(red: 0.4, green: 0.6, blue: 0.8)
        case .negative: return Color(red: 0.8, green: 0.3, blue: 0.3)
        }
    }
    
    private var planetGradient: LinearGradient {
        switch category {
        case .positive:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.4),
                    Color(red: 0.1, green: 0.6, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .neutral:
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),
                    Color(red: 0.2, green: 0.4, blue: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .negative:
            return LinearGradient(
                colors: [
                    Color(red: 0.8, green: 0.3, blue: 0.3),
                    Color(red: 0.6, green: 0.2, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    EmotionAnalysisView()
} 