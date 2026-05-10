import Foundation
import SwiftUI

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case apprentice = "Apprentice"
    case student = "Student"
    case qualifiedElectrician = "Qualified Electrician"
    case contractor = "Contractor"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .apprentice: "graduationcap.fill"
        case .student: "book.fill"
        case .qualifiedElectrician: "checkmark.seal.fill"
        case .contractor: "briefcase.fill"
        }
    }
}

enum LearningPath: String, CaseIterable, Identifiable, Codable {
    case ukWiring = "UK Wiring"
    case nec = "NEC"
    case solar = "Solar"
    case evChargers = "EV Chargers"
    case faultFinding = "Fault Finding"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .ukWiring: "building.columns.fill"
        case .nec: "flag.fill"
        case .solar: "sun.max.fill"
        case .evChargers: "ev.charger.fill"
        case .faultFinding: "waveform.path.ecg"
        }
    }
}

enum SkillLevel: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case developing = "Developing"
    case confident = "Confident"
    case advanced = "Advanced"

    var id: String { rawValue }
}

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"

    var color: Color {
        switch self {
        case .beginner: VoltTheme.success
        case .intermediate: VoltTheme.neonBlue
        case .advanced: VoltTheme.warning
        case .expert: VoltTheme.danger
        }
    }
}

enum Rank: String, Codable {
    case trainee = "Trainee"
    case cableRunner = "Cable Runner"
    case circuitSolver = "Circuit Solver"
    case faultHunter = "Fault Hunter"
    case masterTech = "Master Tech"
    case companyOwner = "Company Owner"

    static func rank(for level: Int) -> Rank {
        switch level {
        case 0...2: .trainee
        case 3...5: .cableRunner
        case 6...9: .circuitSolver
        case 10...14: .faultHunter
        case 15...24: .masterTech
        default: .companyOwner
        }
    }
}

struct UserProfile: Identifiable, Codable, Hashable {
    var id = UUID()
    var displayName = "Volt Rookie"
    var role: UserRole = .apprentice
    var learningPath: LearningPath = .ukWiring
    var skillLevel: SkillLevel = .beginner
    var level = 1
    var xp = 120
    var coins = 450
    var streak = 3
    var rank: Rank = .trainee
    var badges: [String] = ["safe-start"]
    var completedMissionIDs: Set<String> = []
    var unlockedAchievements: Set<String> = ["first-login"]
    var businessCash = 1200
    var reputation = 42
    var isPremium = false

    var xpToNextLevel: Int { max(500, level * 500) }
    var xpProgress: Double { min(Double(xp) / Double(xpToNextLevel), 1) }

    mutating func addXP(_ amount: Int) {
        xp += amount
        while xp >= xpToNextLevel {
            xp -= xpToNextLevel
            level += 1
        }
        rank = Rank.rank(for: level)
    }
}

struct CareerLevel: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let summary: String
    let unlockLevel: Int
    let rankTitle: String
    let missionIDs: [String]
}

struct Mission: Identifiable, Codable, Hashable {
    let id: String
    let careerLevelID: String
    let title: String
    let brief: String
    let difficulty: Difficulty
    let expectedTimeMinutes: Int
    let rewardCoins: Int
    let rewardXP: Int
    let safetyRisk: Int
    let iconSystemName: String
    let tags: [LearningPath]
    let learningPoints: [String]
}

enum FaultAction: String, CaseIterable, Identifiable, Codable {
    case visualInspection = "Visual inspection"
    case voltageTester = "Voltage tester"
    case multimeter = "Multimeter"
    case continuityTest = "Continuity test"
    case breakerCheck = "Breaker check"
    case wiringDiagramReview = "Wiring diagram review"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .visualInspection: "eye.fill"
        case .voltageTester: "bolt.badge.a.fill"
        case .multimeter: "gauge.with.dots.needle.33percent"
        case .continuityTest: "point.3.connected.trianglepath.dotted"
        case .breakerCheck: "switch.2"
        case .wiringDiagramReview: "doc.text.magnifyingglass"
        }
    }
}

struct FaultScenario: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let faultDescription: String
    let difficulty: Difficulty
    let expectedActions: [FaultAction]
    let unsafeActions: [FaultAction]
    let explanation: String
    let passScore: Int
}

enum QuizCategory: String, CaseIterable, Identifiable, Codable {
    case safety = "Safety"
    case tools = "Tools"
    case wiringRegulations = "Wiring Regulations"
    case faultFinding = "Fault Finding"
    case calculations = "Calculations"
    case evChargers = "EV Chargers"
    case solar = "Solar"
    case inspectionTesting = "Inspection & Testing"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .safety: "shield.lefthalf.filled"
        case .tools: "wrench.and.screwdriver.fill"
        case .wiringRegulations: "book.closed.fill"
        case .faultFinding: "stethoscope"
        case .calculations: "function"
        case .evChargers: "ev.charger.fill"
        case .solar: "sun.max.fill"
        case .inspectionTesting: "checklist.checked"
        }
    }
}

enum QuizMode: String, CaseIterable, Identifiable, Codable {
    case practice = "Practice"
    case timed = "Timed"
    case bossBattle = "Boss Battle"

    var id: String { rawValue }
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let category: QuizCategory
    let prompt: String
    let answers: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let difficulty: Difficulty
}

enum CircuitNodeKind: String, Codable {
    case supply
    case switchGear
    case load
    case protectiveDevice
    case earth
}

struct CircuitNode: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let kind: CircuitNodeKind
    let x: Double
    let y: Double
}

struct WireConnection: Identifiable, Codable, Hashable {
    let id: String
    let from: String
    let to: String

    init(from: String, to: String) {
        let sorted = [from, to].sorted()
        self.id = sorted.joined(separator: "-")
        self.from = sorted[0]
        self.to = sorted[1]
    }
}

struct WiringPuzzle: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let brief: String
    let difficulty: Difficulty
    let nodes: [CircuitNode]
    let expectedConnections: [WireConnection]
    let safetyRules: [String]
}

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let coinReward: Int
}

enum StoreProductKind: String, Codable {
    case autoRenewableSubscription
    case nonConsumable
    case consumable
}

struct StoreProduct: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let priceText: String
    let kind: StoreProductKind
    let description: String
    let isFeatured: Bool
}

struct ToolItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let icon: String
    let performanceBoost: Int
}

struct BusinessUpgrade: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let reputationBoost: Int
    let icon: String
}

struct BusinessJob: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let payout: Int
    let reputationReward: Int
    let requiredReputation: Int
    let difficulty: Difficulty
}

struct MentorMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

struct MissionResult: Identifiable, Hashable {
    let id = UUID()
    let mission: Mission
    let passed: Bool
    let xpEarned: Int
    let coinsEarned: Int
    let didLevelUp: Bool
    let highlights: [String]
}
