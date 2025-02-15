import SwiftUI

struct RippleEffect: View {
    let progress: Double
    let color: Color
    let baseSize: CGFloat
    
    @State private var rippleScale: CGFloat = 1.0
    @State private var opacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // 多层波纹
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        color.opacity(opacity * (1 - Double(index) * 0.2)),
                        lineWidth: 1.5 - CGFloat(index) * 0.3
                    )
                    .frame(width: baseSize, height: baseSize)
                    .scaleEffect(rippleScale - CGFloat(index) * 0.1)
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            // 根据进度更新动画
            withAnimation(.easeInOut(duration: 0.5)) {
                rippleScale = 1.0 + CGFloat(newValue) * 1.5
                opacity = 0.8 * (1 - newValue)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
            .edgesIgnoringSafeArea(.all)
        
        RippleEffect(
            progress: 0.5,
            color: .blue,
            baseSize: 180
        )
    }
} 