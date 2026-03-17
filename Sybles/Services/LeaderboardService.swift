import Foundation

class LeaderboardService {
    static let shared = LeaderboardService()

    private let storageKey = "leaderboardEntries"
    private let usernamesKey = "registeredUsernames"
    private let maxEntries = 100

    private init() {}

    // MARK: - Username Uniqueness

    func registerUsername(_ name: String) {
        var names = registeredUsernames()
        let lowered = name.lowercased()
        if !names.contains(lowered) {
            names.insert(lowered)
            UserDefaults.standard.set(Array(names), forKey: usernamesKey)
        }
    }

    func unregisterUsername(_ name: String) {
        var names = registeredUsernames()
        names.remove(name.lowercased())
        UserDefaults.standard.set(Array(names), forKey: usernamesKey)
    }

    func isUsernameTaken(_ name: String, excluding currentName: String? = nil) -> Bool {
        let lowered = name.lowercased()
        if let current = currentName?.lowercased(), lowered == current {
            return false
        }
        return registeredUsernames().contains(lowered)
    }

    private func registeredUsernames() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: usernamesKey) ?? []
        return Set(array)
    }

    // MARK: - Public API

    func addEntry(
        playerName: String,
        avatar: String,
        score: Int,
        streak: Int,
        accuracy: Double,
        gamesPlayed: Int
    ) {
        let entry = LeaderboardEntry(
            playerName: playerName,
            avatar: avatar,
            score: score,
            streak: streak,
            accuracy: accuracy,
            gamesPlayed: gamesPlayed
        )
        var entries = loadEntries()
        entries.append(entry)

        // Keep only the most recent entries if we exceed the limit
        if entries.count > maxEntries {
            entries.sort { $0.date > $1.date }
            entries = Array(entries.prefix(maxEntries))
        }

        saveEntries(entries)
    }

    func topEntries(for type: LeaderboardType, limit: Int = 50) -> [LeaderboardEntry] {
        let entries = loadEntries()
        let sorted = entries.sorted { type.sortValue(for: $0) > type.sortValue(for: $1) }
        return Array(sorted.prefix(limit))
    }

    func allEntries() -> [LeaderboardEntry] {
        return loadEntries()
    }

    func clearAll() {
        saveEntries([])
    }

    // MARK: - Persistence

    private func loadEntries() -> [LeaderboardEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([LeaderboardEntry].self, from: data)
        } catch {
            return []
        }
    }

    private func saveEntries(_ entries: [LeaderboardEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
