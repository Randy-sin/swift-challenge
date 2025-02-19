import SwiftUI

struct GuidePageView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showLaunchScreen: Bool
    @State private var currentPage = 0
    @State private var startTransition = false
    
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
            
            // 粒子效果背景
            EmotionParticleView()
                .edgesIgnoringSafeArea(.all)
            
            // 主要内容
            TabView(selection: $currentPage) {
                // 第一页
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 60)
                    
                    Text("The Silent Crisis of Our Time")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("In our modern world, the state of mental health has reached a critical turning point. The numbers tell a story that can no longer be ignored: across the globe, one in every seven adolescents between 14 and 19 years old grapples with mental health conditions. Even more alarming is the fact that suicide has become the fourth leading cause of death among young people aged 15 to 29.")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Text("The shadow of depression looms over 5% of the world's adult population, while anxiety disorders affect more than 301 million people worldwide. These aren't just statistics – they represent real lives, real struggles, and real pain.")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Text("[World Health Organization, 2023]")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .italic()
                                .padding(.top, 8)
                            
                            Text("In this age of unprecedented pressure and relentless expectations, countless individuals find themselves adrift in the darkness of mental health struggles. Like lost stars in a vast universe, they search for even the faintest glimmer of hope, yearning for a way to navigate through their personal darkness toward a brighter tomorrow.")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.vertical, 24)
                    }
                    
                    Button(action: {
                        withAnimation {
                            currentPage = 1
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
                .tag(0)
                
                // 第二页
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 60)
                    
                    Text("Your Cosmic Journey Begins")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("Within the infinite expanse of space, EmotionGalaxy emerges as a beacon of hope, opening a gateway to emotional healing through the vastness of the cosmos. Like a distant nebula giving birth to new stars, we offer a space where healing and renewal become possible.")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Text("In this celestial sanctuary, you'll find yourself surrounded by tools and experiences designed to nurture your emotional well-being. Just as each star illuminates the darkness of space, each moment here illuminates a path toward inner strength and understanding. Our community stands ready to support you, like countless stars forming a brilliant constellation of hope.")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Text("As you embark on this interstellar journey, remember that every star you see represents a step toward healing, every constellation tells a story of recovery, and every nebula holds the promise of a new beginning. Here, among the stars, your journey to emotional well-being isn't just beginning – it's transforming into something beautiful, just like the cosmic dance of galaxies in the night sky.")
                                .font(.system(size: 24, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.vertical, 24)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            startTransition = true
                        }
                        // 直接关闭所有页面
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            dismiss()
                            showLaunchScreen = false
                        }
                    }) {
                        Text("Start Your Journey")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer()
                        .frame(height: 40)
                }
                .tag(1)
                .opacity(startTransition ? 0 : 1)
                .blur(radius: startTransition ? 20 : 0)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // 跳过按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            startTransition = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            dismiss()
                            showLaunchScreen = false
                        }
                    }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
            .opacity(startTransition ? 0 : 1)
            
            // 过渡效果遮罩
            Rectangle()
                .fill(.black)
                .opacity(startTransition ? 1 : 0)
                .ignoresSafeArea()
                .zIndex(1)
        }
        .preferredColorScheme(.dark)
    }
} 