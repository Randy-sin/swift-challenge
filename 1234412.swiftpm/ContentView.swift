import SwiftUI

/// Main Interface
struct ContentView: View {
    @State private var isShowingGuide = false  // 修改为默认不显示引导页
    @State private var showGuideButton = false  // 显示重新打开引导的按钮
    @State private var showCompletion = false  // 添加完成页面状态
    @State private var isLaunchViewPresented = true  // 添加启动页状态
    @StateObject private var visionProcessor = VisionProcessor()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            if !isShowingGuide && !showCompletion {  // 只在非引导和非完成状态显示摄像头
                CameraView()
                    .edgesIgnoringSafeArea(.all)
                    .environmentObject(visionProcessor)
            }
            
            if !isShowingGuide && !showCompletion {  // 只在非引导和非完成状态显示UI
                VStack {
                    // Top guidance text
                    HStack {
                        Text("Face the camera directly\nDon't tilt your head")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                        if showGuideButton {
                            Button(action: {
                                withAnimation {
                                    isShowingGuide = true
                                }
                            }) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Bottom smile detection status
                    VStack(spacing: 10) {
                        Text(visionProcessor.isSmiling ? "Great Smile! 😊" : "Show your teeth and smile big! 😐")
                            .font(.headline)
                            .padding()
                            .background(visionProcessor.isSmiling ? Color.green.opacity(0.8) : Color.gray.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                        if !visionProcessor.isSmiling {
                            Text("Tips: Keep your head straight and show your teeth")
                                .font(.subheadline)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
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
                            .trim(from: 0, to: min(CGFloat(visionProcessor.smilingDuration / 3.0), 1.0))
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                        
                        // 中间的文本
                        if visionProcessor.hasReachedTarget {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text(String(format: "%.1f", max(3.0 - visionProcessor.smilingDuration, 0)))
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 50)
                    
                    // 帮助按钮
                    Button(action: {
                        isShowingGuide = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 30)
                }
            }
            
            // 引导页覆盖层
            if isShowingGuide {
                GuideView(isShowingGuide: $isShowingGuide)
                    .transition(.opacity)
                    .onDisappear {
                        showGuideButton = true
                    }
            }
            
            // 完成页面
            if showCompletion {
                CompletionView()
                    .transition(.opacity)
            }
            
            // 启动页
            if isLaunchViewPresented {
                LaunchView(isLaunchViewPresented: $isLaunchViewPresented)
                    .transition(.opacity)
                    .onDisappear {
                        // 启动页结束后显示引导页
                        isShowingGuide = true
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
        .onAppear {
            setLandscapeOrientation()
        }
    }
    
    private func setLandscapeOrientation() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(
                interfaceOrientations: .landscapeRight
            )
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                if error != nil {
                    print("Failed to set orientation: \(error.localizedDescription)")
                }
            }
        }
    }
}
