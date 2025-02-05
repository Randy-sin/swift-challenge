import SwiftUI

/// 摄像头视图
struct CameraView: UIViewControllerRepresentable {
    @EnvironmentObject var visionProcessor: VisionProcessor
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.visionProcessor = visionProcessor
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // 更新逻辑（如果需要）
    }
}
