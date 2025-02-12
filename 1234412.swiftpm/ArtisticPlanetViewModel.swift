import SwiftUI
import SceneKit
import PencilKit
import Foundation
import Vision
import CoreML

@MainActor
final class ArtisticPlanetViewModel: ObservableObject {
    @Published var selectedColor: DrawingColor = .blue
    @Published var planetNode: SCNNode?
    @Published var currentDrawing: PKDrawing = PKDrawing()
    @Published var showPlanetView = false
    @Published var drawings: [Int: PKDrawing] = [:]
    @Published var processedTextures: [Int: UIImage] = [:]
    @Published var currentStep: Int = 1
    @Published var showFullScreenPreview = false
    @Published var drawingValidationMessage: String = ""
    @Published var isDrawingValid: Bool = false
    @Published var showValidationDialog: Bool = false
    @Published var showDrawingFeedback: Bool = false
    @Published var debugImage: UIImage? = nil  // 添加调试图像属性
    
    // Example images for each step
    private let exampleImages = [
        1: "flower_example",
        2: "tree_example",
        3: "river_example",
        4: "star_example"
    ]
    
    // Required objects for each step
    private let requiredObjects = [
        1: "Flower",
        2: "Tree",
        3: "River",
        4: "Star"
    ]
    
    // 简化分类结果结构体
    private struct ClassificationResult: Sendable {
        let identifier: String
        let confidence: Float
        let error: Error?
    }
    
    // 简化绘画类型枚举
    private enum DrawingType: String {
        case flower = "Flower"
        case tree = "Tree"
        case river = "River"
        case star = "Star"
        
        var confidenceThreshold: Float {
            switch self {
            case .flower: return 0.5
            case .tree: return 0.5
            case .river: return 0.5
            case .star: return 0.5
            }
        }
        
        static func forStep(_ step: Int) -> DrawingType? {
            switch step {
            case 1: return .flower
            case 2: return .tree
            case 3: return .river
            case 4: return .star
            default: return nil
            }
        }
    }
    
    // 修改分类请求存储为单个请求
    private var classificationRequest: VNCoreMLRequest?
    
    // 静态初始化器，确保在类加载时就设置环境变量
    static let setup: Void = {
        // 设置 CoreML 代码生成语言
        setenv("COREML_CODEGEN_LANGUAGE", "Swift", 1)
        print("✅ Set CoreML code generation language to Swift")
    }()
    
    private let imageClassifier: VNCoreMLModel?
    private let scene = SCNScene()
    private let baseTextureSize = CGSize(width: 1024, height: 512)
    
    // 添加步骤验证状态追踪
    private var stepValidationState: [Int: Bool] = [:]
    
    init() {
        // 初始化存储属性
        self.imageClassifier = nil
        
        // 触发静态初始化
        _ = ArtisticPlanetViewModel.setup
        
        print("🔄 Initializing ArtisticPlanetViewModel")
        
        // 在后台线程初始化模型
        Task.detached(priority: .userInitiated) { [weak self] in
            await self?.initializeModel()
        }
        
        // 在所有存储属性初始化后调用
        setupPlanet()
    }
    
    private func initializeModel() async {
        do {
            let config = MLModelConfiguration()
            // 在模拟器上使用 CPU，在真机上使用全部计算单元
            #if targetEnvironment(simulator)
            config.computeUnits = .cpuOnly
            print("🖥 Running in simulator - using CPU only")
            #else
            config.computeUnits = .all
            print("📱 Running on device - using all compute units")
            #endif
            
            guard let modelURL = Bundle.main.url(forResource: "ML/SketchClassifier 1", withExtension: "mlmodel") else {
                print("❌ Failed to find SketchClassifier model")
                return
            }
            
            let compiledModelURL = try await MLModel.compileModel(at: modelURL)
            let model = try MLModel(contentsOf: compiledModelURL, configuration: config)
            let vnModel = try VNCoreMLModel(for: model)
            
            let request = VNCoreMLRequest(model: vnModel)
            request.imageCropAndScaleOption = .scaleFit
            if #available(iOS 17.0, *) {
                request.preferBackgroundProcessing = false
            }
            
            await MainActor.run {
                self.classificationRequest = request
                print("✅ Model initialized successfully")
            }
        } catch {
            print("❌ Error initializing model: \(error.localizedDescription)")
        }
    }
    
    // 更新保存绘画的方法
    func saveDrawing(_ drawing: PKDrawing, forStep step: Int) {
        drawings[step] = drawing
        stepValidationState[step] = true  // 标记该步骤已验证通过
        
        Task {
            if let processedImage = await processDrawing(drawing, step: step) {
                await MainActor.run {
                    processedTextures[step] = processedImage
                    updatePlanetTexture()
                }
            }
        }
    }
    
    // 获取特定步骤的验证状态
    func isStepValidated(_ step: Int) -> Bool {
        return stepValidationState[step] ?? false
    }
    
    // 重置特定步骤的验证状态
    func resetStepValidation(_ step: Int) {
        stepValidationState[step] = false
    }
    
    // 验证当前绘画
    func validateCurrentDrawing(forStep step: Int) {
        print("🎨 Starting drawing validation for step \(step)...")
        print("📝 Current step: \(step)")
        print("✏️ Current drawing strokes: \(currentDrawing.strokes.count)")
        print("📐 Current drawing bounds: \(currentDrawing.bounds)")
        
        // 重置当前步骤的验证状态
        resetStepValidation(step)
        
        // 获取当前步骤需要的对象
        guard let expectedClass = requiredObjects[step] else {
            handleValidationError("Invalid step number: \(step)")
            return
        }
        
        print("🎯 Expected object for step \(step): \(expectedClass)")
        
        // Check if there's actual drawing content
        if currentDrawing.strokes.isEmpty {
            print("⚠️ No strokes in current drawing")
            let message = "Drawing test successful! Please click **[Validate]** again to continue."
            self.drawingValidationMessage = message
            self.isDrawingValid = false
            self.showValidationDialog = true
            return
        }
        
        guard let drawingImage = renderDrawingToImage() else {
            print("❌ Failed to render drawing")
            return
        }
        
        guard let cgImage = drawingImage.cgImage else {
            print("❌ Failed to get CGImage from drawing")
            return
        }
        
        print("📏 Image size: \(cgImage.width)x\(cgImage.height)")
        
        guard let request = classificationRequest else {
            print("❌ Model not initialized")
            return
        }

        // 创建请求处理器时不使用额外的选项
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: .up
        )

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            do {
                try handler.perform([request])
                
                if let results = request.results as? [VNClassificationObservation] {
                    print("🔍 All classification results for step \(step):")
                    for result in results {
                        print("- \(result.identifier): \(result.confidence)")
                    }
                    
                    if let topResult = results.first {
                        let confidence = topResult.confidence
                        let identifier = topResult.identifier
                        
                        print("✨ Top classification result: \(identifier) with confidence: \(confidence)")
                        print("🎯 Expected class: \(expectedClass)")
                        
                        let isValid = identifier == expectedClass && confidence >= 0.5
                        
                        if isValid {
                            let successMessage: String
                            switch step {
                            case 1:
                                successMessage = "Amazing! Your flower is beautiful, filled with colors of hope!"
                            case 2:
                                successMessage = "Wonderful! Your tree is full of life, reaching towards the sky!"
                            case 3:
                                successMessage = "Perfect! Your river flows smoothly, carrying emotions along!"
                            case 4:
                                successMessage = "Beautiful! Your stars shine with the light of dreams!"
                            default:
                                successMessage = "Great job! That looks wonderful!"
                            }
                            self.drawingValidationMessage = successMessage
                            self.isDrawingValid = isValid
                            self.showValidationDialog = true
                        } else {
                            let failureMessage: String
                            switch step {
                            case 1:
                                failureMessage = "I see your creativity, but maybe we could add more elements that represent blooming and growth. Would you like to check out the tip?"
                            case 2:
                                failureMessage = "I see your artistic spirit, but maybe we could make it look more tree-like with branches reaching up. Would you like to check out the tip?"
                            case 3:
                                failureMessage = "I see your flowing lines, but maybe we could make it more river-like with gentle curves. Would you like to check out the tip?"
                            case 4:
                                failureMessage = "These don't quite look like stars. Try adding some bright points in the sky!"
                            default:
                                failureMessage = "Try again, you can do it!"
                            }
                            self.drawingValidationMessage = failureMessage
                            self.isDrawingValid = isValid
                            self.showValidationDialog = true
                        }
                    }
                }
            } catch {
                print("❌ Classification error: \(error.localizedDescription)")
                #if targetEnvironment(simulator)
                self.drawingValidationMessage = "CoreML context cannot be created in simulator.\nPlease tap 'Skip' to continue or run on a real device."
                #else
                self.drawingValidationMessage = "Sorry, an error occurred during validation. Please try again."
                #endif
                self.isDrawingValid = false
                self.showValidationDialog = true
            }
        }
    }
    
    // 获取当前窗口的辅助方法
    private func getCurrentWindow() -> UIWindow? {
        // 获取当前活跃的场景
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window
    }
    
    // Render PKDrawing to UIImage
    private func renderDrawingToImage() -> UIImage? {
        // 获取当前窗口
        guard let window = getCurrentWindow() else {
            print("⚠️ No window found")
            return nil
        }
        
        // 创建一个与屏幕大小相同的上下文
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds, format: format)
        let screenshot = renderer.image { context in
            // 渲染整个窗口
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        // 调整为模型所需的尺寸 (224x224)
        let targetSize = CGSize(width: 224, height: 224)
        let format2 = UIGraphicsImageRendererFormat()
        format2.scale = 1.0
        format2.opaque = true
        
        let finalImage = UIGraphicsImageRenderer(size: targetSize, format: format2).image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: targetSize))
            
            // 使用高质量的缩放
            context.cgContext.interpolationQuality = .high
            screenshot.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        // 保存调试图像
        if let data = finalImage.pngData() {
            do {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let debugImagePath = documentsPath.appendingPathComponent("debug_drawing_\(Date().timeIntervalSince1970).png")
                try data.write(to: debugImagePath)
                print("🔍 Debug image saved to: \(debugImagePath.path)")
                print("📏 Final image size: \(finalImage.size.width)x\(finalImage.size.height)")
            } catch {
                print("❌ Failed to save debug image: \(error.localizedDescription)")
            }
        }
        
        return finalImage
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
    
    // 获取特定步骤的绘画
    func getDrawing(forStep step: Int) -> PKDrawing? {
        // 只返回已验证通过的步骤的绘画
        guard isStepValidated(step) else {
            print("⚠️ Attempting to get drawing for unvalidated step: \(step)")
            return nil
        }
        return drawings[step]
    }
    
    // 处理单步绘画
    private func processDrawing(_ drawing: PKDrawing, step: Int) async -> UIImage? {
        // 创建一个与基础纹理大小相同的上下文
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false  // 设置为透明背景
        
        // 首先将绘画渲染到临时图像
        let drawingImage = UIGraphicsImageRenderer(bounds: drawing.bounds, format: format).image { context in
            drawing.image(from: drawing.bounds, scale: 1.0).draw(in: drawing.bounds)
        }
        
        // 创建最终纹理
        let renderer = UIGraphicsImageRenderer(size: baseTextureSize)
        return renderer.image { context in
            // 设置基础背景为透明
            context.cgContext.clear(CGRect(origin: .zero, size: baseTextureSize))
            
            // 获取每个步骤对应的颜色和特性
            let (stepColor, variations) = getStepColorAndVariations(step: step)
            
            // 根据不同步骤使用不同的渲染参数
            let (scales, rotations, alphas) = getStepParameters(step: step)
            
            // 在不同位置重复绘制元素
            for scale in scales {
                // 计算缩放后的尺寸，并确保不超过基础纹理的尺寸
                let scaledWidth = min(drawingImage.size.width * scale, baseTextureSize.width)
                let scaledHeight = min(drawingImage.size.height * scale, baseTextureSize.height)
                
                // 确保有足够的空间进行随机定位
                let maxX = max(0, baseTextureSize.width - scaledWidth)
                let maxY = max(0, baseTextureSize.height - scaledHeight)
                
                for rotation in rotations {
                    for alpha in alphas {
                        // 使用安全的随机范围
                        let x = CGFloat.random(in: 0...maxX)
                        let y = CGFloat.random(in: 0...maxY)
                        
                        // 保存当前绘图状态
                        context.cgContext.saveGState()
                        
                        // 设置混合模式和透明度
                        context.cgContext.setBlendMode(variations.blendMode)
                        context.cgContext.setAlpha(alpha * variations.baseAlpha)
                        
                        // 设置变换
                        context.cgContext.translateBy(x: x + scaledWidth/2, y: y + scaledHeight/2)
                        context.cgContext.rotate(by: rotation * .pi / 180)
                        context.cgContext.translateBy(x: -scaledWidth/2, y: -scaledHeight/2)
                        
                        // 设置绘制颜色
                        context.cgContext.setFillColor(stepColor.cgColor)
                        
                        // 绘制图像
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
    
    // 添加错误处理辅助方法
    private func handleValidationError(_ message: String) {
        print("❌ Validation error: \(message)")
        self.drawingValidationMessage = "An error occurred: \(message)"
        self.isDrawingValid = false
        self.showValidationDialog = true
    }
    
    // 获取当前绘画的调试图像
    func getDebugImage() -> UIImage? {
        return renderDrawingToImage()
    }
    
    // 添加处理验证结果的方法
    func handleValidationContinue() {
        if isDrawingValid {
            saveDrawing(currentDrawing, forStep: currentStep)
            if currentStep < 4 {
                currentStep += 1
                currentDrawing = PKDrawing()  // 清空当前绘画
            }
        }
        showValidationDialog = false
    }
    
    func handleValidationDismiss() {
        showValidationDialog = false
    }
} 
