import SwiftUI
import SpriteKit

class PsycheParticleScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        
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
        starParticles.particleBirthRate = 100  // 增加生成率
        starParticles.numParticlesToEmit = 0  // 持续发射
        starParticles.particleLifetime = 15  // 增加生命周期
        starParticles.particleLifetimeRange = 8
        
        // 设置更大的发射区域
        starParticles.particlePosition = CGPoint(x: frame.width/2, y: frame.height/2)
        starParticles.particlePositionRange = CGVector(dx: frame.width * 1.5, dy: frame.height * 1.5)
        
        // 调整粒子运动
        starParticles.particleSpeed = 20
        starParticles.particleSpeedRange = 10
        starParticles.emissionAngle = 0
        starParticles.emissionAngleRange = .pi * 2
        
        // 调整粒子外观
        starParticles.particleAlpha = 0.8
        starParticles.particleAlphaRange = 0.3
        starParticles.particleAlphaSpeed = -0.05
        starParticles.particleScale = 0.5
        starParticles.particleScaleRange = 0.3
        starParticles.particleScaleSpeed = -0.01
        
        starParticles.particleColor = .white
        starParticles.particleColorBlendFactor = 1.0
        starParticles.particleBlendMode = .add
        
        starParticles.targetNode = self
        addChild(starParticles)
        
        // 添加大型星云效果
        let nebulaParticles = SKEmitterNode()
        nebulaParticles.particleTexture = SKTexture(image: particleTexture)
        nebulaParticles.particleBirthRate = 8  // 增加生成率
        nebulaParticles.numParticlesToEmit = 0
        nebulaParticles.particleLifetime = 15
        nebulaParticles.particleLifetimeRange = 8
        
        nebulaParticles.particlePosition = CGPoint(x: frame.width/2, y: frame.height/2)
        nebulaParticles.particlePositionRange = CGVector(dx: frame.width * 1.8, dy: frame.height * 1.8)
        
        nebulaParticles.particleSpeed = 10
        nebulaParticles.particleSpeedRange = 5
        nebulaParticles.emissionAngle = 0
        nebulaParticles.emissionAngleRange = .pi * 2
        
        nebulaParticles.particleAlpha = 0.15
        nebulaParticles.particleAlphaRange = 0.1
        nebulaParticles.particleScale = 6.0
        nebulaParticles.particleScaleRange = 3.0
        nebulaParticles.particleScaleSpeed = -0.04
        
        nebulaParticles.particleColor = .white
        nebulaParticles.particleColorBlendFactor = 1.0
        nebulaParticles.particleBlendMode = .add
        
        nebulaParticles.targetNode = self
        addChild(nebulaParticles)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        enumerateChildNodes(withName: "//SKEmitterNode") { node, _ in
            guard let emitter = node as? SKEmitterNode else { return }
            emitter.particlePosition = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            emitter.particlePositionRange = CGVector(dx: self.frame.width * 1.5, dy: self.frame.height * 1.5)
        }
    }
}

struct PsycheParticleView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.allowsTransparency = true
        view.backgroundColor = .clear
        
        let scene = PsycheParticleScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        
        view.presentScene(scene)
        view.frame = UIScreen.main.bounds
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene {
            scene.size = uiView.bounds.size
        }
    }
} 