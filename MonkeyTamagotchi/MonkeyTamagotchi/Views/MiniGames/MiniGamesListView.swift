import SwiftUI

struct MiniGamesListView: View {
    @State private var selectedGame: MiniGame?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(MiniGame.allGames) { game in
                        MiniGameCard(game: game) {
                            selectedGame = game
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Мини-игры")
            .sheet(item: $selectedGame) { game in
                gameView(for: game)
            }
        }
    }

    @ViewBuilder
    private func gameView(for game: MiniGame) -> some View {
        switch game.type {
        case .runner:
            VineRunnerGameView(isPresented: .constant(true))
        case .memory:
            BananaMemoryGameView(isPresented: .constant(true))
        case .rhythm:
            DrumRhythmGameView(isPresented: .constant(true))
        case .match3:
            FruitMatchGameView(isPresented: .constant(true))
        }
    }
}

struct MiniGame: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let type: GameType
    let reward: Int

    enum GameType {
        case runner
        case memory
        case rhythm
        case match3
    }

    static let allGames = [
        MiniGame(
            name: "Лазание по лианам",
            description: "Прыгайте по лианам и собирайте бананы!",
            icon: "🌿",
            type: .runner,
            reward: 50
        ),
        MiniGame(
            name: "Поиск бананов",
            description: "Найдите все пары бананов!",
            icon: "🍌",
            type: .memory,
            reward: 40
        ),
        MiniGame(
            name: "Ритм барабанов",
            description: "Попадайте в ритм на барабанах!",
            icon: "🥁",
            type: .rhythm,
            reward: 60
        ),
        MiniGame(
            name: "Фруктовый матч",
            description: "Собирайте три в ряд!",
            icon: "🍎",
            type: .match3,
            reward: 45
        )
    ]
}

struct MiniGameCard: View {
    let game: MiniGame
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(game.icon)
                    .font(.system(size: 50))
                    .frame(width: 80, height: 80)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(15)

                VStack(alignment: .leading, spacing: 8) {
                    Text(game.name)
                        .font(.headline)

                    Text(game.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Text("Награда:")
                            .font(.caption)
                        Text("🍌 \(game.reward)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.purple)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Vine Runner Game

struct VineRunnerGameView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameManager: GameManager
    @State private var monkeyPosition: CGFloat = 0
    @State private var obstaclePosition: CGFloat = 400
    @State private var isJumping = false
    @State private var score = 0
    @State private var gameOver = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.6), Color.green.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Счет: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Закрыть") {
                        isPresented = false
                    }
                }
                .padding()

                Spacer()

                // Game area
                ZStack {
                    // Monkey
                    Text("🐵")
                        .font(.system(size: 50))
                        .offset(y: monkeyPosition)
                        .position(x: 100, y: 300)

                    // Obstacle
                    Text("🌴")
                        .font(.system(size: 60))
                        .position(x: obstaclePosition, y: 320)
                }
                .frame(height: 400)
                .onTapGesture {
                    jump()
                }

                if gameOver {
                    VStack(spacing: 20) {
                        Text("Игра окончена!")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Ваш счет: \(score)")
                            .font(.headline)

                        Button("Играть снова") {
                            restartGame()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                }

                Text("Нажмите, чтобы прыгнуть")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .onAppear {
            startGame()
        }
    }

    private func jump() {
        guard !isJumping && !gameOver else { return }

        isJumping = true
        withAnimation(.easeOut(duration: 0.3)) {
            monkeyPosition = -100
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                monkeyPosition = 0
            }
            isJumping = false
        }

        HapticManager.shared.impact(style: .light)
    }

    private func startGame() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if gameOver {
                timer.invalidate()
                return
            }

            obstaclePosition -= 5

            if obstaclePosition < -50 {
                obstaclePosition = 400
                score += 1
            }

            // Collision detection
            if obstaclePosition < 150 && obstaclePosition > 50 && monkeyPosition > -50 {
                gameOver = true
                HapticManager.shared.notification(type: .error)
            }
        }
    }

    private func restartGame() {
        gameOver = false
        score = 0
        obstaclePosition = 400
        monkeyPosition = 0
        startGame()
    }
}

// MARK: - Banana Memory Game

struct BananaMemoryGameView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameManager: GameManager
    @State private var cards: [MemoryCard] = []
    @State private var flippedCards: [MemoryCard] = []
    @State private var matchedCards: Set<UUID> = []
    @State private var score = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.4), Color.orange.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Счет: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Закрыть") {
                        isPresented = false
                    }
                }
                .padding()

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 15) {
                    ForEach(cards) { card in
                        MemoryCardView(
                            card: card,
                            isFlipped: flippedCards.contains(card) || matchedCards.contains(card.id),
                            isMatched: matchedCards.contains(card.id)
                        ) {
                            flipCard(card)
                        }
                    }
                }
                .padding()

                if matchedCards.count == cards.count {
                    VStack(spacing: 20) {
                        Text("Победа!")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Ваш счет: \(score)")
                            .font(.headline)

                        Button("Играть снова") {
                            setupGame()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }

    private func setupGame() {
        let emojis = ["🍌", "🥭", "🍎", "🍊", "🍇", "🍓"]
        var cardArray: [MemoryCard] = []

        for emoji in emojis {
            cardArray.append(MemoryCard(emoji: emoji))
            cardArray.append(MemoryCard(emoji: emoji))
        }

        cards = cardArray.shuffled()
        flippedCards = []
        matchedCards = []
        score = 0
    }

    private func flipCard(_ card: MemoryCard) {
        guard !matchedCards.contains(card.id) else { return }
        guard flippedCards.count < 2 else { return }
        guard !flippedCards.contains(card) else { return }

        flippedCards.append(card)
        HapticManager.shared.impact(style: .light)

        if flippedCards.count == 2 {
            checkMatch()
        }
    }

    private func checkMatch() {
        guard flippedCards.count == 2 else { return }

        if flippedCards[0].emoji == flippedCards[1].emoji {
            matchedCards.insert(flippedCards[0].id)
            matchedCards.insert(flippedCards[1].id)
            score += 10
            flippedCards = []
            HapticManager.shared.notification(type: .success)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                flippedCards = []
            }
        }
    }
}

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
}

struct MemoryCardView: View {
    let card: MemoryCard
    let isFlipped: Bool
    let isMatched: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isFlipped {
                    Text(card.emoji)
                        .font(.system(size: 40))
                } else {
                    Text("?")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 80, height: 80)
            .background(isMatched ? Color.green : (isFlipped ? Color.white : Color.blue))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .disabled(isFlipped)
    }
}

// MARK: - Drum Rhythm Game

struct DrumRhythmGameView: View {
    @Binding var isPresented: Bool
    @State private var score = 0

    var body: some View {
        ZStack {
            Color.purple.opacity(0.3)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Счет: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Закрыть") {
                        isPresented = false
                    }
                }
                .padding()

                Spacer()

                Text("🥁")
                    .font(.system(size: 150))

                Text("Нажимайте в ритм!")
                    .font(.title2)

                HStack(spacing: 30) {
                    DrumButton(emoji: "🔴", sound: "left") {
                        score += 1
                    }

                    DrumButton(emoji: "🔵", sound: "right") {
                        score += 1
                    }
                }
                .padding()

                Spacer()
            }
        }
    }
}

struct DrumButton: View {
    let emoji: String
    let sound: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            action()
            HapticManager.shared.impact(style: .heavy)
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            Text(emoji)
                .font(.system(size: 60))
                .frame(width: 120, height: 120)
                .background(Color.white)
                .cornerRadius(60)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
    }
}

// MARK: - Fruit Match-3 Game

struct FruitMatchGameView: View {
    @Binding var isPresented: Bool
    @State private var score = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.3), Color.orange.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Счет: \(score)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button("Закрыть") {
                        isPresented = false
                    }
                }
                .padding()

                Text("Match-3 игра")
                    .font(.title)
                    .padding()

                Text("Игра в разработке")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
    }
}
