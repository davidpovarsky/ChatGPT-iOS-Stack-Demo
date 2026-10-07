import Foundation

enum DemoRole: Hashable {
    case user, assistant
}

struct DemoMessage: Identifiable, Hashable {
    let id = UUID()
    var role: DemoRole
    var markdown: String
    var isStreaming = false
}

enum AgentStage: Equatable {
    case idle
    case thinking
    case searching
    case tool
    case composing
    case done

    var title: String {
        switch self {
        case .idle: return ""
        case .thinking: return "Thinking"
        case .searching: return "Searching the web"
        case .tool: return "Running tools"
        case .composing: return "Writing response"
        case .done: return "Completed"
        }
    }

    var symbol: String {
        switch self {
        case .idle: return "sparkles"
        case .thinking: return "brain.head.profile"
        case .searching: return "globe"
        case .tool: return "wrench.and.screwdriver"
        case .composing: return "text.cursor"
        case .done: return "checkmark.circle.fill"
        }
    }
}

struct DemoSource: Identifiable {
    let id = UUID()
    let title: String
    let domain: String
}

struct DemoTool: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    var complete: Bool
}
