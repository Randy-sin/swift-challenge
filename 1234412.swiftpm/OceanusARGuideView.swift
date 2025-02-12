import SwiftUI

struct OceanusARGuideView: View {
    @Binding var isShowingGuide: Bool
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // 图标
                Image(systemName: "iphone.rear.camera")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .symbolEffect(.bounce, options: .repeating)
                
                // 标题
                Text("扫描平面")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // 说明
                VStack(spacing: 20) {
                    guideItem(
                        icon: "arrow.left.and.right.circle",
                        text: "缓慢移动设备扫描周围环境"
                    )
                    
                    guideItem(
                        icon: "square.dashed",
                        text: "系统会自动检测平面区域"
                    )
                    
                    guideItem(
                        icon: "hand.tap",
                        text: "找到合适的位置后点击屏幕放置星球"
                    )
                }
                .padding(.vertical, 20)
                
                // 开始按钮
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowingGuide = false
                    }
                }) {
                    Text("开始体验")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 200, height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                }
            }
            .padding(30)
        }
    }
    
    private func guideItem(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40)
            
            Text(text)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OceanusARGuideView(isShowingGuide: .constant(true))
} 