@preconcurrency
import SwiftUI
import Combine

/// 呼吸阶段
enum BreathingPhase: CaseIterable {
    case inhale  // 吸气
    case hold    // 屏息
    case exhale  // 呼气
    
    var duration: TimeInterval {
        switch self {
        case .inhale: return 3.0  // 3秒吸气
        case .hold: return 5.0    // 5秒屏息
        case .exhale: return 6.0  // 6秒呼气
        }
    }
    
    var description: String {
        switch self {
        case .inhale: return "吸气"
        case .hold: return "屏息"
        case .exhale: return "呼气"
        }
    }
    
    var color: Color {
        switch self {
        case .inhale: return .blue
        case .hold: return .purple
        case .exhale: return .indigo
        }
    }
    
    var animation: Animation {
        switch self {
        case .inhale:
            return .easeInOut(duration: duration)
        case .hold:
            return .easeInOut(duration: duration)
        case .exhale:
            return .easeInOut(duration: duration)
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .inhale: return 1.5
        case .hold: return 1.5
        case .exhale: return 1.0
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
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var phaseStartTime: Date?
    private var cycleStartTime: Date?
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
        isActive = true
        currentPhase = .inhale
        phaseStartTime = Date()
        cycleStartTime = Date()
        currentCycleCount = 1
        startTimer()
    }
    
    func stopBreathing() {
        isActive = false
        timer?.invalidate()
        timer = nil
        progress = 0.0
        totalProgress = 0.0
        currentCycleCount = 0
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        $isActive
            .sink { [weak self] active in
                Task { @MainActor [weak self] in
                    if !active {
                        self?.stopBreathing()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateProgress()
            }
        }
    }
    
    private func updateProgress() {
        guard let startTime = phaseStartTime,
              let cycleStart = cycleStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let cycleElapsed = Date().timeIntervalSince(cycleStart)
        let duration = currentPhase.duration
        
        // 更新当前阶段进度
        progress = min(elapsed / duration, 1.0)
        
        // 更新总体进度
        totalProgress = min((Double(currentCycleCount - 1) + cycleElapsed / totalDuration) / Double(targetCycles), 1.0)
        
        if progress >= 1.0 {
            moveToNextPhase()
        }
    }
    
    private func moveToNextPhase() {
        let phases = BreathingPhase.allCases
        guard let currentIndex = phases.firstIndex(of: currentPhase) else { return }
        
        let nextIndex = (currentIndex + 1) % phases.count
        currentPhase = phases[nextIndex]
        phaseStartTime = Date()
        progress = 0.0
        
        // 如果完成一个完整的循环
        if nextIndex == 0 {
            cycleStartTime = Date()
            currentCycleCount += 1
            
            // 如果达到目标循环次数，停止
            if currentCycleCount > targetCycles {
                stopBreathing()
            }
        }
    }
    
    deinit {
        Task { @MainActor [weak self] in
            self?.timer?.invalidate()
            self?.timer = nil
            self?.cancellables.removeAll()
        }
    }
} 