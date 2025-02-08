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
    @Published var drawings: [Int: PKDrawing] = [:]
    @Published var processedTextures: [Int: UIImage] = [:]
    @Published var currentStep: Int = 1
    @Published var showFullScreenPreview = false
    
    private let scene = SCNScene()
    private let baseTextureSize = CGSize(width: 1024, height: 512) // 适合球面映射的纹理尺寸
    
    init() {
        setupPlanet()
    }
    
    private func setupPlanet() {
        // 创建基础球体
        let sphere = SCNSphere(radius: 1.0)
        sphere.segmentCount = 100
        
        // 创建基础材质
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0)
        material.roughness.contents = 0.7
        material.metalness.contents = 0.3
        material.emission.contents = UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.2)
        material.lightingModel = .physicallyBased
        
        sphere.materials = [material]
        
        // 创建节点
        let node = SCNNode(geometry: sphere)
        
        // 添加环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.light?.intensity = 800
        scene.rootNode.addChildNode(ambientLight)
        
        // 添加定向光
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
        
        // 添加旋转动画
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 20)
        let repeatRotation = SCNAction.repeatForever(rotation)
        node.runAction(repeatRotation)
        
        scene.rootNode.addChildNode(node)
        planetNode = node
    }
    
    // 保存当前步骤的绘画并处理
    func saveDrawing(_ drawing: PKDrawing, forStep step: Int) {
        drawings[step] = drawing
        Task {
            if let processedImage = await processDrawing(drawing, step: step) {
                await MainActor.run {
                    processedTextures[step] = processedImage
                    updatePlanetTexture()
                }
            }
        }
    }
    
    // 获取特定步骤的绘画
    func getDrawing(forStep step: Int) -> PKDrawing? {
        return drawings[step]
    }
    
    // 处理单步绘画
    private func processDrawing(_ drawing: PKDrawing, step: Int) async -> UIImage? {
        // 创建绘画图像
        let renderer = UIGraphicsImageRenderer(size: baseTextureSize)
        let drawingImage = drawing.image(from: drawing.bounds, scale: 1.0)
        
        return renderer.image { context in
            // 设置基础背景为透明
            context.cgContext.clear(CGRect(origin: .zero, size: baseTextureSize))
            
            // 获取每个步骤对应的颜色和特性
            let (stepColor, variations) = getStepColorAndVariations(step: step)
            
            // 根据不同步骤使用不同的渲染参数
            let (scales, rotations, alphas) = getStepParameters(step: step)
            
            // 在不同位置重复绘制元素
            for scale in scales {
                for rotation in rotations {
                    for alpha in alphas {
                        let scaledWidth = drawingImage.size.width * scale
                        let scaledHeight = drawingImage.size.height * scale
                        
                        // 随机位置，但确保覆盖整个纹理
                        let x = CGFloat.random(in: 0...(baseTextureSize.width - scaledWidth))
                        let y = CGFloat.random(in: 0...(baseTextureSize.height - scaledHeight))
                        
                        // 保存当前绘图状态
                        context.cgContext.saveGState()
                        
                        // 设置混合模式和透明度
                        context.cgContext.setBlendMode(variations.blendMode)
                        context.cgContext.setAlpha(alpha * variations.baseAlpha)
                        
                        // 设置变换
                        context.cgContext.translateBy(x: x + scaledWidth/2, y: y + scaledHeight/2)
                        context.cgContext.rotate(by: rotation * .pi / 180)
                        context.cgContext.translateBy(x: -scaledWidth/2, y: -scaledHeight/2)
                        
                        // 绘制图像
                        stepColor.setFill()
                        drawingImage.draw(in: CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight))
                        
                        // 恢复绘图状态
                        context.cgContext.restoreGState()
                    }
                }
            }
            
            // 添加特殊效果
            if variations.addGlow {
                // 添加发光效果
                context.cgContext.setShadow(offset: .zero, blur: 10, color: stepColor.cgColor)
                context.cgContext.setBlendMode(.plusLighter)
                drawingImage.draw(in: CGRect(origin: .zero, size: baseTextureSize))
            }
        }
    }
    
    // 新增：根据步骤获取渲染参数
    private func getStepParameters(step: Int) -> (scales: [CGFloat], rotations: [CGFloat], alphas: [CGFloat]) {
        switch step {
        case 1: // 花朵
            return (
                scales: [0.8, 0.6, 0.4],
                rotations: [0, 45, 90, 135, 180, 225, 270, 315],
                alphas: [1.0, 0.8, 0.6]
            )
        case 2: // 树木
            return (
                scales: [0.8, 0.7, 0.6],
                rotations: [0, 90, 180, 270],
                alphas: [1.0, 0.8, 0.6]
            )
        case 3: // 河流
            return (
                scales: [0.8, 0.6],
                rotations: [0, 45, 90, 135],
                alphas: [1.0, 0.7]
            )
        case 4: // 星星 - 减少重复次数，增加大小差异
            return (
                scales: [0.3, 0.2],  // 减小星星尺寸
                rotations: [0, 45],   // 减少旋转变化
                alphas: [1.0, 0.8]    // 保持较高亮度
            )
        default:
            return (
                scales: [0.8, 0.6, 0.4],
                rotations: [0, 90, 180, 270],
                alphas: [1.0, 0.8, 0.6]
            )
        }
    }
    
    // 新增：获取每个步骤的颜色和变化特性
    private struct StepVariations {
        let blendMode: CGBlendMode
        let baseAlpha: CGFloat
        let addGlow: Bool
    }
    
    private func getStepColorAndVariations(step: Int) -> (UIColor, StepVariations) {
        switch step {
        case 1: // 花朵
            return (
                UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0),
                StepVariations(blendMode: .normal, baseAlpha: 0.9, addGlow: true)
            )
        case 2: // 树木
            return (
                UIColor(red: 0.3, green: 0.85, blue: 0.3, alpha: 1.0),
                StepVariations(blendMode: .normal, baseAlpha: 0.8, addGlow: false)
            )
        case 3: // 河流
            return (
                UIColor(red: 0.3, green: 0.6, blue: 0.95, alpha: 1.0),
                StepVariations(blendMode: .plusLighter, baseAlpha: 0.7, addGlow: true)
            )
        case 4: // 星星
            return (
                UIColor(red: 0.95, green: 0.85, blue: 0.3, alpha: 1.0),
                StepVariations(blendMode: .plusLighter, baseAlpha: 1.0, addGlow: true)
            )
        default:
            return (
                UIColor.white,
                StepVariations(blendMode: .normal, baseAlpha: 0.8, addGlow: false)
            )
        }
    }
    
    // 检查图像是否包含实际内容
    private func hasContent(in image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        let totalBytes = bytesPerRow * height
        
        guard let context = CGContext(data: nil,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let data = context.data else {
            return false
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: totalBytes)
        var nonEmptyPixels = 0
        
        for i in stride(from: 0, to: totalBytes, by: 4) {
            let alpha = buffer[i + 3]
            if alpha > 0 {
                nonEmptyPixels += 1
            }
        }
        
        // 如果有超过1%的像素不为空，则认为有内容
        return Double(nonEmptyPixels) / Double(width * height) > 0.01
    }
    
    // 更新星球纹理
    func updatePlanetTexture() {
        guard let material = planetNode?.geometry?.materials.first else { return }
        
        // 合并所有纹理
        let renderer = UIGraphicsImageRenderer(size: baseTextureSize)
        let combinedTexture = renderer.image { context in
            // 绘制基础纹理 - 使用渐变的蓝色
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 1.0).cgColor,
                    UIColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 1.0).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: baseTextureSize.width, y: baseTextureSize.height),
                options: []
            )
            
            // 按顺序叠加每个步骤的纹理
            for step in 1...4 {
                if let texture = processedTextures[step] {
                    texture.draw(in: CGRect(origin: .zero, size: baseTextureSize),
                               blendMode: .normal,
                               alpha: 0.8)  // 降低不透明度以便能看到底层的蓝色
                }
            }
        }
        
        // 更新材质
        material.diffuse.contents = combinedTexture
        material.emission.contents = combinedTexture
        material.emission.intensity = 0.5  // 添加发光效果
    }
    
    // 更新当前绘画到星球
    func updateCurrentDrawing(_ drawing: PKDrawing) {
        Task {
            if let processedImage = await processDrawing(drawing, step: currentStep) {
                await MainActor.run {
                    processedTextures[currentStep] = processedImage
                    updatePlanetTexture()
                }
            }
        }
    }
    
    // 生成最终的星球
    func generateFinalPlanet() {
        updatePlanetTexture()
        showPlanetView = true
    }
    
    func getScene() -> SCNScene {
        return scene
    }
    
    func getInkColor() -> UIColor {
        switch selectedColor {
        case .red:
            return UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0)
        case .orange:
            return UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .yellow:
            return UIColor(red: 0.95, green: 0.85, blue: 0.3, alpha: 1.0)
        case .green:
            return UIColor(red: 0.3, green: 0.85, blue: 0.3, alpha: 1.0)
        case .blue:
            return UIColor(red: 0.3, green: 0.6, blue: 0.95, alpha: 1.0)
        case .purple:
            return UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 1.0)
        case .white:
            return UIColor.white
        case .black:
            return UIColor.black
        }
    }
} 