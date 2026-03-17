import Foundation

struct QuestionSet: Identifiable, Codable {
    let id: UUID
    var name: String
    var subject: Question.Subject
    var questions: [Question]
    var isBuiltIn: Bool
    var icon: String

    init(id: UUID = UUID(), name: String, subject: Question.Subject, questions: [Question], isBuiltIn: Bool = false, icon: String? = nil) {
        self.id = id
        self.name = name
        self.subject = subject
        self.questions = questions
        self.isBuiltIn = isBuiltIn
        self.icon = icon ?? subject.icon
    }

    var questionCount: Int { questions.count }
}
