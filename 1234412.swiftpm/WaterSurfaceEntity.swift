import RealityKit
import ARKit

@MainActor
final class WaterSurfaceEntity {
    // MARK: - Properties
    private var waterEntity: ModelEntity?
    private var loadingCompletion: ((ModelEntity?) -> Void)?
    
    // 缩放相关属性
    private let minScale: Float = 0.0001  // 最小缩放比例
    private let maxScale: Float = 0.05    // 最大缩放比例
    private let defaultScale: Float = 0.006 // 默认缩放比例
    private var currentScale: Float = 0.006 // 初始缩放值
    private var normalizedScale: Float = 1.0 // 存储标准化比例
    
    // MARK: - 初始化
    init(completion: ((ModelEntity?) -> Void)? = nil) {
        print("🌊 初始化 WaterSurfaceEntity")
        self.loadingCompletion = completion
        loadWaterModel()
    }
    
    // MARK: - 公共方法
    
    /// 获取完整的水面实体
    /// - Returns: 包含所有子实体的锚点实体
    func getEntity() -> Entity {
        print("🔍 开始创建水面实体锚点")
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        print("📍 创建锚点成功: \(anchor)")
        
        if let water = waterEntity {
            print("🌊 找到水面实体，开始设置...")
            
            // 设置初始变换，使用标准化后的缩放值
            var transform = Transform()
            transform.scale = SIMD3<Float>(repeating: normalizedScale * defaultScale)
            transform.translation = SIMD3<Float>(0, 0, 0)  // 不调整高度
            water.transform = transform
            
            print("📐 变换设置完成:")
            print("  - 缩放: \(transform.scale)")
            print("  - 位置: \(transform.translation)")
            print("  - 旋转: \(transform.rotation)")
            
            // 添加到场景
            anchor.addChild(water)
            print("✅ 水面实体已添加到锚点")
            
            // 打印层级结构
            print("📚 实体层级结构:")
            printEntityHierarchy(anchor, level: 0)
        } else {
            print("⚠️ 水面实体为空，无法添加到场景")
        }
        return anchor
    }
    
    // MARK: - 私有方法
    
    /// 打印实体层级结构
    private func printEntityHierarchy(_ entity: Entity, level: Int) {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)- \(type(of: entity)): \(entity.name)")
        for child in entity.children {
            printEntityHierarchy(child, level: level + 1)
        }
    }
    
    /// 加载水面模型
    private func loadWaterModel() {
        print("🔄 开始加载水面模型...")
        Task {
            do {
                print("📦 尝试加载 Ocean_-_Surface.usdz 模型")
                let modelEntity = try await ModelEntity(named: "Ocean_-_Surface.usdz")
                print("✅ 模型加载成功")
                
                // 调整模型材质
                if let materials = modelEntity.model?.materials {
                    print("🎨 开始调整材质...")
                    for (index, material) in materials.enumerated() {
                        if var pbr = material as? PhysicallyBasedMaterial {
                            // 调整基础颜色的 alpha 值来控制透明度
                            let currentColor = pbr.baseColor
                            pbr.baseColor = .init(tint: currentColor.tint, texture: currentColor.texture)
                            
                            // 设置透明混合模式
                            pbr.blending = .transparent(opacity: 0.9)  // 0.9 表示非常不透明
                            
                            // 更新材质
                            modelEntity.model?.materials[index] = pbr
                            print("  - 已调整材质 \(index) 的不透明度为 0.9")
                        }
                    }
                }
                
                // 计算模型的标准化大小
                let bounds = modelEntity.visualBounds(relativeTo: nil)
                let size = bounds.max - bounds.min
                let maxDimension = max(size.x, max(size.y, size.z))
                self.normalizedScale = 1.0 / maxDimension
                
                print("📏 模型尺寸信息:")
                print("  - 边界: min=\(bounds.min), max=\(bounds.max)")
                print("  - 尺寸: \(size)")
                print("  - 最大维度: \(maxDimension)")
                print("  - 标准化比例: \(normalizedScale)")
                
                // 设置初始变换
                var initialTransform = Transform()
                initialTransform.scale = SIMD3<Float>(repeating: normalizedScale * defaultScale)
                initialTransform.translation = SIMD3<Float>(0, 0, 0)  // 不调整高度
                modelEntity.transform = initialTransform
                
                print("🎯 初始变换设置完成:")
                print("  - 缩放: \(initialTransform.scale)")
                print("  - 位置: \(initialTransform.translation)")
                
                // 设置碰撞属性
                let collisionShape = ShapeResource.generateBox(size: size * normalizedScale)
                modelEntity.collision = CollisionComponent(
                    shapes: [collisionShape],
                    mode: .trigger,
                    filter: .sensor
                )
                print("🎯 碰撞组件已添加")
                
                // 设置为静态物体
                modelEntity.physicsBody = PhysicsBodyComponent(
                    massProperties: .default,
                    material: .default,
                    mode: .static
                )
                print("🎯 物理组件已添加")
                
                // 检查模型的材质
                if let materials = modelEntity.model?.materials {
                    print("🎨 模型材质信息:")
                    for (index, material) in materials.enumerated() {
                        print("  材质 \(index): \(type(of: material))")
                    }
                } else {
                    print("⚠️ 模型没有材质")
                }
                
                self.waterEntity = modelEntity
                print("✅ 水面实体设置完成")
                self.loadingCompletion?(modelEntity)
            } catch {
                print("❌ 水面模型加载失败")
                print("  - 错误描述: \(error.localizedDescription)")
                print("  - 错误详情: \(error)")
                self.loadingCompletion?(nil)
            }
        }
    }
} 