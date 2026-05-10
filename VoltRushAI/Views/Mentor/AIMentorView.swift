import SwiftUI

struct AIMentorView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @State private var messages: [MentorMessage] = [
        MentorMessage(text: "Ask about safety warnings, wiring principles, formulas, or why an answer was wrong.", isUser: false)
    ]
    @State private var draft = ""
    @State private var isResponding = false
    private let mentorService: AIMentorResponding = MockAIMentorService()

    var body: some View {
        ZStack {
            ElectricBackground()
            VStack(spacing: 0) {
                if !appModel.profile.isPremium {
                    premiumNotice
                }
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MentorBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                composer
            }
        }
        .voltNavigationTitle("AI Mentor")
    }

    private var premiumNotice: some View {
        NavigationLink {
            PremiumShopView()
        } label: {
            HStack {
                Label("Premium unlock: full AI Mentor history and advanced explanations", systemImage: "lock.fill")
                    .font(.caption.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(12)
            .background(VoltTheme.neonYellow.opacity(0.16))
            .foregroundStyle(VoltTheme.neonYellow)
        }
        .buttonStyle(.plain)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Ask the mentor", text: $draft, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(12)
                .background(VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .foregroundStyle(.white)
                .lineLimit(1...4)

            Button {
                send()
            } label: {
                Image(systemName: isResponding ? "hourglass" : "paperplane.fill")
                    .frame(width: 44, height: 44)
                    .background(VoltTheme.neonYellow, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .foregroundStyle(.black)
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResponding)
        }
        .padding(12)
        .background(VoltTheme.background)
    }

    private func send() {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        draft = ""
        messages.append(MentorMessage(text: prompt, isUser: true))
        isResponding = true

        Task {
            let response = await mentorService.response(to: prompt, profile: appModel.profile)
            await MainActor.run {
                messages.append(MentorMessage(text: response, isUser: false))
                isResponding = false
            }
        }
    }
}

private struct MentorBubble: View {
    let message: MentorMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 44) }
            Text(message.text)
                .font(.body)
                .padding(12)
                .background(message.isUser ? VoltTheme.neonBlue.opacity(0.28) : VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .foregroundStyle(.white)
            if !message.isUser { Spacer(minLength: 44) }
        }
    }
}
