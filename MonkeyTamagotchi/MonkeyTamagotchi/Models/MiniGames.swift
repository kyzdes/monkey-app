import Foundation
import SwiftUI

// MARK: - Mini Game Base

protocol MiniGame {
    var name: String { get }
    var description: String { get }
    var difficulty: GameDifficulty { get }
    var maxScore: Int { get }
    var duration: TimeInterval { get }
}

enum GameDifficulty: String, Codable {
    case easy = "Легко"
    case medium = "Средне"
    case hard = "Сложно"
    case expert = "Эксперт"

    var multiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        case .expert: return 3.0
        }
    }

    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .blue
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

// MARK: - 1. Rhythm Game

struct RhythmGame: MiniGame {
    let name = "Музыкальный ритм"
    let description = "Нажимайте на ноты в такт музыке"
    var difficulty: GameDifficulty
    let maxScore = 10000
    let duration: TimeInterval = 180 // 3 minutes

    var song: Song
    var notes: [Note]
    var score: Int = 0
    var combo: Int = 0
    var maxCombo: Int = 0
    var accuracy: Double = 0.0

    struct Song: Codable {
        let id: String
        let title: String
        let artist: String
        let bpm: Int
        let duration: TimeInterval

        var noteSpeed: Double {
            Double(bpm) / 60.0
        }
    }

    struct Note: Identifiable, Codable {
        let id = UUID()
        let lane: Int // 0-3 (4 lanes)
        let timestamp: TimeInterval
        let type: NoteType
        var hit: Bool = false
        var hitTiming: HitTiming?

        enum NoteType: String, Codable {
            case single = "Одиночная"
            case long = "Длинная"
            case special = "Особая"

            var points: Int {
                switch self {
                case .single: return 100
                case .long: return 200
                case .special: return 500
                }
            }
        }

        enum HitTiming: String, Codable {
            case perfect = "Идеально"
            case great = "Отлично"
            case good = "Хорошо"
            case miss = "Промах"

            var accuracy: Double {
                switch self {
                case .perfect: return 1.0
                case .great: return 0.9
                case .good: return 0.7
                case .miss: return 0.0
                }
            }

            var points: Double {
                switch self {
                case .perfect: return 1.5
                case .great: return 1.2
                case .good: return 1.0
                case .miss: return 0.0
                }
            }
        }
    }

    mutating func hitNote(_ note: Note, timing: Note.HitTiming) {
        let basePoints = note.type.points
        let timingBonus = timing.points
        let comboBonus = 1.0 + (Double(combo) * 0.01)

        let earnedPoints = Int(Double(basePoints) * timingBonus * comboBonus)
        score += earnedPoints

        if timing != .miss {
            combo += 1
            maxCombo = max(maxCombo, combo)
        } else {
            combo = 0
        }
    }

    static func generateSong(difficulty: GameDifficulty) -> RhythmGame {
        let songs = [
            Song(id: "jungle_beat", title: "Jungle Beat", artist: "Monkey Band", bpm: 120, duration: 180),
            Song(id: "banana_groove", title: "Banana Groove", artist: "Tropical Tunes", bpm: 140, duration: 180),
            Song(id: "wild_rhythm", title: "Wild Rhythm", artist: "Forest Symphony", bpm: 160, duration: 180)
        ]

        let selectedSong = songs.randomElement()!
        var notes: [Note] = []

        let noteCount: Int
        switch difficulty {
        case .easy: noteCount = 50
        case .medium: noteCount = 100
        case .hard: noteCount = 150
        case .expert: noteCount = 200
        }

        for i in 0..<noteCount {
            let timestamp = (selectedSong.duration / Double(noteCount)) * Double(i)
            let note = Note(
                lane: Int.random(in: 0...3),
                timestamp: timestamp,
                type: .single
            )
            notes.append(note)
        }

        return RhythmGame(difficulty: difficulty, song: selectedSong, notes: notes)
    }
}

// MARK: - 2. Platformer Runner

struct PlatformerRunner: MiniGame {
    let name = "Беги и прыгай"
    let description = "Бегите и избегайте препятствий"
    var difficulty: GameDifficulty
    let maxScore = 999999
    let duration: TimeInterval = 300 // 5 minutes

    var distance: Int = 0
    var coins: Int = 0
    var lives: Int = 3
    var speed: Double = 1.0
    var obstacles: [Obstacle]
    var collectibles: [Collectible]

    struct Obstacle: Identifiable {
        let id = UUID()
        let type: ObstacleType
        var position: Double
        var passed: Bool = false

        enum ObstacleType: String {
            case rock = "Камень"
            case pit = "Яма"
            case branch = "Ветка"
            case enemy = "Враг"

            var damage: Int {
                switch self {
                case .rock: return 1
                case .pit: return 2
                case .branch: return 1
                case .enemy: return 2
                }
            }

            var canJumpOver: Bool {
                switch self {
                case .rock, .branch: return true
                case .pit, .enemy: return false
                }
            }
        }
    }

    struct Collectible: Identifiable {
        let id = UUID()
        let type: CollectibleType
        var position: Double
        var collected: Bool = false

        enum CollectibleType: String {
            case banana = "Банан"
            case coin = "Монета"
            case powerup = "Усиление"
            case shield = "Щит"

            var value: Int {
                switch self {
                case .banana: return 10
                case .coin: return 1
                case .powerup: return 50
                case .shield: return 0 // Protection
                }
            }

            var icon: String {
                switch self {
                case .banana: return "🍌"
                case .coin: return "🪙"
                case .powerup: return "⭐"
                case .shield: return "🛡️"
                }
            }
        }
    }

    mutating func update(deltaTime: Double) {
        distance += Int(speed * deltaTime * 100)
        speed += 0.001 // Gradually increase difficulty
    }
}

// MARK: - 3. Puzzle Adventure

struct PuzzleAdventure: MiniGame {
    let name = "Головоломки джунглей"
    let description = "Решайте головоломки и находите выход"
    var difficulty: GameDifficulty
    let maxScore = 5000
    let duration: TimeInterval = 600 // 10 minutes

    var currentLevel: Int = 1
    var puzzles: [Puzzle]
    var score: Int = 0
    var hintsUsed: Int = 0

    struct Puzzle: Identifiable {
        let id = UUID()
        let type: PuzzleType
        let level: Int
        var solution: String
        var userAnswer: String?
        var solved: Bool = false
        var timeSpent: TimeInterval = 0

        enum PuzzleType: String {
            case matchThree = "Собери три"
            case pathFinding = "Найди путь"
            case memory = "Память"
            case logic = "Логика"
            case pattern = "Узор"

            var icon: String {
                switch self {
                case .matchThree: return "square.3.stack.3d"
                case .pathFinding: return "arrow.triangle.turn.up.right.diamond"
                case .memory: return "brain.head.profile"
                case .logic: return "lightbulb"
                case .pattern: return "circle.hexagongrid"
                }
            }

            var basePoints: Int {
                switch self {
                case .matchThree: return 100
                case .pathFinding: return 150
                case .memory: return 200
                case .logic: return 250
                case .pattern: return 300
                }
            }
        }

        func calculateScore() -> Int {
            guard solved else { return 0 }
            let basePoints = type.basePoints * level
            let timeBonus = max(0, 300 - Int(timeSpent)) // Bonus for fast solving
            return basePoints + timeBonus
        }
    }

    static func generatePuzzles(difficulty: GameDifficulty) -> [Puzzle] {
        let count: Int
        switch difficulty {
        case .easy: count = 5
        case .medium: count = 10
        case .hard: count = 15
        case .expert: count = 20
        }

        return (1...count).map { level in
            Puzzle(
                type: Puzzle.PuzzleType.allCases.randomElement()!,
                level: level,
                solution: "solution_\(level)"
            )
        }
    }
}

// MARK: - 4. Card Battler

struct CardBattler: MiniGame {
    let name = "Карточные битвы"
    let description = "Сражайтесь картами с противниками"
    var difficulty: GameDifficulty
    let maxScore = 10000
    let duration: TimeInterval = 600 // 10 minutes

    var playerDeck: [Card]
    var playerHand: [Card]
    var playerHealth: Int = 100
    var playerMana: Int = 10

    var opponent: Opponent
    var opponentHealth: Int = 100

    var round: Int = 1
    var wins: Int = 0

    struct Card: Identifiable, Codable {
        let id = UUID()
        let name: String
        let cost: Int
        let attack: Int
        let defense: Int
        let type: CardType
        var special: SpecialAbility?

        enum CardType: String, Codable {
            case creature = "Существо"
            case spell = "Заклинание"
            case trap = "Ловушка"
            case powerup = "Усиление"

            var color: Color {
                switch self {
                case .creature: return .brown
                case .spell: return .purple
                case .trap: return .orange
                case .powerup: return .yellow
                }
            }
        }

        enum SpecialAbility: String, Codable {
            case doubleAttack = "Двойная атака"
            case shield = "Щит"
            case heal = "Лечение"
            case burn = "Поджог"
            case freeze = "Заморозка"
        }

        static func starter() -> [Card] {
            [
                Card(name: "Горилла", cost: 3, attack: 5, defense: 5, type: .creature),
                Card(name: "Орангутанг", cost: 4, attack: 3, defense: 3, type: .creature, special: .shield),
                Card(name: "Бабуин", cost: 2, attack: 4, defense: 2, type: .creature, special: .doubleAttack),
                Card(name: "Гибон", cost: 3, attack: 6, defense: 1, type: .creature),
                Card(name: "Банановый удар", cost: 2, attack: 3, defense: 0, type: .spell),
                Card(name: "Лечебная магия", cost: 3, attack: 0, defense: 0, type: .spell, special: .heal)
            ]
        }
    }

    struct Opponent: Codable {
        let name: String
        let difficulty: GameDifficulty
        var deck: [Card]

        var health: Int {
            switch difficulty {
            case .easy: return 50
            case .medium: return 100
            case .hard: return 150
            case .expert: return 200
            }
        }
    }
}

// MARK: - 5. Racing Game

struct RacingGame: MiniGame {
    let name = "Гонки по джунглям"
    let description = "Обгоняйте соперников в гонках"
    var difficulty: GameDifficulty
    let maxScore = 50000
    let duration: TimeInterval = 300 // 5 minutes

    var currentLap: Int = 1
    var totalLaps: Int = 3
    var position: Int = 1
    var speed: Double = 0
    var distance: Double = 0
    var boost: Double = 0

    var opponents: [Racer]
    var powerups: [RacePowerup]

    struct Racer: Identifiable {
        let id = UUID()
        let name: String
        let character: MonkeyType
        var position: Double
        var speed: Double
        var placement: Int

        var isPlayer: Bool {
            name == "Player"
        }
    }

    struct RacePowerup: Identifiable {
        let id = UUID()
        let type: PowerupType
        var position: Double
        var collected: Bool = false

        enum PowerupType: String {
            case speedBoost = "Ускорение"
            case shield = "Щит"
            case trap = "Ловушка"
            case coins = "Монеты"

            var icon: String {
                switch self {
                case .speedBoost: return "⚡"
                case .shield: return "🛡️"
                case .trap: return "💣"
                case .coins: return "🪙"
                }
            }

            var duration: TimeInterval {
                switch self {
                case .speedBoost: return 5.0
                case .shield: return 10.0
                case .trap: return 0
                case .coins: return 0
                }
            }
        }
    }

    mutating func update(deltaTime: Double) {
        // Update distance
        distance += speed * deltaTime

        // Update lap
        let trackLength = 1000.0
        if distance >= trackLength * Double(currentLap) {
            currentLap += 1
        }
    }

    var progress: Double {
        let totalDistance = 1000.0 * Double(totalLaps)
        return min(distance / totalDistance, 1.0)
    }

    var isFinished: Bool {
        currentLap > totalLaps
    }
}

// MARK: - Game Result

struct GameResult: Identifiable, Codable {
    let id = UUID()
    let gameName: String
    let score: Int
    let difficulty: GameDifficulty
    let completedAt: Date
    var stars: Int
    let coinsEarned: Int
    let experienceEarned: Int

    var rating: Rating {
        switch stars {
        case 3: return .perfect
        case 2: return .good
        case 1: return .okay
        default: return .failed
        }
    }

    enum Rating: String {
        case perfect = "Идеально"
        case good = "Хорошо"
        case okay = "Неплохо"
        case failed = "Провал"

        var color: Color {
            switch self {
            case .perfect: return .yellow
            case .good: return .green
            case .okay: return .blue
            case .failed: return .gray
            }
        }
    }
}
