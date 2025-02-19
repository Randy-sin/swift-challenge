import SwiftUI

struct SceneCard: View {
    let title: String
    let subtitle: String
    let description: String
    let isLocked: Bool
    let unlockCondition: String
    let gradientColors: [Color]
    let backgroundImage: String?
    let onTap: () -> Void
    
    @State private var showUnlockHint = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 25)
            
            // 标题区域
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(isLocked ? unlockCondition : description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
            }
            .padding(.horizontal, 30)
            
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
            .padding(.horizontal, 30)
            .padding(.bottom, 25)
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
                            colors: isLocked ? 
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.2), Color.clear] :
                                gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.plusLighter)
            }
        )
        .opacity(isLocked ? 0.7 : 1.0)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .overlay(
            Group {
                if showUnlockHint && isLocked {
                    UnlockHintView(message: unlockCondition) {
                        showUnlockHint = false
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .onTapGesture {
            if isLocked {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showUnlockHint = true
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onTap()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}

// 解锁提示视图
struct UnlockHintView: View {
    let message: String
    let onDismiss: () -> Void
    @State private var isAppearing = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 图标和文字组合
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .scaleEffect(isAppearing ? 1 : 0.8)
                
                VStack(spacing: 4) {
                    Text("Locked")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            .offset(y: isAppearing ? 0 : 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .opacity(isAppearing ? 1 : 0)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                isAppearing = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onDismiss()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAppearing = true
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Venus 星球
            SceneCard(
                title: "Venus",
                subtitle: "Let Your Smile Shine Like Venus",
                description: "Transform your emotions through the brightest smile in our solar system",
                isLocked: false,
                unlockCondition: "Start your journey here",
                gradientColors: [
                    Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.6),
                    Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.4),
                    Color.clear
                ],
                backgroundImage: "venusbg",
                onTap: {}
            )
            
            // Artistic 星球
            SceneCard(
                title: "Artistic",
                subtitle: "Paint Your Emotions in Space",
                description: "Create your own celestial world with colors of feelings",
                isLocked: true,
                unlockCondition: "Complete Venus journey to unlock",
                gradientColors: [
                    Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.6),
                    Color(red: 0.2, green: 0.6, blue: 0.8).opacity(0.4),
                    Color.clear
                ],
                backgroundImage: "artisticplanet",
                onTap: {}
            )
            
            // Oceanus 星球
            SceneCard(
                title: "Oceanus",
                subtitle: "Breathe with the Ocean",
                description: "Discover inner peace through the rhythm of the waves",
                isLocked: true,
                unlockCondition: "Complete Artistic journey to unlock",
                gradientColors: [
                    Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.6),
                    Color(red: 0.1, green: 0.4, blue: 0.8).opacity(0.4),
                    Color.clear
                ],
                backgroundImage: "oceanusbg",
                onTap: {}
            )
            
            // Andromeda 星球
            SceneCard(
                title: "Andromeda",
                subtitle: "Journey Through the Stars",
                description: "Share your thoughts with a caring celestial companion",
                isLocked: true,
                unlockCondition: "Complete Oceanus journey to unlock",
                gradientColors: [
                    Color(red: 0.6, green: 0.4, blue: 0.8).opacity(0.6),
                    Color(red: 0.4, green: 0.2, blue: 0.6).opacity(0.4),
                    Color.clear
                ],
                backgroundImage: "Andromeda",
                onTap: {}
            )
        }
        .padding()
    }
    .background(Color.black)
} 