import RealityKit
import SwiftUI

/// 海王星实体管理器
@MainActor
final class OceanusEntity {
    // MARK: - Properties
    private var neptuneEntity: ModelEntity?
    private var loadingCompletion: ((ModelEntity?) -> Void)?
    
    // 缩放相关属性
    private let minScale: Float = 0.0001  // 最小缩放比例
    private let maxScale: Float = 0.05    // 最大缩放比例
    private let defaultScale: Float = 0.006 // 默认缩放比例
    private let scaleSpeed: Float = 1.0    // 缩放速度
    private let scaleDamping: Float = 0.2  // 阻尼系数
    private var currentScale: Float = 0.006 // 初始缩放值
    private var normalizedScale: Float = 1.0 // 存储标准化比例
    
    // MARK: - 初始化
    init(completion: ((ModelEntity?) -> Void)? = nil) {
        self.loadingCompletion = completion
        loadNeptuneModel()
    }
    
    // MARK: - 公共方法
    
    /// 获取完整的海王星实体
    /// - Returns: 包含所有子实体的锚点实体
    func getEntity() -> Entity {
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        
        if let neptune = neptuneEntity {
            print("🔄 Setting up Neptune entity...")
            
            // 设置初始变换，使用标准化后的缩放值
            var transform = Transform()
            transform.scale = SIMD3<Float>(repeating: normalizedScale * defaultScale)
            transform.translation = SIMD3<Float>(0, 0.1, 0)
            neptune.transform = transform
            
            print("📏 Initial combined scale: \(neptune.transform.scale)")
            currentScale = defaultScale  // 只存储用户缩放部分
            
            // 添加到场景
            anchor.addChild(neptune)
        }
        return anchor
    }
    
    /// 处理缩放手势
    /// - Parameter scale: 缩放因子
    func handlePinchGesture(scale: Float) {
        guard let neptune = neptuneEntity else { return }
        
        // 计算新的用户缩放值
        let newScale = currentScale * scale
        
        // 限制缩放范围
        let clampedScale = simd_clamp(newScale, minScale, maxScale)
        
        print("📊 Scale calculation:")
        print("  Current user scale: \(currentScale)")
        print("  Gesture scale: \(scale)")
        print("  New user scale: \(newScale)")
        print("  Clamped user scale: \(clampedScale)")
        print("  Normalization scale: \(normalizedScale)")
        print("  Final combined scale: \(normalizedScale * clampedScale)")
        
        // 创建新的变换，结合标准化比例和用户缩放
        var newTransform = neptune.transform
        newTransform.scale = SIMD3<Float>(repeating: normalizedScale * clampedScale)
        
        // 保持当前位置
        newTransform.translation = SIMD3<Float>(0, 0.1, 0)
        
        // 应用变换
        neptune.move(
            to: newTransform,
            relativeTo: neptune.parent,
            duration: 0.1,
            timingFunction: .easeInOut
        )
        
        // 只更新用户缩放部分
        currentScale = clampedScale
    }
    
    // MARK: - 私有方法
    
    /// 加载海王星模型
    private func loadNeptuneModel() {
        Task {
            do {
                let modelEntity = try await ModelEntity(named: "Neptune")
                
                // 计算模型的标准化大小
                let bounds = modelEntity.visualBounds(relativeTo: nil)
                let size = bounds.max - bounds.min
                let maxDimension = max(size.x, max(size.y, size.z))
                self.normalizedScale = 1.0 / maxDimension  // 存储标准化比例
                
                // 设置初始变换
                var initialTransform = Transform()
                initialTransform.scale = SIMD3<Float>(repeating: normalizedScale * defaultScale)
                initialTransform.translation = SIMD3<Float>(0, 0.1, 0)
                modelEntity.transform = initialTransform
                
                // 获取标准化后的边界框
                let normalizedBounds = modelEntity.visualBounds(relativeTo: nil)
                
                // 打印调试信息
                print("📏 Original model bounds: min=\(bounds.min), max=\(bounds.max)")
                print("📏 Normalized model bounds: min=\(normalizedBounds.min), max=\(normalizedBounds.max)")
                print("📐 Normalization scale: \(normalizedScale)")
                print("📐 Initial user scale: \(defaultScale)")
                print("📐 Initial combined scale: \(modelEntity.transform.scale)")
                print("🎯 Initial position: \(modelEntity.position)")
                
                // 设置碰撞属性
                let collisionShape = ShapeResource.generateBox(size: size * normalizedScale)
                modelEntity.collision = CollisionComponent(
                    shapes: [collisionShape],
                    mode: .trigger,
                    filter: .sensor
                )
                
                // 设置为静态物体
                modelEntity.physicsBody = PhysicsBodyComponent(
                    massProperties: .default,
                    material: .default,
                    mode: .static
                )
                
                self.neptuneEntity = modelEntity
                self.currentScale = defaultScale  // 只存储用户缩放部分
                print("✅ 模型加载成功")
                self.loadingCompletion?(modelEntity)
            } catch {
                print("❌ 模型加载失败: \(error.localizedDescription)")
                print("🔍 错误详情: \(error)")
                self.loadingCompletion?(nil)
            }
        }
    }
}

// MARK: - 辅助类型

/// 动画参数结构体
private struct AnimationParameters: @unchecked Sendable {
    let baseScale: Float
    let maxScale: Float
} 