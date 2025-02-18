import SwiftUI
import SceneKit

// 新增：SceneKit 视图包装器
struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.backgroundColor = .clear
        view.allowsCameraControl = false
        view.autoenablesDefaultLighting = false
        view.isOpaque = false
        view.rendersContinuously = true
        view.antialiasingMode = .multisampling4X
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}

struct PlanetPreviewView: View {
    let planetName: String
    let scene: SCNScene
    @EnvironmentObject var artisticViewModel: ArtisticPlanetViewModel
    
    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // 内容
            VStack(spacing: 8) {
                // 3D星球场景
                if planetName == "Artistic" {
                    Planet3DSceneView(viewModel: artisticViewModel)
                        .frame(width: 100, height: 100)
                        .scaleEffect(0.8)
                } else {
                    SceneKitView(scene: scene)
                        .frame(width: 100, height: 100)
                }
                
                // 星球名称
                Text(planetName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 16)
        }
        .frame(width: 140, height: 140)
    }
} 