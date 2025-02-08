import SwiftUI
import PencilKit

enum DrawingTool {
    case pen
    case pencil
    case marker
    case eraser
    
    var image: String {
        switch self {
        case .pen: return "pencil.tip"
        case .pencil: return "pencil"
        case .marker: return "highlighter"
        case .eraser: return "eraser"
        }
    }
    
    var tool: PKTool {
        switch self {
        case .pen:
            return PKInkingTool(.pen)
        case .pencil:
            return PKInkingTool(.pencil)
        case .marker:
            return PKInkingTool(.marker)
        case .eraser:
            return PKEraserTool(.bitmap)
        }
    }
}

struct DrawingTools {
    static let brushSizes: [CGFloat] = [5, 10, 15, 20, 25]
    
    static func getPKTool(tool: DrawingTool, color: DrawingColor, size: CGFloat) -> PKTool {
        if case .eraser = tool {
            return PKEraserTool(.bitmap, width: size)
        }
        
        let pkTool: PKInkingTool
        switch tool {
        case .pen:
            pkTool = PKInkingTool(.pen, color: UIColor(color.color), width: size)
        case .pencil:
            pkTool = PKInkingTool(.pencil, color: UIColor(color.color), width: size)
        case .marker:
            pkTool = PKInkingTool(.marker, color: UIColor(color.color), width: size)
        default:
            pkTool = PKInkingTool(.pen, color: UIColor(color.color), width: size)
        }
        return pkTool
    }
}

struct ToolButton: View {
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: tool.image)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.white.opacity(0.3) : Color.clear)
                .cornerRadius(10)
        }
    }
}

struct BrushSizeButton: View {
    let size: CGFloat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white)
                .frame(width: size * 1.5, height: size * 1.5)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                        .padding(4)
                )
                .shadow(color: .black.opacity(0.2), radius: isSelected ? 5 : 2)
        }
    }
}

struct ColorButton: View {
    let color: DrawingColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )
                    .shadow(color: color.color.opacity(0.5), radius: isSelected ? 10 : 5)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

struct DrawingToolbar: View {
    @Binding var selectedColor: DrawingColor
    @Binding var brushSize: CGFloat
    @Binding var selectedTool: DrawingTool
    let colors: [DrawingColor] = DrawingColor.allCases
    
    var body: some View {
        VStack(spacing: 20) {
            // 工具选择
            VStack(spacing: 12) {
                ForEach([DrawingTool.pen, .pencil, .marker, .eraser], id: \.self) { tool in
                    ToolButton(
                        tool: tool,
                        isSelected: selectedTool == tool,
                        action: { selectedTool = tool }
                    )
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
                .frame(width: 30)
            
            // 颜色选择
            VStack(spacing: 12) {
                ForEach(colors) { color in
                    ColorButton(
                        color: color,
                        isSelected: selectedColor == color,
                        action: { selectedColor = color }
                    )
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
                .frame(width: 30)
            
            // 笔刷大小选择
            VStack(spacing: 12) {
                ForEach(DrawingTools.brushSizes, id: \.self) { size in
                    BrushSizeButton(
                        size: size,
                        isSelected: brushSize == size,
                        action: { brushSize = size }
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.6))
                .background(.ultraThinMaterial)
        )
        .cornerRadius(20)
    }
} 