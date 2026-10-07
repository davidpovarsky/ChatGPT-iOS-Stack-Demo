import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { ChatDemoView() }
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }
            NavigationStack { LibraryGalleryView() }
                .tabItem { Label("Library", systemImage: "square.grid.2x2") }
            NavigationStack { VoiceDemoView() }
                .tabItem { Label("Voice", systemImage: "waveform") }
            NavigationStack { AboutView() }
                .tabItem { Label("About", systemImage: "info.circle") }
        }
    }
}