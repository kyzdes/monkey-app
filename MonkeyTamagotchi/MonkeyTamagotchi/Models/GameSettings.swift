import Foundation

struct GameSettings: Codable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var notificationsEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var isDarkMode: Bool
    var language: String
    var autoSave: Bool

    static let `default` = GameSettings(
        soundEnabled: true,
        musicEnabled: true,
        notificationsEnabled: true,
        hapticFeedbackEnabled: true,
        isDarkMode: false,
        language: "ru",
        autoSave: true
    )
}

struct DailyTask: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let reward: Int
    let type: TaskType
    var isCompleted: Bool
    var progress: Int
    let targetProgress: Int

    init(title: String, description: String, reward: Int, type: TaskType, targetProgress: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.reward = reward
        self.type = type
        self.isCompleted = false
        self.progress = 0
        self.targetProgress = targetProgress
    }

    enum TaskType: String, Codable {
        case feed = "Покормить"
        case play = "Поиграть"
        case clean = "Помыть"
        case trick = "Выполнить трюк"
        case minigame = "Сыграть в мини-игру"
        case level = "Повысить уровень"
    }

    var progressPercent: Double {
        min(Double(progress) / Double(targetProgress), 1.0)
    }
}

extension DailyTask {
    static func generateDailyTasks() -> [DailyTask] {
        [
            DailyTask(
                title: "Покормить питомца",
                description: "Покормите вашего питомца 3 раза",
                reward: 50,
                type: .feed,
                targetProgress: 3
            ),
            DailyTask(
                title: "Время играть",
                description: "Поиграйте с питомцем 5 раз",
                reward: 75,
                type: .play,
                targetProgress: 5
            ),
            DailyTask(
                title: "Чистота - залог здоровья",
                description: "Помойте питомца 1 раз",
                reward: 30,
                type: .clean,
                targetProgress: 1
            ),
            DailyTask(
                title: "Талантливый артист",
                description: "Выполните 3 трюка",
                reward: 100,
                type: .trick,
                targetProgress: 3
            ),
            DailyTask(
                title: "Мастер игр",
                description: "Пройдите любую мини-игру",
                reward: 150,
                type: .minigame,
                targetProgress: 1
            )
        ]
    }
}
