import SwiftUI
import GameKit

struct LobbyView: View {
    @EnvironmentObject var playerData: PlayerData
    @EnvironmentObject var questionStore: QuestionStore
    @Environment(\.dismiss) var dismiss

    @StateObject private var multipeerService: MultipeerService
    @StateObject private var gcService = GameCenterService()
    @State private var lobbyMode: LobbyMode? = nil
    @State private var isHosting = false
    @State private var isBrowsing = false
    @State private var gameStarted = false
    @State private var gameQuestions: [Question] = []
    @State private var selectedSubjects: Set<Question.Subject> = [.math, .science, .vocabulary]
    @State private var showParentalGate = false

    enum LobbyMode {
        case local, online
    }

    init() {
        _multipeerService = StateObject(wrappedValue: MultipeerService(playerName: "Player"))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                if gameStarted {
                    GameView(
                        mode: .classic,
                        questions: gameQuestions,
                        shopVM: ShopViewModel()
                    )
                    .environmentObject(playerData)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 56))
                                    .foregroundColor(Color(hex: "06D6A0"))
                                Text("Multiplayer")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Play with friends or find opponents")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.top, 24)

                            if lobbyMode == nil {
                                // Mode selection
                                modeSelectionView
                            } else if lobbyMode == .online {
                                onlineLobbyView
                            } else {
                                localLobbyView
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(lobbyMode == nil ? "Close" : "Back") {
                        if lobbyMode != nil {
                            multipeerService.disconnect()
                            gcService.disconnect()
                            isHosting = false
                            isBrowsing = false
                            lobbyMode = nil
                        } else {
                            multipeerService.disconnect()
                            gcService.disconnect()
                            dismiss()
                        }
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
            .onAppear {
                gcService.authenticatePlayer()
            }
            .onReceive(multipeerService.$receivedMessage) { message in
                if case .gameStart(let questions, _) = message {
                    gameQuestions = questions
                    gameStarted = true
                }
            }
            .onReceive(gcService.$gameStarted) { started in
                if started, let questions = gcService.receivedQuestions {
                    gameQuestions = questions
                    gameStarted = true
                }
            }
            .fullScreenCover(isPresented: $showParentalGate) {
                ParentalGateView(
                    onSuccess: {
                        showParentalGate = false
                        lobbyMode = .online
                    },
                    onCancel: {
                        showParentalGate = false
                    }
                )
            }
        }
    }

    // MARK: - Mode Selection

    private var modeSelectionView: some View {
        VStack(spacing: 12) {
            // Online button
            Button {
                if ParentalGate.isUnlocked {
                    lobbyMode = .online
                } else {
                    showParentalGate = true
                }
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "globe")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "4CC9F0"))
                        .frame(width: 50, height: 50)
                        .background(Color(hex: "4CC9F0").opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Play Online")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Find opponents via Game Center")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    if gcService.isAuthenticated {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "06D6A0"))
                    } else {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(Color(hex: "F77F00"))
                    }
                }
                .cardStyle()
            }
            .padding(.horizontal)

            // Local button
            Button {
                lobbyMode = .local
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "wifi")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "06D6A0"))
                        .frame(width: 50, height: 50)
                        .background(Color(hex: "06D6A0").opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Play Nearby")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Same WiFi or Bluetooth")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.3))
                }
                .cardStyle()
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Online Lobby (Game Center)

    private var onlineLobbyView: some View {
        VStack(spacing: 16) {
            if !gcService.isAuthenticated {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "F77F00"))
                    Text("Game Center Not Signed In")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Sign in to Game Center in Settings to play online.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                    Button {
                        gcService.authenticatePlayer()
                    } label: {
                        Text("Try Again")
                            .glowButton(color: Color(hex: "4CC9F0"))
                    }
                }
                .padding(.horizontal)
            } else {
                // Authenticated — show matchmaking options
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                            .foregroundColor(Color(hex: "06D6A0"))
                        Text(gcService.localPlayerName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Button {
                        gcService.findMatch()
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Find Match")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .glowButton(color: Color(hex: "4CC9F0"))
                    }
                    .padding(.horizontal, 40)

                    Button {
                        gcService.inviteFriends()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Invite Friends")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .glowButton(color: Color(hex: "7209B7"))
                    }
                    .padding(.horizontal, 40)
                }

                if let error = gcService.matchmakingError {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "F72585"))
                        .padding(.horizontal)
                }

                // Connected players
                if !gcService.connectedPlayerNames.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CONNECTED PLAYERS")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))

                        ForEach(gcService.connectedPlayerNames, id: \.self) { name in
                            HStack {
                                Image(systemName: "person.fill.checkmark")
                                    .foregroundColor(Color(hex: "06D6A0"))
                                Text(name)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Connected")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "06D6A0"))
                            }
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal)

                    // Subject selection for host
                    subjectSelectionView

                    Button {
                        let questions = questionStore.questions(for: selectedSubjects, difficulty: nil)
                        gameQuestions = Array(questions.prefix(20))
                        gcService.sendGameStart(questions: gameQuestions)
                        gameStarted = true
                    } label: {
                        Text("START GAME")
                            .glowButton(color: Color(hex: "06D6A0"))
                    }
                }
            }
        }
    }

    // MARK: - Local Lobby (MultipeerConnectivity)

    private var localLobbyView: some View {
        VStack(spacing: 16) {
            if !isHosting && !isBrowsing {
                VStack(spacing: 12) {
                    Button {
                        multipeerService.playerName = playerData.username
                        multipeerService.startHosting()
                        isHosting = true
                    } label: {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                            Text("Host Game")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .glowButton(color: Color(hex: "06D6A0"))
                    }

                    Button {
                        multipeerService.playerName = playerData.username
                        multipeerService.startBrowsing()
                        isBrowsing = true
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Join Game")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .glowButton(color: Color(hex: "4CC9F0"))
                    }
                }
                .padding(.horizontal, 40)
            }

            if isHosting {
                VStack(spacing: 16) {
                    HStack {
                        ProgressView()
                            .tint(.white)
                        Text("Waiting for players...")
                            .foregroundColor(.white.opacity(0.6))
                    }

                    subjectSelectionView

                    if multipeerService.isConnected {
                        Button {
                            let questions = questionStore.questions(for: selectedSubjects, difficulty: nil)
                            gameQuestions = Array(questions.prefix(20))
                            multipeerService.send(.gameStart(questions: gameQuestions, mode: "classic"))
                            gameStarted = true
                        } label: {
                            Text("START GAME")
                                .glowButton(color: Color(hex: "06D6A0"))
                        }
                    }
                }
            }

            if isBrowsing {
                if multipeerService.availablePeers.isEmpty {
                    HStack {
                        ProgressView()
                            .tint(.white)
                        Text("Searching for games...")
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AVAILABLE GAMES")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))

                        ForEach(multipeerService.availablePeers, id: \.displayName) { peer in
                            Button {
                                multipeerService.joinPeer(peer)
                            } label: {
                                HStack {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .foregroundColor(Color(hex: "4CC9F0"))
                                    Text(peer.displayName)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Join")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(Color(hex: "4CC9F0"))
                                }
                                .cardStyle()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Connected peers (local)
            if !multipeerService.connectedPeers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CONNECTED")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))

                    ForEach(multipeerService.connectedPeers, id: \.displayName) { peer in
                        HStack {
                            Image(systemName: "person.fill.checkmark")
                                .foregroundColor(Color(hex: "06D6A0"))
                            Text(peer.displayName)
                                .foregroundColor(.white)
                            Spacer()
                            Text("Ready")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "06D6A0"))
                        }
                        .cardStyle()
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Shared Subject Selection

    private var subjectSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SUBJECTS")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.4))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(Question.Subject.allCases.filter { $0 != .custom }, id: \.self) { subject in
                    Button {
                        if selectedSubjects.contains(subject) && selectedSubjects.count > 1 {
                            selectedSubjects.remove(subject)
                        } else {
                            selectedSubjects.insert(subject)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: subject.icon)
                                .font(.system(size: 12))
                            Text(subject.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedSubjects.contains(subject)
                                      ? Color(hex: subject.color).opacity(0.3)
                                      : AppTheme.card)
                        )
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
