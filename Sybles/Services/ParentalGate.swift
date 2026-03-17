import Foundation

/// Parental gate for online multiplayer features.
/// Presents a multiplication problem designed to be easy for adults
/// but too difficult for children aged 6-12.
enum ParentalGate {

    /// Whether the parental gate has been passed this session.
    /// Resets automatically on app relaunch (stored in memory only).
    private(set) static var isUnlocked = false

    /// Mark the gate as passed for the current session.
    static func unlock() {
        isUnlocked = true
    }

    /// Reset the gate (e.g. for testing or on sign-out).
    static func reset() {
        isUnlocked = false
    }

    /// A challenge with a question string, four choice strings, and the
    /// index (0-3) of the correct answer.
    typealias Challenge = (question: String, choices: [String], correctIndex: Int)

    /// Generate a random multiplication challenge.
    /// Both operands are two-digit numbers chosen so the product exceeds 100.
    static func generateChallenge() -> Challenge {
        var a = 0
        var b = 0
        var product = 0

        // Keep generating until the product > 100
        repeat {
            a = Int.random(in: 12...49)
            b = Int.random(in: 12...49)
            product = a * b
        } while product <= 100

        let question = "What is \(a) × \(b)?"

        // Build three unique wrong answers within ±50 of the correct value
        var wrongAnswers = Set<Int>()
        while wrongAnswers.count < 3 {
            let offset = Int.random(in: 1...50) * (Bool.random() ? 1 : -1)
            let wrong = product + offset
            if wrong > 0 && wrong != product && !wrongAnswers.contains(wrong) {
                wrongAnswers.insert(wrong)
            }
        }

        // Place the correct answer at a random index
        var choices = wrongAnswers.map { String($0) }
        let correctIndex = Int.random(in: 0...3)
        choices.insert(String(product), at: correctIndex)

        return (question: question, choices: choices, correctIndex: correctIndex)
    }
}
