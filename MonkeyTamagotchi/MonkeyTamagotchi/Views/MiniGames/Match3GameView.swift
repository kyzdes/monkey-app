import SwiftUI

struct FruitMatchGameView: View {
    @Binding var isPresented: Bool
    @StateObject private var gameEngine = Match3GameEngine()
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTile: Match3Tile?
    @State private var showGameOver = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.3), Color.orange.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Заголовок и статистика
                header

                // Игровое поле
                gameBoard
                    .padding()

                // Индикатор комбо
                if gameEngine.combo > 1 {
                    Text("COMBO x\(gameEngine.combo)!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .shadow(radius: 5)
                }

                Spacer()
            }

            // Экран окончания игры
            if showGameOver {
                GameOverView(
                    gameState: gameEngine.gameState,
                    score: gameEngine.score,
                    reward: gameEngine.getReward(),
                    onRestart: {
                        gameEngine.setupNewGame()
                        showGameOver = false
                    },
                    onClose: {
                        claimReward()
                        isPresented = false
                    }
                )
            }
        }
        .onChange(of: gameEngine.gameState) { newState in
            if newState != .playing {
                showGameOver = true
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                Button("Закрыть") {
                    isPresented = false
                }
                .foregroundColor(.white)
                .padding()

                Spacer()

                Button("Новая игра") {
                    gameEngine.setupNewGame()
                    showGameOver = false
                }
                .foregroundColor(.white)
                .padding()
            }

            HStack(spacing: 40) {
                VStack {
                    Text("Счёт")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(gameEngine.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack {
                    Text("Цель")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(gameEngine.targetScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack {
                    Text("Ходы")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(gameEngine.moves)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(gameEngine.moves < 10 ? .red : .white)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
        }
    }

    private var gameBoard: some View {
        GeometryReader { geometry in
            let tileSize = min(
                (geometry.size.width - CGFloat(gameEngine.cols + 1) * 4) / CGFloat(gameEngine.cols),
                (geometry.size.height - CGFloat(gameEngine.rows + 1) * 4) / CGFloat(gameEngine.rows)
            )

            VStack(spacing: 4) {
                ForEach(0..<gameEngine.rows, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<gameEngine.cols, id: \.self) { col in
                            let tile = gameEngine.board[row][col]
                            TileView(
                                tile: tile,
                                size: tileSize,
                                isSelected: selectedTile?.id == tile.id
                            )
                            .onTapGesture {
                                handleTileTap(tile)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func handleTileTap(_ tile: Match3Tile) {
        guard gameEngine.gameState == .playing else { return }

        if let selected = selectedTile {
            if selected.id == tile.id {
                // Deselect
                selectedTile = nil
            } else if gameEngine.canSwap(tile1: selected, tile2: tile) {
                // Perform swap
                withAnimation(.spring()) {
                    gameEngine.swapTiles(selected, tile)
                    selectedTile = nil
                }
                HapticManager.shared.impact(style: .medium)
            } else {
                // Select different tile
                selectedTile = tile
                HapticManager.shared.selection()
            }
        } else {
            // Select tile
            selectedTile = tile
            HapticManager.shared.selection()
        }
    }

    private func claimReward() {
        let reward = gameEngine.getReward()
        if let monkey = gameManager.currentMonkey {
            monkey.coins += reward
            monkey.addExperience(reward)
            gameManager.saveGame()
        }
    }
}

struct TileView: View {
    let tile: Match3Tile
    let size: CGFloat
    let isSelected: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tile.type.color.opacity(0.3))
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                )
                .shadow(color: isSelected ? .white : .clear, radius: 5)

            Text(tile.type.emoji)
                .font(.system(size: size * 0.6))
                .scaleEffect(tile.isNew ? 0.1 : 1.0)
                .opacity(tile.isMatched ? 0 : 1)
        }
        .animation(.spring(), value: tile.isNew)
        .animation(.easeOut(duration: 0.2), value: tile.isMatched)
    }
}

struct GameOverView: View {
    let gameState: Match3GameEngine.GameState
    let score: Int
    let reward: Int
    let onRestart: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Результат
                Text(gameState == .won ? "Победа!" : "Игра окончена")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(gameState == .won ? .yellow : .white)

                // Звёзды (если победа)
                if gameState == .won {
                    HStack(spacing: 10) {
                        ForEach(0..<3) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                        }
                    }
                }

                // Статистика
                VStack(spacing: 15) {
                    StatRow(label: "Счёт", value: "\(score)")
                    StatRow(label: "Награда", value: "🍌 \(reward)")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)

                // Кнопки
                VStack(spacing: 15) {
                    Button(action: onRestart) {
                        Text("Играть снова")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: onClose) {
                        Text("Забрать награду и выйти")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.2))
            )
            .padding(40)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}
