import SwiftUI
import PencilKit

struct ArtisticPlanetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtisticPlanetViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: DrawingColor = .blue
    @State private var selectedTool: DrawingTool = .pen
    @State private var brushSize: CGFloat = DrawingTools.brushSizes[1]
    @State private var showColorMeaning = false
    @State private var showUndoAlert = false
    @State private var currentStep = 1
    @State private var showCompleteAlert = false
    @State private var showCompletionDialog = false
    @State private var showArtisticCompletion = false
    @State private var showTip = false
    
    let steps = [
        (title: "Blooming Hope", description: "Paint a flower with warm colors to represent hope", color: DrawingColor.red.color, example: "flower_example"),
        (title: "Tree of Life", description: "Draw a tree reaching towards the starry sky", color: DrawingColor.green.color, example: "tree_example"),
        (title: "River of Emotions", description: "Create a flowing river to symbolize emotional journey", color: DrawingColor.blue.color, example: "river_example"),
        (title: "Starlight Dreams", description: "Add shining stars to illuminate your world", color: DrawingColor.yellow.color, example: "star_example")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.05, green: 0.05, blue: 0.15)
                    .edgesIgnoringSafeArea(.all)
                
                // Starfield effect
                EmotionParticleView()
                    .opacity(0.8)
                
                VStack(spacing: 0) {
                    // Top Navigation and Step Guide
                    VStack(spacing: 12) {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Step Navigation
                            HStack(spacing: 20) {
                                if currentStep > 1 {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                                            currentStep -= 1
                                            selectedColor = getStepColor(step: currentStep)
                                            if let previousDrawing = viewModel.getDrawing(forStep: currentStep) {
                                                canvasView.drawing = previousDrawing
                                            } else {
                                                canvasView.drawing = PKDrawing()
                                            }
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "chevron.left")
                                            Text("Previous")
                                        }
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(16)
                                    }
                                }
                                
                                if currentStep < steps.count {
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            viewModel.validateCurrentDrawing(forStep: currentStep)
                                        }) {
                                            HStack(spacing: 8) {
                                                Text("Validate")
                                                Image(systemName: "checkmark.circle")
                                            }
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(16)
                                        }
                                    }
                                } else {
                                    Button(action: {
                                        viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                                        showCompletionDialog = true
                                    }) {
                                        HStack(spacing: 8) {
                                            Text("Complete")
                                            Image(systemName: "checkmark")
                                        }
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(16)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Tool Buttons
                            HStack(spacing: 16) {
                                Button(action: { showColorMeaning = true }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 20, weight: .medium))
                                }
                                
                                Button(action: { showUndoAlert = true }) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 20, weight: .medium))
                                }
                                
                                Button(action: { canvasView.drawing = PKDrawing() }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20, weight: .medium))
                                }
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        
                        // Step Guide
                        VStack(spacing: 8) {
                            Text(steps[min(currentStep - 1, steps.count - 1)].title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(steps[min(currentStep - 1, steps.count - 1)].color)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showTip.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: showTip ? "lightbulb.slash.fill" : "lightbulb.fill")
                                        .font(.system(size: 15))
                                    Text(showTip ? "Hide Tip" : "Need a Tip?")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                )
                            }
                            
                            // 只在第二步（Tree of Life）显示提示文字
                            if currentStep == 2 {
                                Text("This might be difficult")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 4)
                            }
                            
                            if showTip {
                                Text(steps[min(currentStep - 1, steps.count - 1)].description)
                                    .font(.system(size: 17, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .padding(.top, 8)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            // 添加示例图片
                            if let exampleImage = UIImage(named: steps[min(currentStep - 1, steps.count - 1)].example) {
                                Image(uiImage: exampleImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .padding(.vertical, 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    steps[min(currentStep - 1, steps.count - 1)].color.opacity(0.3),
                                                    steps[min(currentStep - 1, steps.count - 1)].color.opacity(0.1)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .blendMode(.overlay)
                                )
                        )
                    }
                    
                    // Main Content Area
                    HStack(spacing: 24) {
                        // Left Toolbar
                        DrawingToolbar(
                            selectedColor: $selectedColor,
                            brushSize: $brushSize,
                            selectedTool: $selectedTool
                        )
                        .padding(.leading, 24)
                        .onChange(of: selectedColor) { oldColor, newColor in
                            viewModel.selectedColor = newColor
                        }
                        
                        // Canvas Area
                        ZStack {
                            // Canvas Background
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.98))
                                .shadow(color: .black.opacity(0.2), radius: 20)
                            
                            // Canvas
                            DrawingCanvas(
                                canvasView: $canvasView,
                                tool: selectedTool,
                                color: selectedColor,
                                brushSize: brushSize
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .onChange(of: canvasView.drawing) { oldDrawing, newDrawing in
                                print("🖌 Drawing updated in view")
                                print("✏️ Strokes count: \(newDrawing.strokes.count)")
                                print("📐 Bounds: \(newDrawing.bounds)")
                                viewModel.currentDrawing = newDrawing
                            }
                            .onAppear {
                                print("📱 Canvas view appeared")
                                canvasView.drawingPolicy = .anyInput
                                canvasView.backgroundColor = .clear
                                selectedColor = getStepColor(step: currentStep)
                                if let drawing = viewModel.getDrawing(forStep: currentStep) {
                                    canvasView.drawing = drawing
                                    viewModel.currentDrawing = drawing
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        
                        // 预览视图
                        VStack {
                            // 预览标题
                            Text("Planet Preview")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                            
                            // 预览窗口
                            Button(action: {
                                viewModel.showFullScreenPreview = true
                            }) {
                                Planet3DSceneView(viewModel: viewModel)
                                    .frame(width: 200, height: 200)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.black.opacity(0.3))
                                            .background(.ultraThinMaterial)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.trailing, 24)
                    }
                }
            }
            .alert("Color Meaning", isPresented: $showColorMeaning) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text(selectedColor.emotionalMeaning)
            }
            .alert("Undo Drawing", isPresented: $showUndoAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Undo", role: .destructive) {
                    canvasView.undoManager?.undo()
                }
            } message: {
                Text("Do you want to undo your last drawing?")
            }
            .overlay {
                if viewModel.showValidationDialog {
                    // 自定义验证对话框
                    ZStack {
                        // 背景遮罩
                        Color.black
                            .opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.handleValidationDismiss()
                                }
                            }
                            .transition(.opacity)
                        
                        // 对话框
                        VStack(spacing: 24) {
                            // 图标和消息
                            VStack(spacing: 20) {
                                // 动态图标
                                ZStack {
                                    Circle()
                                        .fill(viewModel.isDrawingValid ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    Circle()
                                        .stroke(
                                            viewModel.isDrawingValid ? Color.green : Color.blue,
                                            lineWidth: 2
                                        )
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: viewModel.isDrawingValid ? "checkmark" : "lightbulb.fill")
                                        .font(.system(size: 30, weight: .medium))
                                        .foregroundColor(viewModel.isDrawingValid ? Color.green : Color.blue)
                                        .symbolEffect(.bounce, options: .repeating)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    (viewModel.isDrawingValid ? Color.green : Color.blue).opacity(0.5),
                                                    (viewModel.isDrawingValid ? Color.green : Color.blue).opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                        .frame(width: 100, height: 100)
                                )
                                
                                if viewModel.drawingValidationMessage.contains("**[Validate]**") {
                                    // 特殊处理带格式的消息
                                    let parts = viewModel.drawingValidationMessage.components(separatedBy: "**[Validate]**")
                                    HStack(spacing: 0) {
                                        Text(parts[0])
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Validate")
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                        Text(parts[1])
                                            .font(.system(size: 20, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 20)
                                } else {
                                    Text(viewModel.drawingValidationMessage)
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .padding(.horizontal, 20)
                                }
                            }
                            
                            // 按钮区域
                            HStack(spacing: 16) {
                                // Try Again 按钮
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.handleValidationDismiss()
                                    }
                                }) {
                                    Text("Try Again")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 120, height: 44)
                                        .background(
                                            ZStack {
                                                Capsule()
                                                    .fill(.ultraThinMaterial)
                                                
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            }
                                        )
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .transition(.scale.combined(with: .opacity))
                                
                                #if targetEnvironment(simulator)
                                // Skip 按钮（在模拟器中显示，但在空绘画提示时不显示）
                                if !viewModel.drawingValidationMessage.contains("Drawing test successful") {
                                    Button(action: {
                                        // 保存当前绘画
                                        viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                                        // 更新UI
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            currentStep += 1
                                            selectedColor = getStepColor(step: currentStep)
                                            canvasView.drawing = PKDrawing()  // 清空画板
                                            viewModel.handleValidationDismiss()
                                        }
                                    }) {
                                        Text("Skip")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(width: 120, height: 44)
                                            .background(
                                                ZStack {
                                                    Capsule()
                                                        .fill(Color.blue)
                                                    
                                                    Capsule()
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                }
                                            )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                    .transition(.scale.combined(with: .opacity))
                                }
                                #else
                                if viewModel.isDrawingValid {
                                    // Continue 按钮
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            viewModel.handleValidationContinue()
                                            currentStep += 1
                                            selectedColor = getStepColor(step: currentStep)
                                            canvasView.drawing = PKDrawing()  // 清空画板
                                        }
                                    }) {
                                        Text("Continue")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.black)
                                            .frame(width: 120, height: 44)
                                            .background(
                                                ZStack {
                                                    Capsule()
                                                        .fill(Color.white)
                                                    
                                                    Capsule()
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                }
                                            )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                    .transition(.scale.combined(with: .opacity))
                                } else if !viewModel.drawingValidationMessage.contains("Drawing test successful") {
                                    // Skip 按钮（验证失败时显示，但在空绘画提示时不显示）
                                    Button(action: {
                                        // 保存当前绘画
                                        viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                                        // 更新UI
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            currentStep += 1
                                            selectedColor = getStepColor(step: currentStep)
                                            canvasView.drawing = PKDrawing()  // 清空画板
                                            viewModel.handleValidationDismiss()
                                        }
                                    }) {
                                        Text("Skip")
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .frame(width: 120, height: 44)
                                            .background(
                                                ZStack {
                                                    Capsule()
                                                        .fill(Color.blue)
                                                    
                                                    Capsule()
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                }
                                            )
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                    .transition(.scale.combined(with: .opacity))
                                }
                                #endif
                            }
                        }
                        .padding(32)
                        .background(
                            ZStack {
                                // 模糊背景
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                                    .opacity(0.95)
                                
                                // 玻璃效果
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.ultraThinMaterial)
                                
                                // 渐变边框
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.3),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(40)
                        .scaleEffect(viewModel.showValidationDialog ? 1 : 0.7)
                        .opacity(viewModel.showValidationDialog ? 1 : 0)
                        .blur(radius: viewModel.showValidationDialog ? 0 : 10)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.8)),
                            removal: .scale(scale: 0.9).combined(with: .opacity).animation(.easeOut(duration: 0.2))
                        ))
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                }
            }
            .onChange(of: viewModel.showValidationDialog) { oldValue, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.showValidationDialog = true
                    }
                }
            }
            .fullScreenCover(isPresented: $viewModel.showFullScreenPreview) {
                ZStack {
                    // 背景
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    // 3D场景
                    Planet3DSceneView(viewModel: viewModel)
                    
                    // 关闭按钮
                    VStack {
                        HStack {
                            Button(action: {
                                viewModel.showFullScreenPreview = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .padding(20)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .overlay {
                if showCompletionDialog {
                    // 自定义完成对话框
                    ZStack {
                        // 背景遮罩
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .opacity(showCompletionDialog ? 1 : 0)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showCompletionDialog = false
                                }
                            }
                        
                        // 对话框
                        VStack(spacing: 24) {
                            // 标题
                            Text("Complete Your Artwork")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            // 描述
                            Text("Your artistic journey has created something unique. Would you like to complete your healing artwork?")
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 20)
                            
                            // 按钮
                            HStack(spacing: 16) {
                                // Keep Drawing 按钮
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showCompletionDialog = false
                                    }
                                }) {
                                    Text("Keep Drawing")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(width: 140, height: 44)
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                }
                                
                                // Complete 按钮
                                Button(action: {
                                    viewModel.generateFinalPlanet()
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showCompletionDialog = false
                                    }
                                    showArtisticCompletion = true
                                }) {
                                    Text("Complete")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(.black)
                                        .frame(width: 140, height: 44)
                                        .background(
                                            Capsule()
                                                .fill(Color.white)
                                        )
                                }
                            }
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .padding(40)
                        .scaleEffect(showCompletionDialog ? 1 : 0.8)
                        .opacity(showCompletionDialog ? 1 : 0)
                    }
                    .transition(.opacity)
                }
            }
            .onChange(of: showCompletionDialog) { oldValue, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showCompletionDialog = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showArtisticCompletion) {
            ArtisticCompletionView(viewModel: viewModel)
        }
    }
    
    private func getStepColor(step: Int) -> DrawingColor {
        switch step {
        case 1: return .red
        case 2: return .green
        case 3: return .blue
        case 4: return .yellow
        default: return .blue
        }
    }
}

struct DrawingCanvas: View {
    @Binding var canvasView: PKCanvasView
    let tool: DrawingTool
    let color: DrawingColor
    let brushSize: CGFloat
    
    var body: some View {
        CanvasView(
            canvasView: $canvasView,
            tool: DrawingTools.getPKTool(tool: tool, color: color, size: brushSize)
        )
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let tool: PKTool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = tool
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.tag = 999
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
    }
}

#Preview {
    ArtisticPlanetView()
} 