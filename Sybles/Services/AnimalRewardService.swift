import Foundation

struct AnimalRewardService {

    /// Roll for an animal reward after a game.
    /// Returns nil if no animal earned, or the animal they got.
    static func rollForAnimal(accuracy: Double, streak: Int, ownedAnimals: [String]) -> CollectibleAnimal? {
        // Calculate earn chance
        var chance: Double = 0.30
        if accuracy >= 80 { chance += 0.20 }
        if streak >= 5 { chance += 0.10 }

        // Roll the dice
        guard Double.random(in: 0...1) < chance else { return nil }

        // Rarity weights
        var weights: [CollectibleAnimal.Rarity: Double] = [
            .common: 60,
            .rare: 25,
            .epic: 12,
            .legendary: 3,
        ]

        // Bump rare+ chances for high accuracy
        if accuracy >= 90 {
            weights[.common] = 40
            weights[.rare] = 35
            weights[.epic] = 18
            weights[.legendary] = 7
        }

        // Filter out fully-owned rarities and redistribute
        let ownedSet = Set(ownedAnimals)
        var availableByRarity: [CollectibleAnimal.Rarity: [CollectibleAnimal]] = [:]
        for rarity in CollectibleAnimal.Rarity.allCases {
            let available = AnimalCatalog.animals(for: rarity).filter { !ownedSet.contains($0.id) }
            if available.isEmpty {
                weights[rarity] = 0
            } else {
                availableByRarity[rarity] = available
            }
        }

        let totalWeight = weights.values.reduce(0, +)
        guard totalWeight > 0 else { return nil } // All animals owned

        // Pick rarity
        let roll = Double.random(in: 0..<totalWeight)
        var cumulative: Double = 0
        var chosenRarity: CollectibleAnimal.Rarity = .common

        for rarity in CollectibleAnimal.Rarity.allCases {
            cumulative += weights[rarity] ?? 0
            if roll < cumulative {
                chosenRarity = rarity
                break
            }
        }

        // Pick random animal from chosen rarity
        guard let available = availableByRarity[chosenRarity], !available.isEmpty else {
            // Fallback: pick from any available rarity
            let allAvailable = availableByRarity.values.flatMap { $0 }
            return allAvailable.randomElement()
        }

        return available.randomElement()
    }
}
