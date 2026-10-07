import SwiftUI
import MarkdownUI
import Kingfisher
import Pow

struct ChatDemoView: View {
    @StateObject private var agent = DemoAgent()
    @State private var input = ""

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    scenarioStrip
                    ForEach(agent.messages) { message in
                        MessageView(message: message).id(message.id)
                    }
                    if agent.stage != .idle || !agent.sources.isEmpty || !agent.tools.isEmpty {
                        AgentTimelineView(stage: agent.stage, sources: agent.sources, tools: agent.tools)
                            .transition(.movingParts.blur.combined(with: .opacity))
                    }
                    if agent.showRichResult {
                        RichResultCard().transition(.movingParts.pop)
                    }
                    Color.clear.frame(height: 4).id("bottom")
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: agent.messages) { _, _ in scroll(proxy) }
            .onChange(of: agent.stage) { _, _ in scroll(proxy) }
            .safeAreaInset(edge: .bottom) { composer }
        }
        .navigationTitle("Agent UI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Reset conversation", systemImage: "arrow.counterclockwise") { agent.reset() }
                    Button("Run full demo", systemImage: "play.fill") { agent.send("Show me the complete agent experience") }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .animation(.snappy, value: agent.stage)
    }

    private var scenarioStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                scenario("Research", "globe", "Research the best way to build a rich native agent interface")
                scenario("Code", "chevron.left.forwardslash.chevron.right", "Explain a streaming Swift implementation with code")
                scenario("Visual", "photo.on.rectangle.angled", "Show a visual product research result")
                scenario("Tools", "wrench.and.screwdriver", "Run several tools and summarize the results")
            }
        }
    }

    private func scenario(_ title: String, _ symbol: String, _ prompt: String) -> some View {
        Button { agent.send(prompt) } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(.thinMaterial, in: Capsule())
        }.buttonStyle(.plain).disabled(agent.isRunning)
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button {} label: {
                Image(systemName: "plus").frame(width: 34, height: 34).background(.thinMaterial, in: Circle())
            }.buttonStyle(.plain)
            TextField("Message", text: $input, axis: .vertical)
                .lineLimit(1...5).padding(.horizontal, 14).padding(.vertical, 9)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
            Button {
                if agent.isRunning { agent.stop() }
                else { let value = input; input = ""; agent.send(value) }
            } label: {
                Image(systemName: agent.isRunning ? "stop.fill" : "arrow.up")
                    .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(agent.isRunning || !input.isEmpty ? Color.primary : Color.secondary.opacity(0.35), in: Circle())
            }.buttonStyle(.plain)
             .disabled(!agent.isRunning && input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12).padding(.vertical, 10).background(.ultraThinMaterial)
    }

    private func scroll(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom", anchor: .bottom) }
    }
}

private struct MessageView: View {
    let message: DemoMessage
    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 44) }
            VStack(alignment: .leading, spacing: 8) {
                Markdown(message.markdown).textSelection(.enabled)
                if message.isStreaming { Capsule().frame(width: 16, height: 3).opacity(0.45) }
            }
            .padding(message.role == .user ? 12 : 0)
            .background(message.role == .user ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(.clear), in: RoundedRectangle(cornerRadius: 18))
            if message.role == .assistant { Spacer(minLength: 20) }
        }
    }
}

private struct AgentTimelineView: View {
    let stage: AgentStage
    let sources: [DemoSource]
    let tools: [DemoTool]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if stage != .idle {
                HStack(spacing: 10) {
                    Image(systemName: stage.symbol).symbolEffect(.pulse, isActive: stage != .done)
                    Text(stage.title).font(.subheadline.weight(.semibold))
                    Spacer()
                    if stage != .done { ProgressView().controlSize(.small) }
                }
            }
            ForEach(sources) { source in
                HStack(spacing: 10) {
                    Image(systemName: "doc.text.magnifyingglass").foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(source.title).font(.caption.weight(.medium))
                        Text(source.domain).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            ForEach(tools) { tool in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: tool.complete ? "checkmark.circle.fill" : "gearshape.2")
                        .foregroundStyle(tool.complete ? .green : .secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tool.name).font(.caption.monospaced().weight(.semibold))
                        Text(tool.detail).font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
        }.padding(14).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct RichResultCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KFImage(URL(string: "https://images.unsplash.com/photo-1558655146-9f40138edfeb?auto=format&fit=crop&w=1200&q=80"))
                .placeholder { Rectangle().fill(.quaternary).overlay { ProgressView() } }
                .resizable().aspectRatio(contentMode: .fill).frame(height: 160).clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Label("Embedded visual result", systemImage: "sparkles").font(.headline)
            Text("A native result card rendered inline while the agent continues composing its answer.")
                .font(.subheadline).foregroundStyle(.secondary)
            HStack {
                Button("Open") {}.buttonStyle(.borderedProminent)
                Button("Save") {}.buttonStyle(.bordered)
            }
        }.padding(14).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
         .overlay { RoundedRectangle(cornerRadius: 22).stroke(.quaternary) }
    }
}