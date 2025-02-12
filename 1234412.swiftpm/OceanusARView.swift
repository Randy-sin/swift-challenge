import SwiftUI
import ARKit
import RealityKit

struct OceanusARView: View {
    @StateObject private var arProcessor = OceanusARProcessor()
    @State private var showGuide = true
    
    var body: some View {
        ZStack {
            // AR视图容器
            ARViewContainer(arProcessor: arProcessor)
                .edgesIgnoringSafeArea(.all)
            
            // 状态提示
            if arProcessor.isPlaneDetected {
                VStack {
                    Spacer()
                    Text("找到平面，点击放置星球")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.bottom, 50)
                }
            }
            
            // 返回按钮
            VStack {
                HStack {
                    Button(action: {
                        // 这里添加返回操作
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// AR视图容器
struct ARViewContainer: UIViewRepresentable {
    let arProcessor: OceanusARProcessor
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 配置AR视图
        arView.automaticallyConfigureSession = false
        
        // 设置调试选项
        #if DEBUG
        arView.debugOptions = [.showAnchorOrigins, .showWorldOrigin]
        #endif
        
        // 初始化AR会话
        arProcessor.setupAR(view: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 更新逻辑（如果需要）
    }
}

#Preview {
    OceanusARView()
} 