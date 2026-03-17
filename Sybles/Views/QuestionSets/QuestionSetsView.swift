import SwiftUI

struct QuestionSetsView: View {
    @EnvironmentObject var questionStore: QuestionStore
    @State private var showCreateSheet = false
    @State private var selectedTab: SetTab = .builtIn
    @Environment(\.horizontalSizeClass) var sizeClass

    private var isIPad: Bool { sizeClass == .regular }

    enum SetTab: String, CaseIterable {
        case builtIn = "Built-in"
        case custom = "My Sets"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Question Sets")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "4CC9F0"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Tab selector
                HStack(spacing: 8) {
                    ForEach(SetTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedTab == tab
                                              ? Color(hex: "4CC9F0")
                                              : AppTheme.card)
                                )
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Sets list
                let sets = selectedTab == .builtIn ? questionStore.questionSets : questionStore.customSets

                if sets.isEmpty && selectedTab == .custom {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No custom sets yet")
                            .foregroundColor(.white.opacity(0.4))
                        Text("Tap + to create your first set!")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.top, 60)
                } else {
                    if isIPad {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(sets) { set in
                                QuestionSetCard(questionSet: set, canDelete: selectedTab == .custom) {
                                    questionStore.deleteCustomSet(id: set.id)
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        ForEach(sets) { set in
                            QuestionSetCard(questionSet: set, canDelete: selectedTab == .custom) {
                                questionStore.deleteCustomSet(id: set.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer(minLength: 20)
            }
            .frame(maxWidth: isIPad ? 800 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(AppTheme.bg.ignoresSafeArea())
        .sheet(isPresented: $showCreateSheet) {
            CreateQuestionSetView()
                .environmentObject(questionStore)
        }
    }
}

struct QuestionSetCard: View {
    let questionSet: QuestionSet
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: questionSet.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: questionSet.subject.color))
                .frame(width: 48, height: 48)
                .background(Color(hex: questionSet.subject.color).opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(questionSet.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                HStack(spacing: 8) {
                    Text(questionSet.subject.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: questionSet.subject.color))
                    Text("•")
                        .foregroundColor(.white.opacity(0.3))
                    Text("\(questionSet.questionCount) questions")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            if canDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "F72585").opacity(0.7))
                }
            }
        }
        .cardStyle()
    }
}
