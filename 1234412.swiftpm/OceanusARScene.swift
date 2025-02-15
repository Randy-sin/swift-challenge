import SwiftUI
import RealityKit
import ARKit
import os

struct OceanusARScene: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var arController = ARController()
    @State private var showScanningView = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCompletion = false
    
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
            VStack(spacing: 0) {
                // 顶部按钮行
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
                    
                    Button(action: {
                        showCompletion = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .padding(.leading, 12)
                    
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
                }
                .padding(.top, 20)
                
                if !showScanningView {
                    Spacer()
                }
            }
            
            // 指引文字（独立于其他UI元素）
            Text("Point your camera at Neptune")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .position(x: UIScreen.main.bounds.width / 2, y: 7)
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
        .fullScreenCover(isPresented: $showCompletion) {
            OceanusCompletionView()
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
    private let updateThreshold: TimeInterval = 0.1
    private let minPlaneSize: Float = 0.2
    private let requiredStabilityScore: Float = 0.7
    
    private struct PlaneTrackingInfo {
        let anchor: ARPlaneAnchor
        var updateCount: Int = 0
        var lastUpdateTime: TimeInterval = 0
        var stabilityScore: Float = 0
        var previousExtents: [SIMD2<Float>] = []
        var previousCenters: [SIMD3<Float>] = []
        
        mutating func updateStabilityScore() {
            let currentTime = CACurrentMediaTime()
            let timeDelta = currentTime - lastUpdateTime
            
            if timeDelta > 0.5 {
                stabilityScore += 0.1
            } else if timeDelta < 0.1 {
                stabilityScore -= 0.05
            }
            
            if let lastExtent = previousExtents.last {
                let currentExtent = SIMD2<Float>(anchor.planeExtent.width, anchor.planeExtent.height)
                let extentChange = abs(lastExtent - currentExtent)
                if extentChange.x + extentChange.y < 0.01 {
                    stabilityScore += 0.05
                } else {
                    stabilityScore -= 0.1
                }
            }
            
            if let lastCenter = previousCenters.last {
                let centerChange = distance(lastCenter, anchor.center)
                if centerChange < 0.01 {
                    stabilityScore += 0.05
                } else {
                    stabilityScore -= 0.1
                }
            }
            
            previousExtents.append(SIMD2<Float>(anchor.planeExtent.width, anchor.planeExtent.height))
            previousCenters.append(anchor.center)
            
            if previousExtents.count > 10 {
                previousExtents.removeFirst()
                previousCenters.removeFirst()
            }
            
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
        
        config.isAutoFocusEnabled = false
        config.environmentTexturing = .none
        config.isLightEstimationEnabled = false
        
        hasPlacedNeptune = false
        isPlaneDetected = false
        trackedPlanes.removeAll()
        selectedPlaneAnchor = nil
        
        arView.session.delegate = self
        
        let options: ARSession.RunOptions = [
            .resetTracking,
            .removeExistingAnchors,
            .resetSceneReconstruction
        ]
        arView.session.run(config, options: options)
        
        arView.renderOptions = [
            .disableMotionBlur,
            .disableDepthOfField,
            .disablePersonOcclusion,
            .disableFaceMesh,
            .disableGroundingShadows,
            .disableCameraGrain,
            .disableHDR
        ]
        
        arView.environment.sceneUnderstanding.options = [
            .collision,
            .physics
        ]
    }
    
    private func updatePlaneTracking(_ anchor: ARPlaneAnchor) {
        let currentTime = CACurrentMediaTime()
        
        if currentTime - lastUpdateTime < updateThreshold {
            return
        }
        
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
        
        if let bestPlane = findBestPlane() {
            selectedPlaneAnchor = bestPlane
        }
        
        lastUpdateTime = currentTime
    }
    
    private func findBestPlane() -> ARPlaneAnchor? {
        return trackedPlanes
            .filter { _, info in
                let size = info.anchor.planeExtent
                let isLargeEnough = size.width >= minPlaneSize && size.height >= minPlaneSize
                
                let transform = info.anchor.transform
                let worldNormal = SIMD3<Float>(transform.columns.2[0], transform.columns.2[1], transform.columns.2[2])
                let isHorizontal = abs(simd_dot(worldNormal, SIMD3<Float>(0, 1, 0))) > 0.98
                
                let isStable = info.stabilityScore >= requiredStabilityScore
                
                let hasEnoughUpdates = info.updateCount >= 10
                
                return isLargeEnough && isHorizontal && isStable && hasEnoughUpdates
            }
            .max(by: { $0.value.stabilityScore < $1.value.stabilityScore })?
            .value.anchor
    }
    
    private func addOceanusToScene(at anchor: ARPlaneAnchor) {
        guard !hasPlacedNeptune else { return }
        
        var anchorTransform = anchor.transform
        anchorTransform.columns.3.y += 0.05
        
        oceanusEntity = OceanusEntity { [weak self] modelEntity in
            guard let self = self,
                  let modelEntity = modelEntity else { return }
            
            let anchorEntity = AnchorEntity(world: anchorTransform)
            
            modelEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(
                massProperties: .init(mass: 0),
                material: .default,
                mode: .static
            )
            
            anchorEntity.addChild(modelEntity)
            self.arView.scene.addAnchor(anchorEntity)
            
            self.hasPlacedNeptune = true
            self.isPlaneDetected = true
            
            if let config = self.arView.session.configuration as? ARWorldTrackingConfiguration {
                let planeAnchors = self.arView.session.currentFrame?.anchors.filter { $0 is ARPlaneAnchor } ?? []
                for anchor in planeAnchors {
                    self.arView.session.remove(anchor: anchor)
                }
                
                config.planeDetection = []
                self.arView.session.run(config, options: [.removeExistingAnchors])
            }
        }
    }
    
    // MARK: - AR Session Delegate Methods
    
    nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    if !self.hasPlacedNeptune {
                        if planeAnchor.planeExtent.width >= 0.3 && planeAnchor.planeExtent.height >= 0.3 {
                            self.placeNeptuneAndOcean(on: planeAnchor)
                            
                            self.waterSurfaceEntity = WaterSurfaceEntity { [weak self] modelEntity in
                                guard let self = self else { return }
                                guard let modelEntity = modelEntity else { return }
                                
                                let anchorEntity = AnchorEntity(world: planeAnchor.transform)
                                anchorEntity.addChild(modelEntity)
                                self.arView.scene.addAnchor(anchorEntity)
                            }
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
        if let entity = oceanusEntity?.getEntity() {
            if let anchorEntity = entity.anchor {
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        
        if let entity = waterSurfaceEntity?.getEntity() {
            if let anchorEntity = entity.anchor {
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        
        oceanusEntity = nil
        waterSurfaceEntity = nil
        hasPlacedNeptune = false
        isPlaneDetected = false
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        config.isAutoFocusEnabled = false
        config.environmentTexturing = .none
        config.isLightEstimationEnabled = false
        
        let options: ARSession.RunOptions = [
            .resetTracking,
            .removeExistingAnchors,
            .resetSceneReconstruction
        ]
        arView.session.run(config, options: options)
    }
    
    func placeNeptuneAndOcean(on anchor: ARPlaneAnchor) {
        Task { @MainActor in
            do {
                addOceanusToScene(at: anchor)
                
                let config = ARWorldTrackingConfiguration()
                config.planeDetection = []
                config.isAutoFocusEnabled = false
                config.environmentTexturing = .none
                config.isLightEstimationEnabled = false
                arView.session.run(config)
                
            } catch {
                // Handle error silently
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
