import SwiftUI

struct ParentalGateView: View {
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @State private var challenge = ParentalGate.generateChallenge()
    @State private var shakeAttempt: CGFloat = 0
    @State private var showWrong = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Lock icon + title
                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 52))
                        .foregroundColor(Color(hex: "F77F00"))

                    Text("Parent Verification")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("To protect our young players, a parent must verify access to online features.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Question card
                VStack(spacing: 20) {
                    Text(challenge.question)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .modifier(ShakeEffect(animatableData: shakeAttempt))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Answer buttons
                VStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        Button {
                            answerTapped(index)
                        } label: {
                            Text(challenge.choices[index])
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(buttonColor(for: index))
                                )
                                .foregroundColor(.white)
                        }
                        .disabled(showSuccess)
                    }
                }
                .padding(.horizontal, 24)

                // Wrong answer message
                if showWrong {
                    Text("That's not right — try again!")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "F72585"))
                        .transition(.opacity)
                }

                Spacer()

                // Cancel button
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            // Success overlay
            if showSuccess {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(Color(hex: "06D6A0"))
                    Text("Verified!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.bg.opacity(0.85))
                .transition(.opacity)
            }
        }
    }

    // MARK: - Helpers

    private func buttonColor(for index: Int) -> Color {
        let colors = ["4CC9F0", "7209B7", "F77F00", "06D6A0"]
        return Color(hex: colors[index]).opacity(0.35)
    }

    private func answerTapped(_ index: Int) {
        if index == challenge.correctIndex {
            // Correct
            ParentalGate.unlock()
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccess = true
                showWrong = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onSuccess()
            }
        } else {
            // Wrong — shake and regenerate
            withAnimation(.default) {
                shakeAttempt += 1
                showWrong = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    challenge = ParentalGate.generateChallenge()
                    showWrong = false
                }
            }
        }
    }
}
