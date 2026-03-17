import SwiftUI

struct AnimalCollectionView: View {
    @EnvironmentObject var playerData: PlayerData
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var selectedFilter: CollectibleAnimal.Rarity? = nil
    @State private var selectedAnimal: CollectibleAnimal? = nil

    private var isIPad: Bool { sizeClass == .regular }

    private var filteredAnimals: [CollectibleAnimal] {
        if let filter = selectedFilter {
            return AnimalCatalog.all.filter { $0.rarity == filter }
        }
        return AnimalCatalog.all
    }

    private var ownedCount: Int {
        playerData.collectedAnimals.count
    }

    private var totalCount: Int {
        AnimalCatalog.all.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress header
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "F77F00"))
                            Text("My Animals")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }

                        // Progress bar
                        VStack(spacing: 6) {
                            HStack {
                                Text("\(ownedCount)/\(totalCount) Animals Collected")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(String(format: "%.0f%%", Double(ownedCount) / Double(totalCount) * 100))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "F77F00"))
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.1))
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "F77F00"), Color(hex: "FFD700")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geo.size.width * CGFloat(ownedCount) / CGFloat(max(totalCount, 1)), height: 10)
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal)

                    // Rarity filter pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterPill(label: "All", rarity: nil, isSelected: selectedFilter == nil)
                            ForEach(CollectibleAnimal.Rarity.allCases, id: \.self) { rarity in
                                filterPill(label: rarity.label, rarity: rarity, isSelected: selectedFilter == rarity)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Animal grid
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: isIPad ? 6 : 3)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredAnimals) { animal in
                            let isOwned = playerData.hasAnimal(animal.id)
                            AnimalGridCell(animal: animal, isOwned: isOwned)
                                .onTapGesture {
                                    if isOwned {
                                        selectedAnimal = animal
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
                .frame(maxWidth: isIPad ? 700 : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .sheet(item: $selectedAnimal) { animal in
                AnimalDetailPopup(animal: animal)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func filterPill(label: String, rarity: CollectibleAnimal.Rarity?, isSelected: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = rarity
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected
                              ? Color(hex: rarity?.color ?? "F77F00").opacity(0.3)
                              : AppTheme.card)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected
                                ? Color(hex: rarity?.color ?? "F77F00")
                                : Color.clear, lineWidth: 2)
                )
                .foregroundColor(isSelected
                                 ? Color(hex: rarity?.color ?? "F77F00")
                                 : .white.opacity(0.5))
        }
    }
}

// MARK: - Grid Cell

struct AnimalGridCell: View {
    let animal: CollectibleAnimal
    let isOwned: Bool

    var body: some View {
        VStack(spacing: 6) {
            if isOwned {
                Text(animal.emoji)
                    .font(.system(size: 44))
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.15))
            }

            Text(isOwned ? animal.name : "???")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isOwned ? .white : .white.opacity(0.2))
                .lineLimit(1)

            // Rarity badge
            Text(animal.rarity.label)
                .font(.system(size: 9, weight: .black))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color(hex: animal.rarity.color).opacity(isOwned ? 0.3 : 0.1))
                )
                .foregroundColor(Color(hex: animal.rarity.color).opacity(isOwned ? 1 : 0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isOwned ? AppTheme.card : AppTheme.card.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isOwned ? Color(hex: animal.rarity.color).opacity(0.3) : Color.white.opacity(0.03), lineWidth: 1)
        )
    }
}

// MARK: - Detail Popup

struct AnimalDetailPopup: View {
    let animal: CollectibleAnimal
    @Environment(\.dismiss) var dismiss

    @State private var emojiScale: CGFloat = 0.3
    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Big emoji with glow
            Text(animal.emoji)
                .font(.system(size: 100))
                .scaleEffect(emojiScale)
                .shadow(color: Color(hex: animal.rarity.color).opacity(0.6), radius: 30, y: 0)

            VStack(spacing: 8) {
                Text(animal.name)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)

                Text(animal.rarity.label)
                    .font(.system(size: 14, weight: .black))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: animal.rarity.color).opacity(0.3))
                    )
                    .foregroundColor(Color(hex: animal.rarity.color))

                Text(animal.description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }
            .opacity(contentOpacity)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("AWESOME!")
                    .glowButton(color: Color(hex: animal.rarity.color))
            }
            .opacity(contentOpacity)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.bg.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                emojiScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                contentOpacity = 1
            }
        }
        .preferredColorScheme(.dark)
    }
}
