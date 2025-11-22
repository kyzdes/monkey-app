import Foundation
import SwiftUI
import CoreLocation

// MARK: - AR Mode

struct ARSession: Identifiable {
    let id = UUID()
    var isActive: Bool
    var placedMonkey: PlacedMonkey?
    var discoveredItems: [ARDiscoveredItem]
    var sessionDuration: TimeInterval

    struct PlacedMonkey {
        let monkeyID: UUID
        var position: ARPosition
        var scale: Float
        var rotation: Float

        struct ARPosition {
            var x: Float
            var y: Float
            var z: Float
        }
    }
}

struct ARDiscoveredItem: Identifiable, Codable {
    let id = UUID()
    let itemType: String
    let discoveredAt: Date
    let location: CLLocationCoordinate2D?
    var collected: Bool

    var icon: String {
        switch itemType {
        case "banana": return "🍌"
        case "treasure": return "💎"
        case "coin": return "🪙"
        case "potion": return "🧪"
        default: return "⭐"
        }
    }

    var reward: Int {
        switch itemType {
        case "banana": return 10
        case "treasure": return 100
        case "coin": return 25
        case "potion": return 50
        default: return 5
        }
    }
}

// MARK: - AR Mini-Games

enum ARMiniGame: String, CaseIterable {
    case hideAndSeek = "AR Прятки"
    case treasureHunt = "Поиск сокровищ"
    case obstacleCourse = "Полоса препятствий"
    case catchBananas = "Лови бананы"

    var description: String {
        switch self {
        case .hideAndSeek:
            return "Найдите свою обезьяну, спрятавшуюся в реальном мире"
        case .treasureHunt:
            return "Ищите спрятанные предметы вокруг себя"
        case .obstacleCourse:
            return "Пройдите AR полосу препятствий"
        case .catchBananas:
            return "Ловите падающие бананы в AR"
        }
    }

    var duration: TimeInterval {
        switch self {
        case .hideAndSeek: return 300 // 5 min
        case .treasureHunt: return 600 // 10 min
        case .obstacleCourse: return 180 // 3 min
        case .catchBananas: return 120 // 2 min
        }
    }

    var maxReward: Int {
        switch self {
        case .hideAndSeek: return 100
        case .treasureHunt: return 200
        case .obstacleCourse: return 150
        case .catchBananas: return 75
        }
    }
}

// MARK: - Tama Walk

struct TamaWalk: Codable, Identifiable {
    let id = UUID()
    var startDate: Date
    var endDate: Date?
    var distance: Double // meters
    var steps: Int
    var itemsFound: [ARDiscoveredItem]
    var experienceGained: Int
    var coinsEarned: Int

    var isActive: Bool {
        endDate == nil
    }

    var duration: TimeInterval {
        if let end = endDate {
            return end.timeIntervalSince(startDate)
        }
        return Date().timeIntervalSince(startDate)
    }

    var formattedDistance: String {
        if distance < 1000 {
            return String(format: "%.0f м", distance)
        } else {
            return String(format: "%.2f км", distance / 1000)
        }
    }

    mutating func end() {
        endDate = Date()
        // Calculate rewards
        experienceGained = Int(distance / 10) // 1 XP per 10 meters
        coinsEarned = Int(distance / 50) // 1 coin per 50 meters
    }
}

struct LocationEvent: Identifiable, Codable {
    let id = UUID()
    let location: LocationData
    let eventType: EventType
    let availableUntil: Date
    var participants: Int

    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let name: String
        let radius: Double // meters
    }

    enum EventType: String, Codable {
        case communityGathering = "Встреча сообщества"
        case rareTreasure = "Редкое сокровище"
        case specialMonkey = "Особая обезьяна"
        case tournament = "Турнир"

        var icon: String {
            switch self {
            case .communityGathering: return "person.3.fill"
            case .rareTreasure: return "gift.fill"
            case .specialMonkey: return "🐵"
            case .tournament: return "trophy.fill"
            }
        }

        var color: Color {
            switch self {
            case .communityGathering: return .blue
            case .rareTreasure: return .yellow
            case .specialMonkey: return .purple
            case .tournament: return .red
            }
        }
    }

    var isAvailable: Bool {
        Date() < availableUntil
    }

    var timeRemaining: TimeInterval {
        max(availableUntil.timeIntervalSinceNow, 0)
    }
}

// MARK: - Vision Pro Support

struct SpatialEnvironment {
    var style: EnvironmentStyle
    var immersionLevel: ImmersionLevel
    var spatialAudioEnabled: Bool
    var handTrackingEnabled: Bool

    enum EnvironmentStyle: String, CaseIterable {
        case jungle = "Джунгли"
        case island = "Остров"
        case mountain = "Горы"
        case forest = "Лес"
        case space = "Космос"

        var description: String {
            switch self {
            case .jungle: return "Тропические джунгли с лианами"
            case .island: return "Райский остров с пляжем"
            case .mountain: return "Высокие горы с видом"
            case .forest: return "Густой лес с деревьями"
            case .space: return "Космическая среда"
            }
        }
    }

    enum ImmersionLevel: String, CaseIterable {
        case mixed = "Смешанная"
        case progressive = "Прогрессивная"
        case full = "Полная"

        var description: String {
            switch self {
            case .mixed: return "Видите реальный мир"
            case .progressive: return "Частичное погружение"
            case .full: return "Полное погружение"
            }
        }
    }

    static let `default` = SpatialEnvironment(
        style: .jungle,
        immersionLevel: .mixed,
        spatialAudioEnabled: true,
        handTrackingEnabled: true
    )
}

struct HandGesture: Identifiable {
    let id = UUID()
    let type: GestureType
    var timestamp: Date

    enum GestureType: String {
        case tap = "Тап"
        case pinch = "Щипок"
        case swipe = "Свайп"
        case grab = "Захват"
        case point = "Указание"
        case wave = "Помах"

        var action: MonkeyInteraction {
            switch self {
            case .tap: return .pet
            case .pinch: return .feed
            case .swipe: return .play
            case .grab: return .hold
            case .point: return .command
            case .wave: return .greet
            }
        }
    }

    enum MonkeyInteraction {
        case pet
        case feed
        case play
        case hold
        case command
        case greet
    }
}

// MARK: - AR Photo/Video

struct ARMedia: Identifiable, Codable {
    let id = UUID()
    let type: MediaType
    let filename: String
    let createdAt: Date
    var effects: [AREffect]

    enum MediaType: String, Codable {
        case photo = "Фото"
        case video = "Видео"
    }

    enum AREffect: String, Codable, CaseIterable {
        case confetti = "Конфетти"
        case sparkles = "Искры"
        case hearts = "Сердечки"
        case rainbowTrail = "Радужный след"
        case bubbles = "Пузыри"
        case fireworks = "Фейерверк"

        var icon: String {
            switch self {
            case .confetti: return "🎊"
            case .sparkles: return "✨"
            case .hearts: return "💕"
            case .rainbowTrail: return "🌈"
            case .bubbles: return "🫧"
            case .fireworks: return "🎆"
            }
        }
    }
}
