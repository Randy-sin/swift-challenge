import SwiftUI
import SpriteKit

class EmotionParticleScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill  // 确保场景填充整个视图
        
        // 创建星星粒子
        let starParticles = SKEmitterNode()
        
        // 创建一个圆形的粒子纹理
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4))
        let particleTexture = renderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 4, height: 4))
            UIColor.white.setFill()
            path.fill()
        }
        
        starParticles.particleTexture = SKTexture(image: particleTexture)
        starParticles.particleBirthRate = 50  // 增加生成率以适应更大的屏幕
        starParticles.numParticlesToEmit = 0  // 持续发射
        starParticles.particleLifetime = 10
        starParticles.particleLifetimeRange = 5
        
        // 设置发射区域为整个屏幕，考虑 iPad 的尺寸
        starParticles.particlePosition = CGPoint(x: frame.width/2, y: frame.height/2)
        starParticles.particlePositionRange = CGVector(dx: frame.width * 1.2, dy: frame.height * 1.2)  // 稍微超出屏幕范围
        
        // 调整粒子运动
        starParticles.particleSpeed = 15
        starParticles.particleSpeedRange = 8
        starParticles.emissionAngle = 0
        starParticles.emissionAngleRange = .pi * 2  // 360度发射
        
        // 调整粒子外观
        starParticles.particleAlpha = 0.8
        starParticles.particleAlphaRange = 0.3
        starParticles.particleAlphaSpeed = -0.08
        starParticles.particleScale = 0.4
        starParticles.particleScaleRange = 0.2
        starParticles.particleScaleSpeed = -0.01
        
        // 设置粒子颜色
        starParticles.particleColor = .white
        starParticles.particleColorBlendFactor = 1.0
        starParticles.particleBlendMode = .add
        
        starParticles.targetNode = self
        addChild(starParticles)
        
        // 添加大型星云效果
        let nebulaParticles = SKEmitterNode()
        nebulaParticles.particleTexture = SKTexture(image: particleTexture)
        nebulaParticles.particleBirthRate = 5  // 增加生成率
        nebulaParticles.numParticlesToEmit = 0
        nebulaParticles.particleLifetime = 12
        nebulaParticles.particleLifetimeRange = 6
        
        // 设置发射区域，考虑 iPad 尺寸
        nebulaParticles.particlePosition = CGPoint(x: frame.width/2, y: frame.height/2)
        nebulaParticles.particlePositionRange = CGVector(dx: frame.width * 1.5, dy: frame.height * 1.5)  // 更大的范围
        
        // 调整运动
        nebulaParticles.particleSpeed = 8
        nebulaParticles.particleSpeedRange = 4
        nebulaParticles.emissionAngle = 0
        nebulaParticles.emissionAngleRange = .pi * 2
        
        // 调整外观
        nebulaParticles.particleAlpha = 0.12
        nebulaParticles.particleAlphaRange = 0.05
        nebulaParticles.particleScale = 4.0
        nebulaParticles.particleScaleRange = 2.0
        nebulaParticles.particleScaleSpeed = -0.04
        
        // 设置颜色
        nebulaParticles.particleColor = .white
        nebulaParticles.particleColorBlendFactor = 1.0
        nebulaParticles.particleBlendMode = .add
        
        nebulaParticles.targetNode = self
        addChild(nebulaParticles)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        // 当场景大小改变时更新粒子系统
        enumerateChildNodes(withName: "//SKEmitterNode") { node, _ in
            guard let emitter = node as? SKEmitterNode else { return }
            emitter.particlePosition = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            emitter.particlePositionRange = CGVector(dx: self.frame.width * 1.2, dy: self.frame.height * 1.2)
        }
    }
}

struct EmotionParticleView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        
        let scene = EmotionParticleScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        
        view.presentScene(scene)
        view.frame = UIScreen.main.bounds  // 确保视图填充整个屏幕
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene {
            scene.size = uiView.bounds.size
        }
    }
} 