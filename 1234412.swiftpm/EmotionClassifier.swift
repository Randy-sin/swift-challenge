import Foundation
@preconcurrency import CoreML
@preconcurrency import Vision
import NaturalLanguage

enum EmotionType: String, Sendable {
    case happy = "happy"
    case hopeful = "hopeful"
    case confident = "confident"
    case neutral = "neutral"
    case confused = "confused"
    case depression = "depression"
    case anxiety = "anxiety"
    case anger = "anger"
    case stress = "stress"
    case loneliness = "loneliness"
    
    var description: String {
        switch self {
        case .happy: return "Happy"
        case .hopeful: return "Hopeful"
        case .confident: return "Confident" 
        case .neutral: return "Neutral"
        case .confused: return "Confused"
        case .depression: return "Depressed"
        case .anxiety: return "Anxious"
        case .anger: return "Angry"
        case .stress: return "Stressed"
        case .loneliness: return "Lonely"
        }
    }
    
    var category: EmotionCategory {
        switch self {
        case .happy, .hopeful, .confident:
            return .positive
        case .neutral, .confused:
            return .neutral
        case .depression, .anxiety, .anger, .stress, .loneliness:
            return .negative
        }
    }
}

enum EmotionCategory: Sendable {
    case positive
    case neutral
    case negative
    
    var description: String {
        switch self {
        case .positive: return "Positive"
        case .neutral: return "Neutral"
        case .negative: return "Negative"
        }
    }
}

@MainActor
final class EmotionClassifier: ObservableObject {
    static let shared = EmotionClassifier()
    private var model: MLModel?
    
    private init() {
        print("🔄 Initializing EmotionClassifier")
        initializeModel()
    }
    
    private func initializeModel() {
        Task {
            do {
                let config = MLModelConfiguration()
                #if targetEnvironment(simulator)
                config.computeUnits = .cpuOnly
                print("🖥 Running in simulator - using CPU only")
                #else
                config.computeUnits = .all
                print("📱 Running on device - using all compute units")
                #endif
                
                guard let modelURL = Bundle.main.url(forResource: "Psychoclassification 1 copy", withExtension: "mlmodel", subdirectory: "ML") else {
                    print("❌ Failed to find model in ML directory")
                    if let resourcePath = Bundle.main.resourcePath {
                        let fileManager = FileManager.default
                        do {
                            let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
                            print("📂 Available resources:")
                            items.forEach { print("- \($0)") }
                        } catch {
                            print("❌ Error listing resources: \(error)")
                        }
                    }
                    return
                }
                
                print("✅ Found model at: \(modelURL.path)")
                
                let compiledModelURL = try await MLModel.compileModel(at: modelURL)
                print("✅ Compiled model at: \(compiledModelURL.path)")
                
                await MainActor.run {
                    do {
                        self.model = try MLModel(contentsOf: compiledModelURL, configuration: config)
                        print("✅ Model initialized successfully")
                    } catch {
                        print("❌ Error creating model: \(error.localizedDescription)")
                    }
                }
            } catch {
                print("❌ Error initializing model: \(error.localizedDescription)")
                print("❌ Detailed error: \(error)")
            }
        }
    }
    
    func classifyEmotion(_ text: String) async throws -> EmotionType {
        guard let model = self.model else {
            throw NSError(domain: "EmotionClassification", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Model not initialized"])
        }
        
        // 创建模型输入
        let inputFeatures = try MLDictionaryFeatureProvider(dictionary: [
            "text": text as NSString
        ])
        
        // 执行预测
        let prediction = try await model.prediction(from: inputFeatures)
        
        // 获取预测结果
        guard let label = prediction.featureValue(for: "label")?.stringValue,
              let emotion = EmotionType(rawValue: label) else {
            throw NSError(domain: "EmotionClassification", code: -3,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to classify emotion"])
        }
        
        return emotion
    }
}

// MARK: - Emotion Analysis Result
struct EmotionAnalysisResult: Sendable {
    let emotion: EmotionType
    let confidence: Double
    let timestamp: Date
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}

// MARK: - Emotion History Manager
@MainActor
final class EmotionHistoryManager: ObservableObject {
    static let shared = EmotionHistoryManager()
    private let maxHistoryCount = 100
    @Published private(set) var histories: [EmotionAnalysisResult] = []
    
    private init() {}
    
    func addEmotion(_ result: EmotionAnalysisResult) {
        histories.insert(result, at: 0)
        if histories.count > maxHistoryCount {
            histories.removeLast()
        }
    }
    
    func getEmotionHistory() -> [EmotionAnalysisResult] {
        return histories
    }
    
    func getEmotionDistribution() -> [EmotionCategory: Double] {
        var distribution: [EmotionCategory: Int] = [.positive: 0, .neutral: 0, .negative: 0]
        
        for result in histories {
            distribution[result.emotion.category, default: 0] += 1
        }
        
        let total = Double(histories.count)
        return distribution.mapValues { Double($0) / total }
    }
} 
