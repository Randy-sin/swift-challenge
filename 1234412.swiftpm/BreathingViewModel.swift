@preconcurrency
import SwiftUI
@preconcurrency
import Combine

/// Breathing phases
enum BreathingPhase: CaseIterable {
    case inhale
    case hold
    case exhale
    
    var duration: TimeInterval {
        switch self {
        case .inhale: return 3.0  // 3s inhale
        case .hold: return 5.0    // 5s hold
        case .exhale: return 6.0  // 6s exhale
        }
    }
    
    var description: String {
        switch self {
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        }
    }
    
    var guideText: String {
        switch self {
        case .inhale: return "Take a deep breath"
        case .hold: return "Hold your breath"
        case .exhale: return "Slowly release"
        }
    }
    
    var color: Color {
        switch self {
        case .inhale: return .blue
        case .hold: return .purple
        case .exhale: return .indigo
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .inhale: return 2.5  // 吸气时放大
        case .hold: return 2.5    // 保持与吸气时相同大小
        case .exhale: return 1.0  // 呼气时恢复原始大小
        }
    }
}

@MainActor
class BreathingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var progress: Double = 0.0
    @Published var isActive: Bool = false
    @Published var totalProgress: Double = 0.0  // 总体进度
    @Published var currentCycleCount: Int = 0   // 当前循环次数
    @Published var showTranscendence: Bool = false
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var phaseStartTime: Date?
    private var cycleStartTime: Date?
    private var activeTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    private let totalDuration: TimeInterval = 14.0  // 3 + 5 + 6
    private let targetCycles: Int = 3  // 默认3个循环
    
    // MARK: - Initialization
    init() {
        setupObservers()
    }
    
    // MARK: - Public Methods
    func startBreathing() {
        guard !isActive else { return }
        
        progress = 0.0
        totalProgress = 0.0
        currentCycleCount = 1
        
        currentPhase = .exhale
        
        DispatchQueue.main.async {
            self.currentPhase = .inhale
            self.phaseStartTime = Date()
            self.cycleStartTime = Date()
            
            self.isActive = true
            self.startTimer()
        }
    }
    
    func stopBreathing() {
        isActive = false
        activeTask?.cancel()
        activeTask = nil
        cleanup()
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        $isActive
            .dropFirst()
            .sink { [weak self] active in
                guard let self = self else { return }
                if !active {
                    self.cleanup()
                }
            }
            .store(in: &cancellables)
    }
    
    private func cleanup() {
        activeTask?.cancel()
        activeTask = nil
        progress = 0.0
        totalProgress = 0.0
        currentCycleCount = 0
        phaseStartTime = nil
        cycleStartTime = nil
    }
    
    private func startTimer() {
        activeTask?.cancel()
        
        activeTask = Task { [weak self] in
            guard let self = self else { return }
            
            while !Task.isCancelled && self.isActive {
                self.updateProgress()
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }
    
    private func updateProgress() {
        guard let startTime = phaseStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let duration = currentPhase.duration
        
        progress = min(elapsed / duration, 1.0)
        
        if progress >= 1.0 {
            moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        let phases = BreathingPhase.allCases
        guard let currentIndex = phases.firstIndex(of: currentPhase) else { return }
        
        let nextIndex = (currentIndex + 1) % phases.count
        let nextPhase = phases[nextIndex]
        
        currentPhase = nextPhase
        phaseStartTime = Date()
        progress = 0.0
        
        if nextIndex == 0 {
            cycleStartTime = Date()
            currentCycleCount += 1
            
            if currentCycleCount > targetCycles {
                showTranscendence = true
                stopBreathing()
            }
        }
    }
    
    deinit {
        activeTask?.cancel()
        cancellables.removeAll()
    }
} 