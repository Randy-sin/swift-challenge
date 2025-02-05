import SwiftUI
import SpriteKit
import SceneKit

struct LaunchView: View {
    @Binding var isLaunchViewPresented: Bool
    @State private var showNebula = false
    @State private var showText = false
    @State private var showSphere = false
    @State private var sphereScale: CGFloat = 0.1
    @State private var textOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.02, green: 0.02, blue: 0.08),
                        Color(red: 0.04, green: 0.04, blue: 0.12)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // 星云效果
                if showNebula {
                    NebulaView()
                        .opacity(showNebula ? 1 : 0)
                        .animation(.easeIn(duration: 2.0), value: showNebula)
                }
                
                // 发光球体
                if showSphere {
                    GlowingSphereView()
                        .scaleEffect(sphereScale)
                        .opacity(showSphere ? 1 : 0)
                        .animation(.easeInOut(duration: 2.0), value: sphereScale)
                }
                
                // 文字层
                VStack {
                    Spacer()
                    Text("Every day, our emotions flow like nebulae...")
                        .font(.system(size: 28, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .padding(.bottom, 8)
                    
                    Text("But do you truly see them?")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(textOpacity)
                        .padding(.bottom, geometry.size.height * 0.2)
                }
                .animation(.easeInOut(duration: 2.0), value: textOpacity)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeIn(duration: 2.0)) {
            showNebula = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 2.0)) {
                textOpacity = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            showSphere = true
            withAnimation(.easeInOut(duration: 2.0)) {
                sphereScale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                isLaunchViewPresented = false
            }
        }
    }
}

// 星云效果视图
struct NebulaView: UIViewRepresentable {
    @MainActor
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        let scene = SKScene(size: UIScreen.main.bounds.size)
        scene.backgroundColor = .clear
        scene.isUserInteractionEnabled = false
        
        if let nebula = SKEmitterNode(fileNamed: "Nebula") {
            nebula.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            nebula.particlePositionRange = CGVector(dx: scene.size.width, dy: scene.size.height)
            nebula.targetNode = scene
            scene.addChild(nebula)
        }
        
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        return view
    }
    
    @MainActor
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene {
            scene.size = uiView.bounds.size
            if let nebula = scene.children.first as? SKEmitterNode {
                nebula.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            }
        }
    }
}

// 发光球体视图
struct GlowingSphereView: UIViewRepresentable {
    // 使用 actor 来管理渲染状态
    actor RenderState {
        private var isActive = true
        
        func deactivate() {
            isActive = false
        }
        
        func isRendering() -> Bool {
            return isActive
        }
    }
    
    class Coordinator: NSObject, SCNSceneRendererDelegate {
        weak var sceneView: SCNView?
        let renderState = RenderState()
        
        nonisolated func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let sceneView = renderer as? SCNView else { return }
            
            Task {
                // 检查渲染状态
                if await renderState.isRendering() {
                    await MainActor.run {
                        sceneView.rendersContinuously = false
                    }
                    await renderState.deactivate()
                }
            }
        }
        
        func cleanup() {
            Task {
                await renderState.deactivate()
                await MainActor.run { [weak self] in
                    self?.sceneView?.delegate = nil
                    self?.sceneView?.scene = nil
                    self?.sceneView = nil
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView(frame: .zero, options: [
            SCNView.Option.preferredRenderingAPI.rawValue: NSNumber(value: SCNRenderingAPI.metal.rawValue),
            SCNView.Option.preferredDevice.rawValue: MTLCreateSystemDefaultDevice()!,
            SCNView.Option.preferLowPowerDevice.rawValue: true
        ])
        
        // 基本设置
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false
        sceneView.isUserInteractionEnabled = false
        sceneView.preferredFramesPerSecond = 30
        sceneView.antialiasingMode = .multisampling4X
        
        // 创建和设置场景
        let scene = createScene()
        
        // 在主线程上设置场景和代理
        DispatchQueue.main.async {
            sceneView.scene = scene
            context.coordinator.sceneView = sceneView
            sceneView.delegate = context.coordinator
        }
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene,
              let camera = scene.rootNode.childNodes.first(where: { $0.camera != nil }) else { return }
        
        let aspectRatio = uiView.bounds.width / uiView.bounds.height
        camera.camera?.fieldOfView = 60 * Double(aspectRatio)
    }
    
    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.cleanup()
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear
        
        // 创建球体
        let sphereNode = createSphereNode()
        
        // 设置相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        // 设置光照
        setupLighting(scene: scene)
        
        scene.rootNode.addChildNode(sphereNode)
        return scene
    }
    
    private func createSphereNode() -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.5)
        sphereGeometry.segmentCount = 32
        let sphereNode = SCNNode(geometry: sphereGeometry)
        
        // 材质
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0)
        material.emission.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.5)
        material.emission.intensity = 1.0
        material.metalness.contents = 0.6
        material.roughness.contents = 0.2
        material.lightingModel = .physicallyBased
        material.isDoubleSided = false
        sphereGeometry.materials = [material]
        
        // 添加光晕
        for i in 0..<2 {
            let scale = CGFloat(i) * 0.3 + 1.2
            let haloNode = createHaloNode(scale: scale)
            sphereNode.addChildNode(haloNode)
        }
        
        // 添加环绕光点
        for _ in 0..<6 {
            let orbNode = createOrbNode()
            sphereNode.addChildNode(orbNode)
        }
        
        // 旋转动画
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 20)
        sphereNode.runAction(SCNAction.repeatForever(rotation))
        
        return sphereNode
    }
    
    private func createHaloNode(scale: CGFloat) -> SCNNode {
        let haloGeometry = SCNPlane(width: 2.0 * scale, height: 2.0 * scale)
        let haloNode = SCNNode(geometry: haloGeometry)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        material.emission.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.15 / scale)
        material.emission.intensity = 1.2
        material.transparent.contents = true
        material.lightingModel = .constant
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        haloGeometry.materials = [material]
        
        haloNode.constraints = [SCNBillboardConstraint()]
        haloNode.renderingOrder = 100
        
        let pulse = SCNAction.sequence([
            SCNAction.scale(to: 1.1, duration: 1.5),
            SCNAction.scale(to: 1.0, duration: 1.5)
        ])
        haloNode.runAction(SCNAction.repeatForever(pulse))
        
        return haloNode
    }
    
    private func createOrbNode() -> SCNNode {
        let orbGeometry = SCNSphere(radius: 0.02)
        orbGeometry.segmentCount = 8
        let orbNode = SCNNode(geometry: orbGeometry)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.emission.contents = UIColor(red: 0.3, green: 0.4, blue: 0.9, alpha: 0.8)
        material.emission.intensity = 2.0
        material.lightingModel = .constant
        material.writesToDepthBuffer = false
        material.readsFromDepthBuffer = false
        orbGeometry.materials = [material]
        
        // 设置轨道
        let radius = 1.0
        let angle = Double.random(in: 0...2 * .pi)
        let height = Double.random(in: -0.5...0.5)
        orbNode.position = SCNVector3(
            x: Float(radius * cos(angle)),
            y: Float(height),
            z: Float(radius * sin(angle))
        )
        
        // 轨道动画
        let orbit = SCNAction.customAction(duration: 12.0) { node, time in
            let progress = time / 12.0
            let currentAngle = angle + Double(progress) * 2 * .pi
            node.position = SCNVector3(
                x: Float(radius * cos(currentAngle)),
                y: node.position.y,
                z: Float(radius * sin(currentAngle))
            )
        }
        orbNode.runAction(SCNAction.repeatForever(orbit))
        
        return orbNode
    }
    
    private func setupLighting(scene: SCNScene) {
        // 主光源
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.color = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        mainLight.light?.intensity = 800
        mainLight.position = SCNVector3(x: 3, y: 3, z: 3)
        scene.rootNode.addChildNode(mainLight)
        
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        ambientLight.light?.intensity = 400
        scene.rootNode.addChildNode(ambientLight)
        
        // 背光
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .directional
        backLight.light?.color = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0)
        backLight.light?.intensity = 400
        backLight.position = SCNVector3(x: -2, y: -1, z: -3)
        scene.rootNode.addChildNode(backLight)
    }
} 
