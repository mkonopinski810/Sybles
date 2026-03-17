import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameVM: GameViewModel
    @EnvironmentObject var playerData: PlayerData
    let onDone: () -> Void

    @State private var showStats = false
    @State private var earnedAnimal: CollectibleAnimal? = nil
    @State private var showAnimalReveal = false
    @State private var animalRollDone = false

    var body: some View {
        ZStack {
            // Main game over content
            VStack(spacing: 24) {
                Spacer()

                // Trophy
                Text(trophyEmoji)
                    .font(.system(size: 80))
                    .modifier(BounceEffect())

                Text("Game Over!")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.white)

                Text(resultMessage)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))

                // Score card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(Color(hex: "FFD700"))
                            .font(.system(size: 28))
                        Text("\(gameVM.coinsEarned)")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("coins earned")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Divider().background(Color.white.opacity(0.1))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ResultStat(icon: "checkmark.circle.fill", label: "Correct", value: "\(gameVM.correctCount)", color: "06D6A0")
                        ResultStat(icon: "xmark.circle.fill", label: "Wrong", value: "\(gameVM.wrongCount)", color: "F72585")
                        ResultStat(icon: "flame.fill", label: "Best Streak", value: "\(gameVM.bestStreak)", color: "F77F00")
                        ResultStat(icon: "percent", label: "Accuracy", value: accuracy, color: "4CC9F0")
                    }
                }
                .cardStyle()
                .padding(.horizontal, 24)
                .opacity(showStats ? 1 : 0)
                .offset(y: showStats ? 0 : 20)

                // Animal earned teaser
                if let animal = earnedAnimal, !showAnimalReveal {
                    Button {
                        showAnimalReveal = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "pawprint.fill")
                                .foregroundColor(Color(hex: animal.rarity.color))
                            Text("You found a new animal!")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: animal.rarity.color).opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: animal.rarity.color).opacity(0.4), lineWidth: 1)
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                    .padding(.horizontal, 24)
                }

                Spacer()

                Button {
                    onDone()
                } label: {
                    Text("COLLECT COINS")
                        .glowButton(color: Color(hex: "FFD700"))
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(AppTheme.bg.ignoresSafeArea())

            // Animal reveal overlay
            if showAnimalReveal, let animal = earnedAnimal {
                AnimalRevealView(animal: animal) {
                    showAnimalReveal = false
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showStats = true
            }
            rollForAnimal()
        }
    }

    private func rollForAnimal() {
        guard !animalRollDone else { return }
        animalRollDone = true

        let total = gameVM.correctCount + gameVM.wrongCount
        let acc = total > 0 ? Double(gameVM.correctCount) / Double(total) * 100 : 0

        if let animal = AnimalRewardService.rollForAnimal(
            accuracy: acc,
            streak: gameVM.bestStreak,
            ownedAnimals: playerData.collectedAnimals
        ) {
            playerData.addAnimal(animal.id)
            withAnimation(.easeOut(duration: 0.4).delay(0.8)) {
                earnedAnimal = animal
            }
        }
    }

    private var accuracy: String {
        let total = gameVM.correctCount + gameVM.wrongCount
        guard total > 0 else { return "0%" }
        return String(format: "%.0f%%", Double(gameVM.correctCount) / Double(total) * 100)
    }

    private var trophyEmoji: String {
        let total = gameVM.correctCount + gameVM.wrongCount
        guard total > 0 else { return "🎮" }
        let pct = Double(gameVM.correctCount) / Double(total)
        if pct >= 0.9 { return "🏆" }
        if pct >= 0.7 { return "🥇" }
        if pct >= 0.5 { return "🥈" }
        return "🥉"
    }

    private var resultMessage: String {
        let total = gameVM.correctCount + gameVM.wrongCount
        guard total > 0 else { return "Good try!" }
        let pct = Double(gameVM.correctCount) / Double(total)
        if pct >= 0.9 { return "Absolutely incredible! You're a genius!" }
        if pct >= 0.7 { return "Great job! You really know your stuff!" }
        if pct >= 0.5 { return "Nice work! Keep practicing!" }
        return "Don't give up — you'll do better next time!"
    }
}

// MARK: - Animal Reveal View

struct AnimalRevealView: View {
    let animal: CollectibleAnimal
    let onDismiss: () -> Void

    @State private var emojiScale: CGFloat = 0.1
    @State private var glowOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var sparkleScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Spacer()

                // "NEW ANIMAL!" header
                Text("NEW ANIMAL!")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(Color(hex: animal.rarity.color))
                    .shadow(color: Color(hex: animal.rarity.color).opacity(0.6), radius: 12)
                    .opacity(textOpacity)

                // Sparkle ring + emoji
                ZStack {
                    // Glow circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: animal.rarity.color).opacity(0.4), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .opacity(glowOpacity)

                    // Sparkle stars
                    ForEach(0..<8, id: \.self) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: animal.rarity.color))
                            .offset(x: 80)
                            .rotationEffect(.degrees(Double(i) * 45 + sparkleRotation))
                            .scaleEffect(sparkleScale)
                    }

                    // Big emoji
                    Text(animal.emoji)
                        .font(.system(size: 100))
                        .scaleEffect(emojiScale)
                        .shadow(color: Color(hex: animal.rarity.color).opacity(0.5), radius: 20)
                }

                // Name
                Text(animal.name)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                    .opacity(textOpacity)

                // Rarity badge
                Text(animal.rarity.label)
                    .font(.system(size: 16, weight: .black))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: animal.rarity.color).opacity(0.3))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: animal.rarity.color), lineWidth: 2)
                    )
                    .foregroundColor(Color(hex: animal.rarity.color))
                    .opacity(textOpacity)

                // Description
                Text(animal.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text("AMAZING!")
                        .glowButton(color: Color(hex: animal.rarity.color))
                }
                .opacity(textOpacity)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Emoji bounce in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                emojiScale = 1.0
            }
            // Glow
            withAnimation(.easeIn(duration: 0.6)) {
                glowOpacity = 1.0
            }
            // Sparkles
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                sparkleScale = 1.0
            }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
            // Text
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                textOpacity = 1.0
            }
        }
    }
}

struct ResultStat: View {
    let icon: String
    let label: String
    let value: String
    let color: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: color))
                .font(.system(size: 20))
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}
