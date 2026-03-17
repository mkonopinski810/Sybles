import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case classic = "Classic"
    case timed = "Timed"
    case streak = "Streak"

    var icon: String {
        switch self {
        case .classic: return "dollarsign.circle.fill"
        case .timed: return "timer"
        case .streak: return "flame.fill"
        }
    }

    var description: String {
        switch self {
        case .classic: return "Answer questions, earn coins, buy upgrades!"
        case .timed: return "Race the clock — earn as much as you can in 60 seconds!"
        case .streak: return "Build your streak for massive multipliers!"
        }
    }

    var color: String {
        switch self {
        case .classic: return "4CC9F0"
        case .timed: return "F72585"
        case .streak: return "F77F00"
        }
    }
}

struct GameResult {
    let mode: GameMode
    let score: Int
    let coinsEarned: Int
    let questionsAnswered: Int
    let correctAnswers: Int
    let bestStreak: Int
    let timePlayed: TimeInterval
}

struct PowerUpState {
    var multiplier: Int = 1
    var hasStreakShield: Bool = false
    var timeFreezeSeconds: Int = 0
    var hasDoubleDown: Bool = false
    var hasFiftyFifty: Bool = false
    var fiftyFiftyUsed: Bool = false

    mutating func reset() {
        multiplier = 1
        hasStreakShield = false
        timeFreezeSeconds = 0
        hasDoubleDown = false
        hasFiftyFifty = false
        fiftyFiftyUsed = false
    }
}
