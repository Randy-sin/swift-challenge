import SwiftUI

enum DrawingColor: String, CaseIterable, Identifiable {
    case red = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green = "Green"
    case blue = "Blue"
    case purple = "Purple"
    case white = "White"
    case black = "Black"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .red:
            return Color(red: 0.95, green: 0.3, blue: 0.3)
        case .orange:
            return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .yellow:
            return Color(red: 0.95, green: 0.85, blue: 0.3)
        case .green:
            return Color(red: 0.3, green: 0.85, blue: 0.3)
        case .blue:
            return Color(red: 0.3, green: 0.6, blue: 0.95)
        case .purple:
            return Color(red: 0.7, green: 0.4, blue: 0.9)
        case .white:
            return Color.white
        case .black:
            return Color.black
        }
    }
    
    var emotionalMeaning: String {
        switch self {
        case .red:
            return "Red represents passion, energy, and vitality. It symbolizes the warmth of life and the power of emotions."
        case .orange:
            return "Orange embodies creativity and joy. It brings warmth and enthusiasm to your artistic expression."
        case .yellow:
            return "Yellow radiates happiness and optimism. It's the color of sunlight and positive energy."
        case .green:
            return "Green symbolizes growth and harmony. It connects us with nature and brings a sense of peace."
        case .blue:
            return "Blue represents tranquility and depth. It's the color of the ocean and sky, bringing calmness to your art."
        case .purple:
            return "Purple signifies mystery and imagination. It adds a touch of magic and creativity to your drawing."
        case .white:
            return "White represents purity and possibility. It's like a fresh canvas waiting for your creativity."
        case .black:
            return "Black embodies strength and elegance. It adds depth and contrast to your artistic creation."
        }
    }
} 