import SwiftUI

struct NeonCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(VoltTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(VoltTheme.neonBlue.opacity(0.28), lineWidth: 1)
                    )
            )
    }
}

struct SectionTitle: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(VoltTheme.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let systemImage: String
    var tint: Color = VoltTheme.neonYellow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .foregroundStyle(.black)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(title.replacingOccurrences(of: " ", with: "-").lowercased())
    }
}

struct XPProgressBar: View {
    let progress: Double
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.12))
                Capsule()
                    .fill(VoltTheme.electricGradient)
                    .frame(width: max(8, proxy.size.width * min(max(progress, 0), 1)))
            }
        }
        .frame(height: height)
        .accessibilityLabel("XP progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = VoltTheme.neonBlue

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(VoltTheme.mutedText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .background(VoltTheme.elevated, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct FeatureTile<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var tint: Color = VoltTheme.neonBlue
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.18), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .foregroundStyle(tint)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(VoltTheme.mutedText)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(12)
            .background(VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct RiskBadge: View {
    let rating: Int

    var body: some View {
        Label("Risk \(rating)/5", systemImage: "exclamationmark.triangle.fill")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(riskColor.opacity(0.16), in: Capsule())
            .foregroundStyle(riskColor)
    }

    private var riskColor: Color {
        switch rating {
        case 0...2: VoltTheme.success
        case 3: VoltTheme.warning
        default: VoltTheme.danger
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(difficulty.color.opacity(0.16), in: Capsule())
            .foregroundStyle(difficulty.color)
    }
}

struct LockedPill: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "lock.fill")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.10), in: Capsule())
            .foregroundStyle(VoltTheme.mutedText)
    }
}

struct CompletionBurst: View {
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 54))
                .foregroundStyle(VoltTheme.neonYellow)
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(28)
        .background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(VoltTheme.neonYellow.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: VoltTheme.neonYellow.opacity(0.28), radius: 22)
    }
}
