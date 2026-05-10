import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile
    @Published var recentResult: MissionResult?
    @Published var achievementBanner: Achievement?

    let dataService: MockDataService
    private let profileKey = "VoltRushAI.profile"

    var dailyMission: Mission {
        dataService.missions[Calendar.current.component(.day, from: .now) % dataService.missions.count]
    }

    init(dataService: MockDataService = .shared) {
        self.dataService = dataService
        if let saved = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: saved) {
            profile = decoded
        } else {
            profile = UserProfile()
        }
    }

    func configure(role: UserRole, path: LearningPath, skill: SkillLevel) {
        profile.role = role
        profile.learningPath = path
        profile.skillLevel = skill
        save()
    }

    func completeMission(_ mission: Mission, passed: Bool = true) {
        let oldLevel = profile.level
        let earnedXP = passed ? mission.rewardXP : max(25, mission.rewardXP / 4)
        let earnedCoins = passed ? mission.rewardCoins : max(10, mission.rewardCoins / 4)

        profile.completedMissionIDs.insert(mission.id)
        profile.addXP(earnedXP)
        profile.coins += earnedCoins
        profile.streak += passed ? 1 : 0

        let result = MissionResult(
            mission: mission,
            passed: passed,
            xpEarned: earnedXP,
            coinsEarned: earnedCoins,
            didLevelUp: profile.level > oldLevel,
            highlights: passed ? mission.learningPoints : ["Review the safety order before retrying.", "Use the mentor explanations after each wrong action."]
        )
        recentResult = result

        if profile.completedMissionIDs.count >= 1 {
            unlockAchievementIfNeeded("fault-pass")
        }

        save()
    }

    func addCoins(_ amount: Int) {
        profile.coins += amount
        save()
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard profile.coins >= amount else { return false }
        profile.coins -= amount
        save()
        return true
    }

    func setPremiumUnlocked(_ unlocked: Bool) {
        profile.isPremium = unlocked
        save()
    }

    func earnBusinessCash(_ amount: Int, reputation: Int) {
        profile.businessCash += amount
        profile.reputation += reputation
        save()
    }

    func spendBusinessCash(_ amount: Int, reputationBoost: Int) -> Bool {
        guard profile.businessCash >= amount else { return false }
        profile.businessCash -= amount
        profile.reputation += reputationBoost
        save()
        return true
    }

    func unlockAchievementIfNeeded(_ id: String) {
        guard !profile.unlockedAchievements.contains(id),
              let achievement = dataService.achievements.first(where: { $0.id == id }) else { return }
        profile.unlockedAchievements.insert(id)
        profile.coins += achievement.coinReward
        achievementBanner = achievement
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
}
