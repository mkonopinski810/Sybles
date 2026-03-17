import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var choices: [String]
    var correctIndex: Int
    var subject: Subject
    var difficulty: Difficulty

    init(id: UUID = UUID(), text: String, choices: [String], correctIndex: Int, subject: Subject, difficulty: Difficulty = .medium) {
        self.id = id
        self.text = text
        self.choices = choices
        self.correctIndex = correctIndex
        self.subject = subject
        self.difficulty = difficulty
    }

    var correctAnswer: String {
        choices[correctIndex]
    }

    enum Subject: String, Codable, CaseIterable, Hashable {
        case math = "Math"
        case vocabulary = "Vocabulary"
        case science = "Science"
        case geography = "Geography"
        case history = "History"
        case custom = "Custom"

        var icon: String {
            switch self {
            case .math: return "number.circle.fill"
            case .vocabulary: return "textformat.abc"
            case .science: return "atom"
            case .geography: return "globe.americas.fill"
            case .history: return "clock.fill"
            case .custom: return "star.fill"
            }
        }

        var color: String {
            switch self {
            case .math: return "4CC9F0"
            case .vocabulary: return "F72585"
            case .science: return "7209B7"
            case .geography: return "4361EE"
            case .history: return "F77F00"
            case .custom: return "06D6A0"
            }
        }
    }

    enum Difficulty: String, Codable, CaseIterable, Hashable {
        case easy, medium, hard

        var multiplier: Double {
            switch self {
            case .easy: return 1.0
            case .medium: return 1.5
            case .hard: return 2.0
            }
        }
    }
}
