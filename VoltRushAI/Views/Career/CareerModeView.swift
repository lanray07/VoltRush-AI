import SwiftUI

struct CareerModeView: View {
    @EnvironmentObject private var appModel: AppViewModel

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(appModel.dataService.careerLevels) { level in
                        CareerLevelCard(level: level)
                    }
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Career Mode")
    }
}

private struct CareerLevelCard: View {
    @EnvironmentObject private var appModel: AppViewModel
    let level: CareerLevel

    private var missions: [Mission] {
        level.missionIDs.compactMap { id in appModel.dataService.missions.first(where: { $0.id == id }) }
    }

    private var isUnlocked: Bool {
        appModel.profile.level >= level.unlockLevel
    }

    var body: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(level.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text(level.summary)
                            .font(.subheadline)
                            .foregroundStyle(VoltTheme.mutedText)
                    }
                    Spacer()
                    if isUnlocked {
                        DifficultyBadge(difficulty: .beginner)
                    } else {
                        LockedPill(text: "Level \(level.unlockLevel)")
                    }
                }

                ForEach(missions) { mission in
                    MissionRow(mission: mission, isUnlocked: isUnlocked)
                }
            }
        }
    }
}

private struct MissionRow: View {
    @EnvironmentObject private var appModel: AppViewModel
    let mission: Mission
    let isUnlocked: Bool

    var body: some View {
        NavigationLink {
            MissionDetailView(mission: mission)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: mission.iconSystemName)
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(VoltTheme.neonBlue.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .foregroundStyle(VoltTheme.neonBlue)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(mission.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        if appModel.profile.completedMissionIDs.contains(mission.id) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(VoltTheme.success)
                        }
                    }
                    Text("\(mission.expectedTimeMinutes) min · \(mission.rewardXP) XP · \(mission.rewardCoins) coins")
                        .font(.caption)
                        .foregroundStyle(VoltTheme.mutedText)
                }
                Spacer()
                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.35))
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(VoltTheme.mutedText)
                }
            }
            .padding(12)
            .background(VoltTheme.elevated.opacity(isUnlocked ? 1 : 0.55), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

struct MissionDetailView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @State private var isRunning = false
    @State private var showCompletion = false

    let mission: Mission

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    NeonCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Image(systemName: mission.iconSystemName)
                                .font(.system(size: 48))
                                .foregroundStyle(VoltTheme.electricGradient)
                            Text(mission.title)
                                .font(.largeTitle.weight(.bold))
                                .foregroundStyle(.white)
                            Text(mission.brief)
                                .foregroundStyle(VoltTheme.mutedText)
                                .lineSpacing(3)
                            HStack {
                                DifficultyBadge(difficulty: mission.difficulty)
                                RiskBadge(rating: mission.safetyRisk)
                            }
                        }
                    }

                    NeonCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "Job Details")
                            DetailLine(icon: "timer", label: "Expected time", value: "\(mission.expectedTimeMinutes) min")
                            DetailLine(icon: "bolt.fill", label: "Reward XP", value: "\(mission.rewardXP)")
                            DetailLine(icon: "creditcard.fill", label: "Reward coins", value: "\(mission.rewardCoins)")
                        }
                    }

                    NeonCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "Learning Focus")
                            ForEach(mission.learningPoints, id: \.self) { point in
                                Label(point, systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(VoltTheme.mutedText)
                            }
                        }
                    }

                    if isRunning {
                        MissionRunPanel(mission: mission) {
                            appModel.completeMission(mission)
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                                showCompletion = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                withAnimation { showCompletion = false }
                            }
                        }
                    } else {
                        PrimaryActionButton(title: "Start Mission", systemImage: "play.fill") {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                isRunning = true
                            }
                        }
                    }
                }
                .padding(16)
            }

            if showCompletion {
                CompletionBurst(title: "Mission Complete")
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .voltNavigationTitle("Mission")
    }
}

private struct MissionRunPanel: View {
    let mission: Mission
    let onComplete: () -> Void
    @State private var completedSteps: Set<String> = []

    private let steps = ["Review brief", "Identify hazards", "Choose test sequence", "Confirm result"]

    var body: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Simulated Job Flow", subtitle: "Complete the safe order before claiming rewards.")
                ForEach(steps, id: \.self) { step in
                    Button {
                        completedSteps.insert(step)
                    } label: {
                        HStack {
                            Image(systemName: completedSteps.contains(step) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(completedSteps.contains(step) ? VoltTheme.success : VoltTheme.mutedText)
                            Text(step)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                PrimaryActionButton(title: "Complete Job", systemImage: "flag.checkered") {
                    onComplete()
                }
                .opacity(completedSteps.count == steps.count ? 1 : 0.5)
                .disabled(completedSteps.count != steps.count)
            }
        }
    }
}

private struct DetailLine: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundStyle(VoltTheme.mutedText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}
