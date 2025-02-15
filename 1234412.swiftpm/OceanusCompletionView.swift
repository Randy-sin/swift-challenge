import SwiftUI
import SceneKit
import SpriteKit

struct OceanusCompletionView: View {
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
    
    @State private var textOpacity1: Double = 0
    @State private var textOpacity2: Double = 0
    @State private var textOpacity3: Double = 0
    @State private var backgroundTextOpacity: Double = 0
    
    private let oceanGradient = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.7, blue: 1.0),  // 浅蓝色
            Color(red: 0.2, green: 0.5, blue: 0.8)   // 深蓝色
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private let purpleGradient = LinearGradient(
        colors: [
            Color(red: 0.5, green: 0.6, blue: 1.0),   // 浅紫色
            Color(red: 0.3, green: 0.4, blue: 0.8)    // 深紫色
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private let calmGradient = LinearGradient(
        colors: [
            Color(red: 0.6, green: 0.8, blue: 1.0),   // 平静的蓝色
            Color(red: 0.4, green: 0.6, blue: 0.8)    // 深蓝色
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    private let backgroundTexts = [
        (text: "Deep Breathing Benefits", color: Color(red: 0.4, green: 0.7, blue: 1.0), scale: 1.15, rotation: -5, position: CGPoint(x: 0.15, y: 0.08)),
        (text: "Reduces Anxiety by 68%", color: Color(red: 0.5, green: 0.6, blue: 1.0), scale: 1.1, rotation: -15, position: CGPoint(x: 0.4, y: 0.15)),
        (text: "Lowers Stress Hormones", color: Color(red: 0.6, green: 0.7, blue: 1.0), scale: 0.9, rotation: 10, position: CGPoint(x: 0.85, y: 0.10)),
        (text: "Improves Sleep Quality", color: Color(red: 0.4, green: 0.6, blue: 0.9), scale: 1.2, rotation: -8, position: CGPoint(x: 0.2, y: 0.85)),
        (text: "Enhances Mental Focus", color: Color(red: 0.5, green: 0.7, blue: 0.9), scale: 0.95, rotation: 12, position: CGPoint(x: 0.9, y: 0.75)),
        (text: "Calms Neural Activity", color: Color(red: 0.3, green: 0.5, blue: 0.8), scale: 1.0, rotation: 15, position: CGPoint(x: 0.8, y: 0.5)),
        (text: "Balances Emotions", color: Color(red: 0.4, green: 0.6, blue: 0.9), scale: 1.05, rotation: -12, position: CGPoint(x: 0.25, y: 0.65)),
        (text: "Mindful Healing", color: Color(red: 0.5, green: 0.7, blue: 1.0), scale: 1.1, rotation: 8, position: CGPoint(x: 0.75, y: 0.9))
    ]
    
    @State private var backgroundTextScales: [CGFloat] = Array(repeating: 1.0, count: 8)
    @State private var backgroundTextOpacities: [Double] = Array(repeating: 0.0, count: 8)
    @State private var heartbeatScale: CGFloat = 1.0
    @State private var heartbeatOpacity: Double = 0.8
    @State private var guideTextOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.2),
                        Color(red: 0.1, green: 0.15, blue: 0.25)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                StarfieldView()
                    .opacity(starAlpha)
                
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
                
                if !planetExpanded {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.7, blue: 1.0),
                                        Color(red: 0.2, green: 0.5, blue: 0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(guideTextOpacity)
                            .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.5), radius: 10)
                        
                        Text("Touch Neptune to return\nto your healing journey")
                            .font(.system(size: 18, weight: .light, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.7, blue: 1.0),
                                        Color(red: 0.2, green: 0.5, blue: 0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(guideTextOpacity)
                            .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.5), radius: 10)
                    }
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.85)
                }
                
                HStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.2),
                                        Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.1),
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
                        
                        NeptuneSceneView()
                            .frame(width: geometry.size.width * 0.4)
                            .scaleEffect(isPlanetTapped ? 0.9 : planetScale)
                            .opacity(isPlanetTapped ? 0 : 1)
                            .offset(x: planetPosition.width, y: planetPosition.height)
                            .blur(radius: blurRadius)
                            .brightness(brightness)
                            .gesture(
                                TapGesture()
                                    .onEnded { _ in
                                        withAnimation(.easeInOut(duration: 0.8)) {
                                            isPlanetTapped = true
                                            planetScale = 0.9
                                            planetPosition = CGSize(width: geometry.size.width, height: 0)
                                            starAlpha = 0
                                            blurRadius = 10
                                            brightness = 0.3
                                        }
                                        
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showCongrats = false
                                            showMainText = false
                                            showSubText = false
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            dismiss()
                                        }
                                    }
                            )
                    }
                    .frame(maxWidth: .infinity)
                    
                    if !planetExpanded {
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()
                                .frame(height: geometry.size.height * 0.2)
                            
                            Text("Every breath you take")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(oceanGradient)
                                .opacity(textOpacity1)
                                .padding(.bottom, 40)
                                .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.5), radius: 10)
                            
                            Text("is a step towards healing")
                                .font(.system(size: 46, weight: .bold))
                                .foregroundStyle(purpleGradient)
                                .opacity(textOpacity2)
                                .padding(.bottom, 40)
                                .shadow(color: Color(red: 0.5, green: 0.6, blue: 1.0).opacity(0.5), radius: 10)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Mindful breathing")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(calmGradient)
                                Text("reduces anxiety and stress")
                                    .font(.system(size: 46, weight: .bold))
                                    .foregroundStyle(calmGradient)
                                Text("bringing peace to your mind")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.6, green: 0.8, blue: 1.0),
                                                Color(red: 0.4, green: 0.6, blue: 0.9),
                                                Color(red: 0.3, green: 0.5, blue: 0.8)
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
            .blur(radius: blurRadius * 0.3)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2)) {
                starAlpha = 0.7
            }
            
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8, blendDuration: 0).delay(1)) {
                planetScale = 1.0
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

            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                heartbeatScale = 1.05
                heartbeatOpacity = 1.0
            }

            withAnimation(.easeIn(duration: 1.2).delay(6.0)) {
                guideTextOpacity = 0.8
            }
        }
    }
}

struct NeptuneSceneView: UIViewRepresentable {
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
        
        let planetNode = SCNNode()
        let planetGeometry = SCNSphere(radius: 1.0)
        planetGeometry.segmentCount = 100
        
        let material = SCNMaterial()
        
        if let texture = UIImage(named: "neptune") {
            material.diffuse.contents = texture
            material.normal.intensity = 0.5
            material.normal.contents = texture
        } else {
            material.diffuse.contents = UIColor.blue
        }
        
        material.roughness.contents = 0.6
        material.metalness.contents = 0.3
        material.emission.contents = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.6)
        material.lightingModel = .physicallyBased
        
        planetGeometry.materials = [material]
        planetNode.geometry = planetGeometry
        
        let atmosphereNode = SCNNode()
        let atmosphereGeometry = SCNSphere(radius: 1.12)
        let atmosphereMaterial = SCNMaterial()
        atmosphereMaterial.diffuse.contents = UIColor.clear
        atmosphereMaterial.emission.contents = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.1)
        atmosphereMaterial.transparent.contents = UIColor.white.withAlphaComponent(0.15)
        atmosphereMaterial.transparencyMode = .rgbZero
        atmosphereMaterial.lightingModel = .constant
        atmosphereGeometry.materials = [atmosphereMaterial]
        atmosphereNode.geometry = atmosphereGeometry
        planetNode.addChildNode(atmosphereNode)
        
        let atmosphere2Node = SCNNode()
        let atmosphere2Geometry = SCNSphere(radius: 1.15)
        let atmosphere2Material = SCNMaterial()
        atmosphere2Material.diffuse.contents = UIColor.clear
        atmosphere2Material.emission.contents = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.05)
        atmosphere2Material.transparent.contents = UIColor.white.withAlphaComponent(0.1)
        atmosphere2Material.transparencyMode = .rgbZero
        atmosphere2Material.lightingModel = .constant
        atmosphere2Geometry.materials = [atmosphere2Material]
        atmosphere2Node.geometry = atmosphere2Geometry
        planetNode.addChildNode(atmosphere2Node)
        
        let mainLight1 = SCNNode()
        mainLight1.light = SCNLight()
        mainLight1.light?.type = .directional
        mainLight1.light?.color = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1)
        mainLight1.light?.intensity = 800
        mainLight1.position = SCNVector3(x: 5, y: 5, z: 5)
        
        let mainLight2 = SCNNode()
        mainLight2.light = SCNLight()
        mainLight2.light?.type = .directional
        mainLight2.light?.color = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1)
        mainLight2.light?.intensity = 800
        mainLight2.position = SCNVector3(x: -5, y: -5, z: 5)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1)
        ambientLight.light?.intensity = 800
        
        let surroundLight = SCNNode()
        surroundLight.light = SCNLight()
        surroundLight.light?.type = .omni
        surroundLight.light?.color = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1)
        surroundLight.light?.intensity = 400
        surroundLight.position = SCNVector3(x: 0, y: 0, z: 6)
        
        scene.rootNode.addChildNode(planetNode)
        scene.rootNode.addChildNode(mainLight1)
        scene.rootNode.addChildNode(mainLight2)
        scene.rootNode.addChildNode(ambientLight)
        scene.rootNode.addChildNode(surroundLight)
        
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0.2 * .pi, duration: 25)
        let repeatRotation = SCNAction.repeatForever(rotation)
        planetNode.runAction(repeatRotation)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 4)
        scene.rootNode.addChildNode(cameraNode)
        
        return scene
    }
} 