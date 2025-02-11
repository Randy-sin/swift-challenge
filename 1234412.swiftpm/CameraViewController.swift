@preconcurrency import Vision
import UIKit
import AVFoundation

/// 管理摄像头会话并显示预览
@MainActor
class CameraViewController: UIViewController {
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    var visionProcessor: VisionProcessor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        
        // 添加设备方向变化通知监听
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeviceOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // 开启设备方向监听
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    deinit {
        Task { @MainActor in
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleDeviceOrientationChange() {
        guard let connection = previewLayer.connection else { return }
        
        let deviceOrientation = UIDevice.current.orientation
        let rotationAngle: Double
        
        // 更新预览层方向
        switch deviceOrientation {
        case .portrait:
            rotationAngle = 0
        case .landscapeLeft:
            rotationAngle = .pi / 2
        case .landscapeRight:
            rotationAngle = -.pi / 2
        case .portraitUpsideDown:
            rotationAngle = .pi
        default:
            rotationAngle = 0
        }
        
        if connection.isVideoRotationAngleSupported(rotationAngle) {
            connection.videoRotationAngle = rotationAngle
        }
        
        // 更新视频输出方向
        if let videoConnection = videoOutput.connection(with: .video),
           videoConnection.isVideoRotationAngleSupported(rotationAngle) {
            videoConnection.videoRotationAngle = rotationAngle
        }
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

            // 设置预览层
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            
            // 调整预览层大小和方向
            let bounds = view.bounds
            let previewFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
            previewLayer.frame = previewFrame
            
            // 设置预览层的方向
            if let connection = previewLayer.connection {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .landscapeRight
                }
            }
            
            view.layer.addSublayer(previewLayer)
            
            // 设置视频输出的方向
            if let videoConnection = videoOutput.connection(with: .video) {
                if videoConnection.isVideoOrientationSupported {
                    videoConnection.videoOrientation = .landscapeRight
                }
            }

            // 开始捕获会话
            session.startRunning()
        } catch {
            print("Camera initialization failed: \(error)")
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        Task { @MainActor [weak self] in
            guard let processor = self?.visionProcessor else { return }
            await processor.processImage(pixelBuffer)
        }
    }
}
