import SwiftUI
import ARKit
import RealityKit
import Combine
import os.log

@MainActor
final class OceanusARProcessor: NSObject, ObservableObject {
    // AR状态
    enum ARStatus: Equatable {
        case initializing
        case ready
        case failed(Error)
        case placing
        case tracking
        
        static func == (lhs: ARStatus, rhs: ARStatus) -> Bool {
            switch (lhs, rhs) {
            case (.initializing, .initializing):
                return true
            case (.ready, .ready):
                return true
            case (.placing, .placing):
                return true
            case (.tracking, .tracking):
                return true
            case (.failed(let lhsError), .failed(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // 发布状态变化
    @Published var status: ARStatus = .initializing
    @Published var isPlaneDetected = false
    @Published var canPlacePlanet = false
    
    // AR配置
    private var arView: ARView?
    private var planetAnchor: AnchorEntity?
    private var subscriptions = Set<AnyCancellable>()
    
    // 调试信息
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.oceanus.ar",
        category: "OceanusARProcessor"
    )
    
    override init() {
        super.init()
        logger.debug("🚀 Initializing OceanusARProcessor")
    }
    
    func setupAR(view: ARView) {
        logger.debug("⚙️ Setting up AR session")
        self.arView = view
        
        // 配置AR会话
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // 启用人员遮挡
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }
        
        // 启用实体遮挡
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        // 启动会话
        view.session.run(config)
        
        // 添加手势识别
        setupGestures(for: view)
        
        // 设置代理
        view.session.delegate = self
        
        logger.debug("✅ AR session setup completed")
    }
    
    private func setupGestures(for view: ARView) {
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView = arView,
              status == .ready || status == .placing,
              canPlacePlanet else {
            logger.debug("⚠️ Cannot place planet: conditions not met")
            return
        }
        
        // 获取点击位置
        let location = gesture.location(in: arView)
        
        // 进行射线检测
        if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
            placePlanet(at: result.worldTransform)
        }
    }
    
    private func placePlanet(at transform: simd_float4x4) {
        logger.debug("🌍 Placing planet")
        // 这里后续会添加星球的创建和放置逻辑
    }
}

// MARK: - ARSessionDelegate
extension OceanusARProcessor: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // 更新平面检测状态
        if let _ = frame.anchors.first(where: { $0 is ARPlaneAnchor }) {
            Task { @MainActor in
                if !isPlaneDetected {
                    logger.debug("🎯 Plane detected")
                    isPlaneDetected = true
                    canPlacePlanet = true
                    status = .ready
                }
            }
        }
    }
    
    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        Task { @MainActor in
            logger.error("❌ AR session failed: \(error.localizedDescription)")
            status = .failed(error)
        }
    }
    
    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        Task { @MainActor in
            logger.debug("⚠️ AR session interrupted")
        }
    }
    
    nonisolated func sessionInterruptionEnded(_ session: ARSession) {
        Task { @MainActor in
            logger.debug("✅ AR session interruption ended")
            resetTracking()
        }
    }
    
    private func resetTracking() {
        guard let arView = arView else { return }
        
        // 重置会话
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // 重置状态
        isPlaneDetected = false
        canPlacePlanet = false
        status = .initializing
        
        logger.debug("🔄 Tracking reset")
    }
} 