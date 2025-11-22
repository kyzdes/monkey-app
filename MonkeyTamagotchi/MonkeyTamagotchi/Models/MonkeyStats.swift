import Foundation

struct MonkeyStats: Codable {
    var health: Double
    var hunger: Double
    var happiness: Double
    var energy: Double
    var cleanliness: Double
    var strength: Double
    var intelligence: Double
    var creativity: Double
    var agility: Double

    mutating func clamp() {
        health = min(max(health, 0), 100)
        hunger = min(max(hunger, 0), 100)
        happiness = min(max(happiness, 0), 100)
        energy = min(max(energy, 0), 100)
        cleanliness = min(max(cleanliness, 0), 100)
        strength = min(max(strength, 0), 100)
        intelligence = min(max(intelligence, 0), 100)
        creativity = min(max(creativity, 0), 100)
        agility = min(max(agility, 0), 100)
    }

    var isHealthy: Bool {
        health > 30 && hunger < 80 && energy > 20
    }

    var isHappy: Bool {
        happiness > 50 && health > 50
    }

    var needsCare: Bool {
        health < 40 || hunger > 70 || energy < 30 || cleanliness < 40
    }

    var overallWellness: Double {
        (health + (100 - hunger) + happiness + energy + cleanliness) / 5
    }
}

enum Mood: String, Codable {
    case happy = "Счастливый"
    case sad = "Грустный"
    case energetic = "Энергичный"
    case tired = "Усталый"
    case hungry = "Голодный"
    case sick = "Больной"
    case playful = "Игривый"
    case sleepy = "Сонный"
    case angry = "Злой"
    case loving = "Любящий"

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .energetic: return "⚡️"
        case .tired: return "😴"
        case .hungry: return "🤤"
        case .sick: return "🤒"
        case .playful: return "🤗"
        case .sleepy: return "😪"
        case .angry: return "😠"
        case .loving: return "🥰"
        }
    }

    static func determineMood(from stats: MonkeyStats) -> Mood {
        if stats.health < 30 {
            return .sick
        } else if stats.hunger > 80 {
            return .hungry
        } else if stats.energy < 20 {
            return .sleepy
        } else if stats.cleanliness < 30 {
            return .sad
        } else if stats.happiness > 80 && stats.energy > 70 {
            return .playful
        } else if stats.energy > 80 {
            return .energetic
        } else if stats.happiness > 80 {
            return .happy
        } else if stats.happiness < 30 {
            return .sad
        } else if stats.energy < 40 {
            return .tired
        } else {
            return .happy
        }
    }
}
