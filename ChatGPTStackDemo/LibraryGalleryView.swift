import SwiftUI
import MarkdownUI
import Kingfisher
import Highlightr
import Pow

struct LibraryGalleryView: View {
    @State private var burst = 0
    var body: some View {
        List {
            Section("Rendering") {
                NavigationLink("MarkdownUI + cmark-gfm") { MarkdownDemo() }
                NavigationLink("Highlightr") { CodeDemo() }
                NavigationLink("Kingfisher") { ImageDemo() }
            }
            Section("Motion") {
                Button("Trigger Pow effect") { burst += 1 }
                    .changeEffect(.shake, value: burst)
                Label("Lottie is linked for vector animation support", systemImage: "play.square.stack")
            }
            Section("Purpose") {
                Text("Each page isolates a UI-facing library from the dependency stack so its value can be judged on a real device.")
            }
        }.navigationTitle("Library Gallery")
    }
}

private struct MarkdownDemo: View {
    var body: some View {
        ScrollView {
            Markdown("""
# Markdown renderer

This page is rendered by **MarkdownUI**, whose parser stack uses cmark-gfm.

> Blockquotes, emphasis, links and structured documents render natively.

| Capability | Status |
| --- | --- |
| Headings | Yes |
| Lists | Yes |
| Tables | Yes |
| Code | Yes |

- Fast native layout
- Dynamic Type
- Text selection
""").textSelection(.enabled).padding()
        }.navigationTitle("Markdown")
    }
}

private struct CodeDemo: View {
    private let code = "struct AgentEvent: Sendable {\n    let phase: String\n    let payload: String\n}\n\nfor await event in stream {\n    await timeline.consume(event)\n}"
    var body: some View {
        ScrollView {
            if let highlighter = Highlightr(), let highlighted = highlighter.highlight(code, as: "swift") {
                AttributedText(attributed: highlighted).padding(16)
            } else {
                Text(code).font(.system(.body, design: .monospaced)).padding()
            }
        }.navigationTitle("Highlightr")
    }
}

private struct AttributedText: UIViewRepresentable {
    let attributed: NSAttributedString
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        return view
    }
    func updateUIView(_ uiView: UITextView, context: Context) { uiView.attributedText = attributed }
}

private struct ImageDemo: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KFImage(URL(string: "https://images.unsplash.com/photo-1558655146-d09347e92766?auto=format&fit=crop&w=1400&q=85"))
                    .placeholder { RoundedRectangle(cornerRadius: 22).fill(.quaternary).overlay { ProgressView() } }
                    .resizable().aspectRatio(contentMode: .fill)
                    .frame(height: 300).clipped().clipShape(RoundedRectangle(cornerRadius: 22))
                Text("Loaded and cached by Kingfisher").font(.headline)
                Text("Reload this screen to observe cached-image behavior.").foregroundStyle(.secondary)
            }.padding()
        }.navigationTitle("Kingfisher")
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Label("No AI API key", systemImage: "key.slash")
                Label("No backend", systemImage: "server.rack")
                Label("Deterministic live simulation", systemImage: "waveform.path.ecg")
                Label("iPhone + iPad", systemImage: "iphone.and.arrow.forward")
            }
            Section("Purpose") {
                Text("This app isolates the UI-facing open-source stack so it can be evaluated on a real device before deciding what belongs in another product.")
            }
        }.navigationTitle("About")
    }
}