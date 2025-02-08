import SwiftUI
import PencilKit

struct ArtisticPlanetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    @State private var selectedColor: DrawingColor = .blue
    @State private var brushSize: CGFloat = DrawingTools.brushSizes[1]
    @State private var showColorMeaning = false
    @State private var showUndoAlert = false
    @State private var canvasView = PKCanvasView()
    @State private var selectedTool: DrawingTool = .pen
    @State private var showNextStepAlert = false
    @State private var showCompleteAlert = false
    @StateObject private var viewModel = ArtisticPlanetViewModel()
    
    let steps = [
        (
            title: "Flower of Life",
            description: "Draw a flower that symbolizes hope. Let the petals spread wide, expressing the vitality of life through warm colors.",
            prompt: "Imagine a blooming flower that represents the hope and strength within your heart."
        ),
        (
            title: "Tree of Resilience",
            description: "Create a strong tree with roots deep in the earth and branches reaching for the sky.",
            prompt: "Like this tree, you stand strong through all storms, growing ever taller."
        ),
        (
            title: "River of Emotions",
            description: "Paint a winding river that carries your emotions towards distant horizons.",
            prompt: "Let your brushstrokes flow naturally like water, washing away all worries."
        ),
        (
            title: "Stars of Hope",
            description: "Add bright stars that shine through the darkness, guiding the way forward.",
            prompt: "Each star you draw is a wish for the future, illuminating your path."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                // Particle Effect Background
                EmotionParticleView()
                    .opacity(0.4)
                
                if viewModel.showPlanetView {
                    // 3D Planet View
                    PlanetView(viewModel: viewModel)
                        .transition(.opacity)
                } else {
                    HStack(spacing: 0) {
                        // Drawing Tools
                        DrawingToolbar(
                            selectedColor: $selectedColor,
                            brushSize: $brushSize,
                            selectedTool: $selectedTool
                        )
                        .padding(.leading, 20)
                        
                        // Canvas
                        ZStack {
                            DrawingCanvas(
                                canvasView: $canvasView,
                                tool: selectedTool,
                                color: selectedColor,
                                brushSize: brushSize
                            )
                            .alert("Color Meaning", isPresented: $showColorMeaning) {
                                Button("OK", role: .cancel) { }
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
                            .alert("Next Step", isPresented: $showNextStepAlert) {
                                Button("Keep Drawing", role: .cancel) { }
                                Button("Continue", role: .none) {
                                    // 保存当前步骤的绘画
                                    viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                                    // 清空画布
                                    canvasView.drawing = PKDrawing()
                                    // 进入下一步
                                    withAnimation {
                                        currentStep += 1
                                    }
                                }
                            } message: {
                                Text("Would you like to proceed to the next step? Your current drawing will be saved.")
                            }
                            .alert("Complete Artwork", isPresented: $showCompleteAlert) {
                                Button("Keep Drawing", role: .cancel) { }
                                Button("Create Planet", role: .none) {
                                    // Save the last drawing
                                    viewModel.saveDrawing(canvasView.drawing, forStep: currentStep)
                                    // Generate and show the final planet
                                    withAnimation(.easeInOut(duration: 0.8)) {
                                        viewModel.generateFinalPlanet()
                                        viewModel.showPlanetView = true
                                    }
                                }
                            } message: {
                                Text("Would you like to complete your healing artwork and create your planet?")
                            }
                            
                            // Top Navigation Bar
                            VStack {
                                HStack {
                                    Button(action: { dismiss() }) {
                                        Image(systemName: "chevron.left")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: { showColorMeaning = true }) {
                                        Image(systemName: "info.circle")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: { showUndoAlert = true }) {
                                        Image(systemName: "arrow.uturn.backward")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                    
                                    Button(action: { canvasView.drawing = PKDrawing() }) {
                                        Image(systemName: "trash")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                
                                Spacer()
                                
                                // Step Information
                                VStack(spacing: 16) {
                                    Text(steps[currentStep - 1].title)
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Text(steps[currentStep - 1].description)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Text(steps[currentStep - 1].prompt)
                                        .font(.system(.body, design: .serif))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.top, 4)
                                    
                                    // Navigation Buttons
                                    HStack(spacing: 20) {
                                        if currentStep > 1 {
                                            Button(action: {
                                                withAnimation {
                                                    currentStep -= 1
                                                    // 恢复上一步的绘画
                                                    if let previousDrawing = viewModel.getDrawing(forStep: currentStep) {
                                                        canvasView.drawing = previousDrawing
                                                    }
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: "chevron.left")
                                                    Text("Previous")
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.white.opacity(0.2))
                                                .cornerRadius(10)
                                            }
                                        }
                                        
                                        if currentStep < steps.count {
                                            Button(action: { showNextStepAlert = true }) {
                                                HStack {
                                                    Text("Next")
                                                    Image(systemName: "chevron.right")
                                                }
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(Color.white.opacity(0.2))
                                                .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                .padding(.bottom)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
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
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
    }
}

// New PlanetView for displaying the 3D planet
struct PlanetView: View {
    @ObservedObject var viewModel: ArtisticPlanetViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 3D Scene
            Planet3DSceneView(viewModel: viewModel)
            
            // Navigation
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Text("Your Healing Planet")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Planet description
                VStack(spacing: 12) {
                    Text("Your Artistic Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("This planet contains all your emotional expressions,\nfrom the Flower of Life to the Stars of Hope.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    ArtisticPlanetView()
} 