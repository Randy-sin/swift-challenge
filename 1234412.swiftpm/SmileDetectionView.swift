import SwiftUI

struct SmileDetectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showCompletion = false
    @StateObject private var visionProcessor = VisionProcessor()
    @State private var showSkipButton = false  // 控制Skip按钮的显示
    
    var body: some View {
        ZStack {
            // 基础相机视图
            if !showCompletion {
                CameraView()
                    .edgesIgnoringSafeArea(.all)
                    .environmentObject(visionProcessor)
            }
            
            // UI层
            if !showCompletion {
                VStack {
                    // 顶部导航栏
                    HStack {
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
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // 引导文本
                        Text("Face the camera directly\nDon't tilt your head")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
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
                                            .fill(Color.white.opacity(0.2))
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                            }
                            .transition(.opacity.combined(with: .scale))
                            .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // 底部微笑检测状态
                    VStack(spacing: 10) {
                        Text(visionProcessor.isSmiling ? "Great Smile! 😊" : "Show Your Teeth & Smile Big!")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(visionProcessor.isSmiling ? Color.green.opacity(0.8) : Color.white.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 50)
                    
                    // 微笑进度指示器
                    ZStack {
                        // 背景圆环
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 6)
                            .frame(width: 80, height: 80)
                        
                        // 进度圆环
                        Circle()
                            .trim(from: 0, to: min(CGFloat(visionProcessor.smilingDuration / 2.0), 1.0))
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        // 中间的文本
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
                    .padding(.bottom, 50)
                }
            }
            
            // 完成层
            if showCompletion {
                CompletionView()
                    .transition(.opacity)
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