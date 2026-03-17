import Foundation

class QuestionStore: ObservableObject {
    @Published var questionSets: [QuestionSet] = []
    @Published var customSets: [QuestionSet] = []

    private let customSetsKey = "customQuestionSets"

    init() {
        loadBuiltInSets()
        loadCustomSets()
    }

    var allSets: [QuestionSet] {
        questionSets + customSets
    }

    func addCustomSet(_ set: QuestionSet) {
        customSets.append(set)
        saveCustomSets()
    }

    func deleteCustomSet(at offsets: IndexSet) {
        customSets.remove(atOffsets: offsets)
        saveCustomSets()
    }

    func deleteCustomSet(id: UUID) {
        customSets.removeAll { $0.id == id }
        saveCustomSets()
    }

    func updateCustomSet(_ set: QuestionSet) {
        if let idx = customSets.firstIndex(where: { $0.id == set.id }) {
            customSets[idx] = set
            saveCustomSets()
        }
    }

    func questions(for subjects: Set<Question.Subject>, difficulty: Question.Difficulty?) -> [Question] {
        let sets = allSets.filter { subjects.contains($0.subject) }
        var questions = sets.flatMap { $0.questions }
        if let difficulty = difficulty {
            questions = questions.filter { $0.difficulty == difficulty }
        }
        return questions.shuffled()
    }

    func questions(from setIDs: Set<UUID>) -> [Question] {
        return allSets.filter { setIDs.contains($0.id) }.flatMap { $0.questions }.shuffled()
    }

    // MARK: - Persistence

    private func saveCustomSets() {
        if let data = try? JSONEncoder().encode(customSets) {
            UserDefaults.standard.set(data, forKey: customSetsKey)
        }
    }

    private func loadCustomSets() {
        guard let data = UserDefaults.standard.data(forKey: customSetsKey),
              let sets = try? JSONDecoder().decode([QuestionSet].self, from: data) else { return }
        customSets = sets
    }

    // MARK: - Built-in Questions

    private func loadBuiltInSets() {
        questionSets = [
            mathEasy, mathMedium, mathHard,
            vocabEasy, vocabMedium, vocabHard,
            scienceEasy, scienceMedium, scienceHard,
            geographySet, historySet
        ]
    }

    // MARK: Math

    private var mathEasy: QuestionSet {
        QuestionSet(name: "Math Basics", subject: .math, questions: [
            Question(text: "What is 5 + 3?", choices: ["8", "7", "6", "9"], correctIndex: 0, subject: .math, difficulty: .easy),
            Question(text: "What is 10 - 4?", choices: ["5", "6", "7", "8"], correctIndex: 1, subject: .math, difficulty: .easy),
            Question(text: "What is 3 × 2?", choices: ["4", "5", "7", "6"], correctIndex: 3, subject: .math, difficulty: .easy),
            Question(text: "What is 12 ÷ 3?", choices: ["2", "4", "3", "5"], correctIndex: 1, subject: .math, difficulty: .easy),
            Question(text: "What is 7 + 8?", choices: ["13", "15", "14", "16"], correctIndex: 1, subject: .math, difficulty: .easy),
            Question(text: "What is 20 - 7?", choices: ["13", "12", "11", "14"], correctIndex: 0, subject: .math, difficulty: .easy),
            Question(text: "What is 4 × 5?", choices: ["15", "18", "25", "20"], correctIndex: 3, subject: .math, difficulty: .easy),
            Question(text: "What is 9 + 6?", choices: ["14", "16", "15", "17"], correctIndex: 2, subject: .math, difficulty: .easy),
            Question(text: "What is 16 ÷ 4?", choices: ["2", "3", "5", "4"], correctIndex: 3, subject: .math, difficulty: .easy),
            Question(text: "What is 11 + 9?", choices: ["18", "20", "19", "21"], correctIndex: 1, subject: .math, difficulty: .easy),
        ], isBuiltIn: true)
    }

    private var mathMedium: QuestionSet {
        QuestionSet(name: "Math Challenge", subject: .math, questions: [
            Question(text: "What is 15 × 4?", choices: ["55", "60", "50", "65"], correctIndex: 1, subject: .math, difficulty: .medium),
            Question(text: "What is 144 ÷ 12?", choices: ["10", "11", "13", "12"], correctIndex: 3, subject: .math, difficulty: .medium),
            Question(text: "What is 23 + 48?", choices: ["71", "61", "81", "91"], correctIndex: 0, subject: .math, difficulty: .medium),
            Question(text: "What is 7 × 8?", choices: ["48", "56", "54", "63"], correctIndex: 1, subject: .math, difficulty: .medium),
            Question(text: "What is 100 - 37?", choices: ["63", "57", "53", "67"], correctIndex: 0, subject: .math, difficulty: .medium),
            Question(text: "What is 9 × 9?", choices: ["72", "79", "89", "81"], correctIndex: 3, subject: .math, difficulty: .medium),
            Question(text: "What is 250 ÷ 5?", choices: ["40", "50", "45", "55"], correctIndex: 1, subject: .math, difficulty: .medium),
            Question(text: "What is 33 + 67?", choices: ["90", "95", "110", "100"], correctIndex: 3, subject: .math, difficulty: .medium),
            Question(text: "What is 12 × 11?", choices: ["121", "132", "144", "122"], correctIndex: 1, subject: .math, difficulty: .medium),
            Question(text: "What is 3² + 4²?", choices: ["20", "25", "24", "49"], correctIndex: 1, subject: .math, difficulty: .medium),
        ], isBuiltIn: true)
    }

    private var mathHard: QuestionSet {
        QuestionSet(name: "Math Master", subject: .math, questions: [
            Question(text: "What is 17 × 13?", choices: ["201", "221", "211", "231"], correctIndex: 1, subject: .math, difficulty: .hard),
            Question(text: "What is √196?", choices: ["12", "13", "15", "14"], correctIndex: 3, subject: .math, difficulty: .hard),
            Question(text: "What is 15% of 200?", choices: ["30", "25", "20", "35"], correctIndex: 0, subject: .math, difficulty: .hard),
            Question(text: "What is 1000 ÷ 8?", choices: ["120", "130", "125", "135"], correctIndex: 2, subject: .math, difficulty: .hard),
            Question(text: "What is 2⁸?", choices: ["128", "512", "256", "1024"], correctIndex: 2, subject: .math, difficulty: .hard),
            Question(text: "What is 7! / 5!?", choices: ["21", "42", "35", "56"], correctIndex: 1, subject: .math, difficulty: .hard),
            Question(text: "If x + 5 = 12, what is x?", choices: ["5", "7", "6", "8"], correctIndex: 1, subject: .math, difficulty: .hard),
            Question(text: "What is 3/4 + 1/2?", choices: ["1", "5/4", "Both B and C", "1 1/4"], correctIndex: 2, subject: .math, difficulty: .hard),
            Question(text: "What is the next prime after 29?", choices: ["33", "31", "30", "37"], correctIndex: 1, subject: .math, difficulty: .hard),
            Question(text: "What is 45 × 22?", choices: ["880", "990", "1000", "900"], correctIndex: 1, subject: .math, difficulty: .hard),
        ], isBuiltIn: true)
    }

    // MARK: Vocabulary

    private var vocabEasy: QuestionSet {
        QuestionSet(name: "Word Basics", subject: .vocabulary, questions: [
            Question(text: "What does 'happy' mean?", choices: ["Sad", "Angry", "Joyful", "Tired"], correctIndex: 2, subject: .vocabulary, difficulty: .easy),
            Question(text: "What is the opposite of 'big'?", choices: ["Small", "Tall", "Huge", "Wide"], correctIndex: 0, subject: .vocabulary, difficulty: .easy),
            Question(text: "Which word means 'to run fast'?", choices: ["Walk", "Crawl", "Skip", "Sprint"], correctIndex: 3, subject: .vocabulary, difficulty: .easy),
            Question(text: "What does 'brave' mean?", choices: ["Scared", "Courageous", "Lazy", "Quiet"], correctIndex: 1, subject: .vocabulary, difficulty: .easy),
            Question(text: "What is a synonym for 'pretty'?", choices: ["Ugly", "Dark", "Plain", "Beautiful"], correctIndex: 3, subject: .vocabulary, difficulty: .easy),
            Question(text: "What does 'enormous' mean?", choices: ["Very big", "Normal", "Tiny", "Flat"], correctIndex: 0, subject: .vocabulary, difficulty: .easy),
            Question(text: "What is the opposite of 'hot'?", choices: ["Warm", "Mild", "Cold", "Cool"], correctIndex: 2, subject: .vocabulary, difficulty: .easy),
            Question(text: "Which word means 'not real'?", choices: ["True", "Solid", "Fake", "Honest"], correctIndex: 2, subject: .vocabulary, difficulty: .easy),
            Question(text: "What does 'ancient' mean?", choices: ["New", "Shiny", "Broken", "Very old"], correctIndex: 3, subject: .vocabulary, difficulty: .easy),
            Question(text: "What is a synonym for 'smart'?", choices: ["Clever", "Foolish", "Slow", "Dull"], correctIndex: 0, subject: .vocabulary, difficulty: .easy),
        ], isBuiltIn: true)
    }

    private var vocabMedium: QuestionSet {
        QuestionSet(name: "Word Power", subject: .vocabulary, questions: [
            Question(text: "What does 'benevolent' mean?", choices: ["Mean", "Tired", "Kind", "Loud"], correctIndex: 2, subject: .vocabulary, difficulty: .medium),
            Question(text: "What is a synonym for 'peculiar'?", choices: ["Strange", "Normal", "Pretty", "Fast"], correctIndex: 0, subject: .vocabulary, difficulty: .medium),
            Question(text: "What does 'abundant' mean?", choices: ["Scarce", "Empty", "Lost", "Plentiful"], correctIndex: 3, subject: .vocabulary, difficulty: .medium),
            Question(text: "What is the opposite of 'transparent'?", choices: ["Clear", "Opaque", "Bright", "Glass"], correctIndex: 1, subject: .vocabulary, difficulty: .medium),
            Question(text: "What does 'diligent' mean?", choices: ["Lazy", "Sneaky", "Lucky", "Hardworking"], correctIndex: 3, subject: .vocabulary, difficulty: .medium),
            Question(text: "What is an antonym for 'expand'?", choices: ["Contract", "Inflate", "Grow", "Spread"], correctIndex: 0, subject: .vocabulary, difficulty: .medium),
            Question(text: "What does 'hesitate' mean?", choices: ["Rush", "Jump", "Pause", "Scream"], correctIndex: 2, subject: .vocabulary, difficulty: .medium),
            Question(text: "Which word means 'happening every year'?", choices: ["Daily", "Annual", "Monthly", "Weekly"], correctIndex: 1, subject: .vocabulary, difficulty: .medium),
            Question(text: "What does 'fragile' mean?", choices: ["Strong", "Heavy", "Easily broken", "Old"], correctIndex: 2, subject: .vocabulary, difficulty: .medium),
            Question(text: "What is a synonym for 'rapid'?", choices: ["Slow", "Steady", "Late", "Quick"], correctIndex: 3, subject: .vocabulary, difficulty: .medium),
        ], isBuiltIn: true)
    }

    private var vocabHard: QuestionSet {
        QuestionSet(name: "Word Wizard", subject: .vocabulary, questions: [
            Question(text: "What does 'ephemeral' mean?", choices: ["Eternal", "Beautiful", "Short-lived", "Dangerous"], correctIndex: 2, subject: .vocabulary, difficulty: .hard),
            Question(text: "What is a synonym for 'ubiquitous'?", choices: ["Everywhere", "Rare", "Hidden", "Unique"], correctIndex: 0, subject: .vocabulary, difficulty: .hard),
            Question(text: "What does 'pragmatic' mean?", choices: ["Dreamy", "Artistic", "Nervous", "Practical"], correctIndex: 3, subject: .vocabulary, difficulty: .hard),
            Question(text: "What does 'juxtapose' mean?", choices: ["Hide", "Destroy", "Place side by side", "Create"], correctIndex: 2, subject: .vocabulary, difficulty: .hard),
            Question(text: "What is an antonym of 'verbose'?", choices: ["Concise", "Wordy", "Long", "Detailed"], correctIndex: 0, subject: .vocabulary, difficulty: .hard),
            Question(text: "What does 'ambiguous' mean?", choices: ["Clear", "Bold", "Simple", "Uncertain"], correctIndex: 3, subject: .vocabulary, difficulty: .hard),
            Question(text: "What does 'meticulous' mean?", choices: ["Very careful", "Careless", "Fast", "Angry"], correctIndex: 0, subject: .vocabulary, difficulty: .hard),
            Question(text: "What is a synonym for 'tenacious'?", choices: ["Weak", "Gentle", "Persistent", "Quick"], correctIndex: 2, subject: .vocabulary, difficulty: .hard),
            Question(text: "What does 'paradigm' mean?", choices: ["Problem", "Paragraph", "Paradise", "Model or pattern"], correctIndex: 3, subject: .vocabulary, difficulty: .hard),
            Question(text: "What does 'quintessential' mean?", choices: ["Ordinary", "Perfect example", "Mysterious", "Forgotten"], correctIndex: 1, subject: .vocabulary, difficulty: .hard),
        ], isBuiltIn: true)
    }

    // MARK: Science

    private var scienceEasy: QuestionSet {
        QuestionSet(name: "Science Starters", subject: .science, questions: [
            Question(text: "What planet is closest to the Sun?", choices: ["Venus", "Earth", "Mercury", "Mars"], correctIndex: 2, subject: .science, difficulty: .easy),
            Question(text: "How many legs does a spider have?", choices: ["6", "10", "12", "8"], correctIndex: 3, subject: .science, difficulty: .easy),
            Question(text: "What gas do plants breathe in?", choices: ["Carbon dioxide", "Nitrogen", "Oxygen", "Helium"], correctIndex: 0, subject: .science, difficulty: .easy),
            Question(text: "What is H₂O?", choices: ["Salt", "Water", "Sugar", "Air"], correctIndex: 1, subject: .science, difficulty: .easy),
            Question(text: "Which organ pumps blood?", choices: ["Brain", "Lungs", "Liver", "Heart"], correctIndex: 3, subject: .science, difficulty: .easy),
            Question(text: "What is the largest planet?", choices: ["Jupiter", "Saturn", "Neptune", "Uranus"], correctIndex: 0, subject: .science, difficulty: .easy),
            Question(text: "What do caterpillars turn into?", choices: ["Beetles", "Bees", "Butterflies", "Birds"], correctIndex: 2, subject: .science, difficulty: .easy),
            Question(text: "What force keeps us on the ground?", choices: ["Magnetism", "Gravity", "Friction", "Wind"], correctIndex: 1, subject: .science, difficulty: .easy),
            Question(text: "How many bones does an adult have?", choices: ["106", "206", "156", "306"], correctIndex: 1, subject: .science, difficulty: .easy),
            Question(text: "What is the boiling point of water?", choices: ["50°C", "75°C", "150°C", "100°C"], correctIndex: 3, subject: .science, difficulty: .easy),
        ], isBuiltIn: true)
    }

    private var scienceMedium: QuestionSet {
        QuestionSet(name: "Science Explorer", subject: .science, questions: [
            Question(text: "What is the chemical symbol for gold?", choices: ["Go", "Au", "Gd", "Ag"], correctIndex: 1, subject: .science, difficulty: .medium),
            Question(text: "What type of rock is formed by lava?", choices: ["Sedimentary", "Limestone", "Metamorphic", "Igneous"], correctIndex: 3, subject: .science, difficulty: .medium),
            Question(text: "What is the powerhouse of the cell?", choices: ["Mitochondria", "Ribosome", "Nucleus", "Membrane"], correctIndex: 0, subject: .science, difficulty: .medium),
            Question(text: "What causes tides?", choices: ["Wind", "Earth's spin", "Moon's gravity", "Sun's heat"], correctIndex: 2, subject: .science, difficulty: .medium),
            Question(text: "What is the speed of light?", choices: ["300,000 km/s", "300 km/s", "3,000 km/s", "30,000 km/s"], correctIndex: 0, subject: .science, difficulty: .medium),
            Question(text: "What element do diamonds consist of?", choices: ["Silicon", "Iron", "Crystal", "Carbon"], correctIndex: 3, subject: .science, difficulty: .medium),
            Question(text: "Which planet has the most moons?", choices: ["Saturn", "Jupiter", "Uranus", "Neptune"], correctIndex: 0, subject: .science, difficulty: .medium),
            Question(text: "What part of the plant makes food?", choices: ["Root", "Leaf", "Stem", "Flower"], correctIndex: 1, subject: .science, difficulty: .medium),
            Question(text: "What is the hardest natural substance?", choices: ["Quartz", "Topaz", "Ruby", "Diamond"], correctIndex: 3, subject: .science, difficulty: .medium),
            Question(text: "What gas makes up most of Earth's atmosphere?", choices: ["Nitrogen", "Carbon dioxide", "Oxygen", "Hydrogen"], correctIndex: 0, subject: .science, difficulty: .medium),
        ], isBuiltIn: true)
    }

    private var scienceHard: QuestionSet {
        QuestionSet(name: "Science Master", subject: .science, questions: [
            Question(text: "What is the atomic number of carbon?", choices: ["4", "8", "6", "12"], correctIndex: 2, subject: .science, difficulty: .hard),
            Question(text: "What is the pH of pure water?", choices: ["7", "5", "0", "14"], correctIndex: 0, subject: .science, difficulty: .hard),
            Question(text: "What organelle is responsible for photosynthesis?", choices: ["Mitochondria", "Nucleus", "Chloroplast", "Vacuole"], correctIndex: 2, subject: .science, difficulty: .hard),
            Question(text: "What is Newton's first law about?", choices: ["Force", "Gravity", "Energy", "Inertia"], correctIndex: 3, subject: .science, difficulty: .hard),
            Question(text: "What is the most abundant element in the universe?", choices: ["Helium", "Hydrogen", "Oxygen", "Carbon"], correctIndex: 1, subject: .science, difficulty: .hard),
            Question(text: "What type of bond shares electrons?", choices: ["Ionic", "Metallic", "Hydrogen", "Covalent"], correctIndex: 3, subject: .science, difficulty: .hard),
            Question(text: "What is the SI unit of force?", choices: ["Newton", "Watt", "Joule", "Pascal"], correctIndex: 0, subject: .science, difficulty: .hard),
            Question(text: "What layer of Earth is liquid?", choices: ["Inner core", "Mantle", "Outer core", "Crust"], correctIndex: 2, subject: .science, difficulty: .hard),
            Question(text: "How many chromosomes do humans have?", choices: ["23", "46", "44", "48"], correctIndex: 1, subject: .science, difficulty: .hard),
            Question(text: "What is the process of cell division called?", choices: ["Osmosis", "Diffusion", "Synthesis", "Mitosis"], correctIndex: 3, subject: .science, difficulty: .hard),
        ], isBuiltIn: true)
    }

    // MARK: Geography & History

    private var geographySet: QuestionSet {
        QuestionSet(name: "World Explorer", subject: .geography, questions: [
            Question(text: "What is the largest continent?", choices: ["Africa", "Asia", "Europe", "North America"], correctIndex: 1, subject: .geography, difficulty: .medium),
            Question(text: "What is the longest river?", choices: ["Amazon", "Mississippi", "Nile", "Yangtze"], correctIndex: 2, subject: .geography, difficulty: .medium),
            Question(text: "What is the capital of France?", choices: ["Paris", "Berlin", "London", "Madrid"], correctIndex: 0, subject: .geography, difficulty: .easy),
            Question(text: "What ocean is the largest?", choices: ["Atlantic", "Indian", "Arctic", "Pacific"], correctIndex: 3, subject: .geography, difficulty: .easy),
            Question(text: "What country has the most people?", choices: ["USA", "China", "India", "Russia"], correctIndex: 2, subject: .geography, difficulty: .medium),
            Question(text: "What is the smallest country?", choices: ["Monaco", "Malta", "Vatican City", "Luxembourg"], correctIndex: 2, subject: .geography, difficulty: .medium),
            Question(text: "What is the tallest mountain?", choices: ["Everest", "Kilimanjaro", "K2", "Denali"], correctIndex: 0, subject: .geography, difficulty: .easy),
            Question(text: "What desert is the largest?", choices: ["Gobi", "Sahara", "Antarctic", "Arabian"], correctIndex: 2, subject: .geography, difficulty: .hard),
            Question(text: "What is the capital of Japan?", choices: ["Beijing", "Tokyo", "Seoul", "Bangkok"], correctIndex: 1, subject: .geography, difficulty: .easy),
            Question(text: "How many continents are there?", choices: ["5", "6", "8", "7"], correctIndex: 3, subject: .geography, difficulty: .easy),
        ], isBuiltIn: true)
    }

    private var historySet: QuestionSet {
        QuestionSet(name: "Time Travelers", subject: .history, questions: [
            Question(text: "Who was the first US President?", choices: ["Washington", "Jefferson", "Lincoln", "Adams"], correctIndex: 0, subject: .history, difficulty: .easy),
            Question(text: "In what year did WWII end?", choices: ["1943", "1945", "1944", "1946"], correctIndex: 1, subject: .history, difficulty: .medium),
            Question(text: "What ancient civilization built pyramids?", choices: ["Romans", "Greeks", "Vikings", "Egyptians"], correctIndex: 3, subject: .history, difficulty: .easy),
            Question(text: "Who painted the Mona Lisa?", choices: ["Michelangelo", "Raphael", "Da Vinci", "Picasso"], correctIndex: 2, subject: .history, difficulty: .medium),
            Question(text: "What year did humans land on the Moon?", choices: ["1969", "1967", "1965", "1971"], correctIndex: 0, subject: .history, difficulty: .medium),
            Question(text: "Who discovered America in 1492?", choices: ["Magellan", "Drake", "Cortez", "Columbus"], correctIndex: 3, subject: .history, difficulty: .easy),
            Question(text: "What empire was ruled by Caesars?", choices: ["Greek", "Roman", "Persian", "Ottoman"], correctIndex: 1, subject: .history, difficulty: .easy),
            Question(text: "What was the Titanic?", choices: ["Airplane", "Train", "Ship", "Submarine"], correctIndex: 2, subject: .history, difficulty: .easy),
            Question(text: "Who invented the lightbulb?", choices: ["Edison", "Tesla", "Bell", "Franklin"], correctIndex: 0, subject: .history, difficulty: .medium),
            Question(text: "What wall divided Berlin?", choices: ["Great Wall", "Hadrian's Wall", "Iron Curtain", "Berlin Wall"], correctIndex: 3, subject: .history, difficulty: .medium),
        ], isBuiltIn: true)
    }
}
