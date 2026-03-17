import Foundation
import MultipeerConnectivity

enum MultiplayerMessage: Codable {
    case gameStart(questions: [Question], mode: String)
    case answerResult(playerName: String, correct: Bool, score: Int, streak: Int)
    case gameOver(playerName: String, finalScore: Int)
    case playerReady(playerName: String)

    var data: Data? {
        try? JSONEncoder().encode(self)
    }

    static func from(data: Data) -> MultiplayerMessage? {
        try? JSONDecoder().decode(MultiplayerMessage.self, from: data)
    }
}

class MultipeerService: NSObject, ObservableObject {
    private let serviceType = "sybles-quiz"
    private let myPeerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    @Published var isHost: Bool = false
    @Published var connectedPeers: [MCPeerID] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedMessage: MultiplayerMessage?
    @Published var isConnected: Bool = false
    @Published var opponentScores: [String: Int] = [:]
    @Published var opponentStreaks: [String: Int] = [:]

    var playerName: String

    init(playerName: String) {
        self.playerName = playerName
        self.myPeerID = MCPeerID(displayName: playerName)
        super.init()
    }

    func startHosting() {
        isHost = true
        setupSession()
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func startBrowsing() {
        isHost = false
        setupSession()
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func joinPeer(_ peer: MCPeerID) {
        guard let session = session, let browser = browser else { return }
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }

    func send(_ message: MultiplayerMessage) {
        guard let session = session, !session.connectedPeers.isEmpty,
              let data = message.data else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func disconnect() {
        session?.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        connectedPeers = []
        availablePeers = []
        isConnected = false
        opponentScores = [:]
        opponentStreaks = [:]
    }

    private func setupSession() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session?.delegate = self
    }
}

// MARK: - MCSessionDelegate

extension MultipeerService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            self.isConnected = !session.connectedPeers.isEmpty
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = MultiplayerMessage.from(data: data) {
            DispatchQueue.main.async {
                switch message {
                case .answerResult(let name, _, let score, let streak):
                    self.opponentScores[name] = score
                    self.opponentStreaks[name] = streak
                default:
                    break
                }
                self.receivedMessage = message
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerService: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
}
