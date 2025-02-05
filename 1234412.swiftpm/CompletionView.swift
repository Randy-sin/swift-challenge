import SwiftUI
import SceneKit
import SpriteKit

// 星空背景视图
struct StarfieldView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.backgroundColor = .clear
        view.allowsTransparency = true
        
        let scene = SKScene(size: view.bounds.size)
        scene.backgroundColor = .clear
        
        // 创建粒子效果
        if let starfield = SKEmitterNode(fileNamed: "Starfield") {
            starfield.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
            starfield.particlePositionRange = CGVector(dx: scene.size.width * 1.5, dy: scene.size.height * 1.5)
            scene.addChild(starfield)
        }
        
        view.presentScene(scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}

struct CompletionView: View {
    @State private var showCongrats = false
    @State private var showMainText = false
    @State private var showSubText = false
    @State private var starAlpha: Double = 0
    @State private var planetScale: CGFloat = 0.8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.06, green: 0.06, blue: 0.15),
                        Color(red: 0.08, green: 0.08, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // 星空背景
                StarfieldView()
                    .opacity(starAlpha)
                
                // 内容容器
                HStack(spacing: 0) {
                    // 左侧：3D星球场景
                    ZStack {
                        // 星球光晕背景
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.2),
                                        Color.blue.opacity(0.1),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: geometry.size.width * 0.2
                                )
                            )
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                            .blur(radius: 30)
                        
                        PlanetSceneView()
                            .frame(width: geometry.size.width * 0.4)
                            .scaleEffect(planetScale)
                    }
                    
                    // 右侧：文字内容
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height * 0.2)  // 增加顶部空间
                        
                        if showCongrats {
                            Text("Congratulations!")
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .transition(.opacity.combined(with: .slide))
                                .shadow(color: .white.opacity(0.3), radius: 10)
                        }
                        
                        if showMainText {
                            Text("You are as peaceful as\nMercury today")
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(0.9)
                                .transition(.opacity.combined(with: .slide))
                                .shadow(color: .white.opacity(0.2), radius: 8)
                                .padding(.top, 40)  // 增加与标题的间距
                                .lineSpacing(8)  // 增加行间距
                        }
                        
                        if showSubText {
                            Text("Let your tranquility flow\nthrough the universe")
                                .font(.system(size: 18, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                                .opacity(0.6)  // 降低不透明度
                                .transition(.opacity.combined(with: .slide))
                                .shadow(color: .white.opacity(0.1), radius: 6)
                                .padding(.top, 24)  // 调整与主文本的间距
                                .lineSpacing(6)  // 增加行间距
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 80)  // 增加左侧留白
                    .frame(width: geometry.size.width * 0.6)
                }
                
                // 底部装饰线
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            // 星空渐入
            withAnimation(.easeIn(duration: 2)) {
                starAlpha = 0.7
            }
            
            // 星球缩放动画
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8, blendDuration: 0).delay(1)) {
                planetScale = 1.0
            }
            
            // 文字依次显示
            withAnimation(.easeIn(duration: 0.8).delay(1.8)) {
                showCongrats = true
            }
            withAnimation(.easeIn(duration: 0.8).delay(2.2)) {
                showMainText = true
            }
            withAnimation(.easeIn(duration: 0.8).delay(2.6)) {
                showSubText = true
            }
        }
    }
}

// 3D星球场景视图
struct PlanetSceneView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // 创建星球节点
        let planetNode = SCNNode()
        
        // 星球几何体
        let planetGeometry = SCNSphere(radius: 1.0)
        planetGeometry.segmentCount = 100  // 增加细节
        
        // 创建材质
        let material = SCNMaterial()
        
        // 基础颜色和纹理
        if let texture = UIImage(named: "planet_texture") {
            print("✅ 纹理加载成功")
            material.diffuse.contents = texture
            
            // 添加法线贴图以增强表面细节
            material.normal.intensity = 0.8  // 增强表面细节
            material.normal.contents = texture
        } else {
            print("❌ 纹理加载失败")
            material.diffuse.contents = UIColor.red
        }
        
        // 调整材质参数
        material.roughness.contents = 0.4  // 降低粗糙度，增加光泽感
        material.metalness.contents = 0.4  // 增加金属感
        material.emission.contents = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0)
        material.lightingModel = .physicallyBased
        
        planetGeometry.materials = [material]
        planetNode.geometry = planetGeometry
        
        // 添加大气层效果
        let atmosphereNode = SCNNode()
        let atmosphereGeometry = SCNSphere(radius: 1.08)  // 增加大气层厚度
        let atmosphereMaterial = SCNMaterial()
        atmosphereMaterial.diffuse.contents = UIColor.clear
        atmosphereMaterial.emission.contents = UIColor(red: 0.3, green: 0.4, blue: 0.8, alpha: 0.15)  // 调整发光强度
        atmosphereMaterial.transparent.contents = UIColor.white.withAlphaComponent(0.2)
        atmosphereMaterial.transparencyMode = .rgbZero
        atmosphereMaterial.lightingModel = .constant
        atmosphereGeometry.materials = [atmosphereMaterial]
        atmosphereNode.geometry = atmosphereGeometry
        planetNode.addChildNode(atmosphereNode)
        
        // 添加光晕效果
        let glowNode = SCNNode()
        let glowGeometry = SCNPlane(width: 3.5, height: 3.5)  // 增加光晕大小
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = UIColor.clear
        glowMaterial.emission.contents = UIColor(red: 0.3, green: 0.4, blue: 0.8, alpha: 0.08)  // 调整发光强度
        glowMaterial.transparent.contents = UIImage(named: "glow")
        glowMaterial.transparencyMode = .rgbZero
        glowMaterial.lightingModel = .constant
        glowGeometry.materials = [glowMaterial]
        glowNode.geometry = glowGeometry
        glowNode.constraints = [SCNBillboardConstraint()]
        planetNode.addChildNode(glowNode)
        
        // 添加自转动画
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0.2 * .pi, duration: 25)  // 稍微倾斜自转轴，减慢速度
        let repeatRotation = SCNAction.repeatForever(rotation)
        planetNode.runAction(repeatRotation)
        
        // 设置主光源（太阳光）
        let mainLight = SCNNode()
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.color = UIColor(red: 1, green: 0.98, blue: 0.9, alpha: 1)  // 更温暖的光色
        mainLight.light?.intensity = 1200
        mainLight.position = SCNVector3(x: 5, y: 5, z: 5)
        
        // 添加环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)
        ambientLight.light?.intensity = 600  // 调整环境光强度
        
        // 添加次级光源（背光）
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .directional
        backLight.light?.color = UIColor(red: 0.3, green: 0.4, blue: 0.8, alpha: 1)
        backLight.light?.intensity = 500
        backLight.position = SCNVector3(x: -3, y: -2, z: -4)
        
        // 添加节点到场景
        scene.rootNode.addChildNode(planetNode)
        scene.rootNode.addChildNode(mainLight)
        scene.rootNode.addChildNode(ambientLight)
        scene.rootNode.addChildNode(backLight)
        
        // 设置相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
} 