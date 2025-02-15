import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
    var color: Color
    var velocity: CGPoint
    
    static func random(in rect: CGRect) -> Particle {
        // 在屏幕顶部随机生成粒子
        let randomX = CGFloat.random(in: rect.minX...rect.maxX)
        let randomY = rect.minY + CGFloat.random(in: 0...100)
        
        // 随机速度
        let velocityX = CGFloat.random(in: -1...1)
        let velocityY = CGFloat.random(in: 2...4)
        
        return Particle(
            position: CGPoint(x: randomX, y: randomY),
            scale: CGFloat.random(in: 0.3...1.2),
            opacity: Double.random(in: 0.5...1.0),
            rotation: Double.random(in: 0...360),
            color: Color(
                hue: Double.random(in: 0.5...0.7),
                saturation: Double.random(in: 0.5...0.8),
                brightness: Double.random(in: 0.8...1.0)
            ),
            velocity: CGPoint(x: velocityX, y: velocityY)
        )
    }
}

@MainActor
final class ParticleSystem: ObservableObject {
    @Published private(set) var particles: [Particle] = []
    private var rect: CGRect = .zero
    private var updateTask: Task<Void, Never>?
    private var isRunning = false
    
    func updateRect(_ newRect: CGRect) {
        rect = newRect
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        // 清理现有任务
        updateTask?.cancel()
        
        // 创建新的更新任务
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            
            while !Task.isCancelled && self.isRunning {
                self.updateParticles()
                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }
    
    func stop() {
        isRunning = false
        updateTask?.cancel()
        updateTask = nil
        particles.removeAll()
    }
    
    private func updateParticles() {
        withAnimation(.easeOut(duration: 0.16)) {
            // 移除已消失的粒子
            particles = particles.filter { particle in
                particle.position.y < rect.maxY && particle.opacity > 0.1
            }
            
            // 添加新粒子
            if particles.count < 100 {
                particles.append(Particle.random(in: rect))
            }
            
            // 更新现有粒子
            particles = particles.map { particle in
                var updatedParticle = particle
                
                // 应用重力和速度
                updatedParticle.position.y += particle.velocity.y
                updatedParticle.position.x += particle.velocity.x
                
                // 轻微摆动
                updatedParticle.position.x += CGFloat.random(in: -0.5...0.5)
                
                // 逐渐消失
                updatedParticle.opacity *= 0.99
                
                // 缓慢旋转
                updatedParticle.rotation += Double.random(in: -2...2)
                
                return updatedParticle
            }
        }
    }
    
    deinit {
        updateTask?.cancel()
        isRunning = false
    }
}

struct ParticleEffect: View {
    let progress: Double
    let baseSize: CGFloat
    
    @StateObject private var particleSystem = ParticleSystem()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 粒子层
                ForEach(particleSystem.particles) { particle in
                    ParticleView(particle: particle)
                }
            }
            .onChange(of: progress) { oldValue, newValue in
                // 更新粒子系统的绘制区域
                particleSystem.updateRect(geometry.frame(in: .local))
                
                // 根据进度控制粒子系统
                if newValue > oldValue {
                    particleSystem.start()
                } else {
                    particleSystem.stop()
                }
            }
            .onDisappear {
                particleSystem.stop()
            }
        }
    }
}

struct ParticleView: View {
    let particle: Particle
    
    var body: some View {
        Image(systemName: "sparkle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(particle.color)
            .opacity(particle.opacity)
            .scaleEffect(particle.scale)
            .rotationEffect(.degrees(particle.rotation))
            .position(particle.position)
            .blur(radius: 0.2)
    }
}

#Preview {
    ZStack {
        Color.black
            .edgesIgnoringSafeArea(.all)
        
        ParticleEffect(
            progress: 0.5,
            baseSize: 180
        )
    }
} 