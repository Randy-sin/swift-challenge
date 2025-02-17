import SwiftUI
import SceneKit
import SpriteKit

struct AndromedaSceneView: UIViewRepresentable {
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
        
        // 创建仙女座星系节点
        let galaxyNode = SCNNode()
        let galaxyGeometry = SCNSphere(radius: 1.0)
        galaxyGeometry.segmentCount = 200  // 高精度球体
        
        // 创建基础材质
        let material = SCNMaterial()
        
        // 使用 Andromedaplanet 纹理
        if let texture = UIImage(named: "Andromedaplanet") {
            print("✅ 仙女座纹理加载成功")
            material.diffuse.contents = texture
            material.normal.intensity = 0.8
            material.normal.contents = texture
            material.specular.contents = UIColor.white
            material.specular.intensity = 0.6
            material.metalness.contents = 0.3
            material.roughness.contents = 0.4
            material.emission.contents = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.3)  // 紫色发光
        } else {
            print("❌ 仙女座纹理加载失败")
            material.diffuse.contents = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
        }
        
        material.lightingModel = .physicallyBased
        galaxyGeometry.materials = [material]
        galaxyNode.geometry = galaxyGeometry
        
        // 星系光晕效果
        let haloNode = SCNNode()
        let haloGeometry = SCNSphere(radius: 1.15)
        let haloMaterial = SCNMaterial()
        haloMaterial.diffuse.contents = UIColor.clear
        haloMaterial.emission.contents = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.2)  // 紫色光晕
        haloMaterial.transparent.contents = UIColor(white: 1.0, alpha: 0.3)
        haloMaterial.transparencyMode = .rgbZero
        haloMaterial.lightingModel = .constant
        haloMaterial.writesToDepthBuffer = false
        haloMaterial.readsFromDepthBuffer = false
        haloGeometry.materials = [haloMaterial]
        haloNode.geometry = haloGeometry
        
        // 添加光晕动画
        let haloPulse = SCNAction.sequence([
            SCNAction.scale(to: 1.05, duration: 2.0),
            SCNAction.scale(to: 0.95, duration: 2.0)
        ])
        haloNode.runAction(SCNAction.repeatForever(haloPulse))
        galaxyNode.addChildNode(haloNode)
        
        // 外层星云效果
        let nebulaNode = SCNNode()
        let nebulaGeometry = SCNSphere(radius: 1.25)
        let nebulaMaterial = SCNMaterial()
        nebulaMaterial.diffuse.contents = UIColor.clear
        nebulaMaterial.emission.contents = UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 0.1)  // 淡紫色星云
        nebulaMaterial.transparent.contents = UIColor(white: 1.0, alpha: 0.2)
        nebulaMaterial.transparencyMode = .rgbZero
        nebulaMaterial.lightingModel = .constant
        nebulaGeometry.materials = [nebulaMaterial]
        nebulaNode.geometry = nebulaGeometry
        galaxyNode.addChildNode(nebulaNode)
        
        // 优化光照系统
        let mainLight1 = SCNNode()
        mainLight1.light = SCNLight()
        mainLight1.light?.type = .directional
        mainLight1.light?.color = UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1)  // 紫色主光源
        mainLight1.light?.intensity = 1000
        mainLight1.position = SCNVector3(x: 5, y: 5, z: 5)
        
        let mainLight2 = SCNNode()
        mainLight2.light = SCNLight()
        mainLight2.light?.type = .directional
        mainLight2.light?.color = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1)  // 深紫色辅助光源
        mainLight2.light?.intensity = 800
        mainLight2.position = SCNVector3(x: -5, y: -5, z: 5)
        
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.4, green: 0.3, blue: 0.6, alpha: 1)  // 柔和紫色环境光
        ambientLight.light?.intensity = 500
        
        // 边缘光效果
        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light?.type = .directional
        rimLight.light?.color = UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1)  // 亮紫色边缘光
        rimLight.light?.intensity = 600
        rimLight.position = SCNVector3(x: 0, y: 0, z: -8)
        
        scene.rootNode.addChildNode(galaxyNode)
        scene.rootNode.addChildNode(mainLight1)
        scene.rootNode.addChildNode(mainLight2)
        scene.rootNode.addChildNode(ambientLight)
        scene.rootNode.addChildNode(rimLight)
        
        // 星系旋转动画
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0.1 * .pi, duration: 20)  // 缓慢旋转
        let repeatRotation = SCNAction.repeatForever(rotation)
        galaxyNode.runAction(repeatRotation)
        
        // 添加轻微摇摆动画
        let wobble = SCNAction.sequence([
            SCNAction.rotateBy(x: 0.03, y: 0, z: 0.03, duration: 2),
            SCNAction.rotateBy(x: -0.03, y: 0, z: -0.03, duration: 2)
        ])
        galaxyNode.runAction(SCNAction.repeatForever(wobble))
        
        // 设置相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
}

struct AndromedaCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var starAlpha: Double = 0
    @State private var textOpacity1: Double = 0
    @State private var textOpacity2: Double = 0
    @State private var textOpacity3: Double = 0
    @State private var backgroundTextOpacity: Double = 0
    @State private var backgroundTextScales: [CGFloat] = Array(repeating: 1.0, count: 8)
    @State private var backgroundTextOpacities: [Double] = Array(repeating: 0.0, count: 8)
    @State private var planetScale: CGFloat = 0.8
    @State private var isPlanetTapped = false
    @State private var planetPosition: CGSize = .zero
    @State private var blurRadius: CGFloat = 0
    @State private var brightness: Double = 0
    @State private var planetExpanded = false
    @State private var guideTextOpacity: Double = 0
    @State private var arrowOffset: CGFloat = 0
    
    private let backgroundTexts = [
        (text: "Inner Journey", color: Color(red: 0.6, green: 0.4, blue: 0.9), scale: 1.15, rotation: -5, position: CGPoint(x: 0.15, y: 0.08)),
        (text: "Emotional Growth", color: Color(red: 0.8, green: 0.5, blue: 0.9), scale: 1.1, rotation: -15, position: CGPoint(x: 0.4, y: 0.15)),
        (text: "Self Discovery", color: Color(red: 0.9, green: 0.7, blue: 0.5), scale: 0.9, rotation: 10, position: CGPoint(x: 0.85, y: 0.10)),
        (text: "Mind Exploration", color: Color(red: 0.5, green: 0.8, blue: 0.7), scale: 1.2, rotation: -8, position: CGPoint(x: 0.2, y: 0.85)),
        (text: "Healing Dialogue", color: Color(red: 0.7, green: 0.5, blue: 0.8), scale: 0.95, rotation: 12, position: CGPoint(x: 0.9, y: 0.75)),
        (text: "Soul Connection", color: Color(red: 0.8, green: 0.6, blue: 0.4), scale: 1.0, rotation: 15, position: CGPoint(x: 0.8, y: 0.5)),
        (text: "Cosmic Wisdom", color: Color(red: 0.6, green: 0.7, blue: 0.8), scale: 1.05, rotation: -12, position: CGPoint(x: 0.25, y: 0.65)),
        (text: "Starlit Guidance", color: Color(red: 0.7, green: 0.4, blue: 0.9), scale: 1.1, rotation: 8, position: CGPoint(x: 0.75, y: 0.9))
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景
                Color.black.edgesIgnoringSafeArea(.all)
                
                // 星空效果
                PsycheParticleView()
                    .opacity(0.6)
                
                // 添加背景说明文字
                ForEach(backgroundTexts.indices, id: \.self) { index in
                    let text = backgroundTexts[index]
                    Text(text.text)
                        .font(.system(size: index % 2 == 0 ? 16 : 14, weight: .medium, design: .rounded))
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
                        .blur(radius: 0.6)
                }
                
                HStack(spacing: 0) {
                    if !planetExpanded {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                                .frame(height: geometry.size.height * 0.2)
                            
                            Text("In the depths of stars")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.6, green: 0.4, blue: 0.9),
                                            Color(red: 0.4, green: 0.2, blue: 0.7)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(textOpacity1)
                                .padding(.bottom, 40)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5), radius: 10)
                            
                            Text("your heart finds its voice")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.8, green: 0.5, blue: 0.9),
                                            Color(red: 0.6, green: 0.3, blue: 0.7)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(textOpacity2)
                                .padding(.bottom, 40)
                                .shadow(color: Color(red: 0.7, green: 0.4, blue: 0.9).opacity(0.5), radius: 10)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Through cosmic whispers")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.9, green: 0.7, blue: 0.5),
                                                Color(red: 0.7, green: 0.5, blue: 0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("we discover ourselves")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.9, green: 0.7, blue: 0.5),
                                                Color(red: 0.7, green: 0.5, blue: 0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("in the light of understanding")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.9, green: 0.7, blue: 0.5),
                                                Color(red: 0.8, green: 0.6, blue: 0.4),
                                                Color(red: 0.7, green: 0.5, blue: 0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .opacity(textOpacity3)
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5), radius: 10)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 80)
                        .frame(width: geometry.size.width * 0.6)
                        .opacity(isPlanetTapped ? 0 : 1)
                    }
                    
                    ZStack {
                        // 星系光晕背景
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.2),
                                        Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.1),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: planetExpanded ? geometry.size.width * 0.4 : geometry.size.width * 0.2
                                )
                            )
                            .frame(width: planetExpanded ? geometry.size.width * 0.8 : geometry.size.width * 0.4,
                                   height: planetExpanded ? geometry.size.width * 0.8 : geometry.size.width * 0.4)
                            .blur(radius: 30)
                            .opacity(isPlanetTapped ? 0 : 1)
                        
                        VStack(spacing: 30) {
                            AndromedaSceneView()
                                .frame(width: planetExpanded ? geometry.size.width * 0.8 : geometry.size.width * 0.4)
                                .scaleEffect(isPlanetTapped ? 0.9 : planetScale)
                                .opacity(isPlanetTapped ? 0 : 1)
                                .offset(x: planetPosition.width, y: planetPosition.height)
                                .blur(radius: blurRadius)
                                .brightness(brightness)
                            
                            if !isPlanetTapped {
                                VStack(spacing: 16) {
                                    if !planetExpanded {
                                        // 初始状态的提示文字
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.6, green: 0.4, blue: 0.9),
                                                        Color(red: 0.4, green: 0.2, blue: 0.7)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .offset(y: arrowOffset)
                                        
                                        Text("Touch to witness")
                                            .font(.system(size: 20, weight: .medium, design: .serif))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.6, green: 0.4, blue: 0.9),
                                                        Color(red: 0.4, green: 0.2, blue: 0.7)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        Text("Andromeda's cosmic ballet")
                                            .font(.system(size: 16, weight: .regular, design: .serif))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.8, green: 0.6, blue: 1.0),
                                                        Color(red: 0.6, green: 0.4, blue: 0.8)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    }
                                }
                                .opacity(planetExpanded ? 0 : guideTextOpacity)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5), radius: 10)
                            }
                        }
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    if planetExpanded {
                                        withAnimation(.easeInOut(duration: 0.8)) {
                                            isPlanetTapped = true
                                            planetScale = 0.9
                                            planetPosition = CGSize(width: -geometry.size.width, height: 0)
                                            starAlpha = 0
                                            blurRadius = 10
                                            brightness = 0.3
                                        }
                                        
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            textOpacity1 = 0
                                            textOpacity2 = 0
                                            textOpacity3 = 0
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            dismiss()
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.8)) {
                                            planetExpanded = true
                                        }
                                    }
                                }
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Group {
                            if planetExpanded && !isPlanetTapped {
                                // 放大状态的提示文字
                                VStack(spacing: 16) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.6, green: 0.4, blue: 0.9),
                                                    Color(red: 0.4, green: 0.2, blue: 0.7)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .rotationEffect(.degrees(180))
                                        .offset(y: arrowOffset)
                                    
                                    Text("Touch to return")
                                        .font(.system(size: 20, weight: .medium, design: .serif))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.6, green: 0.4, blue: 0.9),
                                                    Color(red: 0.4, green: 0.2, blue: 0.7)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    Text("through the starlit gateway")
                                        .font(.system(size: 16, weight: .regular, design: .serif))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.8, green: 0.6, blue: 1.0),
                                                    Color(red: 0.6, green: 0.4, blue: 0.8)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                }
                                .opacity(guideTextOpacity)
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5), radius: 10)
                                .padding(.bottom, 40)
                                .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.5), value: planetExpanded)
                    )
                }
                
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
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2)) {
                starAlpha = 0.7
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(1.5)) {
                textOpacity1 = 1
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(3.0)) {
                textOpacity2 = 1
            }
            
            withAnimation(.easeIn(duration: 1.2).delay(4.5)) {
                textOpacity3 = 1
            }
            
            for index in backgroundTexts.indices {
                withAnimation(.easeIn(duration: 1.5).delay(Double(index) * 0.3 + 2.0)) {
                    backgroundTextOpacities[index] = 0.7
                }
                
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.5)
                ) {
                    backgroundTextScales[index] = 1.1
                }
            }
            
            // 添加箭头动画
            withAnimation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true)
            ) {
                arrowOffset = -10
            }
            
            // 延迟显示提示文字，等待所有主要文字显示完成
            withAnimation(.easeIn(duration: 1.2).delay(6.0)) {
                guideTextOpacity = 1
            }
        }
    }
} 