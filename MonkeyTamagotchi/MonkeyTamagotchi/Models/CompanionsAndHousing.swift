import Foundation
import SwiftUI

// MARK: - Companion Pets

struct Companion: Codable, Identifiable {
    let id = UUID()
    var name: String
    let type: CompanionType
    var level: Int
    var happiness: Int
    var bond: Int // 0-100
    var unlocked: Bool

    enum CompanionType: String, Codable, CaseIterable {
        case butterfly = "Бабочка"
        case parrot = "Попугай"
        case squirrel = "Белка"
        case toucan = "Тукан"
        case firefly = "Светлячок"
        case hummingbird = "Колибри"

        var emoji: String {
            switch self {
            case .butterfly: return "🦋"
            case .parrot: return "🦜"
            case .squirrel: return "🐿️"
            case .toucan: return "🦤"
            case .firefly: return "🐝"
            case .hummingbird: return "🐦"
            }
        }

        var description: String {
            switch self {
            case .butterfly: return "Красивая бабочка, следует за вами"
            case .parrot: return "Повторяет звуки и помогает в общении"
            case .squirrel: return "Собирает орехи и бонусные предметы"
            case .toucan: return "Находит редкие фрукты"
            case .firefly: return "Светится ночью и находит скрытое"
            case .hummingbird: return "Увеличивает скорость сбора"
            }
        }

        var unlockLevel: Int {
            switch self {
            case .butterfly: return 1
            case .parrot: return 5
            case .squirrel: return 10
            case .toucan: return 15
            case .firefly: return 20
            case .hummingbird: return 25
            }
        }

        var bonus: CompanionBonus {
            switch self {
            case .butterfly:
                return CompanionBonus(type: .happiness, value: 5)
            case .parrot:
                return CompanionBonus(type: .social, value: 10)
            case .squirrel:
                return CompanionBonus(type: .collection, value: 15)
            case .toucan:
                return CompanionBonus(type: .rarity, value: 20)
            case .firefly:
                return CompanionBonus(type: .discovery, value: 25)
            case .hummingbird:
                return CompanionBonus(type: .speed, value: 30)
            }
        }
    }

    struct CompanionBonus {
        let type: BonusType
        let value: Int

        enum BonusType {
            case happiness    // +% happiness gain
            case social       // +% friend points
            case collection   // +% item find rate
            case rarity       // +% rare item chance
            case discovery    // +% discovery range
            case speed        // +% action speed
        }
    }

    var bondLevel: BondLevel {
        switch bond {
        case 0..<20: return .stranger
        case 20..<40: return .acquaintance
        case 40..<60: return .friend
        case 60..<80: return .bestFriend
        default: return .soulmate
        }
    }

    enum BondLevel: String {
        case stranger = "Незнакомец"
        case acquaintance = "Знакомый"
        case friend = "Друг"
        case bestFriend = "Лучший друг"
        case soulmate = "Родная душа"

        var multiplier: Double {
            switch self {
            case .stranger: return 1.0
            case .acquaintance: return 1.2
            case .friend: return 1.5
            case .bestFriend: return 2.0
            case .soulmate: return 3.0
            }
        }

        var color: Color {
            switch self {
            case .stranger: return .gray
            case .acquaintance: return .blue
            case .friend: return .green
            case .bestFriend: return .purple
            case .soulmate: return .yellow
            }
        }
    }

    mutating func increaseBond(_ amount: Int = 1) {
        bond = min(bond + amount, 100)
    }
}

// MARK: - Housing 2.0

struct House: Codable, Identifiable {
    let id = UUID()
    var name: String
    var style: HouseStyle
    var rooms: [Room]
    var furniture: [Furniture]
    var decorations: [Decoration]
    var level: Int
    var visitCount: Int

    enum HouseStyle: String, Codable, CaseIterable {
        case treehouse = "Домик на дереве"
        case bambooHut = "Бамбуковая хижина"
        case caveHome = "Пещерный дом"
        case tropicalVilla = "Тропическая вилла"
        case junglePalace = "Дворец в джунглях"
        case modernLoft = "Современный лофт"

        var cost: Int {
            switch self {
            case .treehouse: return 1000
            case .bambooHut: return 1500
            case .caveHome: return 2000
            case .tropicalVilla: return 5000
            case .junglePalace: return 10000
            case .modernLoft: return 15000
            }
        }

        var maxRooms: Int {
            switch self {
            case .treehouse: return 3
            case .bambooHut: return 4
            case .caveHome: return 5
            case .tropicalVilla: return 7
            case .junglePalace: return 10
            case .modernLoft: return 8
            }
        }

        var description: String {
            switch self {
            case .treehouse: return "Уютный домик среди деревьев"
            case .bambooHut: return "Традиционная бамбуковая постройка"
            case .caveHome: return "Просторная пещера с удобствами"
            case .tropicalVilla: return "Роскошная вилла на берегу"
            case .junglePalace: return "Величественный дворец в сердце джунглей"
            case .modernLoft: return "Стильное современное пространство"
            }
        }
    }

    struct Room: Codable, Identifiable {
        let id = UUID()
        var name: String
        let type: RoomType
        var furniture: [UUID] // Furniture IDs
        var size: RoomSize
        var theme: String

        enum RoomType: String, Codable, CaseIterable {
            case bedroom = "Спальня"
            case kitchen = "Кухня"
            case playroom = "Игровая"
            case bathroom = "Ванная"
            case gym = "Спортзал"
            case studio = "Студия"
            case garden = "Сад"
            case library = "Библиотека"

            var icon: String {
                switch self {
                case .bedroom: return "bed.double.fill"
                case .kitchen: return "fork.knife"
                case .playroom: return "gamecontroller.fill"
                case .bathroom: return "shower.fill"
                case .gym: return "dumbbell.fill"
                case .studio: return "paintpalette.fill"
                case .garden: return "leaf.fill"
                case .library: return "book.fill"
                }
            }

            var baseCost: Int {
                switch self {
                case .bedroom: return 500
                case .kitchen: return 800
                case .playroom: return 1000
                case .bathroom: return 600
                case .gym: return 1500
                case .studio: return 1200
                case .garden: return 2000
                case .library: return 1800
                }
            }
        }

        enum RoomSize: String, Codable {
            case small = "Маленькая"
            case medium = "Средняя"
            case large = "Большая"
            case huge = "Огромная"

            var maxFurniture: Int {
                switch self {
                case .small: return 5
                case .medium: return 10
                case .large: return 20
                case .huge: return 40
                }
            }

            var costMultiplier: Double {
                switch self {
                case .small: return 1.0
                case .medium: return 1.5
                case .large: return 2.5
                case .huge: return 4.0
                }
            }
        }
    }

    struct Furniture: Codable, Identifiable {
        let id = UUID()
        let name: String
        let type: FurnitureType
        var quality: Quality
        let cost: Int
        var functionality: [Functionality]

        enum FurnitureType: String, Codable {
            case bed = "Кровать"
            case chair = "Стул"
            case table = "Стол"
            case wardrobe = "Шкаф"
            case lamp = "Лампа"
            case plant = "Растение"
            case rug = "Ковер"
            case shelf = "Полка"
            case toy = "Игрушка"
            case equipment = "Оборудование"

            var icon: String {
                switch self {
                case .bed: return "bed.double"
                case .chair: return "chair"
                case .table: return "table"
                case .wardrobe: return "cabinet"
                case .lamp: return "lamp.desk"
                case .plant: return "leaf"
                case .rug: return "square.grid.2x2"
                case .shelf: return "books.vertical"
                case .toy: return "teddybear"
                case .equipment: return "wrench.and.screwdriver"
                }
            }
        }

        enum Quality: String, Codable {
            case basic = "Обычное"
            case good = "Хорошее"
            case premium = "Премиум"
            case luxury = "Роскошное"

            var statBonus: Int {
                switch self {
                case .basic: return 1
                case .good: return 2
                case .premium: return 5
                case .luxury: return 10
                }
            }

            var color: Color {
                switch self {
                case .basic: return .gray
                case .good: return .blue
                case .premium: return .purple
                case .luxury: return .yellow
                }
            }
        }

        enum Functionality {
            case rest          // Increases energy recovery
            case comfort       // Increases happiness
            case productivity  // Increases work output
            case entertainment // Provides fun
            case storage       // Stores items
            case decoration    // Aesthetic only
        }
    }

    struct Decoration: Codable, Identifiable {
        let id = UUID()
        let name: String
        let type: DecorationType
        var position: Position
        let cost: Int

        struct Position: Codable {
            var x: Double
            var y: Double
            var rotation: Double
        }

        enum DecorationType: String, Codable {
            case wallArt = "Картина"
            case statue = "Статуя"
            case plant = "Растение"
            case lighting = "Освещение"
            case carpet = "Ковер"
            case curtain = "Штора"
            case poster = "Постер"
            case trophy = "Трофей"

            var category: String {
                switch self {
                case .wallArt, .poster: return "Настенное"
                case .statue, .trophy: return "Напольное"
                case .plant: return "Природа"
                case .lighting: return "Освещение"
                case .carpet: return "Пол"
                case .curtain: return "Окно"
                }
            }
        }
    }

    var totalValue: Int {
        var value = style.cost
        for room in rooms {
            value += room.type.baseCost
        }
        for furniture in furniture {
            value += furniture.cost
        }
        for decoration in decorations {
            value += decoration.cost
        }
        return value
    }

    var comfortRating: Int {
        var rating = 0
        for furniture in furniture {
            rating += furniture.quality.statBonus
        }
        rating += decorations.count * 2
        return min(rating, 100)
    }

    mutating func addRoom(_ room: Room) {
        guard rooms.count < style.maxRooms else { return }
        rooms.append(room)
    }

    mutating func addFurniture(_ item: Furniture, to roomID: UUID) {
        guard let roomIndex = rooms.firstIndex(where: { $0.id == roomID }) else { return }
        let room = rooms[roomIndex]
        guard room.furniture.count < room.size.maxFurniture else { return }

        furniture.append(item)
        rooms[roomIndex].furniture.append(item.id)
    }
}

// MARK: - House Party

struct HouseParty: Identifiable {
    let id = UUID()
    let hostID: UUID
    let hostName: String
    var guests: [UUID]
    let startTime: Date
    let duration: TimeInterval
    var activities: [PartyActivity]
    var refreshments: [String]

    enum PartyActivity: String, CaseIterable {
        case dancing = "Танцы"
        case games = "Игры"
        case music = "Музыка"
        case contests = "Конкурсы"
        case karaoke = "Караоке"

        var icon: String {
            switch self {
            case .dancing: return "figure.dance"
            case .games: return "gamecontroller"
            case .music: return "music.note"
            case .contests: return "trophy"
            case .karaoke: return "mic"
            }
        }

        var funBonus: Int {
            switch self {
            case .dancing: return 20
            case .games: return 25
            case .music: return 15
            case .contests: return 30
            case .karaoke: return 35
            }
        }
    }

    var isActive: Bool {
        let now = Date()
        let endTime = startTime.addingTimeInterval(duration)
        return now >= startTime && now <= endTime
    }

    var timeRemaining: TimeInterval {
        let endTime = startTime.addingTimeInterval(duration)
        return max(endTime.timeIntervalSinceNow, 0)
    }
}
