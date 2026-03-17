import SwiftUI

struct ShopView: View {
    @EnvironmentObject var playerData: PlayerData
    @StateObject private var shopVM = ShopViewModel()
    @State private var selectedCategory: ShopItem.Category = .powerUp
    @Environment(\.horizontalSizeClass) var sizeClass

    private var isIPad: Bool { sizeClass == .regular }

    private var gridColumns: [GridItem] {
        if isIPad {
            return [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        } else {
            return [GridItem(.flexible()), GridItem(.flexible())]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Shop")
                            .font(.system(size: isIPad ? 34 : 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Spend your hard-earned coins!")
                            .font(.system(size: isIPad ? 16 : 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    CurrencyBadge(coins: playerData.coins)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Category tabs
                HStack(spacing: 8) {
                    ForEach(ShopItem.Category.allCases, id: \.self) { category in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = category
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: isIPad ? 16 : 14))
                                Text(category.rawValue)
                                    .font(.system(size: isIPad ? 15 : 13, weight: .semibold))
                            }
                            .padding(.horizontal, isIPad ? 20 : 14)
                            .padding(.vertical, isIPad ? 12 : 10)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == category
                                          ? Color(hex: "4CC9F0")
                                          : AppTheme.card)
                            )
                            .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Purchase message
                if let msg = shopVM.purchaseMessage {
                    Text(msg)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "FFD700"))
                        .transition(.scale)
                }

                // Items grid — 4 columns on iPad, 2 on iPhone
                let items = itemsForCategory(selectedCategory)
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(items) { item in
                        ShopItemCard(item: item, shopVM: shopVM, playerData: playerData)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .frame(maxWidth: isIPad ? 900 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.bg.ignoresSafeArea())
    }

    private func itemsForCategory(_ category: ShopItem.Category) -> [ShopItem] {
        switch category {
        case .powerUp: return ShopCatalog.powerUps
        case .avatar: return ShopCatalog.avatars
        case .theme: return ShopCatalog.themes
        }
    }
}

struct ShopItemCard: View {
    let item: ShopItem
    @ObservedObject var shopVM: ShopViewModel
    @ObservedObject var playerData: PlayerData

    var isOwned: Bool {
        shopVM.isOwned(item: item, playerData: playerData)
    }

    var isEquipped: Bool {
        (item.category == .avatar && playerData.selectedAvatar == item.value) ||
        (item.category == .theme && playerData.selectedTheme == item.value)
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(item.icon)
                .font(.system(size: 40))

            Text(item.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

            Text(item.description)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)

            if isEquipped {
                Text("EQUIPPED")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "06D6A0"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "06D6A0").opacity(0.2))
                    .clipShape(Capsule())
            } else if isOwned {
                Button {
                    if item.category == .avatar {
                        shopVM.equipAvatar(item.value, playerData: playerData)
                    } else if item.category == .theme {
                        shopVM.equipTheme(item.value, playerData: playerData)
                    }
                } label: {
                    Text("EQUIP")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "4CC9F0"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "4CC9F0").opacity(0.2))
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    _ = shopVM.purchase(item: item, playerData: playerData)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("\(item.price)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(playerData.coins >= item.price
                                  ? Color(hex: "4CC9F0")
                                  : Color.gray.opacity(0.3))
                    )
                }
                .disabled(playerData.coins < item.price)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isEquipped ? Color(hex: "06D6A0").opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
