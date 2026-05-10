import SwiftUI

struct BusinessModeView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @StateObject private var viewModel = BusinessViewModel()

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    jobs
                    tools
                    upgrades
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Contractor Mode")
    }

    private var header: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("VoltWorks Ltd.", systemImage: "briefcase.fill")
                    .font(.title.weight(.bold))
                    .foregroundStyle(VoltTheme.neonYellow)
                HStack {
                    StatTile(title: "Virtual Cash", value: "GBP \(appModel.profile.businessCash)", systemImage: "banknote.fill", tint: VoltTheme.success)
                    StatTile(title: "Reputation", value: "\(appModel.profile.reputation)", systemImage: "star.fill", tint: VoltTheme.neonYellow)
                }
            }
        }
    }

    private var jobs: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Accept Jobs", subtitle: "Build reputation to unlock larger contracts.")
            ForEach(viewModel.jobs) { job in
                NeonCard {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(job.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                            HStack {
                                DifficultyBadge(difficulty: job.difficulty)
                                Text("GBP \(job.payout) · +\(job.reputationReward) rep")
                                    .font(.caption)
                                    .foregroundStyle(VoltTheme.mutedText)
                            }
                        }
                        Spacer()
                        Button(viewModel.acceptedJobs.contains(job.id) ? "Done" : "Accept") {
                            viewModel.accept(job, appModel: appModel)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(VoltTheme.neonYellow)
                        .foregroundStyle(.black)
                        .disabled(viewModel.acceptedJobs.contains(job.id) || appModel.profile.reputation < job.requiredReputation)
                    }
                    if appModel.profile.reputation < job.requiredReputation {
                        Text("Requires \(job.requiredReputation) reputation")
                            .font(.caption)
                            .foregroundStyle(VoltTheme.warning)
                            .padding(.top, 6)
                    }
                }
            }
        }
    }

    private var tools: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Buy Tools")
            ForEach(viewModel.tools) { tool in
                NeonCard {
                    HStack {
                        Image(systemName: tool.icon)
                            .font(.title2)
                            .foregroundStyle(VoltTheme.neonBlue)
                            .frame(width: 42)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tool.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(tool.description)
                                .font(.caption)
                                .foregroundStyle(VoltTheme.mutedText)
                        }
                        Spacer()
                        Text("\(tool.cost) coins")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(VoltTheme.neonYellow)
                    }
                }
            }
        }
    }

    private var upgrades: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Upgrade Business")
            ForEach(viewModel.upgrades) { upgrade in
                NeonCard {
                    HStack {
                        Image(systemName: upgrade.icon)
                            .font(.title2)
                            .foregroundStyle(VoltTheme.success)
                            .frame(width: 42)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(upgrade.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text(upgrade.description)
                                .font(.caption)
                                .foregroundStyle(VoltTheme.mutedText)
                            Text("GBP \(upgrade.cost) · +\(upgrade.reputationBoost) rep")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(VoltTheme.neonYellow)
                        }
                        Spacer()
                        Button(viewModel.purchasedUpgrades.contains(upgrade.id) ? "Owned" : "Buy") {
                            viewModel.buy(upgrade, appModel: appModel)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(VoltTheme.neonBlue)
                        .disabled(viewModel.purchasedUpgrades.contains(upgrade.id))
                    }
                }
            }
        }
    }
}
