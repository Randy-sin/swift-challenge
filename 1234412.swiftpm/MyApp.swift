import SwiftUI

@main
struct MyApp: App {
    @StateObject private var audioManager = AudioManager.shared
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchView(showLaunchScreen: $showLaunchScreen)
                } else {
                    SceneMenuView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
