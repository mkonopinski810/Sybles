import Foundation
import GameKit
import SwiftUI

// MARK: - GameCenterMessage

enum GameCenterMessage: Codable {
    case gameStart(questions: [Question], mode: String)
    case answerResult(playerName: String, correct: Bool, score: Int, streak: Int)
    case gameOver(playerName: String, finalScore: Int)

    var data: Data? {
        try? JSONEncoder().encode(self)
    }

    static func from(data: Data) -> GameCenterMessage? {
        try? JSONDecoder().decode(GameCenterMessage.self, from: data)
    }
}

// MARK: - GameCenterService

class GameCenterService: NSObject, ObservableObject {

    @Published var isAuthenticated: Bool = false
    @Published var currentMatch: GKMatch?
    @Published var opponentScores: [String: Int] = [:]
    @Published var opponentStreaks: [String: Int] = [:]
    @Published var receivedQuestions: [Question]?
    @Published var gameStarted: Bool = false
    @Published var matchmakingError: String?
    @Published var connectedPlayerNames: [String] = []
    @Published var receivedMessage: GameCenterMessage?
    @Published var gameMode: String?

    private var matchmakerVC: GKMatchmakerViewController?

    var localPlayerName: String {
        GKLocalPlayer.local.displayName
    }

    // MARK: - Authentication

    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Game Center auth error: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    return
                }

                if let vc = viewController {
                    // Present the Game Center login view controller
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(vc, animated: true)
                    }
                    return
                }

                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    GKLocalPlayer.local.register(self!)
                    print("Game Center authenticated: \(GKLocalPlayer.local.displayName)")
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
    }

    // MARK: - Matchmaking

    func findMatch(minPlayers: Int = 2, maxPlayers: Int = 4) {
        guard isAuthenticated else {
            matchmakingError = "Not authenticated with Game Center"
            return
        }

        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers

        guard let matchmakerVC = GKMatchmakerViewController(matchRequest: request) else {
            matchmakingError = "Failed to create matchmaker"
            return
        }

        matchmakerVC.matchmakerDelegate = self
        self.matchmakerVC = matchmakerVC

        presentViewController(matchmakerVC)
    }

    func inviteFriends() {
        guard isAuthenticated else {
            matchmakingError = "Not authenticated with Game Center"
            return
        }

        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4

        guard let matchmakerVC = GKMatchmakerViewController(matchRequest: request) else {
            matchmakingError = "Failed to create matchmaker"
            return
        }

        matchmakerVC.matchmakerDelegate = self
        self.matchmakerVC = matchmakerVC

        presentViewController(matchmakerVC)
    }

    // MARK: - Sending Messages

    func sendGameStart(questions: [Question], mode: String = "multiplayer") {
        let message = GameCenterMessage.gameStart(questions: questions, mode: mode)
        sendToAllPlayers(message)
    }

    func sendAnswerResult(playerName: String, correct: Bool, score: Int, streak: Int) {
        let message = GameCenterMessage.answerResult(
            playerName: playerName,
            correct: correct,
            score: score,
            streak: streak
        )
        sendToAllPlayers(message)
    }

    func sendGameOver(playerName: String, finalScore: Int) {
        let message = GameCenterMessage.gameOver(playerName: playerName, finalScore: finalScore)
        sendToAllPlayers(message)
    }

    func disconnect() {
        currentMatch?.disconnect()
        DispatchQueue.main.async {
            self.currentMatch = nil
            self.opponentScores = [:]
            self.opponentStreaks = [:]
            self.receivedQuestions = nil
            self.gameStarted = false
            self.connectedPlayerNames = []
            self.receivedMessage = nil
            self.gameMode = nil
            self.matchmakingError = nil
        }
    }

    // MARK: - Private Helpers

    private func sendToAllPlayers(_ message: GameCenterMessage) {
        guard let match = currentMatch, !match.players.isEmpty else { return }
        guard let data = message.data else {
            print("Failed to encode GameCenterMessage")
            return
        }

        do {
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }

    private func presentViewController(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                // Walk up to the topmost presented controller
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                topVC.present(viewController, animated: true)
            }
        }
    }

    func updateConnectedPlayerNames() {
        guard let match = currentMatch else {
            connectedPlayerNames = []
            return
        }
        connectedPlayerNames = match.players.map { $0.displayName }
    }
}

// MARK: - GKMatchDelegate

extension GameCenterService: GKMatchDelegate {

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let message = GameCenterMessage.from(data: data) else {
            print("Failed to decode message from \(player.displayName)")
            return
        }

        DispatchQueue.main.async {
            switch message {
            case .gameStart(let questions, let mode):
                self.receivedQuestions = questions
                self.gameMode = mode
                self.gameStarted = true

            case .answerResult(let name, _, let score, let streak):
                self.opponentScores[name] = score
                self.opponentStreaks[name] = streak

            case .gameOver(_, _):
                break
            }

            self.receivedMessage = message
        }
    }

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Player connected: \(player.displayName)")
                self.updateConnectedPlayerNames()

            case .disconnected:
                print("Player disconnected: \(player.displayName)")
                self.updateConnectedPlayerNames()
                self.opponentScores.removeValue(forKey: player.displayName)
                self.opponentStreaks.removeValue(forKey: player.displayName)

            case .unknown:
                print("Player state unknown: \(player.displayName)")

            @unknown default:
                break
            }
        }
    }

    func match(_ match: GKMatch, didFailWithError error: Error?) {
        DispatchQueue.main.async {
            self.matchmakingError = error?.localizedDescription ?? "Match failed"
            print("Match failed: \(error?.localizedDescription ?? "unknown error")")
        }
    }

    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return true
    }
}

// MARK: - GKMatchmakerViewControllerDelegate

extension GameCenterService: GKMatchmakerViewControllerDelegate {

    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
        DispatchQueue.main.async {
            self.matchmakingError = nil
        }
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        DispatchQueue.main.async {
            self.matchmakingError = error.localizedDescription
            print("Matchmaker failed: \(error.localizedDescription)")
        }
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        DispatchQueue.main.async {
            self.currentMatch = match
            match.delegate = self
            self.updateConnectedPlayerNames()
            self.matchmakingError = nil
            print("Match found with \(match.players.count) players")
        }
    }
}

// MARK: - GKLocalPlayerListener

extension GameCenterService: GKLocalPlayerListener {

    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        guard let matchmakerVC = GKMatchmakerViewController(invite: invite) else { return }
        matchmakerVC.matchmakerDelegate = self
        self.matchmakerVC = matchmakerVC
        presentViewController(matchmakerVC)
    }

    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4
        request.recipients = recipientPlayers

        guard let matchmakerVC = GKMatchmakerViewController(matchRequest: request) else { return }
        matchmakerVC.matchmakerDelegate = self
        self.matchmakerVC = matchmakerVC
        presentViewController(matchmakerVC)
    }
}

// MARK: - GameCenterMatchmakerView (UIViewControllerRepresentable)

struct GameCenterMatchmakerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let minPlayers: Int
    let maxPlayers: Int
    let gameCenterService: GameCenterService

    init(isPresented: Binding<Bool>, minPlayers: Int = 2, maxPlayers: Int = 4, gameCenterService: GameCenterService) {
        self._isPresented = isPresented
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.gameCenterService = gameCenterService
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers

        guard let matchmakerVC = GKMatchmakerViewController(matchRequest: request) else {
            // Return an empty controller if matchmaker can't be created
            return UIViewController()
        }

        matchmakerVC.matchmakerDelegate = context.coordinator
        return matchmakerVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GKMatchmakerViewControllerDelegate {
        let parent: GameCenterMatchmakerView

        init(_ parent: GameCenterMatchmakerView) {
            self.parent = parent
        }

        func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
            DispatchQueue.main.async {
                self.parent.isPresented = false
            }
        }

        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
            DispatchQueue.main.async {
                self.parent.gameCenterService.matchmakingError = error.localizedDescription
                self.parent.isPresented = false
            }
        }

        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
            DispatchQueue.main.async {
                self.parent.gameCenterService.currentMatch = match
                match.delegate = self.parent.gameCenterService
                self.parent.gameCenterService.updateConnectedPlayerNames()
                self.parent.gameCenterService.matchmakingError = nil
                self.parent.isPresented = false
            }
        }
    }
}
