import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var playerData: PlayerData
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var selectedType: LeaderboardType = .coins
    @State private var entries: [LeaderboardEntry] = []
    @State private var appearAnimation = false

    private var isIPad: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isIPad ? 700 : .infinity }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Leaderboard type picker
                typeSelector
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // Entries list
                if entries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Top 3 podium
                            if entries.count >= 3 {
                                podiumView
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                    .padding(.bottom, 16)
                            }

                            // Ranked list
                            VStack(spacing: 8) {
                                let startIndex = entries.count >= 3 ? 3 : 0
                                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                    if index >= startIndex {
                                        leaderboardRow(entry: entry, rank: index + 1)
                                            .opacity(appearAnimation ? 1 : 0)
                                            .offset(y: appearAnimation ? 0 : 10)
                                            .animation(
                                                .easeOut(duration: 0.3).delay(Double(index - startIndex) * 0.04),
                                                value: appearAnimation
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                        .frame(maxWidth: contentMaxWidth)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .background(AppTheme.bg.ignoresSafeArea())
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(6)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                refreshEntries()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        appearAnimation = true
                    }
                }
            }
            .onChange(of: selectedType) { _ in
                appearAnimation = false
                refreshEntries()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        appearAnimation = true
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Type Selector

    private var typeSelector: some View {
        HStack(spacing: 6) {
            ForEach(LeaderboardType.allCases) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = type
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: type.icon)
                            .font(.system(size: isIPad ? 14 : 12))
                        Text(type.rawValue)
                            .font(.system(size: isIPad ? 14 : 11, weight: .bold))
                    }
                    .padding(.horizontal, isIPad ? 14 : 10)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedType == type
                                  ? Color(hex: type.color).opacity(0.3)
                                  : AppTheme.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedType == type
                                    ? Color(hex: type.color)
                                    : Color.clear, lineWidth: 2)
                    )
                    .foregroundColor(selectedType == type ? Color(hex: type.color) : .white.opacity(0.5))
                }
            }
        }
    }

    // MARK: - Podium (Top 3)

    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: isIPad ? 16 : 10) {
            if entries.count >= 2 {
                podiumCard(entry: entries[1], rank: 2, height: isIPad ? 130 : 110)
            }
            if entries.count >= 1 {
                podiumCard(entry: entries[0], rank: 1, height: isIPad ? 160 : 140)
            }
            if entries.count >= 3 {
                podiumCard(entry: entries[2], rank: 3, height: isIPad ? 110 : 90)
            }
        }
    }

    private func podiumCard(entry: LeaderboardEntry, rank: Int, height: CGFloat) -> some View {
        VStack(spacing: 6) {
            // Medal
            Text(medalEmoji(for: rank))
                .font(.system(size: rank == 1 ? 36 : 28))

            // Avatar
            Text(entry.avatar)
                .font(.system(size: rank == 1 ? 36 : 28))

            // Name
            Text(entry.playerName)
                .font(.system(size: isIPad ? 14 : 12, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)

            // Value
            Text(selectedType.value(for: entry))
                .font(.system(size: isIPad ? 18 : 16, weight: .black))
                .foregroundColor(Color(hex: selectedType.color))

            // Date
            Text(shortDate(entry.date))
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            rank == 1 ? Color(hex: "FFD700").opacity(0.4)
                            : rank == 2 ? Color(hex: "C0C0C0").opacity(0.3)
                            : Color(hex: "CD7F32").opacity(0.3),
                            lineWidth: rank == 1 ? 2 : 1
                        )
                )
        )
        .overlay(
            rank == 1 ?
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "FFD700").opacity(0.05))
            : nil
        )
    }

    // MARK: - Row

    private func leaderboardRow(entry: LeaderboardEntry, rank: Int) -> some View {
        let isCurrentPlayer = entry.playerName == playerData.username
            && entry.avatar == playerData.selectedAvatar

        return HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: isIPad ? 16 : 14, weight: .bold, design: .monospaced))
                .foregroundColor(rankColor(rank))
                .frame(width: isIPad ? 48 : 40, alignment: .center)

            // Avatar
            Text(entry.avatar)
                .font(.system(size: isIPad ? 28 : 24))

            // Name + date
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.playerName)
                    .font(.system(size: isIPad ? 16 : 14, weight: .semibold))
                    .foregroundColor(isCurrentPlayer ? Color(hex: "4CC9F0") : .white)
                    .lineLimit(1)
                Text(shortDate(entry.date))
                    .font(.system(size: isIPad ? 12 : 10))
                    .foregroundColor(.white.opacity(0.3))
            }

            Spacer()

            // Value
            Text(selectedType.value(for: entry))
                .font(.system(size: isIPad ? 20 : 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: selectedType.color))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCurrentPlayer
                      ? Color(hex: "4CC9F0").opacity(0.1)
                      : AppTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCurrentPlayer
                        ? Color(hex: "4CC9F0").opacity(0.3)
                        : Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🏆")
                .font(.system(size: 64))
            Text("No Games Yet!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text("Play a game to see your scores\non the leaderboard!")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func refreshEntries() {
        entries = LeaderboardService.shared.topEntries(for: selectedType)
    }

    private func medalEmoji(for rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: "FFD700")
        case 2: return Color(hex: "C0C0C0")
        case 3: return Color(hex: "CD7F32")
        default: return .white.opacity(0.4)
        }
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today' h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: date)
    }
}
