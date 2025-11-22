import Foundation
import SwiftUI

enum MonkeyType: String, Codable, CaseIterable {
    case gorilla = "Горилла"
    case orangutan = "Орангутанг"
    case baboon = "Бабуин"
    case gibbon = "Гибон"

    var description: String {
        switch self {
        case .gorilla:
            return "Сильный и спокойный"
        case .orangutan:
            return "Умный и творческий"
        case .baboon:
            return "Энергичный и социальный"
        case .gibbon:
            return "Акробатичный и музыкальный"
        }
    }

    var baseStats: MonkeyStats {
        switch self {
        case .gorilla:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 80,
                cleanliness: 100,
                strength: 90,
                intelligence: 60,
                creativity: 50,
                agility: 40
            )
        case .orangutan:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 70,
                cleanliness: 100,
                strength: 50,
                intelligence: 95,
                creativity: 90,
                agility: 60
            )
        case .baboon:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 90,
                cleanliness: 100,
                strength: 70,
                intelligence: 65,
                creativity: 60,
                agility: 85
            )
        case .gibbon:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 85,
                cleanliness: 100,
                strength: 50,
                intelligence: 70,
                creativity: 75,
                agility: 95
            )
        }
    }

    var favoriteFoods: [FoodType] {
        switch self {
        case .gorilla:
            return [.banana, .leaves, .bamboo]
        case .orangutan:
            return [.mango, .nuts, .honey]
        case .baboon:
            return [.banana, .insects, .fruits]
        case .gibbon:
            return [.fruits, .flowers, .honey]
        }
    }

    var primaryColor: Color {
        switch self {
        case .gorilla:
            return Color.gray
        case .orangutan:
            return Color.orange
        case .baboon:
            return Color.brown
        case .gibbon:
            return Color.init(red: 0.4, green: 0.3, blue: 0.2)
        }
    }

    var specialAbility: String {
        switch self {
        case .gorilla:
            return "Супер сила - может поднимать тяжелые предметы"
        case .orangutan:
            return "Решение головоломок - быстро учится новым трюкам"
        case .baboon:
            return "Социальная бабочка - получает бонусы от общения"
        case .gibbon:
            return "Акробатика - может выполнять сложные трюки"
        }
    }
}

enum FoodType: String, Codable, CaseIterable {
    case banana = "Банан"
    case mango = "Манго"
    case nuts = "Орехи"
    case fruits = "Фрукты"
    case leaves = "Листья"
    case bamboo = "Бамбук"
    case honey = "Мед"
    case insects = "Насекомые"
    case flowers = "Цветы"

    var nutritionValue: Int {
        switch self {
        case .banana: return 30
        case .mango: return 35
        case .nuts: return 25
        case .fruits: return 30
        case .leaves: return 15
        case .bamboo: return 20
        case .honey: return 40
        case .insects: return 20
        case .flowers: return 10
        }
    }

    var cost: Int {
        switch self {
        case .banana: return 10
        case .mango: return 20
        case .nuts: return 15
        case .fruits: return 15
        case .leaves: return 5
        case .bamboo: return 10
        case .honey: return 30
        case .insects: return 12
        case .flowers: return 8
        }
    }

    var icon: String {
        switch self {
        case .banana: return "🍌"
        case .mango: return "🥭"
        case .nuts: return "🥜"
        case .fruits: return "🍎"
        case .leaves: return "🍃"
        case .bamboo: return "🎋"
        case .honey: return "🍯"
        case .insects: return "🦗"
        case .flowers: return "🌺"
        }
    }
}
