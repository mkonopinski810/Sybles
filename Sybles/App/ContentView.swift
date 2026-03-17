import SwiftUI

struct ContentView: View {
    @EnvironmentObject var playerData: PlayerData
    @State private var selectedTab: Tab = .home
    @Environment(\.horizontalSizeClass) var sizeClass

    enum Tab: String, CaseIterable, Hashable {
        case home, shop, sets, profile

        var icon: String {
            switch self {
            case .home: return "gamecontroller.fill"
            case .shop: return "cart.fill"
            case .sets: return "book.fill"
            case .profile: return "person.fill"
            }
        }

        var label: String {
            switch self {
            case .home: return "Play"
            case .shop: return "Shop"
            case .sets: return "Questions"
            case .profile: return "Profile"
            }
        }
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .background(AppTheme.bg.ignoresSafeArea())
    }

    // MARK: - iPad: Sidebar + Detail

    private var iPadLayout: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(spacing: 4) {
                Text("Sybles")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                                .frame(width: 28)
                            Text(tab.label)
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTab == tab
                                      ? Color(hex: "4CC9F0").opacity(0.2)
                                      : Color.clear)
                        )
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                    }
                    .padding(.horizontal, 12)
                }

                Spacer()
            }
            .frame(width: 220)
            .background(AppTheme.card)

            // Detail
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - iPhone: Custom bottom tab bar

    private var iPhoneLayout: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 80)

            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: selectedTab == tab ? .bold : .regular))
                                .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                            Text(tab.label)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.card)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .shop:
            ShopView()
        case .sets:
            QuestionSetsView()
        case .profile:
            ProfileView()
        }
    }
}
