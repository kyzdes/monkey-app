import Foundation
import SwiftUI

enum MonkeyType: String, Codable, CaseIterable {
    case gorilla = "Горилла"
    case orangutan = "Орангутанг"
    case baboon = "Бабуин"
    case gibbon = "Гибон"
    // v2.0 - New monkey types
    case marmoset = "Мартышка"
    case macaque = "Макака"
    case tamarin = "Тамарин"
    case capuchin = "Капуцин"
    case howler = "Ревун"
    case golden = "Золотая обезьяна"

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
        case .marmoset:
            return "Быстрый и ловкий"
        case .macaque:
            return "Умный и хитрый"
        case .tamarin:
            return "Маленький и милый"
        case .capuchin:
            return "Социальный и игривый"
        case .howler:
            return "Громкий и доминантный"
        case .golden:
            return "Редкий и красивый"
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
        case .marmoset:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 95,
                cleanliness: 100,
                strength: 35,
                intelligence: 75,
                creativity: 70,
                agility: 98
            )
        case .macaque:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 75,
                cleanliness: 100,
                strength: 60,
                intelligence: 92,
                creativity: 80,
                agility: 70
            )
        case .tamarin:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 80,
                cleanliness: 100,
                strength: 30,
                intelligence: 65,
                creativity: 85,
                agility: 90
            )
        case .capuchin:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 88,
                cleanliness: 100,
                strength: 55,
                intelligence: 88,
                creativity: 78,
                agility: 82
            )
        case .howler:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 85,
                cleanliness: 100,
                strength: 85,
                intelligence: 60,
                creativity: 55,
                agility: 65
            )
        case .golden:
            return MonkeyStats(
                health: 100,
                hunger: 50,
                happiness: 70,
                energy: 80,
                cleanliness: 100,
                strength: 70,
                intelligence: 85,
                creativity: 95,
                agility: 80
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
        case .marmoset:
            return [.insects, .fruits, .flowers]
        case .macaque:
            return [.nuts, .fruits, .banana]
        case .tamarin:
            return [.fruits, .flowers, .honey]
        case .capuchin:
            return [.fruits, .nuts, .banana]
        case .howler:
            return [.leaves, .fruits, .flowers]
        case .golden:
            return [.honey, .fruits, .mango]
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
        case .marmoset:
            return Color.init(red: 0.6, green: 0.4, blue: 0.3)
        case .macaque:
            return Color.init(red: 0.7, green: 0.5, blue: 0.4)
        case .tamarin:
            return Color.init(red: 0.9, green: 0.7, blue: 0.3)
        case .capuchin:
            return Color.init(red: 0.5, green: 0.35, blue: 0.25)
        case .howler:
            return Color.init(red: 0.3, green: 0.2, blue: 0.1)
        case .golden:
            return Color.init(red: 1.0, green: 0.84, blue: 0.0)
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
        case .marmoset:
            return "Супер скорость - быстрее других собирает предметы"
        case .macaque:
            return "Хитрость - находит скрытые бонусы и секреты"
        case .tamarin:
            return "Очарование - получает больше подарков от друзей"
        case .capuchin:
            return "Командная работа - бонусы в кооперативных играх"
        case .howler:
            return "Лидерство - получает бонусы репутации в клане"
        case .golden:
            return "Удача - увеличенный шанс получить редкие предметы"
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
