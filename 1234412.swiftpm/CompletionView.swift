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
    @Environment(\.dismiss) private var dismiss
    @State private var showCongrats = false
    @State private var showMainText = false
    @State private var showSubText = false
    @State private var starAlpha: Double = 0
    @State private var planetScale: CGFloat = 0.8
    @State private var isPlanetTapped = false
    @State private var planetPosition: CGSize = .zero
    @State private var planetExpanded = false
    @State private var blurRadius: CGFloat = 0
    @State private var brightness: Double = 0
    
    // 添加文字动画状态
    @State private var textOpacity1: Double = 0
    @State private var textOpacity2: Double = 0
    @State private var textOpacity3: Double = 0
    @State private var backgroundTextOpacity: Double = 0  // 背景文字透明度
    
    // 定义渐变色
    private let goldGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.85, blue: 0.4),  // 明亮的金色
            Color(red: 1.0, green: 0.7, blue: 0.2)    // 深金色
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private let purpleGradient = LinearGradient(
        colors: [
            Color(red: 0.7, green: 0.4, blue: 1.0),   // 浅紫色
            Color(red: 0.5, green: 0.2, blue: 0.8)    // 深紫色
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private let blueGradient = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.8, blue: 1.0),   // 浅蓝色
            Color(red: 0.2, green: 0.6, blue: 0.8)    // 深蓝色
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // 背景说明文字数组
    private let backgroundTexts = [
        (text: "You're Not Alone", color: Color(red: 1.0, green: 0.85, blue: 0.4), scale: 1.15, rotation: -5, position: CGPoint(x: 0.15, y: 0.08)),
        (text: "WHO Report 2023", color: Color(red: 0.4, green: 0.8, blue: 1.0), scale: 1.1, rotation: -15, position: CGPoint(x: 0.4, y: 0.15)),
        (text: "Global Depression Statistics", color: Color(red: 0.7, green: 0.4, blue: 1.0), scale: 0.9, rotation: 10, position: CGPoint(x: 0.85, y: 0.10)),
        (text: "5% of Adults Worldwide", color: Color(red: 1.0, green: 0.7, blue: 0.3), scale: 1.2, rotation: -8, position: CGPoint(x: 0.2, y: 0.85)),
        (text: "Seeking Light Together", color: Color(red: 0.3, green: 0.7, blue: 0.9), scale: 0.95, rotation: 12, position: CGPoint(x: 0.9, y: 0.75)),
        (text: "Every 40 Seconds", color: Color(red: 0.8, green: 0.5, blue: 1.0), scale: 1.0, rotation: 15, position: CGPoint(x: 0.8, y: 0.5)),
        (text: "A Global Challenge", color: Color(red: 0.5, green: 0.8, blue: 0.9), scale: 1.05, rotation: -12, position: CGPoint(x: 0.25, y: 0.65)),
        (text: "Hope Begins With A Smile", color: Color(red: 1.0, green: 0.8, blue: 0.3), scale: 1.1, rotation: 8, position: CGPoint(x: 0.75, y: 0.9))
    ]
    
    // 添加动画状态
    @State private var backgroundTextScales: [CGFloat] = Array(repeating: 1.0, count: 8)
    @State private var backgroundTextOpacities: [Double] = Array(repeating: 0.0, count: 8)
    @State private var heartbeatScale: CGFloat = 1.0
    @State private var heartbeatOpacity: Double = 0.8
    @State private var guideTextOpacity: Double = 0  // 添加引导文字透明度状态
    
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
                
                // 添加背景说明文字
                ForEach(backgroundTexts.indices, id: \.self) { index in
                    let text = backgroundTexts[index]
                    Text(text.text)
                        .font(.system(size: index % 2 == 0 ? 16 : 14, weight: .medium, design: .monospaced))  // 交替字体大小
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    text.color,
                                    text.color.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: text.color.opacity(0.8), radius: 15, x: 0, y: 0)
                        .shadow(color: text.color.opacity(0.4), radius: 5, x: 0, y: 0)
                        .opacity(backgroundTextOpacities[index])
                        .scaleEffect(backgroundTextScales[index] * text.scale)
                        .position(
                            x: geometry.size.width * text.position.x,
                            y: geometry.size.height * text.position.y
                        )
                        .rotationEffect(.degrees(Double(text.rotation)))
                        .blur(radius: 0.6)  // 添加轻微模糊效果
                }
                
                // 添加引导文字
                if !planetExpanded {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.85, blue: 0.4),  // 金色
                                        Color(red: 1.0, green: 0.7, blue: 0.2)    // 暖金色
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(guideTextOpacity)
                            .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.5), radius: 10)
                        
                        Text("Touch Venus to carry your smile\nback to where your journey began")
                            .font(.system(size: 18, weight: .light, design: .serif))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.85, blue: 0.4),  // 金色
                                        Color(red: 1.0, green: 0.7, blue: 0.2)    // 暖金色
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(guideTextOpacity)
                            .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.5), radius: 10)
                    }
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85)
                }
                
                // 内容容器
                HStack(spacing: 0) {
                    // 左侧：3D星球场景
                    ZStack {
                        // 星球光晕背景
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.2),
                                        Color(red: 1.0, green: 0.7, blue: 0.2).opacity(0.1),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: geometry.size.width * 0.2
                                )
                            )
                            .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                            .blur(radius: 30)
                            .opacity(isPlanetTapped ? 0 : 1)
                        
                        PlanetSceneView()
                            .frame(width: geometry.size.width * 0.4)
                            .scaleEffect(isPlanetTapped ? 0.9 : planetScale)
                            .opacity(isPlanetTapped ? 0 : 1)
                            .offset(x: planetPosition.width, y: planetPosition.height)
                            .blur(radius: blurRadius)
                            .brightness(brightness)
                            .gesture(
                                TapGesture()
                                    .onEnded { _ in
                                        // 添加向右移动的动画
                                        withAnimation(.easeInOut(duration: 0.8)) {
                                            isPlanetTapped = true
                                            planetScale = 0.9
                                            planetPosition = CGSize(width: geometry.size.width, height: 0)
                                            starAlpha = 0
                                            blurRadius = 10
                                            brightness = 0.3
                                        }
                                        
                                        // 淡出文字
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showCongrats = false
                                            showMainText = false
                                            showSubText = false
                                        }
                                        
                                        // 延迟返回菜单
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            dismiss()
                                        }
                                    }
                            )
                    }
                    .frame(maxWidth: .infinity)
                    
                    // 右侧：文字内容
                    if !planetExpanded {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                                .frame(height: geometry.size.height * 0.2)
                            
                            // 第一行文字
                            Text("In the depths of darkness")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(goldGradient)
                                .opacity(textOpacity1)
                                .padding(.bottom, 40)
                                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.3).opacity(0.5), radius: 10)
                            
                            // 第二行文字
                            Text("a smile becomes starlight")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(purpleGradient)
                                .opacity(textOpacity2)
                                .padding(.bottom, 40)
                                .shadow(color: Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.5), radius: 10)
                            
                            // 第三行文字
                            VStack(alignment: .leading, spacing: 20) {
                                Text("322 million people worldwide")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(blueGradient)
                                Text("live with depression")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(blueGradient)
                                Text("their hearts beating with yours")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.6, green: 0.8, blue: 1.0),  // 浅蓝色
                                                Color(red: 0.4, green: 0.6, blue: 0.9),  // 中蓝色
                                                Color(red: 0.3, green: 0.5, blue: 0.8)   // 深蓝色
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.8), radius: 8)
                                    .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.5), radius: 4)
                                    .scaleEffect(heartbeatScale)
                                    .opacity(heartbeatOpacity)
                            }
                            .opacity(textOpacity3)
                            .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.9).opacity(0.5), radius: 10)
                            
                            Spacer()
                        }
                        .padding(.leading, 80)
                        .frame(width: geometry.size.width * 0.6)
                        .opacity(isPlanetTapped ? 0 : 1)
                    }
                }
                
                // 底部装饰线
                if !planetExpanded {
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
                    .opacity(isPlanetTapped ? 0 : 1)
                }
            }
            .blur(radius: blurRadius * 0.3) // 给整体添加轻微模糊效果
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
            
            // 文字动画序列
            withAnimation(.easeIn(duration: 1.2).delay(1.5)) {
                textOpacity1 = 1
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(3.0)) {
                textOpacity2 = 1
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(4.5)) {
                textOpacity3 = 1
            }
            
            // 背景文字动画
            for index in backgroundTexts.indices {
                // 延迟显示每个文字
                withAnimation(.easeIn(duration: 1.5).delay(Double(index) * 0.3 + 2.0)) {
                    backgroundTextOpacities[index] = 0.7
                }
                
                // 添加呼吸动画
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.5)
                ) {
                    backgroundTextScales[index] = 1.1
                }
            }

            // 添加心跳动画
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                heartbeatScale = 1.05
                heartbeatOpacity = 1.0
            }

            // 添加引导文字动画，在所有主要内容显示后
            withAnimation(.easeIn(duration: 1.2).delay(6.0)) {
                guideTextOpacity = 0.8
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
        if let texture = UIImage(named: "venus") {
            print("✅ 纹理加载成功")
            material.diffuse.contents = texture
            
            // 调整法线贴图设置
            material.normal.intensity = 0.5  // 降低法线强度，使表面更均匀
            material.normal.contents = texture
        } else {
            print("❌ 纹理加载失败")
            material.diffuse.contents = UIColor.red
        }
        
        // 调整材质参数
        material.roughness.contents = 0.6  // 增加粗糙度，使光照更分散
        material.metalness.contents = 0.3  // 降低金属感，减少强反射
        material.emission.contents = UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 0.6)  // 增加整体发光强度
        material.lightingModel = .physicallyBased
        
        planetGeometry.materials = [material]
        planetNode.geometry = planetGeometry
        
        // 添加大气层效果
        let atmosphereNode = SCNNode()
        let atmosphereGeometry = SCNSphere(radius: 1.12)  // 增加大气层厚度
        let atmosphereMaterial = SCNMaterial()
        atmosphereMaterial.diffuse.contents = UIColor.clear
        atmosphereMaterial.emission.contents = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.1)  // 改为金色大气层
        atmosphereMaterial.transparent.contents = UIColor.white.withAlphaComponent(0.15)
        atmosphereMaterial.transparencyMode = .rgbZero
        atmosphereMaterial.lightingModel = .constant
        atmosphereGeometry.materials = [atmosphereMaterial]
        atmosphereNode.geometry = atmosphereGeometry
        planetNode.addChildNode(atmosphereNode)
        
        // 添加第二层大气效果
        let atmosphere2Node = SCNNode()
        let atmosphere2Geometry = SCNSphere(radius: 1.15)
        let atmosphere2Material = SCNMaterial()
        atmosphere2Material.diffuse.contents = UIColor.clear
        atmosphere2Material.emission.contents = UIColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.05)
        atmosphere2Material.transparent.contents = UIColor.white.withAlphaComponent(0.1)
        atmosphere2Material.transparencyMode = .rgbZero
        atmosphere2Material.lightingModel = .constant
        atmosphere2Geometry.materials = [atmosphere2Material]
        atmosphere2Node.geometry = atmosphere2Geometry
        planetNode.addChildNode(atmosphere2Node)
        
        // 设置主光源（太阳光）- 调整为多光源
        let mainLight1 = SCNNode()
        mainLight1.light = SCNLight()
        mainLight1.light?.type = .directional
        mainLight1.light?.color = UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1)
        mainLight1.light?.intensity = 800
        mainLight1.position = SCNVector3(x: 5, y: 5, z: 5)
        
        let mainLight2 = SCNNode()
        mainLight2.light = SCNLight()
        mainLight2.light?.type = .directional
        mainLight2.light?.color = UIColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1)
        mainLight2.light?.intensity = 800
        mainLight2.position = SCNVector3(x: -5, y: -5, z: 5)
        
        // 环境光调整
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1)
        ambientLight.light?.intensity = 800  // 增加环境光强度
        
        // 添加环绕光源
        let surroundLight = SCNNode()
        surroundLight.light = SCNLight()
        surroundLight.light?.type = .omni
        surroundLight.light?.color = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1)
        surroundLight.light?.intensity = 400
        surroundLight.position = SCNVector3(x: 0, y: 0, z: 6)
        
        // 添加节点到场景
        scene.rootNode.addChildNode(planetNode)
        scene.rootNode.addChildNode(mainLight1)
        scene.rootNode.addChildNode(mainLight2)
        scene.rootNode.addChildNode(ambientLight)
        scene.rootNode.addChildNode(surroundLight)
        
        // 添加自转动画
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0.2 * .pi, duration: 25)  // 稍微倾斜自转轴，减慢速度
        let repeatRotation = SCNAction.repeatForever(rotation)
        planetNode.runAction(repeatRotation)
        
        // 设置相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
} 