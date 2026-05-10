import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedRole: UserRole = .apprentice
    @Published var selectedPath: LearningPath = .ukWiring
    @Published var selectedSkill: SkillLevel = .beginner
    @Published var step = 0
}

@MainActor
final class FaultDiagnosisViewModel: ObservableObject {
    @Published private(set) var scenario: FaultScenario
    @Published private(set) var correctActions: [FaultAction] = []
    @Published private(set) var wrongActions: [FaultAction] = []
    @Published private(set) var safetyMistakes = 0
    @Published private(set) var elapsedSeconds = 0
    @Published var isComplete = false

    private var timer: Timer?

    init(scenario: FaultScenario) {
        self.scenario = scenario
    }

    var score: Int {
        let correctValue = correctActions.count * 25
        let wrongPenalty = wrongActions.count * 12
        let safetyPenalty = safetyMistakes * 20
        let timePenalty = elapsedSeconds / 20
        return max(0, min(100, correctValue - wrongPenalty - safetyPenalty - timePenalty + 20))
    }

    var passed: Bool { score >= scenario.passScore && !correctActions.isEmpty }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.elapsedSeconds += 1 }
        }
    }

    func choose(_ action: FaultAction) {
        guard !isComplete else { return }

        if scenario.expectedActions.contains(action), !correctActions.contains(action) {
            correctActions.append(action)
        } else if !wrongActions.contains(action) {
            wrongActions.append(action)
        }

        if scenario.unsafeActions.contains(action) {
            safetyMistakes += 1
        }

        if correctActions.count == scenario.expectedActions.count {
            finish()
        }
    }

    func finish() {
        isComplete = true
        timer?.invalidate()
        timer = nil
    }
}

@MainActor
final class WiringLabViewModel: ObservableObject {
    @Published var selectedPuzzle: WiringPuzzle
    @Published private(set) var userConnections: [WireConnection] = []
    @Published private(set) var mistakes = 0
    @Published private(set) var safetyWarnings = 0
    @Published var elapsedSeconds = 0

    let puzzles: [WiringPuzzle]

    init(puzzles: [WiringPuzzle] = MockDataService.shared.wiringPuzzles) {
        self.puzzles = puzzles
        selectedPuzzle = puzzles[0]
    }

    var correctConnections: Int {
        userConnections.filter { selectedPuzzle.expectedConnections.contains($0) }.count
    }

    var isComplete: Bool {
        correctConnections == selectedPuzzle.expectedConnections.count
    }

    var score: Int {
        let base = Int((Double(correctConnections) / Double(max(1, selectedPuzzle.expectedConnections.count))) * 100)
        return max(0, base - mistakes * 10 - safetyWarnings * 15 - elapsedSeconds / 30)
    }

    func select(_ puzzle: WiringPuzzle) {
        selectedPuzzle = puzzle
        reset()
    }

    func connect(from: CircuitNode, to: CircuitNode) {
        guard from.id != to.id else { return }
        let connection = WireConnection(from: from.id, to: to.id)
        guard !userConnections.contains(connection) else { return }

        userConnections.append(connection)
        if !selectedPuzzle.expectedConnections.contains(connection) {
            mistakes += 1
            if from.kind == .supply && to.kind == .earth || from.kind == .earth && to.kind == .supply {
                safetyWarnings += 1
            }
        }
    }

    func reset() {
        userConnections = []
        mistakes = 0
        safetyWarnings = 0
        elapsedSeconds = 0
    }
}

@MainActor
final class QuizViewModel: ObservableObject {
    @Published var selectedCategory: QuizCategory?
    @Published var mode: QuizMode = .practice
    @Published private(set) var currentIndex = 0
    @Published private(set) var selectedAnswerIndex: Int?
    @Published private(set) var score = 0
    @Published private(set) var submittedAnswers = 0
    @Published var timeRemaining = 60
    @Published var isFinished = false

    let allQuestions: [QuizQuestion]

    init(questions: [QuizQuestion] = MockDataService.shared.quizQuestions) {
        allQuestions = questions
    }

    var activeQuestions: [QuizQuestion] {
        let filtered = selectedCategory.map { category in
            allQuestions.filter { $0.category == category }
        } ?? allQuestions
        return Array(filtered.prefix(mode == .bossBattle ? 6 : filtered.count))
    }

    var currentQuestion: QuizQuestion? {
        guard !activeQuestions.isEmpty, currentIndex < activeQuestions.count else { return nil }
        return activeQuestions[currentIndex]
    }

    var progress: Double {
        guard !activeQuestions.isEmpty else { return 0 }
        return Double(currentIndex + 1) / Double(activeQuestions.count)
    }

    func start(mode: QuizMode, category: QuizCategory?) {
        self.mode = mode
        selectedCategory = category
        currentIndex = 0
        selectedAnswerIndex = nil
        score = 0
        submittedAnswers = 0
        timeRemaining = mode == .bossBattle ? 45 : 60
        isFinished = false
    }

    func chooseAnswer(_ index: Int) {
        guard selectedAnswerIndex == nil, let question = currentQuestion else { return }
        selectedAnswerIndex = index
        submittedAnswers += 1
        if index == question.correctAnswerIndex {
            score += mode == .bossBattle ? 150 : 100
        }
    }

    func next() {
        selectedAnswerIndex = nil
        if currentIndex + 1 >= activeQuestions.count {
            isFinished = true
        } else {
            currentIndex += 1
        }
    }

    func tick() {
        guard mode != .practice, !isFinished else { return }
        timeRemaining -= 1
        if timeRemaining <= 0 {
            isFinished = true
        }
    }
}

enum BattleState {
    case ready
    case countdown
    case running
    case finished
}

@MainActor
final class BattleViewModel: ObservableObject {
    @Published var opponentName = "Sparky-7"
    @Published var countdown = 3
    @Published var timeRemaining = 90
    @Published var playerProgress = 0.0
    @Published var opponentProgress = 0.0
    @Published var battleState: BattleState = .ready
    @Published var winnerText = ""

    func start() {
        countdown = 3
        timeRemaining = 90
        playerProgress = 0
        opponentProgress = 0
        winnerText = ""
        battleState = .countdown
    }

    func tick() {
        switch battleState {
        case .ready, .finished:
            return
        case .countdown:
            countdown -= 1
            if countdown <= 0 {
                battleState = .running
            }
        case .running:
            timeRemaining -= 1
            opponentProgress = min(1, opponentProgress + Double.random(in: 0.018...0.052))
            if timeRemaining <= 0 || playerProgress >= 1 || opponentProgress >= 1 {
                finish()
            }
        }
    }

    func playerAction() {
        guard battleState == .running else { return }
        playerProgress = min(1, playerProgress + Double.random(in: 0.09...0.16))
        if playerProgress >= 1 {
            finish()
        }
    }

    private func finish() {
        battleState = .finished
        if playerProgress >= opponentProgress {
            winnerText = "You diagnosed the fault first."
        } else {
            winnerText = "\(opponentName) reached the diagnosis first."
        }
    }
}

@MainActor
final class BusinessViewModel: ObservableObject {
    @Published private(set) var acceptedJobs: Set<String> = []
    @Published private(set) var purchasedUpgrades: Set<String> = []

    let jobs = MockDataService.shared.businessJobs
    let upgrades = MockDataService.shared.businessUpgrades
    let tools = MockDataService.shared.toolItems

    func accept(_ job: BusinessJob, appModel: AppViewModel) {
        guard appModel.profile.reputation >= job.requiredReputation else { return }
        acceptedJobs.insert(job.id)
        appModel.earnBusinessCash(job.payout, reputation: job.reputationReward)
    }

    func buy(_ upgrade: BusinessUpgrade, appModel: AppViewModel) {
        guard !purchasedUpgrades.contains(upgrade.id),
              appModel.spendBusinessCash(upgrade.cost, reputationBoost: upgrade.reputationBoost) else { return }
        purchasedUpgrades.insert(upgrade.id)
    }
}
