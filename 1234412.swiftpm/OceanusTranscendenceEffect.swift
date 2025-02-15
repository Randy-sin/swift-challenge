import SwiftUI
import RealityKit

/// 升华效果的状态
enum TranscendenceState: CaseIterable {
    case preparing      // 准备开始
    case rippling      // 水波纹阶段
    case ascending     // 粒子上升阶段
    case resonating    // 海王星共鸣阶段
    case completing    // 完成阶段
    case finished      // 结束状态
    
    var duration: TimeInterval {
        switch self {
        case .preparing: return 0.5
        case .rippling: return 2.0
        case .ascending: return 3.0
        case .resonating: return 2.0
        case .completing: return 1.5
        case .finished: return 0.5
        }
    }
}

/// 海洋升华效果管理器
@MainActor
final class OceanusTranscendenceEffect: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var currentState: TranscendenceState = .preparing
    @Published private(set) var progress: Double = 0.0
    @Published var isActive: Bool = false
    
    // MARK: - Private Properties
    private var stateStartTime: Date?
    private var updateTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init() {
        print("🌊 初始化海洋升华效果")
    }
    
    // MARK: - Public Methods
    
    /// 开始升华效果
    func start() {
        guard !isActive else { return }
        print("✨ 开始升华效果")
        
        // 重置状态
        currentState = .preparing
        progress = 0.0
        stateStartTime = Date()
        isActive = true
        
        // 启动效果更新循环
        startEffectLoop()
    }
    
    /// 停止效果
    func stop() {
        print("⏹️ 停止升华效果")
        isActive = false
        updateTask?.cancel()
        updateTask = nil
        cleanup()
    }
    
    // MARK: - Private Methods
    
    private func cleanup() {
        print("🧹 清理资源")
        progress = 0.0
        stateStartTime = nil
    }
    
    private func startEffectLoop() {
        print("🔄 启动效果循环")
        updateTask?.cancel()
        
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            
            while !Task.isCancelled && self.isActive {
                self.updateEffect()
                try? await Task.sleep(for: .milliseconds(16)) // 约60fps
            }
        }
    }
    
    private func updateEffect() {
        guard let startTime = stateStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let duration = currentState.duration
        
        // 更新当前状态进度
        progress = min(elapsed / duration, 1.0)
        
        // 检查是否需要转换到下一个状态
        if progress >= 1.0 {
            moveToNextState()
        }
    }
    
    private func moveToNextState() {
        let nextState: TranscendenceState = switch currentState {
        case .preparing: .rippling
        case .rippling: .ascending
        case .ascending: .resonating
        case .resonating: .completing
        case .completing: .finished
        case .finished: .finished
        }
        
        if nextState != currentState {
            print("🔀 状态转换: \(currentState) -> \(nextState)")
            withAnimation(.easeInOut(duration: 0.5)) {
                currentState = nextState
            }
            stateStartTime = Date()
            progress = 0.0
            
            if nextState == .finished {
                stop()
            }
        }
    }
    
    deinit {
        print("🗑️ OceanusTranscendenceEffect deinit")
        updateTask?.cancel()
    }
} 