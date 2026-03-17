import SwiftUI

struct QuestionCardView: View {
    let question: Question
    let selectedAnswer: Int?
    let isCorrect: Bool?
    let hiddenChoices: Set<Int>
    let onSelect: (Int) -> Void

    private let choiceColors = ["4CC9F0", "F72585", "7209B7", "F77F00"]

    var body: some View {
        VStack(spacing: 20) {
            // Subject badge
            HStack {
                Image(systemName: question.subject.icon)
                    .font(.system(size: 12))
                Text(question.subject.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                Text("•")
                    .foregroundColor(.white.opacity(0.3))
                Text(question.difficulty.rawValue.capitalized)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(Color(hex: question.subject.color))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(hex: question.subject.color).opacity(0.15))
            .clipShape(Capsule())

            // Question text
            Text(question.text)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 8)

            // Answer choices
            VStack(spacing: 12) {
                ForEach(Array(question.choices.enumerated()), id: \.offset) { index, choice in
                    if !hiddenChoices.contains(index) {
                        Button {
                            onSelect(index)
                        } label: {
                            HStack {
                                Text(choiceLetter(index))
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(choiceColor(index).opacity(0.8))
                                    .frame(width: 32, height: 32)
                                    .background(choiceColor(index).opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Text(choice)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()

                                if let selected = selectedAnswer, selected == index {
                                    Image(systemName: isCorrect == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(isCorrect == true ? Color(hex: "06D6A0") : Color(hex: "F72585"))
                                } else if selectedAnswer != nil && index == question.correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(hex: "06D6A0"))
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(choiceBackground(index))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(choiceBorder(index), lineWidth: 2)
                            )
                        }
                        .disabled(selectedAnswer != nil)
                        .animation(.easeInOut(duration: 0.2), value: selectedAnswer)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.card)
        )
    }

    private func choiceLetter(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }

    private func choiceColor(_ index: Int) -> Color {
        Color(hex: choiceColors[index % choiceColors.count])
    }

    private func choiceBackground(_ index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return AppTheme.bg
        }
        if index == question.correctIndex {
            return Color(hex: "06D6A0").opacity(0.15)
        }
        if selected == index {
            return Color(hex: "F72585").opacity(0.15)
        }
        return AppTheme.bg.opacity(0.5)
    }

    private func choiceBorder(_ index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.08)
        }
        if index == question.correctIndex {
            return Color(hex: "06D6A0")
        }
        if selected == index {
            return Color(hex: "F72585")
        }
        return Color.clear
    }
}
