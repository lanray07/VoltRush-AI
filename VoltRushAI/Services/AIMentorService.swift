import Foundation

protocol AIMentorResponding {
    func response(to prompt: String, profile: UserProfile) async -> String
}

struct MockAIMentorService: AIMentorResponding {
    func response(to prompt: String, profile: UserProfile) async -> String {
        let lower = prompt.lowercased()

        // TODO: Replace this local matcher with a real AI API client and safety-reviewed prompt templates.
        if lower.contains("wrong") || lower.contains("mistake") {
            return "A common reason answers go wrong is skipping the safety sequence. Start with isolation, prove dead where appropriate, identify the circuit, then test with a suitable instrument. In the simulator, look for clues that separate supply faults, load faults, and control faults."
        }

        if lower.contains("formula") || lower.contains("calculate") || lower.contains("current") {
            return "Use the basic relationship P = V x I. If you know power and voltage, current is I = P / V. For example, 2,300 W at 230 V is 10 A. Real installations still need cable selection, protective devices, installation method, and local regulations."
        }

        if lower.contains("ev") {
            return "For EV charger scenarios, think about supply capacity, load management, suitable protection, earthing arrangements, cable route, commissioning, and documentation. This simulator teaches the decision path, not a substitute for local certification."
        }

        if lower.contains("solar") {
            return "Solar PV faults need extra care because DC conductors may remain energized when panels receive light. Follow the safe isolation sequence, manufacturer instructions, and local requirements before testing."
        }

        if lower.contains("safety") {
            return "Safety rule: never guess on a live electrical system. Use the correct tester, prove the tester, isolate where required, verify the state, and escalate work beyond your competence or authorization."
        }

        return "Good question. Break it into three checks: what changed, what is energized, and what evidence proves the fault path. In VoltRush missions, the highest scores come from safe order of operations, not just fast answers."
    }
}
