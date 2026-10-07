import Foundation

@MainActor
final class DemoAgent: ObservableObject {
    @Published var messages: [DemoMessage] = [
        DemoMessage(role: .assistant, markdown: "# Agent UI Lab\n\nThis is a **local, deterministic agent simulation**. Try asking anything, or tap a scenario above.\n\nThe demo visibly moves through thinking, search, tools, rich results and a streamed Markdown answer.")
    ]
    @Published var stage: AgentStage = .idle
    @Published var sources: [DemoSource] = []
    @Published var tools: [DemoTool] = []
    @Published var showRichResult = false
    @Published var isRunning = false
    private var runTask: Task<Void, Never>?

    func send(_ prompt: String) {
        guard !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isRunning else { return }
        runTask?.cancel()
        messages.append(DemoMessage(role: .user, markdown: prompt))
        sources = []; tools = []; showRichResult = false; isRunning = true
        runTask = Task { [weak self] in
            guard let self else { return }
            await pause(450); stage = .thinking
            await pause(850); stage = .searching
            sources.append(.init(title: "Designing fluid interfaces for Apple platforms", domain: "developer.apple.com"))
            await pause(500); sources.append(.init(title: "Markdown rendering and CommonMark", domain: "swift.org"))
            await pause(450); sources.append(.init(title: "Image loading and caching", domain: "github.com"))
            await pause(650); stage = .tool
            tools = [
                .init(name: "analyze_interface", detail: "Inspecting layout, typography and interaction states", complete: false),
                .init(name: "render_rich_result", detail: "Preparing an embedded result card", complete: false)
            ]
            await pause(700); if !tools.isEmpty { tools[0].complete = true }
            await pause(550); if tools.count > 1 { tools[1].complete = true }
            showRichResult = true
            await pause(500); stage = .composing
            let answer = answer(for: prompt)
            let index = messages.count
            messages.append(DemoMessage(role: .assistant, markdown: "", isStreaming: true))
            var current = ""
            for character in answer {
                if Task.isCancelled { return }
                current.append(character)
                messages[index].markdown = current
                try? await Task.sleep(for: .milliseconds(character == "\n" ? 25 : 8))
            }
            messages[index].isStreaming = false
            stage = .done
            await pause(900); stage = .idle; isRunning = false
        }
    }

    func stop() {
        runTask?.cancel()
        if let index = messages.indices.last, messages[index].isStreaming { messages[index].isStreaming = false }
        stage = .idle; isRunning = false
    }

    func reset() {
        stop()
        messages = [DemoMessage(role: .assistant, markdown: "# Agent UI Lab\n\nConversation reset. Pick a scenario or send a message.")]
        sources = []; tools = []; showRichResult = false
    }

    private func pause(_ milliseconds: Int) async { try? await Task.sleep(for: .milliseconds(milliseconds)) }

    private func answer(for prompt: String) -> String {
        return """
## A rich response

I simulated a complete agent run for **“\(prompt)”** and combined the intermediate work into one answer.

> The important part of this demo is not the content — it is the live presentation of agent state, tools and rich output.

### What this stack can render

- GitHub-flavoured **Markdown**
- Tables and structured content
- Inline and fenced code
- Remote imagery with caching
- Interactive SwiftUI result cards
- Smooth state transitions

| Layer | Demo implementation |
| --- | --- |
| Markdown | MarkdownUI / cmark-gfm |
| Images | Kingfisher |
| Code | Highlightr |
| Motion | Pow + SwiftUI |
| Agent | Local async simulation |

Result: the interface can feel like a real multimodal agent without requiring a live model during UI evaluation.
"""
    }
}