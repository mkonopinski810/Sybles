import SwiftUI

struct HomeView: View {
    @EnvironmentObject var playerData: PlayerData
    @EnvironmentObject var questionStore: QuestionStore
    @StateObject private var shopVM = ShopViewModel()
    @State private var gameQuestions: [Question] = []
    @State private var gameMode: GameMode = .classic
    @State private var activeSheet: ActiveSheet? = nil
    @Environment(\.horizontalSizeClass) var sizeClass

    enum ActiveSheet: Identifiable {
        case setup(GameMode)
        case multiplayer
        case playing
        case leaderboard
        case animals

        var id: String {
            switch self {
            case .setup(let m): return "setup-\(m.rawValue)"
            case .multiplayer: return "multiplayer"
            case .playing: return "playing"
            case .leaderboard: return "leaderboard"
            case .animals: return "animals"
            }
        }
    }

    private var isIPad: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isIPad ? 700 : .infinity }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hey, \(playerData.username)!")
                                .font(.system(size: isIPad ? 34 : 28, weight: .bold))
                                .foregroundColor(.white)
                            Text("Ready to play?")
                                .font(.system(size: isIPad ? 18 : 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                        Button {
                            activeSheet = .animals
                        } label: {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "F77F00"))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "F77F00").opacity(0.15))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "F77F00").opacity(0.3), lineWidth: 1)
                                )
                        }
                        Button {
                            activeSheet = .leaderboard
                        } label: {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "FFD700"))
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "FFD700").opacity(0.15))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "FFD700").opacity(0.3), lineWidth: 1)
                                )
                        }
                        CurrencyBadge(coins: playerData.coins)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Level card
                    VStack(spacing: 8) {
                        HStack {
                            Text(playerData.selectedAvatar)
                                .font(.system(size: isIPad ? 56 : 40))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Level \(playerData.level)")
                                    .font(.system(size: isIPad ? 24 : 20, weight: .bold))
                                    .foregroundColor(.white)
                                ProgressView(value: playerData.xpProgress)
                                    .tint(Color(hex: "4CC9F0"))
                                Text("\(playerData.xp)/\(playerData.xpForNextLevel) XP")
                                    .font(.system(size: isIPad ? 14 : 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal)

                    // Game modes — grid on iPad, list on iPhone
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GAME MODES")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal)

                        if isIPad {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(GameMode.allCases, id: \.self) { mode in
                                    gameModeButton(mode)
                                }
                                multiplayerButton
                            }
                            .padding(.horizontal)
                        } else {
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                gameModeButton(mode)
                                    .padding(.horizontal)
                            }
                            multiplayerButton
                                .padding(.horizontal)
                        }
                    }

                    // Quick stats
                    let statColumns = isIPad
                        ? [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                        : [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: statColumns, spacing: 12) {
                        StatCard(title: "Games", value: "\(playerData.gamesPlayed)", icon: "gamecontroller.fill", color: "4CC9F0")
                        StatCard(title: "Accuracy", value: String(format: "%.0f%%", playerData.accuracy), icon: "target", color: "06D6A0")
                        StatCard(title: "Best Streak", value: "\(playerData.bestStreak)", icon: "flame.fill", color: "F77F00")
                        if isIPad {
                            StatCard(title: "Earned", value: "\(playerData.totalEarned)", icon: "dollarsign.circle.fill", color: "FFD700")
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.bg.ignoresSafeArea())
            .fullScreenCover(item: $activeSheet) { sheet in
                switch sheet {
                case .setup(let mode):
                    GameSetupView(mode: mode) { questions in
                        gameQuestions = questions
                        gameMode = mode
                        activeSheet = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            activeSheet = .playing
                        }
                    }
                    .environmentObject(questionStore)
                    .environmentObject(shopVM)
                case .multiplayer:
                    LobbyView()
                        .environmentObject(playerData)
                        .environmentObject(questionStore)
                case .playing:
                    GameView(mode: gameMode, questions: gameQuestions, shopVM: shopVM)
                        .environmentObject(playerData)
                case .leaderboard:
                    LeaderboardView()
                        .environmentObject(playerData)
                case .animals:
                    AnimalCollectionView()
                        .environmentObject(playerData)
                }
            }
        }
    }

    private func gameModeButton(_ mode: GameMode) -> some View {
        Button {
            activeSheet = .setup(mode)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: mode.color))
                    .frame(width: 50, height: 50)
                    .background(Color(hex: mode.color).opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(mode.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
            }
            .cardStyle()
        }
    }

    private var multiplayerButton: some View {
        Button {
            activeSheet = .multiplayer
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "06D6A0"))
                    .frame(width: 50, height: 50)
                    .background(Color(hex: "06D6A0").opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Multiplayer")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Challenge your friends nearby!")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
            }
            .cardStyle()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: color))
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

struct GameSetupView: View {
    let mode: GameMode
    let onStart: ([Question]) -> Void

    @EnvironmentObject var questionStore: QuestionStore
    @EnvironmentObject var shopVM: ShopViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedSubjects: Set<Question.Subject> = [.math]
    @State private var selectedDifficulty: Question.Difficulty = .medium

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Mode header
                    VStack(spacing: 8) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: mode.color))
                        Text(mode.rawValue)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text(mode.description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Subject selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SUBJECTS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Question.Subject.allCases.filter { $0 != .custom }, id: \.self) { subject in
                                Button {
                                    if selectedSubjects.contains(subject) {
                                        if selectedSubjects.count > 1 {
                                            selectedSubjects.remove(subject)
                                        }
                                    } else {
                                        selectedSubjects.insert(subject)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: subject.icon)
                                        Text(subject.rawValue)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedSubjects.contains(subject)
                                                  ? Color(hex: subject.color).opacity(0.3)
                                                  : AppTheme.card)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedSubjects.contains(subject)
                                                    ? Color(hex: subject.color)
                                                    : Color.clear, lineWidth: 2)
                                    )
                                    .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Difficulty selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DIFFICULTY")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))

                        HStack(spacing: 8) {
                            ForEach(Question.Difficulty.allCases, id: \.self) { diff in
                                Button {
                                    selectedDifficulty = diff
                                } label: {
                                    Text(diff.rawValue.capitalized)
                                        .font(.system(size: 14, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedDifficulty == diff
                                                      ? Color(hex: "4CC9F0").opacity(0.3)
                                                      : AppTheme.card)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedDifficulty == diff
                                                        ? Color(hex: "4CC9F0")
                                                        : Color.clear, lineWidth: 2)
                                        )
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Active power-ups
                    if !shopVM.activePowerUps.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ACTIVE POWER-UPS")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                            HStack {
                                ForEach(shopVM.activePowerUps, id: \.self) { powerUp in
                                    let item = ShopCatalog.powerUps.first { $0.value == powerUp }
                                    if let item = item {
                                        Text(item.icon)
                                            .font(.system(size: 24))
                                            .padding(8)
                                            .background(Color(hex: "4CC9F0").opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Start button
                    Button {
                        let questions = questionStore.questions(for: selectedSubjects, difficulty: selectedDifficulty)
                        if questions.isEmpty {
                            // Fallback to all difficulties if none match
                            let fallback = questionStore.questions(for: selectedSubjects, difficulty: nil)
                            onStart(fallback)
                        } else {
                            onStart(questions)
                        }
                    } label: {
                        Text("START GAME")
                            .glowButton(color: Color(hex: mode.color))
                    }
                    .padding(.top)
                }
            }
            .background(AppTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }
}
