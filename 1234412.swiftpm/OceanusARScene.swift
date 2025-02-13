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
                    // Remove pinch gesture hint
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

// AR View Container
struct ARViewContainer: UIViewRepresentable {
    let arController: ARController
    
    func makeUIView(context: Context) -> ARView {
        return arController.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// AR Controller
@MainActor
class ARController: NSObject, ObservableObject, ARSessionDelegate {
    let arView: ARView
    @Published var sessionError: Error?
    @Published var isPlaneDetected = false
    private var oceanusEntity: OceanusEntity?
    private var hasPlacedNeptune = false
    
    override init() {
        arView = ARView(frame: .zero)
        super.init()
        setupAR()
    }
    
    private func setupAR() {
        // 配置AR会话
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        // 重置状态
        hasPlacedNeptune = false
        isPlaneDetected = false
        
        // 启动AR会话
        arView.session.delegate = self
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func addOceanusToScene(at anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              !hasPlacedNeptune else { return }
        
        // 创建海王星实体
        oceanusEntity = OceanusEntity { [weak self] modelEntity in
            guard let self = self,
                  let modelEntity = modelEntity else { return }
            
            // 创建锚点实体
            let anchorEntity = AnchorEntity(anchor: planeAnchor)
            
            // 放置在平面中心，稍微抬高一点以避免穿模
            modelEntity.position = [0, 0.01, 0]
            
            // 添加到场景
            anchorEntity.addChild(modelEntity)
            self.arView.scene.addAnchor(anchorEntity)
            
            // 添加手势识别
            self.setupGestures(for: modelEntity)
            
            // 更新状态
            self.hasPlacedNeptune = true
            self.isPlaneDetected = true
        }
    }
    
    // 添加手势识别器
    private func setupGestures(for entity: ModelEntity) {
        let pinchGesture = EntityScaleGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: EntityScaleGestureRecognizer) {
        switch gesture.state {
        case .changed:
            oceanusEntity?.handlePinchGesture(scale: Float(gesture.scale))
        default:
            break
        }
    }
    
    // MARK: - AR Session Delegate Methods
    
    nonisolated func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            for anchor in anchors {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    // 找到平面后立即放置海王星
                    if !hasPlacedNeptune {
                        self.addOceanusToScene(at: planeAnchor)
                    }
                }
            }
        }
    }
    
    func resetScene() {
        if let entity = oceanusEntity?.getEntity() {
            if let anchorEntity = entity.anchor {
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        oceanusEntity = nil
        hasPlacedNeptune = false
        isPlaneDetected = false
        setupAR()
    }
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
