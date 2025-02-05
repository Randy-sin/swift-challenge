@preconcurrency import Vision
import UIKit
import AVFoundation

/// 管理摄像头会话并显示预览
class CameraViewController: UIViewController {
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    var visionProcessor: VisionProcessor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        // 创建捕获会话
        session.sessionPreset = .high

        // 获取前置摄像头
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Unable to access camera")
            return
        }

        do {
            // 设置摄像头输入
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }

            // 设置视频输出
            let queue = DispatchQueue(label: "camera_frame_processing_queue")
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }

            // 设置视频方向
            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .landscapeRight
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }

            // 设置预览层
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            
            // 调整预览层大小和方向
            let bounds = view.bounds
            let previewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            previewLayer.frame = previewFrame
            previewLayer.connection?.videoOrientation = .landscapeRight
            
            view.layer.addSublayer(previewLayer)

            // 开始捕获会话
            session.startRunning()
        } catch {
            print("Camera initialization failed: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 设置为横屏
        let windowScene = view.window?.windowScene
        windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // 支持所有方向，但在 viewWillAppear 中设置为横屏
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // 使用 weak self 捕获
        Task { @MainActor [weak self] in
            // 在主线程上下文中安全地访问 visionProcessor
            guard let processor = self?.visionProcessor else { return }
            await processor.processImage(pixelBuffer)
        }
    }
}
