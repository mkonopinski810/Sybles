import Foundation

struct ShopItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Int
    let icon: String
    let category: Category
    let value: String // avatar emoji, theme name, or power-up id

    enum Category: String, CaseIterable {
        case powerUp = "Power-Ups"
        case avatar = "Avatars"
        case theme = "Themes"

        var icon: String {
            switch self {
            case .powerUp: return "bolt.fill"
            case .avatar: return "face.smiling.fill"
            case .theme: return "paintpalette.fill"
            }
        }
    }
}

struct ShopCatalog {
    static let powerUps: [ShopItem] = [
        ShopItem(name: "2x Multiplier", description: "Double your earnings for one game", price: 200, icon: "2x", category: .powerUp, value: "multiplier_2x"),
        ShopItem(name: "5x Multiplier", description: "5x earnings for one game!", price: 500, icon: "5x", category: .powerUp, value: "multiplier_5x"),
        ShopItem(name: "Streak Shield", description: "Protect your streak from one wrong answer", price: 150, icon: "🛡️", category: .powerUp, value: "streak_shield"),
        ShopItem(name: "Time Freeze", description: "+15 seconds in timed mode", price: 100, icon: "❄️", category: .powerUp, value: "time_freeze"),
        ShopItem(name: "Double Down", description: "Risk it! Double or nothing on next question", price: 250, icon: "🎲", category: .powerUp, value: "double_down"),
        ShopItem(name: "50/50", description: "Remove two wrong answers", price: 175, icon: "✂️", category: .powerUp, value: "fifty_fifty"),
    ]

    static let avatars: [ShopItem] = [
        ShopItem(name: "Fox", description: "Default", price: 0, icon: "🦊", category: .avatar, value: "🦊"),
        ShopItem(name: "Dragon", description: "Breathe fire!", price: 300, icon: "🐉", category: .avatar, value: "🐉"),
        ShopItem(name: "Unicorn", description: "Magical!", price: 300, icon: "🦄", category: .avatar, value: "🦄"),
        ShopItem(name: "Robot", description: "Beep boop!", price: 500, icon: "🤖", category: .avatar, value: "🤖"),
        ShopItem(name: "Alien", description: "Out of this world", price: 500, icon: "👾", category: .avatar, value: "👾"),
        ShopItem(name: "Ninja", description: "Silent but deadly", price: 750, icon: "🥷", category: .avatar, value: "🥷"),
        ShopItem(name: "Wizard", description: "Master of knowledge", price: 1000, icon: "🧙", category: .avatar, value: "🧙"),
        ShopItem(name: "Astronaut", description: "To infinity!", price: 1000, icon: "🧑‍🚀", category: .avatar, value: "🧑‍🚀"),
        ShopItem(name: "Crown", description: "Quiz royalty", price: 2000, icon: "👑", category: .avatar, value: "👑"),
    ]

    static let themes: [ShopItem] = [
        ShopItem(name: "Default", description: "Classic dark theme", price: 0, icon: "🌙", category: .theme, value: "default"),
        ShopItem(name: "Ocean", description: "Deep blue vibes", price: 400, icon: "🌊", category: .theme, value: "ocean"),
        ShopItem(name: "Forest", description: "Nature feels", price: 400, icon: "🌲", category: .theme, value: "forest"),
        ShopItem(name: "Sunset", description: "Warm orange glow", price: 400, icon: "🌅", category: .theme, value: "sunset"),
        ShopItem(name: "Galaxy", description: "Cosmic purple", price: 600, icon: "🌌", category: .theme, value: "galaxy"),
        ShopItem(name: "Neon", description: "Electric pink", price: 800, icon: "💜", category: .theme, value: "neon"),
    ]
}
