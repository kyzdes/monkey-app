import Foundation
import SwiftUI

struct Match3Tile: Identifiable, Equatable {
    let id = UUID()
    var type: FruitType
    var row: Int
    var col: Int
    var isMatched: Bool = false
    var isNew: Bool = false

    enum FruitType: Int, CaseIterable {
        case banana = 0
        case mango = 1
        case grape = 2
        case apple = 3
        case orange = 4
        case strawberry = 5

        var emoji: String {
            switch self {
            case .banana: return "🍌"
            case .mango: return "🥭"
            case .grape: return "🍇"
            case .apple: return "🍎"
            case .orange: return "🍊"
            case .strawberry: return "🍓"
            }
        }

        var color: Color {
            switch self {
            case .banana: return .yellow
            case .mango: return .orange
            case .grape: return .purple
            case .apple: return .red
            case .orange: return .orange
            case .strawberry: return .pink
            }
        }

        static func random() -> FruitType {
            allCases.randomElement() ?? .banana
        }
    }
}

class Match3GameEngine: ObservableObject {
    @Published var board: [[Match3Tile]] = []
    @Published var score: Int = 0
    @Published var moves: Int = 30
    @Published var targetScore: Int = 1000
    @Published var gameState: GameState = .playing
    @Published var combo: Int = 0

    let rows = 8
    let cols = 7

    enum GameState {
        case playing
        case won
        case lost
    }

    init() {
        setupNewGame()
    }

    func setupNewGame() {
        score = 0
        moves = 30
        gameState = .playing
        combo = 0
        board = generateBoard()
        removeInitialMatches()
    }

    private func generateBoard() -> [[Match3Tile]] {
        var newBoard: [[Match3Tile]] = []

        for row in 0..<rows {
            var rowTiles: [Match3Tile] = []
            for col in 0..<cols {
                let tile = Match3Tile(
                    type: .random(),
                    row: row,
                    col: col
                )
                rowTiles.append(tile)
            }
            newBoard.append(rowTiles)
        }

        return newBoard
    }

    private func removeInitialMatches() {
        var hasMatches = true

        while hasMatches {
            let matches = findMatches()
            if matches.isEmpty {
                hasMatches = false
            } else {
                for match in matches {
                    board[match.row][match.col] = Match3Tile(
                        type: .random(),
                        row: match.row,
                        col: match.col
                    )
                }
            }
        }
    }

    func canSwap(tile1: Match3Tile, tile2: Match3Tile) -> Bool {
        let rowDiff = abs(tile1.row - tile2.row)
        let colDiff = abs(tile1.col - tile2.col)

        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }

    func swapTiles(_ tile1: Match3Tile, _ tile2: Match3Tile) {
        guard canSwap(tile1: tile1, tile2: tile2) else { return }

        // Swap
        let temp = board[tile1.row][tile1.col]
        board[tile1.row][tile1.col] = board[tile2.row][tile2.col]
        board[tile2.row][tile2.col] = temp

        // Update positions
        board[tile1.row][tile1.col].row = tile1.row
        board[tile1.row][tile1.col].col = tile1.col
        board[tile2.row][tile2.col].row = tile2.row
        board[tile2.row][tile2.col].col = tile2.col

        // Check for matches
        let matches = findMatches()

        if matches.isEmpty {
            // Swap back if no matches
            let temp = board[tile1.row][tile1.col]
            board[tile1.row][tile1.col] = board[tile2.row][tile2.col]
            board[tile2.row][tile2.col] = temp

            board[tile1.row][tile1.col].row = tile1.row
            board[tile1.row][tile1.col].col = tile1.col
            board[tile2.row][tile2.col].row = tile2.row
            board[tile2.row][tile2.col].col = tile2.col
        } else {
            moves -= 1
            processMatches()
        }
    }

    private func findMatches() -> [Match3Tile] {
        var matches: [Match3Tile] = []

        // Horizontal matches
        for row in 0..<rows {
            var matchLength = 1
            for col in 1..<cols {
                if board[row][col].type == board[row][col - 1].type {
                    matchLength += 1
                } else {
                    if matchLength >= 3 {
                        for i in (col - matchLength)..<col {
                            if !matches.contains(where: { $0.row == row && $0.col == i }) {
                                matches.append(board[row][i])
                            }
                        }
                    }
                    matchLength = 1
                }
            }
            if matchLength >= 3 {
                for i in (cols - matchLength)..<cols {
                    if !matches.contains(where: { $0.row == row && $0.col == i }) {
                        matches.append(board[row][i])
                    }
                }
            }
        }

        // Vertical matches
        for col in 0..<cols {
            var matchLength = 1
            for row in 1..<rows {
                if board[row][col].type == board[row - 1][col].type {
                    matchLength += 1
                } else {
                    if matchLength >= 3 {
                        for i in (row - matchLength)..<row {
                            if !matches.contains(where: { $0.row == i && $0.col == col }) {
                                matches.append(board[i][col])
                            }
                        }
                    }
                    matchLength = 1
                }
            }
            if matchLength >= 3 {
                for i in (rows - matchLength)..<rows {
                    if !matches.contains(where: { $0.row == i && $0.col == col }) {
                        matches.append(board[i][col])
                    }
                }
            }
        }

        return matches
    }

    private func processMatches() {
        var totalMatches = 0

        while true {
            let matches = findMatches()
            if matches.isEmpty { break }

            totalMatches += matches.count

            // Mark tiles as matched
            for match in matches {
                board[match.row][match.col].isMatched = true
            }

            // Calculate score with combo
            let basePoints = matches.count * 10
            combo += 1
            let comboBonus = combo * 5
            score += basePoints + comboBonus

            // Drop tiles
            dropTiles()

            // Fill empty spaces
            fillBoard()
        }

        if totalMatches == 0 {
            combo = 0
        }

        // Check game state
        checkGameState()
    }

    private func dropTiles() {
        for col in 0..<cols {
            var emptySpaces = 0

            for row in (0..<rows).reversed() {
                if board[row][col].isMatched {
                    emptySpaces += 1
                } else if emptySpaces > 0 {
                    let newRow = row + emptySpaces
                    board[newRow][col] = board[row][col]
                    board[newRow][col].row = newRow
                    board[row][col].isMatched = true
                }
            }
        }
    }

    private func fillBoard() {
        for row in 0..<rows {
            for col in 0..<cols {
                if board[row][col].isMatched {
                    board[row][col] = Match3Tile(
                        type: .random(),
                        row: row,
                        col: col,
                        isNew: true
                    )
                }
            }
        }
    }

    private func checkGameState() {
        if score >= targetScore {
            gameState = .won
        } else if moves <= 0 {
            gameState = .lost
        }
    }

    func getReward() -> Int {
        if gameState == .won {
            return score / 10
        }
        return score / 20
    }
}
