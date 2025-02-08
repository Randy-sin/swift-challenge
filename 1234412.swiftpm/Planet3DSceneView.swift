import SwiftUI
import SceneKit
import PencilKit

struct Planet3DSceneView: UIViewRepresentable {
    @ObservedObject var viewModel: ArtisticPlanetViewModel
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = viewModel.getScene()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        // 设置相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        viewModel.getScene().rootNode.addChildNode(cameraNode)
        
        // 添加绘画视图
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: UIColor(viewModel.selectedColor.color), width: 10)
        canvasView.delegate = context.coordinator
        
        sceneView.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: sceneView.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor)
        ])
        
        context.coordinator.canvasView = canvasView
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let canvasView = context.coordinator.canvasView {
            canvasView.tool = PKInkingTool(.pen, color: UIColor(viewModel.selectedColor.color), width: 10)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: Planet3DSceneView
        var canvasView: PKCanvasView?
        
        init(_ parent: Planet3DSceneView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.viewModel.currentDrawing = canvasView.drawing
            parent.viewModel.updateCurrentDrawing(canvasView.drawing)
        }
    }
} 