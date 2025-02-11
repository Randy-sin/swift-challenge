import SwiftUI

struct SmileDetectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCompletion = false
    @StateObject private var visionProcessor = VisionProcessor()
    @State private var showSkipButton = false  // 控制Skip按钮的显示
    
    // 添加强制横屏支持
    init() {
        // 设置支持的方向为横屏
        if #available(iOS 16.0, *) {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .forEach { windowScene in
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
                }
        } else {
            // iOS 16.0 之前的版本
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 基础相机视图
                if !showCompletion {
                    CameraView()
                        .edgesIgnoringSafeArea(.all)
                        .environmentObject(visionProcessor)
                }
                
                // UI层
                if !showCompletion {
                    HStack {  // 改为 HStack 以适应横屏布局
                        // 左侧控制区
                        VStack {
                            // 返回按钮
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Skip 按钮
                            if showSkipButton {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showCompletion = true
                                    }
                                }) {
                                    Text("Skip")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            Capsule()
                                                .fill(Color.black.opacity(0.6))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.vertical, 20)
                        
                        Spacer()
                        
                        // 右侧状态区
                        VStack(spacing: 20) {
                            // 引导文本
                            Text("Face the camera directly\nDon't tilt your head")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            
                            Spacer()
                            
                            // 微笑检测状态
                            Text(visionProcessor.isSmiling ? "Great Smile! 😊" : "Show Your Teeth & Smile Big!")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(visionProcessor.isSmiling ? Color.green.opacity(0.8) : Color.white.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                            
                            // 微笑进度指示器
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 6)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: min(CGFloat(visionProcessor.smilingDuration / 2.0), 1.0))
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                
                                if visionProcessor.hasReachedTarget {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Text(String(format: "%.1f", max(2.0 - visionProcessor.smilingDuration, 0)))
                                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.vertical, 20)
                    }
                }
                
                // 完成层
                if showCompletion {
                    CompletionView()
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            // 延迟显示Skip按钮
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showSkipButton = true
                }
            }
        }
        .onChange(of: visionProcessor.hasReachedTarget) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCompletion = true
                }
            }
        }
    }
} 