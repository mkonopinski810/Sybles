import Foundation

struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let playerName: String
    let avatar: String
    let score: Int
    let streak: Int
    let accuracy: Double // 0-100
    let gamesPlayed: Int
    let date: Date

    init(
        id: UUID = UUID(),
        playerName: String,
        avatar: String,
        score: Int,
        streak: Int,
        accuracy: Double,
        gamesPlayed: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.playerName = playerName
        self.avatar = avatar
        self.score = score
        self.streak = streak
        self.accuracy = accuracy
        self.gamesPlayed = gamesPlayed
        self.date = date
    }
}

enum LeaderboardType: String, CaseIterable, Identifiable {
    case coins = "Coins"
    case streak = "Streak"
    case accuracy = "Accuracy"
    case highScore = "High Score"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coins: return "dollarsign.circle.fill"
        case .streak: return "flame.fill"
        case .accuracy: return "target"
        case .highScore: return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .coins: return "FFD700"
        case .streak: return "F77F00"
        case .accuracy: return "06D6A0"
        case .highScore: return "F72585"
        }
    }

    func value(for entry: LeaderboardEntry) -> String {
        switch self {
        case .coins: return "\(entry.score)"
        case .streak: return "\(entry.streak)"
        case .accuracy: return String(format: "%.0f%%", entry.accuracy)
        case .highScore: return "\(entry.score)"
        }
    }

    func sortValue(for entry: LeaderboardEntry) -> Double {
        switch self {
        case .coins: return Double(entry.score)
        case .streak: return Double(entry.streak)
        case .accuracy: return entry.accuracy
        case .highScore: return Double(entry.score)
        }
    }
}
