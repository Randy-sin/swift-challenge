import SwiftUI
import SpriteKit
import PencilKit

struct SceneCard: View {
    let title: String
    let subtitle: String
    let description: String
    let isLocked: Bool
    let gradientColors: [Color]
    let backgroundImage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题区域
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
                    .padding(.top, 4)
            }
            
            Spacer()
            
            // 状态指示
            HStack {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                } else {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
        .padding(30)
        .frame(width: 400, height: 180)
        .background(
            ZStack {
                if let bgImage = backgroundImage {
                    Image(bgImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 180)
                        .clipped()
                        .opacity(0.4)
                }
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.15))
                
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                
                // 渐变光效
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.plusLighter)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}

struct SceneMenuView: View {
    @State private var selectedScene: Int? = nil
    @State private var showSmileDetection = false
    @State private var showVenusGuide = false
    @State private var showArtisticGuide = false
    @State private var showArtisticPlanet = false
    @StateObject private var artisticViewModel = ArtisticPlanetViewModel()
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // 粒子背景
            EmotionParticleView()
            
            VStack(spacing: 40) {
                // 标题
                Text("Choose Your Journey")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // 场景网格
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 30),
                    GridItem(.flexible(), spacing: 30)
                ], spacing: 30) {
                    // 第一个场景：微笑检测
                    Button {
                        showVenusGuide = true
                    } label: {
                        SceneCard(
                            title: "Venus Radiance",
                            subtitle: "Let Your Smile Shine Like Venus",
                            description: "Transform your emotions through the brightest smile in our solar system",
                            isLocked: false,
                            gradientColors: [
                                Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.3),
                                Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.2),
                                Color.clear
                            ],
                            backgroundImage: "venusbg"
                        )
                    }
                    
                    // 第二个场景：艺术星球
                    Button {
                        showArtisticGuide = true
                    } label: {
                        SceneCard(
                            title: "Artistic Planet",
                            subtitle: "Paint Your Emotions in Space",
                            description: "Create your own celestial world with colors of feelings",
                            isLocked: false,
                            gradientColors: [
                                Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.3),
                                Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.2),
                                Color.clear
                            ],
                            backgroundImage: nil
                        )
                    }
                    
                    // 第三个场景（待解锁）
                    SceneCard(
                        title: "Coming Soon",
                        subtitle: "Your next journey awaits",
                        description: "Complete previous journey to unlock",
                        isLocked: true,
                        gradientColors: [
                            .white.opacity(0.2),
                            .clear
                        ],
                        backgroundImage: nil
                    )
                    
                    // 第四个场景（待解锁）
                    SceneCard(
                        title: "Coming Soon",
                        subtitle: "Your next journey awaits",
                        description: "Complete previous journey to unlock",
                        isLocked: true,
                        gradientColors: [
                            .white.opacity(0.2),
                            .clear
                        ],
                        backgroundImage: nil
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 底部提示
                Text("Complete each journey to unlock the next")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showVenusGuide) {
            VenusGuideView(isShowingGuide: $showVenusGuide, startSmileDetection: {
                showVenusGuide = false
                showSmileDetection = true
            })
        }
        .fullScreenCover(isPresented: $showSmileDetection) {
            SmileDetectionView()
        }
        .fullScreenCover(isPresented: $showArtisticGuide) {
            ArtisticGuideView(isShowingGuide: $showArtisticGuide, startDrawing: {
                showArtisticGuide = false
                showArtisticPlanet = true
            })
        }
        .fullScreenCover(isPresented: $showArtisticPlanet) {
            DrawingView()
                .environmentObject(artisticViewModel)
        }
    }
}

struct DrawingView: View {
    @EnvironmentObject var viewModel: ArtisticPlanetViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var showColorMeaning = false
    @State private var showUndoAlert = false
    @State private var currentStep = 1
    @State private var showCompleteAlert = false
    @State private var selectedTool: DrawingTool = .pen
    @State private var brushSize: CGFloat = 10
    
    let steps = [
        "Step 1: Choose a color that represents your current emotions",
        "Step 2: Express your feelings freely through drawing",
        "Step 3: Add highlights of hope and positivity",
        "Step 4: Complete your healing artwork"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 深色星空背景
                Color(red: 0.05, green: 0.05, blue: 0.15)
                    .edgesIgnoringSafeArea(.all)
                
                // 星空粒子效果
                EmotionParticleView()
                    .opacity(0.8)
                
                HStack(spacing: 0) {
                    // Drawing Tools
                    DrawingToolbar(
                        selectedColor: $viewModel.selectedColor,
                        brushSize: $brushSize,
                        selectedTool: $selectedTool
                    )
                    .padding(.leading, 20)
                    
                    // Canvas Area
                    ZStack {
                        // 黑色绘画板背景
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 10)
                        
                        CanvasView(
                            canvasView: $canvasView,
                            tool: DrawingTools.getPKTool(tool: selectedTool, color: viewModel.selectedColor, size: brushSize)
                        )
                        .padding(2)
                        .alert("Color Meaning", isPresented: $showColorMeaning) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(viewModel.selectedColor.emotionalMeaning)
                        }
                        .alert("Undo Drawing", isPresented: $showUndoAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Undo", role: .destructive) {
                                canvasView.undoManager?.undo()
                            }
                        } message: {
                            Text("Do you want to undo your last drawing?")
                        }
                        .alert("Complete Artwork", isPresented: $showCompleteAlert) {
                            Button("Keep Drawing", role: .cancel) { }
                            Button("Complete", role: .none) {
                                // 保存作品并返回
                                dismiss()
                            }
                        } message: {
                            Text("Would you like to complete your healing artwork?")
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
                            
                            // Step Navigation
                            VStack(spacing: 16) {
                                Text(steps[currentStep - 1])
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                
                                // 步骤导航按钮
                                HStack(spacing: 20) {
                                    if currentStep > 1 {
                                        Button(action: {
                                            withAnimation {
                                                currentStep -= 1
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "chevron.left")
                                                Text("Previous")
                                            }
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(10)
                                        }
                                    }
                                    
                                    if currentStep < steps.count {
                                        Button(action: {
                                            withAnimation {
                                                currentStep += 1
                                            }
                                        }) {
                                            HStack {
                                                Text("Next")
                                                Image(systemName: "chevron.right")
                                            }
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(10)
                                        }
                                    } else {
                                        Button(action: {
                                            showCompleteAlert = true
                                        }) {
                                            HStack {
                                                Image(systemName: "checkmark")
                                                Text("Complete")
                                            }
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.white)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// End of file