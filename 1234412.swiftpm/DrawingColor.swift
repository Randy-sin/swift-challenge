import SwiftUI

enum DrawingColor: String, CaseIterable, Identifiable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple
    case white
    case black
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .red:
            return Color(red: 0.9, green: 0.3, blue: 0.3)
        case .orange:
            return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .yellow:
            return Color(red: 1.0, green: 0.8, blue: 0.3)
        case .green:
            return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .blue:
            return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .purple:
            return Color(red: 0.7, green: 0.4, blue: 0.9)
        case .white:
            return .white
        case .black:
            return .black
        }
    }
    
    var emotionalMeaning: String {
        switch self {
        case .red:
            return "Passion and Energy"
        case .orange:
            return "Joy and Creativity"
        case .yellow:
            return "Hope and Optimism"
        case .green:
            return "Growth and Healing"
        case .blue:
            return "Peace and Calmness"
        case .purple:
            return "Wisdom and Spirituality"
        case .white:
            return "Purity and Light"
        case .black:
            return "Strength and Protection"
        }
    }
} 