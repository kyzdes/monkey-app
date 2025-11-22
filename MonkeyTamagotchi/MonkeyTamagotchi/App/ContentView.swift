import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab = 0

    var body: some View {
        if gameManager.currentMonkey == nil {
            OnboardingView()
        } else {
            TabView(selection: $selectedTab) {
                MainGameView()
                    .tabItem {
                        Label("Питомец", systemImage: "pawprint.fill")
                    }
                    .tag(0)

                MiniGamesListView()
                    .tabItem {
                        Label("Игры", systemImage: "gamecontroller.fill")
                    }
                    .tag(1)

                CustomizationView()
                    .tabItem {
                        Label("Стиль", systemImage: "tshirt.fill")
                    }
                    .tag(2)

                ShopView()
                    .tabItem {
                        Label("Магазин", systemImage: "cart.fill")
                    }
                    .tag(3)

                SocialView()
                    .tabItem {
                        Label("Друзья", systemImage: "person.2.fill")
                    }
                    .tag(4)
            }
        }
    }
}
