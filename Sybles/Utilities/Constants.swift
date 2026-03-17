import SwiftUI

enum AppTheme {
    // Current theme from UserDefaults — used by all views
    static var current: String {
        UserDefaults.standard.string(forKey: "selectedTheme") ?? "default"
    }

    static var bg: Color { backgroundColor(for: current) }
    static var card: Color { cardBackground(for: current) }
    static var accent: Color { accentColor(for: current) }

    static func backgroundColor(for theme: String) -> Color {
        switch theme {
        case "ocean": return Color(hex: "0a1628")
        case "forest": return Color(hex: "0a1a0a")
        case "sunset": return Color(hex: "1a0f0a")
        case "galaxy": return Color(hex: "0f0a1a")
        case "neon": return Color(hex: "1a0a1a")
        default: return Color(hex: "0f0f23")
        }
    }

    static func accentColor(for theme: String) -> Color {
        switch theme {
        case "ocean": return Color(hex: "4CC9F0")
        case "forest": return Color(hex: "06D6A0")
        case "sunset": return Color(hex: "F77F00")
        case "galaxy": return Color(hex: "7209B7")
        case "neon": return Color(hex: "F72585")
        default: return Color(hex: "4CC9F0")
        }
    }

    static func cardBackground(for theme: String) -> Color {
        switch theme {
        case "ocean": return Color(hex: "162447")
        case "forest": return Color(hex: "1a2e1a")
        case "sunset": return Color(hex: "2e1a0a")
        case "galaxy": return Color(hex: "1a0a2e")
        case "neon": return Color(hex: "2e0a2e")
        default: return Color(hex: "1a1a2e")
        }
    }
}

enum GameConstants {
    static let baseCoinsPerCorrect = 10
    static let streakBonusPerLevel = 5
    static let timedModeDuration: TimeInterval = 60
    static let questionTimeLimit: TimeInterval = 15
    static let maxStreakMultiplier = 10
    static let xpPerCorrect = 10
    static let xpPerGame = 25
}
