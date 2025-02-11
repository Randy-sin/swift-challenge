import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var tool: DrawingTool
    var color: DrawingColor
    var brushSize: CGFloat
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = getTool()
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = getTool()
    }
    
    private func getTool() -> PKTool {
        switch tool {
        case .pen:
            return PKInkingTool(.pen, color: getInkColor(), width: brushSize)
        case .pencil:
            return PKInkingTool(.marker, color: getInkColor(), width: brushSize)
        case .marker:
            return PKInkingTool(.marker, color: getInkColor(), width: brushSize)
        case .eraser:
            return PKEraserTool(.vector)
        }
    }
    
    private func getInkColor() -> UIColor {
        switch color {
        case .red:
            return UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0)
        case .orange:
            return UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        case .yellow:
            return UIColor(red: 0.95, green: 0.85, blue: 0.3, alpha: 1.0)
        case .green:
            return UIColor(red: 0.3, green: 0.85, blue: 0.3, alpha: 1.0)
        case .blue:
            return UIColor(red: 0.3, green: 0.6, blue: 0.95, alpha: 1.0)
        case .purple:
            return UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 1.0)
        case .white:
            return UIColor.white
        case .black:
            return UIColor.black
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // 只在绘画内容真正改变时才更新
            if canvasView.drawing != parent.canvasView.drawing {
                let strokes = canvasView.drawing.strokes.count
                let bounds = canvasView.drawing.bounds
                
                // 只有在有实际内容时才打印和更新
                if strokes > 0 && !bounds.isEmpty {
                    print("✏️ Drawing changed, strokes count: \(strokes)")
                    print("📐 Drawing bounds: \(bounds)")
                    
                    Task { @MainActor in
                        parent.canvasView.drawing = canvasView.drawing
                    }
                }
            }
        }
    }
} 