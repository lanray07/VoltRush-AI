import Foundation

struct MockDataService {
    static let shared = MockDataService()

    let careerLevels: [CareerLevel]
    let missions: [Mission]
    let faultScenarios: [FaultScenario]
    let quizQuestions: [QuizQuestion]
    let wiringPuzzles: [WiringPuzzle]
    let achievements: [Achievement]
    let storeProducts: [StoreProduct]
    let toolItems: [ToolItem]
    let businessUpgrades: [BusinessUpgrade]
    let businessJobs: [BusinessJob]

    private init() {
        careerLevels = [
            CareerLevel(id: "apprentice", title: "Apprentice", summary: "Build safe habits, identify circuits, and solve first-call faults.", unlockLevel: 1, rankTitle: "Trainee", missionIDs: ["dead-socket", "faulty-switch"]),
            CareerLevel(id: "journeyman", title: "Journeyman", summary: "Work faster, diagnose nuisance trips, and restore lighting under pressure.", unlockLevel: 4, rankTitle: "Circuit Solver", missionIDs: ["tripping-breaker", "lighting-circuit"]),
            CareerLevel(id: "master-electrician", title: "Master Electrician", summary: "Handle higher-risk panels, calculations, testing, and advanced installs.", unlockLevel: 8, rankTitle: "Fault Hunter", missionIDs: ["overloaded-panel", "ev-charger"]),
            CareerLevel(id: "contractor", title: "Contractor", summary: "Quote jobs, manage callouts, and protect reputation while solving faults.", unlockLevel: 12, rankTitle: "Master Tech", missionIDs: ["solar-inverter", "emergency-callout"]),
            CareerLevel(id: "company-owner", title: "Electrical Company Owner", summary: "Scale teams, take larger contracts, and run a profitable electrical business.", unlockLevel: 18, rankTitle: "Company Owner", missionIDs: ["emergency-callout", "overloaded-panel"])
        ]

        missions = [
            Mission(id: "dead-socket", careerLevelID: "apprentice", title: "Fix Dead Socket", brief: "A customer reports one socket outlet is dead while nearby outlets still work. Identify likely causes before any repair.", difficulty: .beginner, expectedTimeMinutes: 8, rewardCoins: 90, rewardXP: 160, safetyRisk: 2, iconSystemName: "powerplug.fill", tags: [.ukWiring, .faultFinding], learningPoints: ["Confirm isolation before working.", "Compare known-good outlets.", "Check protective device status and socket connections."]),
            Mission(id: "tripping-breaker", careerLevelID: "journeyman", title: "Diagnose Tripping Breaker", brief: "A breaker trips when a kitchen appliance is used. Separate overload, appliance fault, and circuit fault possibilities.", difficulty: .intermediate, expectedTimeMinutes: 10, rewardCoins: 140, rewardXP: 240, safetyRisk: 3, iconSystemName: "switch.2", tags: [.faultFinding, .nec], learningPoints: ["Do not repeatedly reset without diagnosis.", "Use load information and testing sequence.", "Document evidence before recommending work."]),
            Mission(id: "lighting-circuit", careerLevelID: "journeyman", title: "Restore Lighting Circuit", brief: "The upstairs lights are out after a switch replacement. Trace the permanent live, switched live, neutral, and CPC route.", difficulty: .intermediate, expectedTimeMinutes: 9, rewardCoins: 120, rewardXP: 210, safetyRisk: 3, iconSystemName: "lightbulb.fill", tags: [.ukWiring, .faultFinding], learningPoints: ["Identify conductors before disconnecting.", "Respect local color coding and sleeving.", "Verify continuity and polarity."]),
            Mission(id: "faulty-switch", careerLevelID: "apprentice", title: "Replace Faulty Switch", brief: "A one-way light switch crackles and intermittently fails. Plan a safe replacement and confirm the circuit afterwards.", difficulty: .beginner, expectedTimeMinutes: 7, rewardCoins: 80, rewardXP: 130, safetyRisk: 2, iconSystemName: "light.switch", tags: [.ukWiring, .faultFinding], learningPoints: ["Isolate and prove dead.", "Transfer conductors one at a time.", "Confirm operation and faceplate integrity."]),
            Mission(id: "overloaded-panel", careerLevelID: "master-electrician", title: "Balance Overloaded Panel", brief: "A small workshop panel has frequent nuisance trips during peak tool use. Review load distribution and safe capacity.", difficulty: .advanced, expectedTimeMinutes: 14, rewardCoins: 240, rewardXP: 380, safetyRisk: 4, iconSystemName: "rectangle.3.group.bubble.left.fill", tags: [.faultFinding, .nec], learningPoints: ["Calculate expected demand.", "Never exceed protective device ratings.", "Recommend compliant remedial work."]),
            Mission(id: "ev-charger", careerLevelID: "master-electrician", title: "Install EV Charger", brief: "Plan a domestic EV charger circuit with protection, routing, load considerations, and handover checks.", difficulty: .advanced, expectedTimeMinutes: 16, rewardCoins: 280, rewardXP: 430, safetyRisk: 4, iconSystemName: "ev.charger.fill", tags: [.evChargers, .ukWiring], learningPoints: ["Confirm supply capacity.", "Choose suitable protective devices.", "Record commissioning checks."]),
            Mission(id: "solar-inverter", careerLevelID: "contractor", title: "Troubleshoot Solar Inverter", brief: "A solar inverter reports intermittent grid fault. Review AC/DC isolation, inverter logs, and safe testing order.", difficulty: .expert, expectedTimeMinutes: 18, rewardCoins: 360, rewardXP: 520, safetyRisk: 5, iconSystemName: "sun.max.fill", tags: [.solar, .faultFinding], learningPoints: ["Respect live DC hazards.", "Use manufacturer guidance.", "Escalate where specialist approval is needed."]),
            Mission(id: "emergency-callout", careerLevelID: "contractor", title: "Emergency Callout", brief: "A shop has partial power loss just before opening. Prioritize safety, continuity of supply, and clear customer communication.", difficulty: .expert, expectedTimeMinutes: 15, rewardCoins: 330, rewardXP: 500, safetyRisk: 5, iconSystemName: "phone.badge.waveform.fill", tags: [.faultFinding, .nec], learningPoints: ["Triage critical loads.", "Protect people before property.", "Record temporary measures clearly."])
        ]

        faultScenarios = [
            FaultScenario(id: "socket-open-neutral", title: "Dead Socket: Open Neutral", faultDescription: "One socket is dead. The breaker is on and other outlets on the circuit appear normal.", difficulty: .beginner, expectedActions: [.visualInspection, .voltageTester, .multimeter, .continuityTest], unsafeActions: [.continuityTest], explanation: "A safe sequence starts with visual checks and proving voltage state before dead testing. Continuity testing belongs after isolation is confirmed.", passScore: 70),
            FaultScenario(id: "breaker-overload", title: "Tripping Breaker: Overload", faultDescription: "A breaker trips when two high-load appliances run together.", difficulty: .intermediate, expectedActions: [.visualInspection, .breakerCheck, .multimeter, .wiringDiagramReview], unsafeActions: [.continuityTest], explanation: "The pattern points toward load and circuit capacity. Repeated resets can hide risk; review demand and test safely.", passScore: 75),
            FaultScenario(id: "lighting-miswire", title: "Lighting Circuit: Switched Live Mix-up", faultDescription: "A replacement switch leaves the light permanently on.", difficulty: .intermediate, expectedActions: [.visualInspection, .voltageTester, .wiringDiagramReview, .continuityTest], unsafeActions: [], explanation: "Switch loops need conductor identification. Marking the switched live and confirming continuity prevents guessing.", passScore: 72)
        ]

        quizQuestions = [
            QuizQuestion(id: "q-safety-1", category: .safety, prompt: "Before replacing a light switch, what is the safest first step?", answers: ["Turn the lamp off", "Isolate and prove dead", "Remove the faceplate", "Touch the CPC"], correctAnswerIndex: 1, explanation: "Isolation and proving dead reduce the risk of contact with live parts.", difficulty: .beginner),
            QuizQuestion(id: "q-tools-1", category: .tools, prompt: "Which tool is most appropriate for confirming voltage level between conductors?", answers: ["Insulated screwdriver", "Voltage tester or multimeter used correctly", "Tape measure", "Cable clips"], correctAnswerIndex: 1, explanation: "Use a suitable tester and follow the correct proving process.", difficulty: .beginner),
            QuizQuestion(id: "q-regs-1", category: .wiringRegulations, prompt: "Why should local wiring regulations be checked before selecting a protective device?", answers: ["They make drawings prettier", "They define color names only", "They set requirements for safe design and installation", "They replace manufacturer instructions"], correctAnswerIndex: 2, explanation: "Regulations and standards guide compliant design, installation, inspection, and testing.", difficulty: .intermediate),
            QuizQuestion(id: "q-fault-1", category: .faultFinding, prompt: "A breaker trips immediately after reset. What should you avoid?", answers: ["Investigating connected loads", "Repeatedly resetting without diagnosis", "Checking circuit history", "Recording symptoms"], correctAnswerIndex: 1, explanation: "Repeated resets may worsen a fault or create risk.", difficulty: .beginner),
            QuizQuestion(id: "q-calc-1", category: .calculations, prompt: "Using P = V x I, what current is drawn by a 2,300 W load at 230 V?", answers: ["5 A", "10 A", "13 A", "23 A"], correctAnswerIndex: 1, explanation: "2,300 W divided by 230 V equals 10 A.", difficulty: .beginner),
            QuizQuestion(id: "q-ev-1", category: .evChargers, prompt: "What should be considered before adding an EV charger to an existing supply?", answers: ["Paint color", "Supply capacity and protective requirements", "Only the cable label", "Wi-Fi signal strength only"], correctAnswerIndex: 1, explanation: "EV chargers can be significant loads and must be designed and protected correctly.", difficulty: .intermediate),
            QuizQuestion(id: "q-solar-1", category: .solar, prompt: "What special hazard is common in solar PV diagnosis?", answers: ["DC conductors may remain energized in light", "PV cables are always safe at night", "Inverters remove all need for isolation", "Labels replace testing"], correctAnswerIndex: 0, explanation: "PV DC circuits can remain energized when panels receive light.", difficulty: .advanced),
            QuizQuestion(id: "q-test-1", category: .inspectionTesting, prompt: "Why record test results after completing work?", answers: ["Only for marketing", "To support verification, traceability, and compliance", "To increase cable length", "To avoid using labels"], correctAnswerIndex: 1, explanation: "Test records help prove the work was checked and support future diagnosis.", difficulty: .intermediate)
        ]

        wiringPuzzles = [
            WiringPuzzle(id: "simple-lighting", title: "Simple Lighting Circuit", brief: "Connect supply, switch, lamp, neutral, and protective earth in the safe order.", difficulty: .beginner, nodes: [
                CircuitNode(id: "supply-live", label: "Live", kind: .supply, x: 0.16, y: 0.20),
                CircuitNode(id: "switch", label: "Switch", kind: .switchGear, x: 0.50, y: 0.22),
                CircuitNode(id: "lamp-live", label: "Lamp L", kind: .load, x: 0.82, y: 0.22),
                CircuitNode(id: "neutral", label: "Neutral", kind: .supply, x: 0.18, y: 0.74),
                CircuitNode(id: "lamp-neutral", label: "Lamp N", kind: .load, x: 0.82, y: 0.74),
                CircuitNode(id: "earth", label: "CPC", kind: .earth, x: 0.50, y: 0.86)
            ], expectedConnections: [
                WireConnection(from: "supply-live", to: "switch"),
                WireConnection(from: "switch", to: "lamp-live"),
                WireConnection(from: "neutral", to: "lamp-neutral"),
                WireConnection(from: "earth", to: "lamp-live")
            ], safetyRules: ["Protective conductor must be continuous.", "Neutral must not be switched in this beginner puzzle."]),
            WiringPuzzle(id: "socket-circuit", title: "Socket Circuit", brief: "Build a basic socket outlet circuit with live, neutral, and CPC continuity.", difficulty: .beginner, nodes: [
                CircuitNode(id: "breaker", label: "Breaker", kind: .protectiveDevice, x: 0.14, y: 0.22),
                CircuitNode(id: "socket-l", label: "Socket L", kind: .load, x: 0.78, y: 0.22),
                CircuitNode(id: "neutral-bar", label: "N Bar", kind: .supply, x: 0.14, y: 0.56),
                CircuitNode(id: "socket-n", label: "Socket N", kind: .load, x: 0.78, y: 0.56),
                CircuitNode(id: "earth-bar", label: "Earth", kind: .earth, x: 0.14, y: 0.82),
                CircuitNode(id: "socket-e", label: "Socket E", kind: .earth, x: 0.78, y: 0.82)
            ], expectedConnections: [
                WireConnection(from: "breaker", to: "socket-l"),
                WireConnection(from: "neutral-bar", to: "socket-n"),
                WireConnection(from: "earth-bar", to: "socket-e")
            ], safetyRules: ["Live, neutral, and CPC must each terminate correctly."]),
            WiringPuzzle(id: "ring-final", title: "Ring Final Circuit", brief: "Complete the return path for live, neutral, and CPC around two socket outlets.", difficulty: .intermediate, nodes: [
                CircuitNode(id: "mcb", label: "MCB", kind: .protectiveDevice, x: 0.14, y: 0.20),
                CircuitNode(id: "socket-a", label: "Socket A", kind: .load, x: 0.50, y: 0.18),
                CircuitNode(id: "socket-b", label: "Socket B", kind: .load, x: 0.84, y: 0.20),
                CircuitNode(id: "nbar", label: "N Bar", kind: .supply, x: 0.14, y: 0.62),
                CircuitNode(id: "cpc", label: "CPC", kind: .earth, x: 0.14, y: 0.84)
            ], expectedConnections: [
                WireConnection(from: "mcb", to: "socket-a"),
                WireConnection(from: "socket-a", to: "socket-b"),
                WireConnection(from: "socket-b", to: "mcb"),
                WireConnection(from: "nbar", to: "socket-a"),
                WireConnection(from: "nbar", to: "socket-b"),
                WireConnection(from: "cpc", to: "socket-a"),
                WireConnection(from: "cpc", to: "socket-b")
            ], safetyRules: ["Ring continuity must be verified by testing.", "This simulator is not a design substitute."]),
            WiringPuzzle(id: "breaker-panel", title: "Breaker Panel", brief: "Match protective devices to outgoing circuits and neutral/earth bars.", difficulty: .advanced, nodes: [
                CircuitNode(id: "main", label: "Main", kind: .protectiveDevice, x: 0.16, y: 0.18),
                CircuitNode(id: "rcd", label: "RCD", kind: .protectiveDevice, x: 0.50, y: 0.20),
                CircuitNode(id: "lighting", label: "Lights", kind: .load, x: 0.82, y: 0.24),
                CircuitNode(id: "sockets", label: "Sockets", kind: .load, x: 0.82, y: 0.52),
                CircuitNode(id: "nbar-panel", label: "N Bar", kind: .supply, x: 0.18, y: 0.68),
                CircuitNode(id: "earth-panel", label: "Earth", kind: .earth, x: 0.18, y: 0.86)
            ], expectedConnections: [
                WireConnection(from: "main", to: "rcd"),
                WireConnection(from: "rcd", to: "lighting"),
                WireConnection(from: "rcd", to: "sockets"),
                WireConnection(from: "nbar-panel", to: "lighting"),
                WireConnection(from: "nbar-panel", to: "sockets"),
                WireConnection(from: "earth-panel", to: "lighting"),
                WireConnection(from: "earth-panel", to: "sockets")
            ], safetyRules: ["Protective device choice must match the real design and local code."]),
            WiringPuzzle(id: "ev-charger-circuit", title: "EV Charger Circuit", brief: "Route supply through protection to a charger with earthing and commissioning checks.", difficulty: .advanced, nodes: [
                CircuitNode(id: "supply", label: "Supply", kind: .supply, x: 0.14, y: 0.22),
                CircuitNode(id: "rcbo", label: "RCBO", kind: .protectiveDevice, x: 0.44, y: 0.22),
                CircuitNode(id: "isolator", label: "Isolator", kind: .switchGear, x: 0.70, y: 0.22),
                CircuitNode(id: "charger", label: "Charger", kind: .load, x: 0.86, y: 0.52),
                CircuitNode(id: "earth-ev", label: "Earth", kind: .earth, x: 0.44, y: 0.82),
                CircuitNode(id: "neutral-ev", label: "Neutral", kind: .supply, x: 0.14, y: 0.70)
            ], expectedConnections: [
                WireConnection(from: "supply", to: "rcbo"),
                WireConnection(from: "rcbo", to: "isolator"),
                WireConnection(from: "isolator", to: "charger"),
                WireConnection(from: "neutral-ev", to: "charger"),
                WireConnection(from: "earth-ev", to: "charger")
            ], safetyRules: ["EV charger design may require specialist protection and supply assessment."]),
            WiringPuzzle(id: "solar-inverter", title: "Solar Inverter Circuit", brief: "Connect PV array, DC isolator, inverter, AC protection, and earth reference.", difficulty: .expert, nodes: [
                CircuitNode(id: "pv", label: "PV", kind: .supply, x: 0.12, y: 0.22),
                CircuitNode(id: "dc-iso", label: "DC Iso", kind: .switchGear, x: 0.38, y: 0.22),
                CircuitNode(id: "inverter", label: "Inverter", kind: .load, x: 0.64, y: 0.22),
                CircuitNode(id: "ac-iso", label: "AC Iso", kind: .switchGear, x: 0.84, y: 0.46),
                CircuitNode(id: "consumer", label: "AC Board", kind: .protectiveDevice, x: 0.60, y: 0.78),
                CircuitNode(id: "earth-solar", label: "Earth", kind: .earth, x: 0.20, y: 0.82)
            ], expectedConnections: [
                WireConnection(from: "pv", to: "dc-iso"),
                WireConnection(from: "dc-iso", to: "inverter"),
                WireConnection(from: "inverter", to: "ac-iso"),
                WireConnection(from: "ac-iso", to: "consumer"),
                WireConnection(from: "earth-solar", to: "inverter")
            ], safetyRules: ["PV DC circuits can remain energized in daylight.", "Follow manufacturer and local requirements."])
        ]

        achievements = [
            Achievement(id: "first-login", title: "First Spark", description: "Started the VoltRush journey.", icon: "sparkles", coinReward: 25),
            Achievement(id: "safe-start", title: "Safety First", description: "Reviewed the simulator safety disclaimer.", icon: "shield.fill", coinReward: 50),
            Achievement(id: "fault-pass", title: "Fault Hunter", description: "Passed a fault diagnosis scenario.", icon: "waveform.path.ecg", coinReward: 100),
            Achievement(id: "quiz-streak", title: "Quiz Surge", description: "Answered three quiz questions correctly.", icon: "bolt.circle.fill", coinReward: 120)
        ]

        storeProducts = [
            StoreProduct(id: "com.voltrushai.premium.monthly", displayName: "Monthly Premium", priceText: "GBP 9.99/month", kind: .autoRenewableSubscription, description: "Unlimited missions, advanced scenarios, AI Mentor, analytics, tournaments, and contractor mode.", isFeatured: true),
            StoreProduct(id: "com.voltrushai.premium.yearly", displayName: "Yearly Premium", priceText: "GBP 79.99/year", kind: .autoRenewableSubscription, description: "Best value annual access to all premium learning modes.", isFeatured: true),
            StoreProduct(id: "com.voltrushai.pack.ukwiring", displayName: "UK Wiring Pack", priceText: "One-time purchase", kind: .nonConsumable, description: "Extra UK wiring regulation quizzes, missions, and wiring puzzles.", isFeatured: false),
            StoreProduct(id: "com.voltrushai.pack.nec", displayName: "NEC Pack", priceText: "One-time purchase", kind: .nonConsumable, description: "Extra NEC-focused practice content and fault diagnosis missions.", isFeatured: false),
            StoreProduct(id: "com.voltrushai.pack.solar_ev", displayName: "Solar & EV Pack", priceText: "One-time purchase", kind: .nonConsumable, description: "Advanced solar inverter and EV charger simulations.", isFeatured: false),
            StoreProduct(id: "com.voltrushai.coins.small", displayName: "Small Coin Pack", priceText: "Consumable", kind: .consumable, description: "Virtual coins for cosmetic boosts and simulator shop items.", isFeatured: false)
        ]

        toolItems = [
            ToolItem(id: "multimeter-pro", name: "Pro Multimeter", description: "Improves fault score margin in simulated diagnoses.", cost: 350, icon: "gauge.with.dots.needle.67percent", performanceBoost: 8),
            ToolItem(id: "insulated-kit", name: "Insulated Tool Kit", description: "Reduces safety penalty in timed missions.", cost: 500, icon: "wrench.and.screwdriver.fill", performanceBoost: 12),
            ToolItem(id: "thermal-camera", name: "Thermal Camera", description: "Unlocks advanced panel clues in contractor jobs.", cost: 900, icon: "camera.metering.matrix", performanceBoost: 18)
        ]

        businessUpgrades = [
            BusinessUpgrade(id: "van-rack", name: "Van Racking", description: "Organize stock and finish small jobs faster.", cost: 700, reputationBoost: 5, icon: "truck.box.fill"),
            BusinessUpgrade(id: "hire-apprentice", name: "Hire Apprentice", description: "Take on more jobs while mentoring a trainee.", cost: 1500, reputationBoost: 9, icon: "person.badge.plus.fill"),
            BusinessUpgrade(id: "test-kit", name: "Inspection Test Kit", description: "Unlock larger inspection and testing contracts.", cost: 2200, reputationBoost: 14, icon: "checklist.checked")
        ]

        businessJobs = [
            BusinessJob(id: "small-shop", title: "Small Shop Lighting Repair", payout: 420, reputationReward: 4, requiredReputation: 0, difficulty: .beginner),
            BusinessJob(id: "rental-eicr", title: "Rental Inspection Prep", payout: 780, reputationReward: 7, requiredReputation: 35, difficulty: .intermediate),
            BusinessJob(id: "ev-quote", title: "EV Charger Quote", payout: 980, reputationReward: 9, requiredReputation: 45, difficulty: .advanced),
            BusinessJob(id: "office-refit", title: "Office Refit Contract", payout: 2600, reputationReward: 18, requiredReputation: 65, difficulty: .expert)
        ]
    }
}
