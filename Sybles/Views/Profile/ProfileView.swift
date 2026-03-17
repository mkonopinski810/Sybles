import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var playerData: PlayerData
    @State private var isEditingName = false
    @State private var editedName: String = ""
    @State private var nameError: String? = nil
    @Environment(\.horizontalSizeClass) var sizeClass

    private var isIPad: Bool { sizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: isIPad ? 28 : 20) {
                // Avatar & name
                VStack(spacing: 12) {
                    Text(playerData.selectedAvatar)
                        .font(.system(size: 72))

                    if isEditingName {
                        VStack(spacing: 6) {
                            HStack {
                                TextField("Username", text: $editedName)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(10)
                                    .background(AppTheme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(width: 200)
                                    .onChange(of: editedName) { _ in
                                        nameError = nil
                                    }

                                Button {
                                    let trimmed = editedName.trimmingCharacters(in: .whitespaces)
                                    if trimmed.isEmpty {
                                        nameError = "Name can't be empty"
                                    } else if LeaderboardService.shared.isUsernameTaken(trimmed, excluding: playerData.username) {
                                        nameError = "That name is already taken"
                                    } else {
                                        let oldName = playerData.username
                                        LeaderboardService.shared.unregisterUsername(oldName)
                                        playerData.username = trimmed
                                        LeaderboardService.shared.registerUsername(trimmed)
                                        isEditingName = false
                                        nameError = nil
                                    }
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "06D6A0"))
                                }
                            }
                            if let error = nameError {
                                Text(error)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(hex: "F72585"))
                            }
                        }
                    } else {
                        HStack(spacing: 8) {
                            Text(playerData.username)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Button {
                                editedName = playerData.username
                                isEditingName = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }

                    // Level
                    VStack(spacing: 4) {
                        Text("Level \(playerData.level)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "4CC9F0"))
                        ProgressView(value: playerData.xpProgress)
                            .tint(Color(hex: "4CC9F0"))
                            .frame(width: 150)
                        Text("\(playerData.xp)/\(playerData.xpForNextLevel) XP")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.top, 16)

                // Stats
                VStack(alignment: .leading, spacing: 12) {
                    Text("STATISTICS")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: isIPad ? 3 : 2), spacing: 12) {
                        ProfileStat(icon: "dollarsign.circle.fill", label: "Total Earned", value: "\(playerData.totalEarned)", color: "FFD700")
                        ProfileStat(icon: "gamecontroller.fill", label: "Games Played", value: "\(playerData.gamesPlayed)", color: "4CC9F0")
                        ProfileStat(icon: "questionmark.circle.fill", label: "Answered", value: "\(playerData.questionsAnswered)", color: "7209B7")
                        ProfileStat(icon: "checkmark.circle.fill", label: "Correct", value: "\(playerData.correctAnswers)", color: "06D6A0")
                        ProfileStat(icon: "target", label: "Accuracy", value: String(format: "%.1f%%", playerData.accuracy), color: "F77F00")
                        ProfileStat(icon: "flame.fill", label: "Best Streak", value: "\(playerData.bestStreak)", color: "F72585")
                        ProfileStat(icon: "pawprint.fill", label: "Animals", value: "\(playerData.collectedAnimals.count)/\(AnimalCatalog.all.count)", color: "F77F00")
                    }
                }
                .padding(.horizontal)

                // Owned avatars
                VStack(alignment: .leading, spacing: 12) {
                    Text("MY AVATARS")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: isIPad ? 8 : 5), spacing: 12) {
                        ForEach(playerData.ownedAvatars, id: \.self) { avatar in
                            Button {
                                playerData.selectedAvatar = avatar
                            } label: {
                                Text(avatar)
                                    .font(.system(size: 32))
                                    .frame(width: 56, height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(playerData.selectedAvatar == avatar
                                                  ? Color(hex: "4CC9F0").opacity(0.3)
                                                  : AppTheme.card)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(playerData.selectedAvatar == avatar
                                                    ? Color(hex: "4CC9F0")
                                                    : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .frame(maxWidth: isIPad ? 700 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.bg.ignoresSafeArea())
    }
}

struct ProfileStat: View {
    let icon: String
    let label: String
    let value: String
    let color: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: color))
                .frame(width: 36, height: 36)
                .background(Color(hex: color).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
