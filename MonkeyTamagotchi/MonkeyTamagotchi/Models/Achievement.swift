import Foundation

struct Achievement: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let requirement: AchievementRequirement
    let reward: Int
    let icon: String
    var isUnlocked: Bool
    var progress: Double

    init(title: String, description: String, requirement: AchievementRequirement, reward: Int, icon: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.requirement = requirement
        self.reward = reward
        self.icon = icon
        self.isUnlocked = false
        self.progress = 0.0
    }
}

enum AchievementRequirement: Codable {
    case reachLevel(Int)
    case feedTimes(Int)
    case playTimes(Int)
    case learnTricks(Int)
    case collectCoins(Int)
    case daysAlive(Int)
    case completeMinigame(String, times: Int)
    case ownItems(Int)
    case maxStat(String, value: Double)
    case performTrick(String, times: Int)

    var progressTarget: Double {
        switch self {
        case .reachLevel(let level): return Double(level)
        case .feedTimes(let times): return Double(times)
        case .playTimes(let times): return Double(times)
        case .learnTricks(let count): return Double(count)
        case .collectCoins(let amount): return Double(amount)
        case .daysAlive(let days): return Double(days)
        case .completeMinigame(_, let times): return Double(times)
        case .ownItems(let count): return Double(count)
        case .maxStat(_, let value): return value
        case .performTrick(_, let times): return Double(times)
        }
    }
}

extension Achievement {
    static let defaultAchievements: [Achievement] = [
        // Уровни
        Achievement(
            title: "Новичок",
            description: "Достигните 5 уровня",
            requirement: .reachLevel(5),
            reward: 100,
            icon: "⭐️"
        ),
        Achievement(
            title: "Опытный",
            description: "Достигните 10 уровня",
            requirement: .reachLevel(10),
            reward: 250,
            icon: "🌟"
        ),
        Achievement(
            title: "Мастер",
            description: "Достигните 25 уровня",
            requirement: .reachLevel(25),
            reward: 500,
            icon: "✨"
        ),
        Achievement(
            title: "Легенда",
            description: "Достигните 50 уровня",
            requirement: .reachLevel(50),
            reward: 1000,
            icon: "💫"
        ),

        // Кормление
        Achievement(
            title: "Гурман",
            description: "Покормите 100 раз",
            requirement: .feedTimes(100),
            reward: 200,
            icon: "🍽️"
        ),
        Achievement(
            title: "Шеф-повар",
            description: "Покормите 500 раз",
            requirement: .feedTimes(500),
            reward: 500,
            icon: "👨‍🍳"
        ),

        // Игры
        Achievement(
            title: "Игрок",
            description: "Сыграйте 50 раз",
            requirement: .playTimes(50),
            reward: 150,
            icon: "🎮"
        ),
        Achievement(
            title: "Про-игрок",
            description: "Сыграйте 200 раз",
            requirement: .playTimes(200),
            reward: 400,
            icon: "🏆"
        ),

        // Трюки
        Achievement(
            title: "Артист",
            description: "Выучите 5 трюков",
            requirement: .learnTricks(5),
            reward: 300,
            icon: "🎭"
        ),
        Achievement(
            title: "Циркач",
            description: "Выучите 15 трюков",
            requirement: .learnTricks(15),
            reward: 750,
            icon: "🎪"
        ),

        // Монеты
        Achievement(
            title: "Накопитель",
            description: "Соберите 1000 монет",
            requirement: .collectCoins(1000),
            reward: 100,
            icon: "💰"
        ),
        Achievement(
            title: "Миллионер",
            description: "Соберите 10000 монет",
            requirement: .collectCoins(10000),
            reward: 1000,
            icon: "💎"
        ),

        // Время
        Achievement(
            title: "Неделя вместе",
            description: "Проведите 7 дней с питомцем",
            requirement: .daysAlive(7),
            reward: 200,
            icon: "📅"
        ),
        Achievement(
            title: "Месяц вместе",
            description: "Проведите 30 дней с питомцем",
            requirement: .daysAlive(30),
            reward: 500,
            icon: "🗓️"
        ),
        Achievement(
            title: "Год вместе",
            description: "Проведите 365 дней с питомцем",
            requirement: .daysAlive(365),
            reward: 2000,
            icon: "🎂"
        ),

        // Коллекционирование
        Achievement(
            title: "Коллекционер",
            description: "Соберите 20 предметов",
            requirement: .ownItems(20),
            reward: 300,
            icon: "📦"
        ),
        Achievement(
            title: "Собиратель",
            description: "Соберите 50 предметов",
            requirement: .ownItems(50),
            reward: 700,
            icon: "🎁"
        ),

        // Статы
        Achievement(
            title: "Атлет",
            description: "Достигните 100 силы",
            requirement: .maxStat("strength", value: 100),
            reward: 250,
            icon: "💪"
        ),
        Achievement(
            title: "Гений",
            description: "Достигните 100 интеллекта",
            requirement: .maxStat("intelligence", value: 100),
            reward: 250,
            icon: "🧠"
        ),
        Achievement(
            title: "Акробат",
            description: "Достигните 100 ловкости",
            requirement: .maxStat("agility", value: 100),
            reward: 250,
            icon: "🤸"
        )
    ]
}
