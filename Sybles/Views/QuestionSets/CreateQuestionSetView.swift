import SwiftUI

struct CreateQuestionSetView: View {
    @EnvironmentObject var questionStore: QuestionStore
    @Environment(\.dismiss) var dismiss

    @State private var setName: String = ""
    @State private var selectedSubject: Question.Subject = .custom
    @State private var questions: [QuestionDraft] = [QuestionDraft()]

    struct QuestionDraft: Identifiable {
        let id = UUID()
        var text: String = ""
        var choices: [String] = ["", "", "", ""]
        var correctIndex: Int = 0
    }

    var isValid: Bool {
        !setName.isEmpty && questions.allSatisfy { draft in
            !draft.text.isEmpty && draft.choices.allSatisfy { !$0.isEmpty }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Set info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SET NAME")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))

                        TextField("My Question Set", text: $setName)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundColor(.white)

                        Text("SUBJECT")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Question.Subject.allCases, id: \.self) { subject in
                                    Button {
                                        selectedSubject = subject
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: subject.icon)
                                            Text(subject.rawValue)
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedSubject == subject
                                                      ? Color(hex: subject.color).opacity(0.3)
                                                      : AppTheme.card)
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(selectedSubject == subject
                                                        ? Color(hex: subject.color)
                                                        : Color.clear, lineWidth: 2)
                                        )
                                        .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Questions
                    ForEach(questions.indices, id: \.self) { qIdx in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Question \(qIdx + 1)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                if questions.count > 1 {
                                    Button {
                                        questions.remove(at: qIdx)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "F72585").opacity(0.7))
                                    }
                                }
                            }

                            TextField("Question text", text: $questions[qIdx].text)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(AppTheme.bg)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .foregroundColor(.white)

                            ForEach(0..<4, id: \.self) { cIdx in
                                HStack(spacing: 8) {
                                    Button {
                                        questions[qIdx].correctIndex = cIdx
                                    } label: {
                                        Image(systemName: questions[qIdx].correctIndex == cIdx
                                              ? "checkmark.circle.fill"
                                              : "circle")
                                            .foregroundColor(questions[qIdx].correctIndex == cIdx
                                                             ? Color(hex: "06D6A0")
                                                             : .white.opacity(0.3))
                                    }

                                    TextField("Choice \(["A", "B", "C", "D"][cIdx])", text: $questions[qIdx].choices[cIdx])
                                        .font(.system(size: 14))
                                        .padding(10)
                                        .background(AppTheme.bg)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal)
                    }

                    // Add question button
                    Button {
                        questions.append(QuestionDraft())
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Question")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "4CC9F0"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "4CC9F0").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(AppTheme.bg.ignoresSafeArea())
            .navigationTitle("New Question Set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSet()
                    }
                    .foregroundColor(isValid ? Color(hex: "4CC9F0") : .gray)
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveSet() {
        let builtQuestions = questions.map { draft in
            Question(
                text: draft.text,
                choices: draft.choices,
                correctIndex: draft.correctIndex,
                subject: selectedSubject,
                difficulty: .medium
            )
        }
        let set = QuestionSet(
            name: setName,
            subject: selectedSubject,
            questions: builtQuestions,
            isBuiltIn: false
        )
        questionStore.addCustomSet(set)
        dismiss()
    }
}
