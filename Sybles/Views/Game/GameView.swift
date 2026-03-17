import SwiftUI

struct GameView: View {
    @EnvironmentObject var playerData: PlayerData
    @StateObject private var gameVM = GameViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass

    let mode: GameMode
    let questions: [Question]
    let shopVM: ShopViewModel

    private var isIPad: Bool { sizeClass == .regular }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()

            if gameVM.isGameOver {
                GameOverView(gameVM: gameVM) {
                    let result = gameVM.gameResult()
                    playerData.addCoins(result.coinsEarned)
                    playerData.gamesPlayed += 1
                    playerData.addXP(GameConstants.xpPerGame + (result.correctAnswers * GameConstants.xpPerCorrect))
                    if result.bestStreak > playerData.bestStreak {
                        playerData.bestStreak = result.bestStreak
                    }

                    // Save to leaderboard
                    let total = result.correctAnswers + (result.questionsAnswered - result.correctAnswers)
                    let accuracy = total > 0 ? Double(result.correctAnswers) / Double(total) * 100 : 0
                    LeaderboardService.shared.addEntry(
                        playerName: playerData.username,
                        avatar: playerData.selectedAvatar,
                        score: result.coinsEarned,
                        streak: result.bestStreak,
                        accuracy: accuracy,
                        gamesPlayed: playerData.gamesPlayed
                    )

                    dismiss()
                }
            } else if let question = gameVM.currentQuestion {
                VStack(spacing: 0) {
                    // Top bar — constrained width on iPad
                    GameTopBar(gameVM: gameVM, mode: mode) {
                        dismiss()
                    }
                    .frame(maxWidth: isIPad ? 700 : .infinity)
                    .frame(maxWidth: .infinity)

                    ScrollView {
                        VStack(spacing: 20) {
                            // Question card — centered and constrained on iPad
                            QuestionCardView(
                                question: question,
                                selectedAnswer: gameVM.selectedAnswer,
                                isCorrect: gameVM.isCorrect,
                                hiddenChoices: gameVM.hiddenChoices,
                                onSelect: { gameVM.selectAnswer($0) }
                            )
                            .modifier(ShakeEffect(animatableData: gameVM.shakeAmount))
                            .frame(maxWidth: isIPad ? 650 : .infinity)

                            // Power-up bar
                            if gameVM.powerUps.hasFiftyFifty && !gameVM.powerUps.fiftyFiftyUsed {
                                Button {
                                    gameVM.useFiftyFifty()
                                } label: {
                                    HStack {
                                        Text("✂️")
                                        Text("50/50")
                                            .font(.system(size: isIPad ? 16 : 14, weight: .bold))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "F72585").opacity(0.3))
                                    .clipShape(Capsule())
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(isIPad ? 32 : 16)
                        .frame(maxWidth: .infinity)
                    }
                }

                // Coin animation
                if gameVM.showCoinAnimation {
                    CoinAnimationView(amount: gameVM.earnedCoinAmount)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            for powerUp in shopVM.activePowerUps {
                gameVM.applyPowerUp(powerUp)
            }
            shopVM.activePowerUps.removeAll()
            gameVM.startGame(mode: mode, questions: questions)
        }
    }
}

// MARK: - Game Top Bar

struct GameTopBar: View {
    @ObservedObject var gameVM: GameViewModel
    let mode: GameMode
    let onQuit: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    onQuit()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }

                Spacer()

                // Score
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(Color(hex: "FFD700"))
                    Text("\(gameVM.score)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "FFD700"))
                }

                Spacer()

                // Streak
                if gameVM.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(hex: "F77F00"))
                        Text("\(gameVM.streak)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "F77F00"))
                        if gameVM.totalMultiplier > 1 {
                            Text("×\(gameVM.totalMultiplier)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "F72585"))
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Progress / Timer
            if mode == .timed {
                HStack(spacing: 8) {
                    Image(systemName: "timer")
                        .foregroundColor(gameVM.timeRemaining < 10 ? Color(hex: "F72585") : .white.opacity(0.5))
                    Text(String(format: "%.0f", gameVM.timeRemaining))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(gameVM.timeRemaining < 10 ? Color(hex: "F72585") : .white)
                    Spacer()
                    Text("Q\(gameVM.currentIndex + 1)/\(gameVM.questions.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal)
            } else {
                HStack {
                    ProgressView(value: gameVM.progress)
                        .tint(Color(hex: mode.color))
                    Text("\(gameVM.currentIndex + 1)/\(gameVM.questions.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal)
            }

            // Question timer bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 3)
                    Rectangle()
                        .fill(gameVM.questionTimeRemaining < 5 ? Color(hex: "F72585") : Color(hex: "4CC9F0"))
                        .frame(width: geo.size.width * (gameVM.questionTimeRemaining / GameConstants.questionTimeLimit), height: 3)
                        .animation(.linear(duration: 0.1), value: gameVM.questionTimeRemaining)
                }
            }
            .frame(height: 3)
        }
        .padding(.top, 8)
    }
}

// MARK: - Coin Animation

struct CoinAnimationView: View {
    let amount: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text("+\(amount)")
            .font(.system(size: 32, weight: .black))
            .foregroundColor(Color(hex: "FFD700"))
            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 8)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    offset = -60
                    opacity = 0
                }
            }
    }
}
