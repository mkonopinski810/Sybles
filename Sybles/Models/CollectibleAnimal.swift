import SwiftUI

struct CollectibleAnimal: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let rarity: Rarity
    let description: String

    enum Rarity: String, Codable, CaseIterable, Hashable {
        case common, rare, epic, legendary

        var color: String {
            switch self {
            case .common: return "9E9E9E"
            case .rare: return "4CC9F0"
            case .epic: return "7209B7"
            case .legendary: return "FFD700"
            }
        }

        var label: String {
            rawValue.uppercased()
        }
    }
}

struct AnimalCatalog {
    static let all: [CollectibleAnimal] = [
        // Common (~12)
        CollectibleAnimal(id: "puppy", name: "Puppy", emoji: "🐶", rarity: .common, description: "A loyal little pup who loves belly rubs and treats!"),
        CollectibleAnimal(id: "kitten", name: "Kitten", emoji: "🐱", rarity: .common, description: "Soft, fluffy, and always chasing laser dots!"),
        CollectibleAnimal(id: "bunny", name: "Bunny", emoji: "🐰", rarity: .common, description: "Hop hop hop! This bunny loves carrots and cuddles."),
        CollectibleAnimal(id: "hamster", name: "Hamster", emoji: "🐹", rarity: .common, description: "Tiny but mighty! Loves running on its wheel all night."),
        CollectibleAnimal(id: "chick", name: "Chick", emoji: "🐣", rarity: .common, description: "Just hatched and ready to explore the world!"),
        CollectibleAnimal(id: "turtle", name: "Turtle", emoji: "🐢", rarity: .common, description: "Slow and steady wins the race. Wise beyond its years!"),
        CollectibleAnimal(id: "fish", name: "Tropical Fish", emoji: "🐠", rarity: .common, description: "Swims in rainbow circles and loves bubbles!"),
        CollectibleAnimal(id: "frog", name: "Frog", emoji: "🐸", rarity: .common, description: "Ribbit! This cool frog hangs out on lily pads all day."),
        CollectibleAnimal(id: "mouse", name: "Mouse", emoji: "🐭", rarity: .common, description: "Sneaky and sweet — always finds the cheese!"),
        CollectibleAnimal(id: "duck", name: "Duck", emoji: "🦆", rarity: .common, description: "Quack quack! Splashes in puddles for fun."),
        CollectibleAnimal(id: "pig", name: "Piglet", emoji: "🐷", rarity: .common, description: "Oink! Rolls in mud and giggles all day long."),
        CollectibleAnimal(id: "cow", name: "Cow", emoji: "🐮", rarity: .common, description: "Moo! Gives the best milk and loves grassy fields."),

        // Rare (~8)
        CollectibleAnimal(id: "fox", name: "Fox", emoji: "🦊", rarity: .rare, description: "Clever and quick — the smartest animal in the forest!"),
        CollectibleAnimal(id: "panda", name: "Panda", emoji: "🐼", rarity: .rare, description: "Munches bamboo and does somersaults for fun!"),
        CollectibleAnimal(id: "koala", name: "Koala", emoji: "🐨", rarity: .rare, description: "Sleepy and cuddly — naps 22 hours a day!"),
        CollectibleAnimal(id: "penguin", name: "Penguin", emoji: "🐧", rarity: .rare, description: "Waddles on ice and slides on its belly. So cool!"),
        CollectibleAnimal(id: "owl", name: "Owl", emoji: "🦉", rarity: .rare, description: "The wisest bird! Stays up all night reading books."),
        CollectibleAnimal(id: "dolphin", name: "Dolphin", emoji: "🐬", rarity: .rare, description: "Jumps through waves and loves to play with friends!"),
        CollectibleAnimal(id: "horse", name: "Horse", emoji: "🐴", rarity: .rare, description: "Fast as the wind! Gallops across open meadows."),
        CollectibleAnimal(id: "butterfly", name: "Butterfly", emoji: "🦋", rarity: .rare, description: "Beautiful wings that shimmer in the sunlight!"),

        // Epic (~5)
        CollectibleAnimal(id: "lion", name: "Lion", emoji: "🦁", rarity: .epic, description: "The king of the jungle! Has the most amazing roar."),
        CollectibleAnimal(id: "wolf", name: "Wolf", emoji: "🐺", rarity: .epic, description: "Howls at the moon and leads the pack with courage!"),
        CollectibleAnimal(id: "eagle", name: "Eagle", emoji: "🦅", rarity: .epic, description: "Soars above the clouds with incredible speed!"),
        CollectibleAnimal(id: "octopus", name: "Octopus", emoji: "🐙", rarity: .epic, description: "Super smart with eight amazing arms! A true genius."),
        CollectibleAnimal(id: "peacock", name: "Peacock", emoji: "🦚", rarity: .epic, description: "The most dazzling feathers in the entire animal kingdom!"),

        // Legendary (~3)
        CollectibleAnimal(id: "dragon", name: "Dragon", emoji: "🐉", rarity: .legendary, description: "Breathes fire and guards treasure! The rarest of all!"),
        CollectibleAnimal(id: "unicorn", name: "Unicorn", emoji: "🦄", rarity: .legendary, description: "Pure magic! Grants wishes and sparkles wherever it goes."),
        CollectibleAnimal(id: "phoenix", name: "Phoenix", emoji: "🪶", rarity: .legendary, description: "Rises from the ashes in a blaze of glory! Immortal and legendary."),
    ]

    static func animal(for id: String) -> CollectibleAnimal? {
        all.first { $0.id == id }
    }

    static func animals(for rarity: CollectibleAnimal.Rarity) -> [CollectibleAnimal] {
        all.filter { $0.rarity == rarity }
    }
}
