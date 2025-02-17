import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.isUser == rhs.isUser &&
        lhs.timestamp == rhs.timestamp
    }
}

struct TypewriterText: View {
    let text: String
    let messageId: UUID
    @State private var displayedText: String = ""
    @State private var isAnimating: Bool = true
    @State private var hasCompleted: Bool = false
    @State private var timer: Timer?
    
    // 使用静态集合存储已完成动画的消息ID
    private static var completedMessageIds: Set<UUID> = []
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                if !TypewriterText.completedMessageIds.contains(messageId) {
                    startAnimation()
                } else {
                    displayedText = text
                }
            }
            .onDisappear {
                stopAnimation()
            }
    }
    
    @MainActor
    private func startAnimation() {
        displayedText = ""
        let characters = Array(text)
        var currentIndex = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard currentIndex < characters.count else {
                Task { @MainActor in
                    stopAnimation()
                    hasCompleted = true
                    TypewriterText.completedMessageIds.insert(messageId)
                }
                return
            }
            
            Task { @MainActor in
                displayedText += String(characters[currentIndex])
                currentIndex += 1
            }
        }
        
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @MainActor
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        isAnimating = false
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Group {
                if message.isUser {
                    Text(message.content)
                } else {
                    TypewriterText(text: message.content, messageId: message.id)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                message.isUser
                    ? LinearGradient(
                        colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.9),
                            Color(red: 0.5, green: 0.3, blue: 0.7).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
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
            .shadow(color: message.isUser ? Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.3) : Color.white.opacity(0.1), radius: 8, x: 0, y: 4)
            .foregroundColor(.white)
            
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct PsycheDialogueView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showingStars = false
    @State private var isTyping = false
    @State private var currentEmotion: EmotionType?
    @State private var showingEmotionAnalysis = false
    @State private var hasShownWelcomeMessages = false
    @State private var dialogueCount = 0
    @State private var showingJourneyHint = false
    @State private var arrowOffset: CGFloat = 0
    @State private var showingCompletion = false
    
    // Welcome messages
    private let welcomeMessages = [
        "Welcome to Andromeda Dialogue, your emotional sanctuary in the heart of our neighboring galaxy.",
        "I will listen to your words and understand your feelings.",
        "Feel free to share your thoughts with me."
    ]
    
    // 预设问题示例
    private let exampleQuestions = [
        (text: "I am very happy to code for Swift Student Challenge!", emotion: EmotionType.happy),
        (text: "I feel quite sad today...", emotion: EmotionType.depression),
        (text: "I'm worried about my upcoming exam", emotion: EmotionType.anxiety),
        (text: "I am scared of sleeping alone.", emotion: EmotionType.loneliness),
        (text: "Everything makes me angry lately", emotion: EmotionType.anger),
        (text: "I'm hopeful about the future", emotion: EmotionType.hopeful),
        (text: "How can I get my life back?", emotion: EmotionType.confused),
        (text: "I'm proud of my achievements", emotion: EmotionType.confident),
        (text: "I am unemployed and overwhelmed. What would you suggest I do?", emotion: EmotionType.stress),
        (text: "I feel peaceful and calm", emotion: EmotionType.neutral)
    ]
    
    // 预设回应
    private let emotionResponses: [EmotionType: [String]] = [
        .happy: [
            "Your joy is radiating through your words! It's wonderful to see you in such high spirits.",
            "That's fantastic! Happiness is such a precious feeling - cherish this moment.",
            "Your positive energy is contagious! Keep embracing these joyful moments.",
            "I'm so glad to hear you're happy! These moments are what make life beautiful.",
            "Your happiness brightens up our conversation. Tell me more about what brings you joy!"
        ],
        .hopeful: [
            "Hope is like a light guiding us forward. Keep nurturing that optimistic outlook!",
            "It's inspiring to see you maintain hope. That's a real strength.",
            "Your hopeful perspective will help guide you toward better days ahead.",
            "Hold onto that hope - it's a powerful force for positive change.",
            "That's the spirit! Hope has a way of making everything seem possible."
        ],
        .confident: [
            "Your confidence is well-deserved. Keep believing in yourself!",
            "That's the kind of self-assurance that can move mountains!",
            "Your confidence will open many doors. Keep that spirit strong!",
            "It's wonderful to see you so sure of yourself. You've got this!",
            "Confidence looks good on you! Keep embracing your capabilities."
        ],
        .neutral: [
            "I hear you. Sometimes taking a neutral stance helps us think more clearly.",
            "Thank you for sharing that. Would you like to explore these thoughts further?",
            "I understand where you're coming from. Let's process this together.",
            "Sometimes being neutral gives us space to reflect. What's on your mind?",
            "I appreciate your balanced perspective. Would you like to discuss this more?"
        ],
        .confused: [
            "It's perfectly normal to feel uncertain sometimes. Let's figure this out together.",
            "Confusion often comes before clarity. What specific aspects feel unclear?",
            "Take your time to process these thoughts. I'm here to help you find clarity.",
            "Sometimes feeling lost is part of finding our way.",
            "Let's break this down together and make sense of what's confusing you."
        ],
        .depression: [
            "I hear the weight in your words, and I want you to know you're not alone in this.",
            "Depression can make everything feel heavy, but remember - this feeling isn't permanent.",
            "Your feelings are valid, and there is always hope, even in the darkest moments.",
            "I'm here to listen and support you through this difficult time.",
            "It takes courage to share these feelings. Let's work through this together."
        ],
        .anxiety: [
            "I can sense your anxiety. Let's take a moment to breathe together.",
            "Anxiety can be overwhelming, but you don't have to face it alone.",
            "Your concerns are valid. Let's explore ways to manage these anxious thoughts.",
            "Sometimes anxiety is our mind's way of processing change. Let's work through this.",
            "I'm here to support you through these anxious moments. What helps you feel grounded?"
        ],
        .anger: [
            "I understand your frustration. It's okay to feel angry about this.",
            "Anger often points us toward what needs to change. Let's explore that together.",
            "Your feelings are valid. Would you like to talk about what triggered this anger?",
            "It's healthy to acknowledge our anger. Let's find constructive ways to address it.",
            "I hear your anger. Let's work on understanding and processing these feelings."
        ],
        .stress: [
            "I can feel the pressure you're under. Let's find ways to lighten this load.",
            "Stress can be overwhelming. Would you like to explore some coping strategies?",
            "It sounds like you're carrying a lot right now. Let's break it down together.",
            "Your stress is valid. Let's focus on what we can manage right now.",
            "Sometimes sharing our stress helps make it more manageable."
        ],
        .loneliness: [
            "Even though you feel alone, I want you to know that I'm here with you.",
            "Loneliness can be really difficult. Let's talk about ways to feel more connected.",
            "I hear how isolated you feel. Your feelings matter, and you matter.",
            "It's okay to feel lonely sometimes. Let's explore ways to bridge this gap.",
            "You may feel alone, but you're not alone in this journey."
        ]
    ]
    
    var body: some View {
        ZStack {
            // 纯黑色背景
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 粒子效果背景
            if showingStars {
                // 添加粒子效果
                PsycheParticleView()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.6)
                    .colorMultiply(Color(red: 0.6, green: 0.4, blue: 0.8))  // 添加紫色调
                    .allowsHitTesting(false)  // 确保不会影响下面视图的交互
            }
            
            // Main content
            VStack(spacing: 0) {
                // 更新顶部栏背景为半透明效果
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                        .frame(width: 44)  // 添加固定宽度，与左侧按钮对称
                    
                    Text("Andromeda Guide")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 16) {
                        // Journey hint
                        if showingJourneyHint {
                            Button(action: {
                                showingEmotionAnalysis = true
                            }) {
                                HStack(spacing: 8) {
                                    Text("View Your Constellation")
                                        .font(.system(size: 14, weight: .medium))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14))
                                        .offset(x: arrowOffset)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.3),
                                                    Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                    removal: .scale(scale: 1.1).combined(with: .opacity)
                                ))
                            }
                        }
                        
                        Button(action: {
                            showingEmotionAnalysis = true
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                // Message list with suggestions
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Suggestions section
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("You may say:")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 20)
                                        .padding(.top, 12)
                                        .padding(.bottom, 4)
                                    
                                    HStack(spacing: 16) {
                                        ForEach(exampleQuestions, id: \.text) { question in
                                            VStack(spacing: 8) {
                                                Image(systemName: emotionIcon(question.emotion))
                                                    .font(.system(size: 24))
                                                    .foregroundColor(emotionColor(question.emotion))
                                                    .frame(width: 40, height: 40)
                                                    .background(
                                                        Circle()
                                                            .fill(emotionColor(question.emotion).opacity(0.2))
                                                    )
                                                
                                                Button(action: {
                                                    inputText = question.text
                                                    sendMessage()
                                                }) {
                                                    Text(question.text)
                                                        .font(.system(size: 15, weight: .medium))
                                                        .foregroundColor(.white)
                                                        .multilineTextAlignment(.center)
                                                        .padding(.horizontal, 20)
                                                        .padding(.vertical, 12)
                                                        .frame(width: 200)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .fill(
                                                                    LinearGradient(
                                                                        colors: [
                                                                            emotionColor(question.emotion).opacity(0.3),
                                                                            emotionColor(question.emotion).opacity(0.1)
                                                                        ],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    )
                                                                )
                                                        )
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 20)
                                                                .stroke(
                                                                    emotionColor(question.emotion).opacity(0.3),
                                                                    lineWidth: 1
                                                                )
                                                        )
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            .background(
                                Color.black.opacity(0.4)
                                    .overlay(
                                        Rectangle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.clear, Color.white.opacity(0.1), .clear],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            )
                            
                            // Messages
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.vertical)
                        .onChange(of: messages) { oldValue, newValue in
                            if let lastMessage = newValue.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: isInputFocused) { wasFocused, isFocused in
                            if isFocused {
                                // 当输入框获得焦点时，确保键盘不会遮挡输入框
                                withAnimation {
                                    if let lastMessage = messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Current emotion indicator
                if let emotion = currentEmotion {
                    HStack(spacing: 16) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(emotionColor(emotion))
                            Text("Current Emotion: \(emotion.description)")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        
                        // Journey to Stars button
                        if dialogueCount >= 3 {
                            Button(action: {
                                showingCompletion = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "hand.tap.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                    Text("Journey to the Stars")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.3),
                                                    Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.3)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 4, height: 4)
                                        .blur(radius: 1)
                                        .offset(x: -8, y: -8)
                                )
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Input area
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    HStack(spacing: 12) {
                        TextField("Share your thoughts...", text: $inputText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                            .focused($isInputFocused)
                            .submitLabel(.send)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                if !inputText.isEmpty {
                                    sendMessage()
                                }
                            }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(
                                    inputText.isEmpty
                                        ? Color.white.opacity(0.3)
                                        : Color(red: 0.6, green: 0.4, blue: 0.8)
                                )
                        }
                        .disabled(inputText.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // AI disclaimer
                    Text("AI-generated content. Please use discretion.")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.bottom, 8)
                }
                .background(Color.black.opacity(0.3))
            }
        }
        .sheet(isPresented: $showingEmotionAnalysis) {
            EmotionAnalysisView()
        }
        .fullScreenCover(isPresented: $showingCompletion) {
            AndromedaCompletionView()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                showingStars = true
            }
            sendWelcomeMessages()
        }
    }
    
    private func sendWelcomeMessages() {
        guard !hasShownWelcomeMessages else { return }
        
        var delay: Double = 0
        for message in welcomeMessages {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    messages.append(ChatMessage(content: message, isUser: false))
                }
            }
            delay += 1
        }
        hasShownWelcomeMessages = true
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: inputText, isUser: true)
        withAnimation {
            messages.append(userMessage)
        }
        
        let messageToRespond = inputText
        inputText = ""
        
        // Increment dialogue count and check for hint
        dialogueCount += 1
        if dialogueCount == 2 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showingJourneyHint = true
            }
        }
        
        // Analyze emotion and generate response
        Task {
            do {
                let emotion = try await EmotionClassifier.shared.classifyEmotion(messageToRespond)
                
                await MainActor.run {
                    currentEmotion = emotion
                    
                    // Record emotion analysis result
                    let result = EmotionAnalysisResult(
                        emotion: emotion,
                        confidence: 1.0,
                        timestamp: Date()
                    )
                    
                    Task {
                        await EmotionHistoryManager.shared.addEmotion(result)
                    }
                    
                    // Generate and send response with typing animation
                    let response = generateResponse(for: emotion)
                    withAnimation {
                        messages.append(ChatMessage(content: response, isUser: false))
                    }
                }
            } catch {
                print("Emotion analysis error: \(error)")
                // 使用默认的积极回应，而不是 "I'm listening"
                withAnimation {
                    messages.append(ChatMessage(
                        content: "I sense you have something important to share. I'm here to support you through whatever you're experiencing.",
                        isUser: false
                    ))
                }
            }
        }
    }
    
    private func generateResponse(for emotion: EmotionType) -> String {
        guard let responses = emotionResponses[emotion],
              let response = responses.randomElement() else {
            return "I'm listening, please continue."
        }
        return response
    }
    
    private func emotionColor(_ emotion: EmotionType) -> Color {
        switch emotion.category {
        case .positive:
            return .green
        case .neutral:
            return .blue
        case .negative:
            return .red
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

#Preview {
    PsycheDialogueView()
} 