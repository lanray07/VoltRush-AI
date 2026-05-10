import SwiftUI

struct FaultDiagnosisView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @StateObject private var viewModel: FaultDiagnosisViewModel

    init(scenario: FaultScenario = MockDataService.shared.faultScenarios[0]) {
        _viewModel = StateObject(wrappedValue: FaultDiagnosisViewModel(scenario: scenario))
    }

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    scenarioCard
                    actionGrid
                    scorePanel
                    if viewModel.isComplete {
                        FaultResultPanel(viewModel: viewModel)
                    }
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Fault Diagnosis")
        .onAppear { viewModel.start() }
    }

    private var scenarioCard: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    DifficultyBadge(difficulty: viewModel.scenario.difficulty)
                    Spacer()
                    Label("\(viewModel.elapsedSeconds)s", systemImage: "timer")
                        .foregroundStyle(VoltTheme.mutedText)
                }
                Text(viewModel.scenario.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                Text(viewModel.scenario.faultDescription)
                    .foregroundStyle(VoltTheme.mutedText)
            }
        }
    }

    private var actionGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Choose Tools & Actions", subtitle: "Order matters. Unsafe actions reduce score.")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 12)], spacing: 12) {
                ForEach(FaultAction.allCases) { action in
                    Button {
                        viewModel.choose(action)
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: action.icon)
                                .font(.title2)
                            Text(action.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 98)
                        .background(actionBackground(action), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isComplete)
                }
            }
        }
    }

    private var scorePanel: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Live Score")
                XPProgressBar(progress: Double(viewModel.score) / 100, height: 12)
                HStack {
                    StatTile(title: "Correct", value: "\(viewModel.correctActions.count)", systemImage: "checkmark.circle.fill", tint: VoltTheme.success)
                    StatTile(title: "Wrong", value: "\(viewModel.wrongActions.count)", systemImage: "xmark.circle.fill", tint: VoltTheme.warning)
                    StatTile(title: "Safety", value: "\(viewModel.safetyMistakes)", systemImage: "exclamationmark.triangle.fill", tint: VoltTheme.danger)
                }
                PrimaryActionButton(title: "Finish Diagnosis", systemImage: "flag.checkered", tint: VoltTheme.neonBlue) {
                    viewModel.finish()
                    appModel.unlockAchievementIfNeeded("fault-pass")
                }
                .disabled(viewModel.isComplete)
                .opacity(viewModel.isComplete ? 0.6 : 1)
            }
        }
    }

    private func actionBackground(_ action: FaultAction) -> Color {
        if viewModel.correctActions.contains(action) { return VoltTheme.success.opacity(0.35) }
        if viewModel.wrongActions.contains(action) { return VoltTheme.warning.opacity(0.35) }
        return VoltTheme.surface
    }
}

private struct FaultResultPanel: View {
    @ObservedObject var viewModel: FaultDiagnosisViewModel

    var body: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: viewModel.passed ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .font(.title)
                        .foregroundStyle(viewModel.passed ? VoltTheme.success : VoltTheme.warning)
                    VStack(alignment: .leading) {
                        Text(viewModel.passed ? "Pass" : "Try Again")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(viewModel.score) score · \(viewModel.passed ? 120 : 35) XP · \(viewModel.passed ? 80 : 15) coins")
                            .font(.caption)
                            .foregroundStyle(VoltTheme.mutedText)
                    }
                }

                ResultList(title: "You did right", items: viewModel.correctActions.map(\.rawValue), tint: VoltTheme.success)
                ResultList(title: "Review next time", items: viewModel.wrongActions.map(\.rawValue) + (viewModel.safetyMistakes > 0 ? ["Unsafe test order detected"] : []), tint: VoltTheme.warning)

                Text(viewModel.scenario.explanation)
                    .font(.subheadline)
                    .foregroundStyle(VoltTheme.mutedText)
                    .lineSpacing(3)
            }
        }
    }
}

private struct ResultList: View {
    let title: String
    let items: [String]
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            if items.isEmpty {
                Text("None")
                    .foregroundStyle(VoltTheme.mutedText)
            } else {
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: "circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(tint)
                }
            }
        }
    }
}

struct FaultBattleView: View {
    @StateObject private var viewModel = BattleViewModel()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ElectricBackground()
            VStack(spacing: 16) {
                NeonCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Opponent: \(viewModel.opponentName)", systemImage: "person.2.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(statusText)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(VoltTheme.neonYellow)
                        Text("\(viewModel.timeRemaining)s remaining")
                            .foregroundStyle(VoltTheme.mutedText)
                    }
                }

                BattleProgress(title: "You", progress: viewModel.playerProgress, tint: VoltTheme.neonYellow)
                BattleProgress(title: viewModel.opponentName, progress: viewModel.opponentProgress, tint: VoltTheme.neonBlue)

                Spacer()

                switch viewModel.battleState {
                case .ready:
                    PrimaryActionButton(title: "Start Fault Battle", systemImage: "play.fill") {
                        viewModel.start()
                    }
                case .countdown:
                    Text("\(viewModel.countdown)")
                        .font(.system(size: 96, weight: .black))
                        .foregroundStyle(VoltTheme.neonYellow)
                case .running:
                    VStack(spacing: 12) {
                        PrimaryActionButton(title: "Correct Diagnostic Action", systemImage: "checkmark.circle.fill") {
                            viewModel.playerAction()
                        }
                        NavigationLink {
                            FaultDiagnosisView()
                        } label: {
                            Label("Open Full Fault Scenario", systemImage: "waveform.path.ecg")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                    }
                case .finished:
                    CompletionBurst(title: viewModel.winnerText)
                    PrimaryActionButton(title: "Rematch", systemImage: "arrow.clockwise") {
                        viewModel.start()
                    }
                }
            }
            .padding(16)
        }
        .voltNavigationTitle("Fault Battle")
        .onReceive(timer) { _ in viewModel.tick() }
    }

    private var statusText: String {
        switch viewModel.battleState {
        case .ready: "Ready"
        case .countdown: "Starting in \(viewModel.countdown)"
        case .running: "Diagnose the same fault"
        case .finished: viewModel.winnerText
        }
    }
}

private struct BattleProgress: View {
    let title: String
    let progress: Double
    let tint: Color

    var body: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .foregroundStyle(VoltTheme.mutedText)
                }
                XPProgressBar(progress: progress, height: 14)
            }
        }
    }
}
