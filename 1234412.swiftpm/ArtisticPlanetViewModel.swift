import SwiftUI
import SceneKit
import PencilKit
import Foundation

@MainActor
class ArtisticPlanetViewModel: ObservableObject {
    @Published var selectedColor: DrawingColor = .blue
    @Published var planetNode: SCNNode?
    @Published var currentDrawing: PKDrawing = PKDrawing()
    @Published var showPlanetView = false
    
    private var drawings: [Int: PKDrawing] = [:]
    private let scene = SCNScene()
    
    init() {
        setupPlanet()
    }
    
    private func setupPlanet() {
        // Create base sphere
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 100  // Increase detail
        
        // Create base material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0)
        material.roughness.contents = 0.7
        material.metalness.contents = 0.3
        material.emission.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.2)
        material.lightingModel = .physicallyBased
        
        sphere.materials = [material]
        
        // Create node
        let node = SCNNode(geometry: sphere)
        
        // Add ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.light?.intensity = 800
        scene.rootNode.addChildNode(ambientLight)
        
        // Add directional lights
        let directionalLight1 = SCNNode()
        directionalLight1.light = SCNLight()
        directionalLight1.light?.type = .directional
        directionalLight1.light?.color = UIColor(white: 0.8, alpha: 1.0)
        directionalLight1.light?.intensity = 800
        directionalLight1.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(directionalLight1)
        
        let directionalLight2 = SCNNode()
        directionalLight2.light = SCNLight()
        directionalLight2.light?.type = .directional
        directionalLight2.light?.color = UIColor(white: 0.8, alpha: 1.0)
        directionalLight2.light?.intensity = 600
        directionalLight2.position = SCNVector3(x: -5, y: -5, z: -5)
        scene.rootNode.addChildNode(directionalLight2)
        
        // Add rotation animation
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 20)
        let repeatRotation = SCNAction.repeatForever(rotation)
        node.runAction(repeatRotation)
        
        scene.rootNode.addChildNode(node)
        planetNode = node
    }
    
    func clearDrawing() {
        currentDrawing = PKDrawing()
        // 重置星球纹理
        setupPlanet()
    }
    
    func updatePlanetTexture(with drawing: PKDrawing) {
        // 将要实现：更新星球纹理
    }
    
    func getScene() -> SCNScene {
        return scene
    }
    
    // 保存当前步骤的绘画
    func saveDrawing(_ drawing: PKDrawing, forStep step: Int) {
        drawings[step] = drawing
    }
    
    // 获取特定步骤的绘画
    func getDrawing(forStep step: Int) -> PKDrawing? {
        return drawings[step]
    }
    
    // 生成最终的星球
    func generateFinalPlanet() {
        guard let planetNode = planetNode,
              let sphere = planetNode.geometry as? SCNSphere else { return }
        
        // Create a combined texture from all drawings
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let combinedTexture = renderer.image { context in
            // Fill background
            UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw each drawing with specific blend mode and opacity
            for (step, drawing) in drawings {
                let bounds = CGRect(origin: .zero, size: size)
                let image = drawing.image(from: bounds, scale: 1.0)
                
                // Apply different blend modes based on the step
                let blendMode: CGBlendMode
                let alpha: CGFloat
                
                switch step {
                case 1: // Flower
                    blendMode = .overlay
                    alpha = 0.8
                case 2: // Tree
                    blendMode = .plusLighter
                    alpha = 0.7
                case 3: // River
                    blendMode = .softLight
                    alpha = 0.6
                case 4: // Stars
                    blendMode = .plusLighter
                    alpha = 0.9
                default:
                    blendMode = .normal
                    alpha = 0.7
                }
                
                image.draw(in: bounds, blendMode: blendMode, alpha: alpha)
            }
        }
        
        // Create new materials for the planet
        let material = SCNMaterial()
        material.diffuse.contents = combinedTexture
        material.roughness.contents = 0.5
        material.metalness.contents = 0.3
        material.emission.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.2)
        material.normal.intensity = 0.5
        material.lightingModel = .physicallyBased
        
        // Apply materials
        sphere.materials = [material]
        
        // Add atmosphere effect
        let atmosphere = SCNSphere(radius: 1.05)
        atmosphere.segmentCount = 100
        
        let atmosphereMaterial = SCNMaterial()
        atmosphereMaterial.diffuse.contents = UIColor.clear
        atmosphereMaterial.emission.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.1)
        atmosphereMaterial.transparent.contents = UIColor(white: 1.0, alpha: 0.2)
        atmosphereMaterial.transparencyMode = .rgbZero
        atmosphereMaterial.lightingModel = .constant
        
        atmosphere.materials = [atmosphereMaterial]
        
        let atmosphereNode = SCNNode(geometry: atmosphere)
        planetNode.addChildNode(atmosphereNode)
    }
} 