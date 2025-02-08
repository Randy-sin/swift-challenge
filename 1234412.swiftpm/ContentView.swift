import SwiftUI

/// Main Interface
struct ContentView: View {
    @State private var showLaunchScreen = true
    @State private var isShowingGuide = true
    @State private var showGuideButton = false
    @State private var showCompletion = false
    @StateObject private var visionProcessor = VisionProcessor()
    
    var body: some View {
        ZStack {
            if showLaunchScreen {
                LaunchView(showLaunchScreen: $showLaunchScreen)
                    .transition(.opacity)
            } else {
                SceneMenuView()
                    .transition(.opacity)
            }
        }
    }
}
