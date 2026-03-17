import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var coinsEarned: Int = 0
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var correctCount: Int = 0
    @Published var wrongCount: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var isCorrect: Bool? = nil
    @Published var isGameOver: Bool = false
    @Published var timeRemaining: TimeInterval = 60
    @Published var questionTimeRemaining: TimeInterval = 15
    @Published var shakeAmount: CGFloat = 0
    @Published var showCoinAnimation: Bool = false
    @Published var earnedCoinAmount: Int = 0
    @Published var hiddenChoices: Set<Int> = []
    @Published var powerUps: PowerUpState = PowerUpState()

    var gameMode: GameMode = .classic
    var multipeerService: MultipeerService?
    private var timer: AnyCancellable?
    private var questionTimer: AnyCancellable?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var streakMultiplier: Int {
        min(streak + 1, GameConstants.maxStreakMultiplier)
    }

    var totalMultiplier: Int {
        streakMultiplier * powerUps.multiplier
    }

    func startGame(mode: GameMode, questions: [Question]) {
        self.gameMode = mode
        self.questions = Array(questions.prefix(20))
        self.currentIndex = 0
        self.score = 0
        self.coinsEarned = 0
        self.streak = 0
        self.bestStreak = 0
        self.correctCount = 0
        self.wrongCount = 0
        self.selectedAnswer = nil
        self.isCorrect = nil
        self.isGameOver = false
        self.hiddenChoices = []

        if mode == .timed {
            timeRemaining = GameConstants.timedModeDuration + Double(powerUps.timeFreezeSeconds)
            startTimer()
        }

        startQuestionTimer()
    }

    func selectAnswer(_ index: Int) {
        guard selectedAnswer == nil, let question = currentQuestion else { return }
        selectedAnswer = index
        let correct = index == question.correctIndex
        isCorrect = correct
        feedbackGenerator.impactOccurred()

        if correct {
            correctCount += 1
            streak += 1
            bestStreak = max(bestStreak, streak)

            let baseCoins = GameConstants.baseCoinsPerCorrect
            let difficultyBonus = Int(Double(baseCoins) * question.difficulty.multiplier)
            let streakBonus = GameConstants.streakBonusPerLevel * (streakMultiplier - 1)
            var earned = (difficultyBonus + streakBonus) * powerUps.multiplier

            if powerUps.hasDoubleDown {
                earned *= 2
                powerUps.hasDoubleDown = false
            }

            coinsEarned += earned
            score += earned
            earnedCoinAmount = earned
            showCoinAnimation = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showCoinAnimation = false
            }
        } else {
            wrongCount += 1
            if powerUps.hasStreakShield {
                powerUps.hasStreakShield = false
            } else {
                streak = 0
            }

            if powerUps.hasDoubleDown {
                let penalty = min(coinsEarned, GameConstants.baseCoinsPerCorrect * 2)
                coinsEarned = max(0, coinsEarned - penalty)
                score = max(0, score - penalty)
                powerUps.hasDoubleDown = false
            }

            withAnimation(.default) {
                shakeAmount += 1
            }
        }

        // Send to multiplayer
        multipeerService?.send(.answerResult(
            playerName: multipeerService?.playerName ?? "Player",
            correct: correct,
            score: score,
            streak: streak
        ))

        // Next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nextQuestion()
        }
    }

    func useFiftyFifty() {
        guard let question = currentQuestion, !powerUps.fiftyFiftyUsed, powerUps.hasFiftyFifty else { return }
        powerUps.fiftyFiftyUsed = true
        powerUps.hasFiftyFifty = false

        var wrongIndices = question.choices.indices.filter { $0 != question.correctIndex }
        wrongIndices.shuffle()
        let toHide = wrongIndices.prefix(2)
        hiddenChoices = Set(toHide)
    }

    func useDoubleDown() {
        powerUps.hasDoubleDown = true
    }

    private func nextQuestion() {
        selectedAnswer = nil
        isCorrect = nil
        hiddenChoices = []
        currentIndex += 1
        questionTimeRemaining = GameConstants.questionTimeLimit

        if currentIndex >= questions.count {
            endGame()
        }
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 0.1
                if self.timeRemaining <= 0 {
                    self.timeRemaining = 0
                    self.endGame()
                }
            }
    }

    private func startQuestionTimer() {
        questionTimeRemaining = GameConstants.questionTimeLimit
        questionTimer?.cancel()
        questionTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.selectedAnswer != nil { return }
                self.questionTimeRemaining -= 0.1
                if self.questionTimeRemaining <= 0 {
                    self.questionTimeRemaining = 0
                    // Auto-wrong if time runs out
                    if self.selectedAnswer == nil {
                        self.selectAnswer(-1)
                    }
                }
            }
    }

    private func endGame() {
        timer?.cancel()
        questionTimer?.cancel()
        isGameOver = true

        multipeerService?.send(.gameOver(
            playerName: multipeerService?.playerName ?? "Player",
            finalScore: score
        ))
    }

    func applyPowerUp(_ id: String) {
        switch id {
        case "multiplier_2x": powerUps.multiplier = 2
        case "multiplier_5x": powerUps.multiplier = 5
        case "streak_shield": powerUps.hasStreakShield = true
        case "time_freeze": powerUps.timeFreezeSeconds = 15
        case "fifty_fifty": powerUps.hasFiftyFifty = true
        default: break
        }
    }

    func gameResult() -> GameResult {
        GameResult(
            mode: gameMode,
            score: score,
            coinsEarned: coinsEarned,
            questionsAnswered: correctCount + wrongCount,
            correctAnswers: correctCount,
            bestStreak: bestStreak,
            timePlayed: 0
        )
    }
}
