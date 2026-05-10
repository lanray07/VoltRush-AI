import SwiftUI

struct QuizArenaView: View {
    @EnvironmentObject private var appModel: AppViewModel
    @StateObject private var viewModel = QuizViewModel()
    @State private var selectedMode: QuizMode = .practice
    @State private var selectedCategory: QuizCategory?
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    modePicker
                    categoryPicker
                    quizCard
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Quiz Arena")
        .onReceive(timer) { _ in viewModel.tick() }
    }

    private var modePicker: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle(title: "Mode")
                Picker("Quiz mode", selection: $selectedMode) {
                    ForEach(QuizMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                PrimaryActionButton(title: "Start \(selectedMode.rawValue)", systemImage: "play.fill") {
                    viewModel.start(mode: selectedMode, category: selectedCategory)
                }
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Categories")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 10)], spacing: 10) {
                CategoryButton(title: "All", icon: "square.grid.2x2.fill", selected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(QuizCategory.allCases) { category in
                    CategoryButton(title: category.rawValue, icon: category.icon, selected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var quizCard: some View {
        if viewModel.isFinished {
            NeonCard {
                VStack(alignment: .leading, spacing: 14) {
                    CompletionBurst(title: "Quiz Complete")
                        .frame(maxWidth: .infinity)
                    Text("Score: \(viewModel.score)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Text("\(viewModel.submittedAnswers) questions answered")
                        .foregroundStyle(VoltTheme.mutedText)
                    PrimaryActionButton(title: "Restart", systemImage: "arrow.clockwise") {
                        viewModel.start(mode: selectedMode, category: selectedCategory)
                    }
                }
            }
        } else if let question = viewModel.currentQuestion {
            NeonCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        DifficultyBadge(difficulty: question.difficulty)
                        Spacer()
                        if viewModel.mode != .practice {
                            Label("\(viewModel.timeRemaining)s", systemImage: "timer")
                                .foregroundStyle(VoltTheme.neonYellow)
                        }
                    }
                    XPProgressBar(progress: viewModel.progress, height: 10)
                    Text(question.prompt)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    ForEach(question.answers.indices, id: \.self) { index in
                        Button {
                            viewModel.chooseAnswer(index)
                            if index == question.correctAnswerIndex {
                                appModel.unlockAchievementIfNeeded("quiz-streak")
                            }
                        } label: {
                            HStack {
                                Text(question.answers[index])
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if let selected = viewModel.selectedAnswerIndex, selected == index {
                                    Image(systemName: index == question.correctAnswerIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                }
                            }
                            .padding(14)
                            .background(answerColor(index, question: question), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.selectedAnswerIndex != nil)
                    }

                    if viewModel.selectedAnswerIndex != nil {
                        Text(question.explanation)
                            .font(.subheadline)
                            .foregroundStyle(VoltTheme.mutedText)
                            .lineSpacing(3)
                        PrimaryActionButton(title: "Next", systemImage: "arrow.right", action: viewModel.next)
                    }
                }
            }
        }
    }

    private func answerColor(_ index: Int, question: QuizQuestion) -> Color {
        guard let selected = viewModel.selectedAnswerIndex else { return VoltTheme.elevated }
        if index == question.correctAnswerIndex { return VoltTheme.success.opacity(0.32) }
        if selected == index { return VoltTheme.danger.opacity(0.32) }
        return VoltTheme.elevated
    }
}

private struct CategoryButton: View {
    let title: String
    let icon: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 8)
                .background(selected ? VoltTheme.neonYellow : VoltTheme.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .foregroundStyle(selected ? .black : .white)
        }
        .buttonStyle(.plain)
    }
}
