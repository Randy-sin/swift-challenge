import SwiftUI
import SpriteKit
import PencilKit

struct SceneMenuView: View {
    @StateObject private var progressViewModel = PlanetProgressViewModel()
    @StateObject private var artisticViewModel = ArtisticPlanetViewModel()
    
    @State private var selectedScene: Int? = nil
    @State private var showSmileDetection = false
    @State private var showVenusGuide = false
    @State private var showArtisticGuide = false
    @State private var showArtisticPlanet = false
    @State private var showOceanusGuide = false
    @State private var showOceanusAR = false
    @State private var showPsycheDialogue = false
    @State private var showAndromedaGuide = false
    @State private var showEndingCredits = false
    
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
                .edgesIgnoringSafeArea(.all)
            
            // 主要内容
            VStack(spacing: 40) {
                ZStack {
                    // 标题区域
                    if progressViewModel.isPlanetCompleted(.andromeda) {
                        HStack(spacing: 24) {
                            // Finish 按钮
                            Button(action: {
                                showEndingCredits = true
                            }) {
                                Text("Journey's End")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.85, blue: 0.4),
                                                Color(red: 1.0, green: 0.7, blue: 0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3).opacity(0.5), radius: 10, x: 0, y: 5)
                            }
                            .fullScreenCover(isPresented: $showEndingCredits) {
                                JourneyEndingView()
                            }

                            // 标题和副标题
                            VStack(spacing: 8) {
                                Text("EmotionGalaxy Journey Complete")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .tracking(0.5)
                                    .multilineTextAlignment(.center)
                                
                                Text("Your emotional odyssey through the cosmos has reached its zenith")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // 占位视图，保持布局平衡
                            Color.clear
                                .frame(width: 140)
                        }
                    } else {
                        Text("Choose Your Journey")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    // 右侧按钮组
                    HStack {
                        Spacer()
                        HStack(spacing: 15) {
                            // 音乐控制按钮
                            AudioPlayerView()
                            
                            // 设置按钮
                            Menu {
                                Button(action: {
                                    progressViewModel.resetAllPlanets()
                                }) {
                                    Label("Reset Journey", systemImage: "arrow.counterclockwise")
                                        .foregroundColor(.white)
                                }
                                
                                Menu("Unlock Celestial Paths") {
                                    ForEach(PlanetProgressViewModel.PlanetType.allCases, id: \.self) { planet in
                                        if !progressViewModel.isPlanetLocked(planet) {
                                            Button(action: {
                                                progressViewModel.unlockPlanetsAfter(planet)
                                            }) {
                                                Label("Beyond \(planet.name)", systemImage: "sparkles")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                
                // 场景网格
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 30),
                    GridItem(.flexible(), spacing: 30)
                ], spacing: 30) {
                    // Venus 星球
                    Button {
                        if !progressViewModel.isPlanetLocked(.venus) {
                            showVenusGuide = true
                        }
                    } label: {
                        SceneCard(
                            title: PlanetProgressViewModel.PlanetType.venus.name,
                            subtitle: "Let Your Smile Shine Like Venus",
                            description: "Transform your emotions through the brightest smile in our solar system",
                            isLocked: progressViewModel.isPlanetLocked(.venus),
                            unlockCondition: PlanetProgressViewModel.PlanetType.venus.unlockCondition,
                            gradientColors: [
                                Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.6),
                                Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.4),
                                Color.clear
                            ],
                            backgroundImage: "venusbg",
                            onTap: { showVenusGuide = true }
                        )
                    }
                    
                    // Artistic 星球
                    Button {
                        if !progressViewModel.isPlanetLocked(.artistic) {
                            showArtisticGuide = true
                        }
                    } label: {
                        SceneCard(
                            title: PlanetProgressViewModel.PlanetType.artistic.name,
                            subtitle: "Paint Your Emotions in Space",
                            description: "Create your own celestial world with colors of feelings",
                            isLocked: progressViewModel.isPlanetLocked(.artistic),
                            unlockCondition: PlanetProgressViewModel.PlanetType.artistic.unlockCondition,
                            gradientColors: [
                                Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.6),
                                Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.4),
                                Color.clear
                            ],
                            backgroundImage: "artisticplanet",
                            onTap: { showArtisticGuide = true }
                        )
                    }
                    
                    // Oceanus 星球
                    Button {
                        if !progressViewModel.isPlanetLocked(.oceanus) {
                            showOceanusGuide = true
                        }
                    } label: {
                        SceneCard(
                            title: PlanetProgressViewModel.PlanetType.oceanus.name,
                            subtitle: "Breathe with the Ocean",
                            description: "Discover inner peace through the rhythm of the waves",
                            isLocked: progressViewModel.isPlanetLocked(.oceanus),
                            unlockCondition: PlanetProgressViewModel.PlanetType.oceanus.unlockCondition,
                            gradientColors: [
                                Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.6),
                                Color(red: 0.1, green: 0.4, blue: 0.8).opacity(0.4),
                                Color.clear
                            ],
                            backgroundImage: "oceanusbg",
                            onTap: { showOceanusGuide = true }
                        )
                    }
                    
                    // Andromeda 星球
                    Button {
                        if !progressViewModel.isPlanetLocked(.andromeda) {
                            showAndromedaGuide = true
                        }
                    } label: {
                        SceneCard(
                            title: PlanetProgressViewModel.PlanetType.andromeda.name,
                            subtitle: "Journey Through the Stars",
                            description: "Share your thoughts with a caring celestial companion",
                            isLocked: progressViewModel.isPlanetLocked(.andromeda),
                            unlockCondition: PlanetProgressViewModel.PlanetType.andromeda.unlockCondition,
                            gradientColors: [
                                Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.6),
                                Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.4),
                                Color.clear
                            ],
                            backgroundImage: "Andromeda",
                            onTap: { showAndromedaGuide = true }
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 星球预览容器
                PlanetPreviewContainer()
                    .frame(height: 150)
                    .environmentObject(artisticViewModel)
                    .environmentObject(progressViewModel)
            }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showVenusGuide) {
            VenusGuideView(isShowingGuide: $showVenusGuide, startSmileDetection: {
                showVenusGuide = false
                showSmileDetection = true
            })
        }
        .fullScreenCover(isPresented: $showSmileDetection) {
            SmileDetectionView()
                .onDisappear {
                    // Venus 完成后标记为已完成并解锁 Artistic
                    progressViewModel.markPlanetAsCompleted(.venus)
                    AudioManager.shared.play()
                }
        }
        .fullScreenCover(isPresented: $showArtisticGuide) {
            ArtisticGuideView(isShowingGuide: $showArtisticGuide, startDrawing: {
                showArtisticGuide = false
                showArtisticPlanet = true
            })
        }
        .fullScreenCover(isPresented: $showArtisticPlanet) {
            ArtisticPlanetView()
                .environmentObject(artisticViewModel)
                .onDisappear {
                    // Artistic 完成后标记为已完成并解锁 Oceanus
                    progressViewModel.markPlanetAsCompleted(.artistic)
                }
        }
        .fullScreenCover(isPresented: $showOceanusGuide) {
            OceanusGuideView(isShowingGuide: $showOceanusGuide, startBreathing: {
                showOceanusGuide = false
                showOceanusAR = true
            })
        }
        .fullScreenCover(isPresented: $showOceanusAR) {
            OceanusARScene()
                .onDisappear {
                    // Oceanus 完成后标记为已完成并解锁 Andromeda
                    progressViewModel.markPlanetAsCompleted(.oceanus)
                }
        }
        .fullScreenCover(isPresented: $showAndromedaGuide) {
            AndromedaGuideView(isShowingGuide: $showAndromedaGuide, startChat: {
                showAndromedaGuide = false
                showPsycheDialogue = true
            })
        }
        .fullScreenCover(isPresented: $showPsycheDialogue) {
            PsycheDialogueView()
                .onDisappear {
                    // Andromeda 完成后标记为已完成
                    progressViewModel.markPlanetAsCompleted(.andromeda)
                }
        }
    }
}

#Preview {
    SceneMenuView()
}

// End of file
