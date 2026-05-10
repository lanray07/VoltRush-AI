import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appModel: AppViewModel

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    statsGrid
                    dailyMission
                    quickActions
                    leaderboardPlaceholder
                    achievements
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Dashboard")
    }

    private var hero: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Level \(appModel.profile.level)")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.white)
                        Text(appModel.profile.rank.rawValue)
                            .font(.headline)
                            .foregroundStyle(VoltTheme.neonYellow)
                    }
                    Spacer()
                    Image(systemName: "bolt.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(VoltTheme.electricGradient)
                }
                XPProgressBar(progress: appModel.profile.xpProgress, height: 12)
                Text("\(appModel.profile.xp) / \(appModel.profile.xpToNextLevel) XP to next level")
                    .font(.caption)
                    .foregroundStyle(VoltTheme.mutedText)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatTile(title: "Coins", value: "\(appModel.profile.coins)", systemImage: "creditcard.fill", tint: VoltTheme.neonYellow)
            StatTile(title: "Streak", value: "\(appModel.profile.streak) days", systemImage: "flame.fill", tint: VoltTheme.warning)
            StatTile(title: "Role", value: appModel.profile.role.rawValue, systemImage: appModel.profile.role.icon, tint: VoltTheme.success)
            StatTile(title: "Path", value: appModel.profile.learningPath.rawValue, systemImage: appModel.profile.learningPath.icon, tint: VoltTheme.purple)
        }
    }

    private var dailyMission: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Daily Mission", subtitle: "Keep your streak alive with one focused job.")
                HStack {
                    Image(systemName: appModel.dailyMission.iconSystemName)
                        .font(.title2)
                        .foregroundStyle(VoltTheme.neonYellow)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appModel.dailyMission.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(appModel.dailyMission.rewardXP) XP · \(appModel.dailyMission.rewardCoins) coins")
                            .font(.caption)
                            .foregroundStyle(VoltTheme.mutedText)
                    }
                    Spacer()
                    NavigationLink {
                        MissionDetailView(mission: appModel.dailyMission)
                    } label: {
                        Text("Start")
                            .font(.subheadline.weight(.bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(VoltTheme.neonYellow, in: Capsule())
                            .foregroundStyle(.black)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Quick Launch")
            FeatureTile(title: "Career Mode", subtitle: "Progress from apprentice to company owner.", systemImage: "map.fill", destination: CareerModeView())
            FeatureTile(title: "Fault Battle", subtitle: "Race an AI opponent through diagnosis.", systemImage: "person.2.wave.2.fill", tint: VoltTheme.warning, destination: FaultBattleView())
            FeatureTile(title: "Wiring Lab", subtitle: "Drag wires and solve circuit puzzles.", systemImage: "cable.connector", tint: VoltTheme.success, destination: WiringLabView())
            FeatureTile(title: "Quiz Arena", subtitle: "Practice, timed runs, and boss battles.", systemImage: "questionmark.circle.fill", tint: VoltTheme.purple, destination: QuizArenaView())
            FeatureTile(title: "AI Mentor", subtitle: "Ask for safety, formulas, and explanations.", systemImage: "message.fill", tint: VoltTheme.neonBlue, destination: AIMentorView())
            FeatureTile(title: "Contractor Business", subtitle: "Accept jobs, upgrade your van, and build reputation.", systemImage: "briefcase.fill", tint: VoltTheme.neonYellow, destination: BusinessModeView())
        }
    }

    private var achievements: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Badges")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(appModel.dataService.achievements) { achievement in
                        VStack(spacing: 8) {
                            Image(systemName: achievement.icon)
                                .font(.title2)
                                .foregroundStyle(appModel.profile.unlockedAchievements.contains(achievement.id) ? VoltTheme.neonYellow : VoltTheme.mutedText)
                            Text(achievement.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        .frame(width: 118, height: 92)
                        .background(VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }

    private var leaderboardPlaceholder: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Leaderboard", subtitle: "Local preview until online seasons are connected.")
                // TODO: Connect a real leaderboard backend with anti-cheat checks, privacy review, and Game Center or server-side identity.
                LeaderboardRow(position: 1, name: appModel.profile.displayName, score: appModel.profile.level * 820 + appModel.profile.xp, isPlayer: true)
                LeaderboardRow(position: 2, name: "FusePilot", score: 2180, isPlayer: false)
                LeaderboardRow(position: 3, name: "CircuitAce", score: 1960, isPlayer: false)
            }
        }
    }
}

private struct LeaderboardRow: View {
    let position: Int
    let name: String
    let score: Int
    let isPlayer: Bool

    var body: some View {
        HStack {
            Text("#\(position)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(isPlayer ? VoltTheme.neonYellow : VoltTheme.mutedText)
                .frame(width: 42, alignment: .leading)
            Text(name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            Spacer()
            Text("\(score) XP")
                .font(.caption.weight(.bold))
                .foregroundStyle(VoltTheme.neonBlue)
        }
        .padding(10)
        .background(isPlayer ? VoltTheme.neonYellow.opacity(0.10) : VoltTheme.elevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
