import SwiftUI

struct VoiceDemoView: View {
    @State private var active = false
    @State private var level: Double = 0.15
    @State private var transcript = "Tap the orb to simulate a realtime voice session."
    @State private var task: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 34) {
            Spacer()
            ZStack {
                Circle().fill(.ultraThinMaterial).frame(width: 190, height: 190)
                    .scaleEffect(active ? 1.06 + level * 0.12 : 1)
                    .animation(.easeInOut(duration: 0.25), value: level)
                Circle().fill(Color.primary.opacity(0.08)).frame(width: 138, height: 138)
                Image(systemName: active ? "waveform" : "mic.fill")
                    .font(.system(size: 46, weight: .medium))
                    .symbolEffect(.variableColor.iterative, isActive: active)
            }
            .onTapGesture { active ? stop() : start() }

            VStack(spacing: 8) {
                Text(active ? "Listening…" : "Voice mode").font(.title2.bold())
                Text(transcript).multilineTextAlignment(.center).foregroundStyle(.secondary)
                    .frame(maxWidth: 420)
            }

            if active {
                HStack(spacing: 5) {
                    ForEach(0..<14, id: \.self) { i in
                        Capsule()
                            .frame(width: 4, height: 12 + CGFloat((i * 17) % 34))
                            .opacity(0.35 + Double(i % 4) * 0.15)
                    }
                }.transition(.opacity)
            }
            Spacer()
            Text("UI simulation only — no microphone audio is transmitted.")
                .font(.caption).foregroundStyle(.tertiary)
        }
        .padding()
        .navigationTitle("Voice")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { stop() }
    }

    private func start() {
        active = true
        transcript = "Listening…"
        task = Task {
            for step in 0..<20 {
                if Task.isCancelled { return }
                level = Double((step * 37) % 100) / 100
                try? await Task.sleep(for: .milliseconds(130))
            }
            if !Task.isCancelled {
                transcript = "I can show live speaking, listening and response states here."
            }
        }
    }

    private func stop() {
        task?.cancel(); task = nil; active = false; level = 0.15
        if transcript == "Listening…" { transcript = "Voice session ended." }
    }
}