import SwiftUI

@main
struct SyblesApp: App {
    @StateObject private var playerData = PlayerData()
    @StateObject private var questionStore = QuestionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerData)
                .environmentObject(questionStore)
                .preferredColorScheme(.dark)
        }
    }
}
