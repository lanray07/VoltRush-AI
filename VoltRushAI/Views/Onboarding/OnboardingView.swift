import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var notificationStatus = "Daily challenges are optional."

    var body: some View {
        ZStack {
            ElectricBackground()
            VStack(spacing: 0) {
                progressHeader
                TabView(selection: $viewModel.step) {
                    welcome.tag(0)
                    rolePicker.tag(1)
                    pathPicker.tag(2)
                    skillPicker.tag(3)
                    notificationPermission.tag(4)
                    DisclaimerView {
                        appModel.configure(
                            role: viewModel.selectedRole,
                            path: viewModel.selectedPath,
                            skill: viewModel.selectedSkill
                        )
                        hasCompletedOnboarding = true
                    }
                    .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if viewModel.step < 5 {
                    PrimaryActionButton(
                        title: viewModel.step == 4 ? "Continue to Disclaimer" : "Continue",
                        systemImage: "arrow.right"
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            viewModel.step += 1
                        }
                    }
                    .padding([.horizontal, .bottom], 20)
                }
            }
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("VoltRush AI", systemImage: "bolt.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(VoltTheme.neonYellow)
                Spacer()
                Text("\(viewModel.step + 1)/6")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(VoltTheme.mutedText)
            }
            XPProgressBar(progress: Double(viewModel.step + 1) / 6)
        }
        .padding(20)
    }

    private var welcome: some View {
        OnboardingPanel(
            icon: "bolt.shield.fill",
            title: "Learn Like a Game. Think Like an Electrician.",
            message: "Train with interactive missions, wiring puzzles, fault diagnosis, quizzes, and career progression. VoltRush AI is a simulator for learning decisions, safety habits, and practical concepts."
        )
    }

    private var rolePicker: some View {
        ChoicePanel(
            title: "Choose Your Role",
            subtitle: "We will tune examples and progression language to your current stage.",
            options: UserRole.allCases,
            selection: $viewModel.selectedRole,
            label: { role in
                Label(role.rawValue, systemImage: role.icon)
            }
        )
    }

    private var pathPicker: some View {
        ChoicePanel(
            title: "Choose Learning Path",
            subtitle: "Start with one track. More packs can be added later.",
            options: LearningPath.allCases,
            selection: $viewModel.selectedPath,
            label: { path in
                Label(path.rawValue, systemImage: path.icon)
            }
        )
    }

    private var skillPicker: some View {
        ChoicePanel(
            title: "Set Skill Level",
            subtitle: "This affects early difficulty and hints.",
            options: SkillLevel.allCases,
            selection: $viewModel.selectedSkill,
            label: { level in
                Text(level.rawValue)
            }
        )
    }

    private var notificationPermission: some View {
        VStack(spacing: 18) {
            OnboardingPanel(
                icon: "bell.badge.fill",
                title: "Daily Challenge Reminders",
                message: "Optional notifications can remind you to keep your streak alive. You can decline now and still use every free training mode."
            )

            NeonCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(notificationStatus)
                        .foregroundStyle(VoltTheme.mutedText)
                    Button {
                        requestNotifications()
                    } label: {
                        Label("Enable Daily Challenge Alerts", systemImage: "bell.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(VoltTheme.neonBlue)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                notificationStatus = granted ? "Notifications enabled for future daily challenge scheduling." : "Notifications skipped. You can enable them later in Settings."
            }
        }
        // TODO: Schedule a local daily challenge notification after the user chooses a preferred reminder time.
    }
}

private struct OnboardingPanel: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 70))
                .foregroundStyle(VoltTheme.electricGradient)
            Text(title)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .minimumScaleFactor(0.82)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(VoltTheme.mutedText)
                .lineSpacing(3)
            Spacer()
        }
        .padding(24)
    }
}

private struct ChoicePanel<Option: Identifiable & Hashable, LabelContent: View>: View {
    let title: String
    let subtitle: String
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> LabelContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: title, subtitle: subtitle)
                ForEach(options) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack {
                            label(option)
                                .font(.headline)
                            Spacer()
                            Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selection == option ? VoltTheme.neonYellow : VoltTheme.mutedText)
                        }
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(selection == option ? VoltTheme.elevated : VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(selection == option ? VoltTheme.neonYellow.opacity(0.7) : .white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }
}

struct DisclaimerView: View {
    let onAccept: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 58))
                    .foregroundStyle(VoltTheme.neonYellow)
                    .frame(maxWidth: .infinity)

                Text("Learning & Safety Disclaimer")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text("VoltRush AI is an educational simulator. It does not replace formal electrician training, licensing, certification, apprenticeships, manufacturer instructions, site risk assessments, or qualified professional guidance.")
                    .foregroundStyle(.white)
                    .font(.headline)

                Text("Electrical work can be dangerous and may be regulated by local law. Always follow local electrical regulations, workplace procedures, lockout/isolation requirements, approved test methods, and advice from qualified professionals. Do not use simulated guidance as instructions for real-world electrical work.")
                    .foregroundStyle(VoltTheme.mutedText)
                    .lineSpacing(3)

                NeonCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("No live-work instruction", systemImage: "bolt.slash.fill")
                        Label("No licensing or certification guarantee", systemImage: "doc.badge.gearshape")
                        Label("Local regulations always take priority", systemImage: "building.columns.fill")
                    }
                    .foregroundStyle(.white)
                }

                PrimaryActionButton(title: "I Understand", systemImage: "checkmark.shield.fill", action: onAccept)
            }
            .padding(20)
        }
    }
}
