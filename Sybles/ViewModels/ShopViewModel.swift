import SwiftUI

class ShopViewModel: ObservableObject {
    @Published var selectedCategory: ShopItem.Category = .powerUp
    @Published var purchaseMessage: String? = nil
    @Published var activePowerUps: [String] = [] {
        didSet { savePowerUps() }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "activePowerUps"),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            activePowerUps = decoded
        }
    }

    private func savePowerUps() {
        if let data = try? JSONEncoder().encode(activePowerUps) {
            UserDefaults.standard.set(data, forKey: "activePowerUps")
        }
    }

    func purchase(item: ShopItem, playerData: PlayerData) -> Bool {
        // Check if already owned (avatars/themes)
        if item.category == .avatar && playerData.ownedAvatars.contains(item.value) {
            purchaseMessage = "Already owned!"
            clearMessage()
            return false
        }
        if item.category == .theme && playerData.ownedThemes.contains(item.value) {
            purchaseMessage = "Already owned!"
            clearMessage()
            return false
        }

        guard playerData.spendCoins(item.price) else {
            purchaseMessage = "Not enough coins!"
            clearMessage()
            return false
        }

        switch item.category {
        case .avatar:
            playerData.ownedAvatars.append(item.value)
            playerData.selectedAvatar = item.value
            purchaseMessage = "Avatar equipped! \(item.icon)"
        case .theme:
            playerData.ownedThemes.append(item.value)
            playerData.selectedTheme = item.value
            purchaseMessage = "Theme applied! \(item.icon)"
        case .powerUp:
            activePowerUps.append(item.value)
            purchaseMessage = "Power-up ready! \(item.icon)"
        }

        clearMessage()
        return true
    }

    func equipAvatar(_ emoji: String, playerData: PlayerData) {
        guard playerData.ownedAvatars.contains(emoji) else { return }
        playerData.selectedAvatar = emoji
    }

    func equipTheme(_ theme: String, playerData: PlayerData) {
        guard playerData.ownedThemes.contains(theme) else { return }
        playerData.selectedTheme = theme
    }

    func isOwned(item: ShopItem, playerData: PlayerData) -> Bool {
        switch item.category {
        case .avatar: return playerData.ownedAvatars.contains(item.value)
        case .theme: return playerData.ownedThemes.contains(item.value)
        case .powerUp: return false
        }
    }

    func consumePowerUp(_ id: String) {
        if let idx = activePowerUps.firstIndex(of: id) {
            activePowerUps.remove(at: idx)
        }
    }

    private func clearMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.purchaseMessage = nil
        }
    }
}
