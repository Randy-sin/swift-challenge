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
        VStack(alignment: .leading, spacing: 0) {  // 改为 spacing: 0
            Spacer().frame(height: 25)  // 增加顶部间距
            
            // 标题区域
            VStack(alignment: .leading, spacing: 12) {  // 增加间距
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 30)  // 添加水平内边距
            
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
            .padding(.horizontal, 30)  // 添加水平内边距
            .padding(.bottom, 25)  // 减少底部间距
        }
        .frame(width: 400, height: 180)
        .background(
            ZStack {
                if let bgImage = backgroundImage {
                    Image(bgImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 180)
                        .clipped()
                        .opacity(0.3)
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
    @State private var showOceanusGuide = false
    @State private var showOceanusAR = false
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
                                Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.6),
                                Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.4),
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
                                Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.6),
                                Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.4),
                                Color.clear
                            ],
                            backgroundImage: "artisticplanet"
                        )
                    }
                    
                    // 第三个场景：Oceanus
                    Button {
                        showOceanusGuide = true
                    } label: {
                        SceneCard(
                            title: "Oceanus",
                            subtitle: "Breathe with the Ocean",
                            description: "Discover inner peace through the rhythm of the waves",
                            isLocked: false,
                            gradientColors: [
                                Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.6),
                                Color(red: 0.1, green: 0.4, blue: 0.8).opacity(0.4),
                                Color.clear
                            ],
                            backgroundImage: "oceanusbg"
                        )
                    }
                    
                    // 第四个场景（待解锁）
                    SceneCard(
                        title: "Coming Soon",
                        subtitle: "Your next journey awaits",
                        description: "Complete previous journey to unlock",
                        isLocked: true,
                        gradientColors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.2),
                            Color.clear
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
            ArtisticPlanetView()
                .environmentObject(artisticViewModel)
        }
        .fullScreenCover(isPresented: $showOceanusGuide) {
            OceanusGuideView(isShowingGuide: $showOceanusGuide, startBreathing: {
                showOceanusGuide = false
                showOceanusAR = true
            })
        }
        .fullScreenCover(isPresented: $showOceanusAR) {
            OceanusARScene()
        }
    }
}

// End of file
