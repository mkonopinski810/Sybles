import Foundation

class PlayerData: ObservableObject {
    @Published var username: String {
        didSet { save() }
    }
    @Published var coins: Int {
        didSet { save() }
    }
    @Published var totalEarned: Int {
        didSet { save() }
    }
    @Published var gamesPlayed: Int {
        didSet { save() }
    }
    @Published var questionsAnswered: Int {
        didSet { save() }
    }
    @Published var correctAnswers: Int {
        didSet { save() }
    }
    @Published var bestStreak: Int {
        didSet { save() }
    }
    @Published var selectedAvatar: String {
        didSet { save() }
    }
    @Published var selectedTheme: String {
        didSet { save() }
    }
    @Published var ownedAvatars: [String] {
        didSet { save() }
    }
    @Published var ownedThemes: [String] {
        didSet { save() }
    }
    @Published var level: Int {
        didSet { save() }
    }
    @Published var xp: Int {
        didSet { save() }
    }
    @Published var collectedAnimals: [String] {
        didSet { save() }
    }

    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered) * 100
    }

    var xpForNextLevel: Int {
        return level * 100 + 50
    }

    var xpProgress: Double {
        return Double(xp) / Double(xpForNextLevel)
    }

    init() {
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username") ?? "Player"
        self.coins = defaults.integer(forKey: "coins")
        self.totalEarned = defaults.integer(forKey: "totalEarned")
        self.gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        self.questionsAnswered = defaults.integer(forKey: "questionsAnswered")
        self.correctAnswers = defaults.integer(forKey: "correctAnswers")
        self.bestStreak = defaults.integer(forKey: "bestStreak")
        self.selectedAvatar = defaults.string(forKey: "selectedAvatar") ?? "🦊"
        self.selectedTheme = defaults.string(forKey: "selectedTheme") ?? "default"
        self.level = max(defaults.integer(forKey: "level"), 1)
        self.xp = defaults.integer(forKey: "xp")

        if let avatarData = defaults.data(forKey: "ownedAvatars"),
           let avatars = try? JSONDecoder().decode([String].self, from: avatarData) {
            self.ownedAvatars = avatars
        } else {
            self.ownedAvatars = ["🦊"]
        }

        if let themeData = defaults.data(forKey: "ownedThemes"),
           let themes = try? JSONDecoder().decode([String].self, from: themeData) {
            self.ownedThemes = themes
        } else {
            self.ownedThemes = ["default"]
        }

        if let animalData = defaults.data(forKey: "collectedAnimals"),
           let animals = try? JSONDecoder().decode([String].self, from: animalData) {
            self.collectedAnimals = animals
        } else {
            self.collectedAnimals = []
        }

        if coins == 0 && gamesPlayed == 0 {
            self.coins = 100 // Starting coins
        }

        // Register username for uniqueness tracking
        LeaderboardService.shared.registerUsername(self.username)
    }

    func addCoins(_ amount: Int) {
        coins += amount
        totalEarned += amount
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        return true
    }

    func addXP(_ amount: Int) {
        xp += amount
        while xp >= xpForNextLevel {
            xp -= xpForNextLevel
            level += 1
            addCoins(50) // Level up bonus
        }
    }

    func addAnimal(_ id: String) {
        guard !collectedAnimals.contains(id) else { return }
        collectedAnimals.append(id)
    }

    func hasAnimal(_ id: String) -> Bool {
        collectedAnimals.contains(id)
    }

    func recordAnswer(correct: Bool) {
        questionsAnswered += 1
        if correct {
            correctAnswers += 1
        }
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "username")
        defaults.set(coins, forKey: "coins")
        defaults.set(totalEarned, forKey: "totalEarned")
        defaults.set(gamesPlayed, forKey: "gamesPlayed")
        defaults.set(questionsAnswered, forKey: "questionsAnswered")
        defaults.set(correctAnswers, forKey: "correctAnswers")
        defaults.set(bestStreak, forKey: "bestStreak")
        defaults.set(selectedAvatar, forKey: "selectedAvatar")
        defaults.set(selectedTheme, forKey: "selectedTheme")
        defaults.set(level, forKey: "level")
        defaults.set(xp, forKey: "xp")

        if let avatarData = try? JSONEncoder().encode(ownedAvatars) {
            defaults.set(avatarData, forKey: "ownedAvatars")
        }
        if let themeData = try? JSONEncoder().encode(ownedThemes) {
            defaults.set(themeData, forKey: "ownedThemes")
        }
        if let animalData = try? JSONEncoder().encode(collectedAnimals) {
            defaults.set(animalData, forKey: "collectedAnimals")
        }
    }
}
