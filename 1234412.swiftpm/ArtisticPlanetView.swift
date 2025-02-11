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
    @State private var showDebugImage = false
    
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
                                        
                                        Button(action: {
                                            viewModel.debugImage = viewModel.getDebugImage()
                                            showDebugImage = true
                                        }) {
                                            Image(systemName: "magnifyingglass")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(.ultraThinMaterial)
                                                .clipShape(Circle())
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
                            Text(steps[currentStep - 1].title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(steps[currentStep - 1].color)
                            
                            Text(steps[currentStep - 1].description)
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            // 添加示例图片
                            if let exampleImage = UIImage(named: steps[currentStep - 1].example) {
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
                                                    steps[currentStep - 1].color.opacity(0.3),
                                                    steps[currentStep - 1].color.opacity(0.1)
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
                        .onChange(of: selectedColor) { newColor in
                            viewModel.selectedColor = newColor
                        }
                        
                        // Canvas Area
                        ZStack {
                            // Canvas Background
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.98))
                                .shadow(color: .black.opacity(0.2), radius: 20)
                            
                            // Canvas
                            DrawingCanvasView(
                                canvasView: $canvasView,
                                tool: selectedTool,
                                color: selectedColor,
                                brushSize: brushSize
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .onChange(of: canvasView.drawing) { newDrawing in
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
            .alert(viewModel.drawingValidationMessage, isPresented: $viewModel.showDrawingFeedback) {
                if viewModel.isDrawingValid {
                    Button("Continue") {
                        withAnimation {
                            viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                            if currentStep < steps.count {
                                currentStep += 1
                                selectedColor = getStepColor(step: currentStep)
                                canvasView.drawing = PKDrawing()
                                viewModel.currentStep = currentStep
                            }
                        }
                    }
                }
                Button("Try Again", role: .cancel) { }
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
            .onChange(of: showCompletionDialog) { newValue in
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
        .sheet(isPresented: $showDebugImage) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    if let image = viewModel.debugImage {
                        ScrollView([.horizontal, .vertical]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 1024, height: 1024)
                                .padding()
                        }
                    } else {
                        Text("No debug image available")
                            .foregroundColor(.white)
                    }
                    
                    Text("ML Model Input Image")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        showDebugImage = false
                    }) {
                        Text("Close")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                    }
                }
            }
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

// 保持原有的 DrawingCanvas 和 CanvasView 结构体不变
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