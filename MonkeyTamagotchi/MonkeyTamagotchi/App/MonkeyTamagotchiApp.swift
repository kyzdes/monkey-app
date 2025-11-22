import SwiftUI

@main
struct MonkeyTamagotchiApp: App {
    @StateObject private var gameManager = GameManager.shared
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(gameManager.settings.isDarkMode ? .dark : .light)
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
    }

    private func setupApp() {
        // App setup configuration
    }
}
