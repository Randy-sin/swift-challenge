import SwiftUI
import RealityKit
import ARKit
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.oceanus.ar",
    category: "OceanusARScene"
)

struct OceanusARScene: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var arController = ARController()
    @State private var showScanningView = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(arController: arController)
                .edgesIgnoringSafeArea(.all)
            
            // Scanning Overlay
            if showScanningView {
                ScanningView(isScanning: $showScanningView, arController: arController)
                    .transition(.opacity)
            }
            
            // 呼吸引导视图
            if !showScanningView {
                BreathingGuideView()
                    .padding(.top, 100)  // 调整顶部距离
                    .transition(.opacity)
            }
            
            // Back Button and Reset Button
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Reset button with hint
                    HStack(spacing: 12) {
                        // Hint text
                        Text("If Neptune is not visible, tap Reset")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        
                        // Reset button
                        Button(action: {
                            withAnimation {
                                showScanningView = true
                                arController.resetScene()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                if !showScanningView {
                    Spacer()
                }
                
                Spacer()
            }
        }
        .alert("AR Session Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onReceive(arController.$sessionError) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .onChange(of: arController.isPlaneDetected) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showScanningView = false
                    }
                }
            }
        }
    }
}

// AR Controller
@MainActor
class ARController: NSObject, ObservableObject, ARSessionDelegate {
    let arView: ARView
    @Published var sessionError: Error?
    @Published var isPlaneDetected = false
    private var oceanusEntity: OceanusEntity?
    private var waterSurfaceEntity: WaterSurfaceEntity?
    private var hasPlacedNeptune = false
    
    // 平面跟踪相关属性
    private var trackedPlanes: [UUID: PlaneTrackingInfo] = [:]
    private var selectedPlaneAnchor: ARPlaneAnchor?
    private var lastUpdateTime: TimeInterval = 0
    private let updateThreshold: TimeInterval = 0.1  // 100ms
    private let minPlaneSize: Float = 0.2  // 最小平面尺寸
    private let requiredStabilityScore: Float = 0.7  // 所需稳定性分数
    
    // 平面跟踪信息结构体
    private struct PlaneTrackingInfo {
        let anchor: ARPlaneAnchor
        var updateCount: Int = 0
        var lastUpdateTime: TimeInterval = 0
        var stabilityScore: Float = 0
        var previousExtents: [SIMD2<Float>] = []  // 存储历史尺寸
        var previousCenters: [SIMD3<Float>] = []  // 存储历史中心点
        
        // 计算平面稳定性分数
        mutating func updateStabilityScore() {
            let currentTime = CACurrentMediaTime()
            let timeDelta = currentTime - lastUpdateTime
            
            // 根据更新频率调整稳定性
            if timeDelta > 0.5 {
                stabilityScore += 0.1
            } else if timeDelta < 0.1 {
                stabilityScore -= 0.05
            }
            
            // 检查尺寸变化
            if let lastExtent = previousExtents.last {
                let currentExtent = SIMD2<Float>(anchor.planeExtent.width, anchor.planeExtent.height)
                let extentChange = abs(lastExtent - currentExtent)
                if extentChange.x + extentChange.y < 0.01 {
                    stabilityScore += 0.05
                } else {
                    stabilityScore -= 0.1
                }
            }
            
            // 检查位置变化
            if let lastCenter = previousCenters.last {
                let centerChange = distance(lastCenter, anchor.center)
                if centerChange < 0.01 {
                    stabilityScore += 0.05
                } else {
                    stabilityScore -= 0.1
                }
            }
            
            // 更新历史记录
            previousExtents.append(SIMD2<Float>(anchor.planeExtent.width, anchor.planeExtent.height))
            previousCenters.append(anchor.center)
            
            // 限制历史记录长度
            if previousExtents.count > 10 {
                previousExtents.removeFirst()
                previousCenters.removeFirst()
            }
            
            // 确保分数在有效范围内
            stabilityScore = min(max(stabilityScore, 0), 1.0)
            lastUpdateTime = currentTime
        }
    }
    
    override init() {
        arView = ARView(frame: .zero)
        super.init()
        setupAR()
    }
    
    private func setupAR() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // 关闭自动对焦和其他可能导致抖动的功能
        config.isAutoFocusEnabled = false
        config.environmentTexturing = .none
        config.isLightEstimationEnabled = false
        
        // 重置状态
        hasPlacedNeptune = false
        isPlaneDetected = false
        trackedPlanes.removeAll()
        selectedPlaneAnchor = nil
        
        // 配置AR会话
        arView.session.delegate = self
        
        // 使用更保守的跟踪选项
        let options: ARSession.RunOptions = [
            .resetTracking,
            .removeExistingAnchors,
            .resetSceneReconstruction
        ]
        arView.session.run(config, options: options)
        
        // 优化渲染设置
        arView.renderOptions = [
            .disableMotionBlur,
            .disableDepthOfField,
            .disablePersonOcclusion,
            .disableFaceMesh,
            .disableGroundingShadows,
            .disableCameraGrain,
            .disableHDR
        ]
        
        // 配置场景理解
        arView.environment.sceneUnderstanding.options = [
            .collision,
            .physics
        ]
    }
    
    private func updatePlaneTracking(_ anchor: ARPlaneAnchor) {
        let currentTime = CACurrentMediaTime()
        
        // 如果更新太频繁，跳过
        if currentTime - lastUpdateTime < updateThreshold {
            return
        }
        
        // 更新或添加平面跟踪信息
        if var info = trackedPlanes[anchor.identifier] {
            info.updateCount += 1
            info.updateStabilityScore()
            trackedPlanes[anchor.identifier] = info
        } else {
            trackedPlanes[anchor.identifier] = PlaneTrackingInfo(
                anchor: anchor,
                lastUpdateTime: currentTime
            )
        }
        
        // 评估平面质量
        if let bestPlane = findBestPlane() {
            selectedPlaneAnchor = bestPlane
        }
        
        lastUpdateTime = currentTime
    }
    
    private func findBestPlane() -> ARPlaneAnchor? {
        return trackedPlanes
            .filter { _, info in
                // 过滤条件
                let size = info.anchor.planeExtent
                let isLargeEnough = size.width >= minPlaneSize && size.height >= minPlaneSize
                
                // 检查平面是否足够水平
                let transform = info.anchor.transform
                let worldNormal = SIMD3<Float>(transform.columns.2[0], transform.columns.2[1], transform.columns.2[2])
                let isHorizontal = abs(simd_dot(worldNormal, SIMD3<Float>(0, 1, 0))) > 0.98
                
                // 检查稳定性分数
                let isStable = info.stabilityScore >= requiredStabilityScore
                
                // 检查更新次数
                let hasEnoughUpdates = info.updateCount >= 10
                
                return isLargeEnough && isHorizontal && isStable && hasEnoughUpdates
            }
            .max(by: { $0.value.stabilityScore < $1.value.stabilityScore })?
            .value.anchor
    }
    
    private func addOceanusToScene(at anchor: ARPlaneAnchor) {
        guard !hasPlacedNeptune else { 
            print("⚠️ 已经放置了海王星，忽略新的放置请求")
            return 
        }
        
        print("🎯 开始放置海王星")
        print("📍 锚点位置: x=\(anchor.transform.columns.3.x), y=\(anchor.transform.columns.3.y), z=\(anchor.transform.columns.3.z)")
        
        // 使用检测到的平面锚点创建变换矩阵
        var anchorTransform = anchor.transform
        
        // 调整高度，避免穿模和抖动
        anchorTransform.columns.3.y += 0.05
        
        // 创建海王星实体
        oceanusEntity = OceanusEntity { [weak self] modelEntity in
            guard let self = self,
                  let modelEntity = modelEntity else { 
                print("❌ 模型加载失败")
                return 
            }
            
            print("✅ 模型加载成功")
            
            // 创建锚点实体
            let anchorEntity = AnchorEntity(world: anchorTransform)
            print("🔗 创建锚点实体: position=\(anchorEntity.position)")
            
            // 配置物理属性
            modelEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                massProperties: .init(mass: 0),
                material: .default,
                mode: .static
            )
            
            // 添加到场景
            anchorEntity.addChild(modelEntity)
            self.arView.scene.addAnchor(anchorEntity)
            print("➕ 添加到场景完成")
            
            // 更新状态
            self.hasPlacedNeptune = true
            self.isPlaneDetected = true
            
            // 放置后停止平面检测
            if let config = self.arView.session.configuration as? ARWorldTrackingConfiguration {
                print("🛑 停止平面检测")
                
                // 移除所有现有的平面锚点
                let planeAnchors = self.arView.session.currentFrame?.anchors.filter { $0 is ARPlaneAnchor } ?? []
                for anchor in planeAnchors {
                    self.arView.session.remove(anchor: anchor)
                }
                print("🧹 已移除所有平面锚点: \(planeAnchors.count) 个")
                
                // 停止平面检测并重新配置会话
                config.planeDetection = []
                self.arView.session.run(config, options: [.removeExistingAnchors])
                print("✅ AR配置更新完成")
                
                // 打印当前会话的状态
                print("📊 AR会话状态:")
                print("  - 跟踪状态: \(self.arView.session.currentFrame?.camera.trackingState ?? .notAvailable)")
                print("  - 世界原点: \(self.arView.session.currentFrame?.camera.transform ?? matrix_identity_float4x4)")
                print("  - 锚点数量: \(self.arView.session.currentFrame?.anchors.count ?? 0)")
            } else {
                print("⚠️ 无法获取AR配置")
            }
        }
    }
    
    // MARK: - AR Session Delegate Methods
    
    nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    print("📍 检测到新平面，尺寸: \(planeAnchor.planeExtent.width) x \(planeAnchor.planeExtent.height)")
                    
                    if !self.hasPlacedNeptune {
                        // 检查平面是否足够大以放置海王星
                        if planeAnchor.planeExtent.width >= 0.3 && planeAnchor.planeExtent.height >= 0.3 {
                            print("🌊 找到合适的平面，准备放置海王星")
                            self.placeNeptuneAndOcean(on: planeAnchor)
                            
                            // 创建水面实体
                            print("💧 开始创建水面实体")
                            self.waterSurfaceEntity = WaterSurfaceEntity { [weak self] modelEntity in
                                guard let self = self else {
                                    print("⚠️ self 已被释放，无法继续处理水面实体")
                                    return
                                }
                                
                                guard let modelEntity = modelEntity else {
                                    print("❌ 水面模型实体创建失败")
                                    return
                                }
                                
                                print("🎯 水面模型实体创建成功，准备添加到场景")
                                print("  - 模型位置: \(modelEntity.position)")
                                print("  - 模型缩放: \(modelEntity.scale)")
                                print("  - 模型变换: \(modelEntity.transform)")
                                
                                // 创建锚点实体
                                let anchorEntity = AnchorEntity(world: planeAnchor.transform)
                                print("📍 创建水面锚点实体: \(anchorEntity)")
                                print("  - 锚点位置: \(anchorEntity.position)")
                                print("  - 锚点变换: \(anchorEntity.transform)")
                                
                                anchorEntity.addChild(modelEntity)
                                print("🔗 水面模型已添加到锚点")
                                
                                self.arView.scene.addAnchor(anchorEntity)
                                print("✅ 水面实体已添加到场景")
                                
                                // 打印场景中的所有锚点
                                print("📊 当前场景锚点状态:")
                                for anchor in self.arView.scene.anchors {
                                    print("  - \(type(of: anchor)): \(anchor.name)")
                                    for child in anchor.children {
                                        print("    └─ \(type(of: child)): \(child.name)")
                                    }
                                }
                            }
                            print("💧 水面实体创建完成，等待加载回调")
                        }
                    }
                }
            }
        }
    }
    
    nonisolated func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        Task { @MainActor in
            if !self.hasPlacedNeptune {
                for anchor in anchors {
                    if let planeAnchor = anchor as? ARPlaneAnchor {
                        self.updatePlaneTracking(planeAnchor)
                    }
                }
            }
        }
    }
    
    // 添加新的方法来处理会话中断
    nonisolated func session(_ session: ARSession, didInterrupt: ()) {
        print("⚠️ AR会话被中断")
    }
    
    // 添加新的方法来处理会话恢复
    nonisolated func session(_ session: ARSession, didEndInterrupt: ()) {
        print("✅ AR会话恢复")
    }
    
    func resetScene() {
        print("🔄 开始重置场景")
        
        if let entity = oceanusEntity?.getEntity() {
            if let anchorEntity = entity.anchor {
                print("🗑️ 移除现有实体")
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        
        if let entity = waterSurfaceEntity?.getEntity() {
            if let anchorEntity = entity.anchor {
                print("🗑️ 移除水面实体")
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        
        oceanusEntity = nil
        waterSurfaceEntity = nil
        hasPlacedNeptune = false
        isPlaneDetected = false
        
        // 重新设置 AR 配置，重新启用平面检测
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // 保持与 setupAR 相同的配置
        config.isAutoFocusEnabled = false
        config.environmentTexturing = .none
        config.isLightEstimationEnabled = false
        
        print("🛠️ 重新配置AR会话")
        // 使用更保守的跟踪选项
        let options: ARSession.RunOptions = [
            .resetTracking,
            .removeExistingAnchors,
            .resetSceneReconstruction
        ]
        arView.session.run(config, options: options)
        
        print("✅ 重置完成")
    }
    
    func placeNeptuneAndOcean(on anchor: ARPlaneAnchor) {
        Task { @MainActor in
            do {
                addOceanusToScene(at: anchor)
                
                // 停止平面检测
                let config = ARWorldTrackingConfiguration()
                config.planeDetection = []
                config.isAutoFocusEnabled = false
                config.environmentTexturing = .none
                config.isLightEstimationEnabled = false
                arView.session.run(config)  // 不需要重置场景重建
                
                print("✅ 已停止平面检测")
                
            } catch {
                print("❌ 放置海王星时出错: \(error.localizedDescription)")
            }
        }
    }
}

// AR View Container
struct ARViewContainer: UIViewRepresentable {
    let arController: ARController
    
    func makeUIView(context: Context) -> ARView {
        return arController.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// Scanning Animation View
struct ScanningView: View {
    @Binding var isScanning: Bool
    @State private var animationOffset: CGFloat = 0
    @State private var showInstructions = true
    let arController: ARController
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Scanning animation
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 250, height: 250)
                    
                    // Scanning line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 250, height: 3)
                        .offset(y: animationOffset)
                }
                
                // Instructions
                VStack(spacing: 16) {
                    Text("Move your device slowly")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Point your camera at the floor to detect surfaces")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(showInstructions ? 1 : 0)
            }
        }
        .onAppear {
            // 重置平面检测状态
            arController.isPlaneDetected = false
            
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                animationOffset = 120
            }
        }
        .onChange(of: arController.isPlaneDetected) { oldValue, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.5)) {
                    showInstructions = false
                }
            }
        }
    }
}

#Preview {
    OceanusARScene()
} 
