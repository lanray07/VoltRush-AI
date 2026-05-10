import SwiftUI

struct WiringLabView: View {
    @StateObject private var viewModel = WiringLabViewModel()
    @State private var selectedNode: CircuitNode?
    @State private var draggingFrom: CircuitNode?
    @State private var dragLocation: CGPoint?
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ElectricBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    puzzlePicker
                    board
                    scoring
                    safetyRules
                }
                .padding(16)
            }
        }
        .voltNavigationTitle("Wiring Lab")
        .onReceive(timer) { _ in
            if !viewModel.isComplete { viewModel.elapsedSeconds += 1 }
        }
    }

    private var puzzlePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Puzzle", subtitle: viewModel.selectedPuzzle.brief)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.puzzles) { puzzle in
                        Button {
                            selectedNode = nil
                            viewModel.select(puzzle)
                        } label: {
                            Text(puzzle.title)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(viewModel.selectedPuzzle.id == puzzle.id ? VoltTheme.neonYellow : VoltTheme.surface, in: Capsule())
                                .foregroundStyle(viewModel.selectedPuzzle.id == puzzle.id ? .black : .white)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var board: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(VoltTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(VoltTheme.neonBlue.opacity(0.28), lineWidth: 1)
                    )

                ForEach(viewModel.userConnections) { connection in
                    if let from = node(for: connection.from), let to = node(for: connection.to) {
                        Path { path in
                            path.move(to: point(for: from, in: size))
                            path.addLine(to: point(for: to, in: size))
                        }
                        .stroke(viewModel.selectedPuzzle.expectedConnections.contains(connection) ? VoltTheme.neonYellow : VoltTheme.danger, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    }
                }

                if let draggingFrom, let dragLocation {
                    Path { path in
                        path.move(to: point(for: draggingFrom, in: size))
                        path.addLine(to: dragLocation)
                    }
                    .stroke(VoltTheme.neonBlue, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6]))
                }

                ForEach(viewModel.selectedPuzzle.nodes) { node in
                    WireNodeView(node: node, isSelected: selectedNode?.id == node.id)
                        .position(point(for: node, in: size))
                        .gesture(
                            DragGesture(minimumDistance: 8, coordinateSpace: .named("wiringCanvas"))
                                .onChanged { value in
                                    draggingFrom = node
                                    dragLocation = value.location
                                }
                                .onEnded { value in
                                    if let target = nearestNode(to: value.location, in: size, excluding: node) {
                                        viewModel.connect(from: node, to: target)
                                    }
                                    draggingFrom = nil
                                    dragLocation = nil
                                }
                        )
                        .onTapGesture {
                            handleTap(node)
                        }
                }
            }
            .coordinateSpace(name: "wiringCanvas")
        }
        .frame(height: 360)
    }

    private var scoring: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionTitle(title: "Score", subtitle: "\(viewModel.elapsedSeconds)s · \(viewModel.correctConnections)/\(viewModel.selectedPuzzle.expectedConnections.count) correct")
                    Spacer()
                    Text("\(viewModel.score)")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(VoltTheme.neonYellow)
                }
                XPProgressBar(progress: Double(viewModel.score) / 100, height: 12)
                HStack {
                    StatTile(title: "Mistakes", value: "\(viewModel.mistakes)", systemImage: "xmark.circle.fill", tint: VoltTheme.warning)
                    StatTile(title: "Safety", value: "\(viewModel.safetyWarnings)", systemImage: "shield.slash.fill", tint: VoltTheme.danger)
                }
                if viewModel.isComplete {
                    CompletionBurst(title: "Puzzle Complete")
                        .frame(maxWidth: .infinity)
                }
                PrimaryActionButton(title: "Reset Puzzle", systemImage: "arrow.clockwise", tint: VoltTheme.neonBlue) {
                    selectedNode = nil
                    viewModel.reset()
                }
            }
        }
    }

    private var safetyRules: some View {
        NeonCard {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle(title: "Safety Checks")
                ForEach(viewModel.selectedPuzzle.safetyRules, id: \.self) { rule in
                    Label(rule, systemImage: "shield.fill")
                        .font(.subheadline)
                        .foregroundStyle(VoltTheme.mutedText)
                }
            }
        }
    }

    private func handleTap(_ node: CircuitNode) {
        if let selectedNode, selectedNode.id != node.id {
            viewModel.connect(from: selectedNode, to: node)
            self.selectedNode = nil
        } else {
            selectedNode = node
        }
    }

    private func point(for node: CircuitNode, in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * node.x, y: size.height * node.y)
    }

    private func node(for id: String) -> CircuitNode? {
        viewModel.selectedPuzzle.nodes.first { $0.id == id }
    }

    private func nearestNode(to point: CGPoint, in size: CGSize, excluding source: CircuitNode) -> CircuitNode? {
        viewModel.selectedPuzzle.nodes
            .filter { $0.id != source.id }
            .map { ($0, distance(point, point(for: $0, in: size))) }
            .filter { $0.1 < 70 }
            .min { $0.1 < $1.1 }?
            .0
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}

private struct WireNodeView: View {
    let node: CircuitNode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .overlay(Circle().stroke(isSelected ? VoltTheme.neonYellow : .white.opacity(0.45), lineWidth: isSelected ? 3 : 1))
                .overlay(Image(systemName: icon).foregroundStyle(.black).font(.headline))
            Text(node.label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(.black.opacity(0.36), in: Capsule())
        }
        .frame(width: 86, height: 74)
    }

    private var color: Color {
        switch node.kind {
        case .supply: VoltTheme.neonYellow
        case .switchGear: VoltTheme.neonBlue
        case .load: VoltTheme.success
        case .protectiveDevice: VoltTheme.warning
        case .earth: Color.green
        }
    }

    private var icon: String {
        switch node.kind {
        case .supply: "bolt.fill"
        case .switchGear: "switch.2"
        case .load: "lightbulb.fill"
        case .protectiveDevice: "shield.fill"
        case .earth: "leaf.fill"
        }
    }
}
