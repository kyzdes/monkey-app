import Foundation
import SwiftUI

// MARK: - Widgets

struct MonkeyWidgetData: Codable {
    let monkeyName: String
    let monkeyType: MonkeyType
    let health: Int
    let hunger: Int
    let happiness: Int
    let energy: Int
    let level: Int
    let mood: String
    let lastUpdated: Date

    var healthColor: Color {
        switch health {
        case 75...100: return .green
        case 50...74: return .yellow
        case 25...49: return .orange
        default: return .red
        }
    }

    var needsAttention: Bool {
        health < 50 || hunger < 30 || happiness < 30 || energy < 20
    }

    var statusMessage: String {
        if health < 30 { return "Нужна помощь!" }
        if hunger < 30 { return "Голоден" }
        if happiness < 30 { return "Грустит" }
        if energy < 20 { return "Устал" }
        return "Всё хорошо!"
    }
}

struct WidgetConfiguration {
    let family: WidgetFamily
    var showStats: Bool
    var showQuickActions: Bool
    var theme: WidgetTheme

    enum WidgetFamily {
        case small      // Status only
        case medium     // Status + quick actions
        case large      // Full view
        case extraLarge // iPad only

        var supportedActions: Int {
            switch self {
            case .small: return 0
            case .medium: return 2
            case .large: return 4
            case .extraLarge: return 6
            }
        }
    }

    enum WidgetTheme: String, CaseIterable {
        case light = "Светлая"
        case dark = "Темная"
        case auto = "Авто"
        case colorful = "Цветная"
    }
}

struct QuickAction: Identifiable {
    let id = UUID()
    let type: ActionType
    let icon: String
    let color: Color

    enum ActionType: String {
        case feed = "Покормить"
        case play = "Играть"
        case clean = "Помыть"
        case sleep = "Спать"
        case heal = "Лечить"
        case visit = "Посетить"

        var deeplink: String {
            "monkeytama://action/\(self.rawValue)"
        }
    }

    static let allActions = [
        QuickAction(type: .feed, icon: "🍌", color: .yellow),
        QuickAction(type: .play, icon: "🎮", color: .blue),
        QuickAction(type: .clean, icon: "🚿", color: .cyan),
        QuickAction(type: .sleep, icon: "😴", color: .purple),
        QuickAction(type: .heal, icon: "❤️", color: .red),
        QuickAction(type: .visit, icon: "👋", color: .green)
    ]
}

// MARK: - Live Activities

struct MonkeyActivity: Codable {
    let id: UUID
    let activityType: ActivityType
    let startTime: Date
    let estimatedEndTime: Date
    var currentProgress: Double
    let monkeyName: String

    enum ActivityType: String, Codable {
        case training = "Тренировка"
        case sleeping = "Сон"
        case playing = "Игра"
        case exploring = "Исследование"
        case breeding = "Разведение"
        case career = "Карьера"

        var icon: String {
            switch self {
            case .training: return "figure.run"
            case .sleeping: return "moon.zzz.fill"
            case .playing: return "gamecontroller.fill"
            case .exploring: return "safari"
            case .breeding: return "heart.fill"
            case .career: return "briefcase.fill"
            }
        }

        var color: Color {
            switch self {
            case .training: return .orange
            case .sleeping: return .purple
            case .playing: return .blue
            case .exploring: return .green
            case .breeding: return .pink
            case .career: return .yellow
            }
        }
    }

    var progress: Double {
        let totalDuration = estimatedEndTime.timeIntervalSince(startTime)
        let elapsed = Date().timeIntervalSince(startTime)
        return min(elapsed / totalDuration, 1.0)
    }

    var timeRemaining: TimeInterval {
        max(estimatedEndTime.timeIntervalSinceNow, 0)
    }

    var formattedTimeRemaining: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) / 60 % 60

        if hours > 0 {
            return "\(hours)ч \(minutes)м"
        } else {
            return "\(minutes)м"
        }
    }

    var isComplete: Bool {
        Date() >= estimatedEndTime
    }
}

// MARK: - Lock Screen Widgets

struct LockScreenWidget {
    let style: LockScreenStyle
    var data: MonkeyWidgetData

    enum LockScreenStyle {
        case circular      // Small circular widget
        case rectangular   // Small rectangular
        case inline        // Text only

        var maxContent: Int {
            switch self {
            case .circular: return 1 // One stat
            case .rectangular: return 2 // Two stats
            case .inline: return 1 // Text only
            }
        }
    }

    var displayText: String {
        switch style {
        case .circular:
            return "\(data.health)%"
        case .rectangular:
            return "❤️\(data.health) 😊\(data.happiness)"
        case .inline:
            return "\(data.monkeyName): \(data.statusMessage)"
        }
    }
}

// MARK: - Apple Watch Support

struct WatchMonkeyData: Codable {
    let monkeyName: String
    let monkeyType: MonkeyType
    let health: Int
    let hunger: Int
    let happiness: Int
    let energy: Int
    let coins: Int
    let level: Int
    let lastSync: Date

    var criticalStat: String? {
        if health < 30 { return "Health" }
        if hunger < 30 { return "Hunger" }
        if energy < 20 { return "Energy" }
        if happiness < 30 { return "Happiness" }
        return nil
    }

    var needsUrgentCare: Bool {
        health < 20 || hunger < 20 || energy < 10
    }
}

struct WatchQuickAction: Identifiable {
    let id = UUID()
    let type: ActionType
    let icon: String
    let hapticType: HapticType

    enum ActionType: String {
        case feed = "Покормить"
        case play = "Играть"
        case rest = "Отдых"
        case check = "Проверить"

        var energyCost: Int {
            switch self {
            case .feed: return 0
            case .play: return 10
            case .rest: return -20
            case .check: return 0
            }
        }
    }

    enum HapticType {
        case success
        case warning
        case error
        case selection
    }

    static let quickActions = [
        WatchQuickAction(type: .feed, icon: "fork.knife", hapticType: .success),
        WatchQuickAction(type: .play, icon: "gamecontroller", hapticType: .success),
        WatchQuickAction(type: .rest, icon: "moon.zzz", hapticType: .selection),
        WatchQuickAction(type: .check, icon: "checkmark.circle", hapticType: .selection)
    ]
}

struct WatchComplication: Codable {
    let family: ComplicationFamily
    var template: ComplicationTemplate
    var updateInterval: TimeInterval

    enum ComplicationFamily: String, Codable {
        case modularSmall
        case modularLarge
        case utilitarianSmall
        case utilitarianLarge
        case circularSmall
        case graphicCorner
        case graphicCircular
        case graphicRectangular
        case graphicExtraLarge

        var maxDataFields: Int {
            switch self {
            case .modularSmall, .utilitarianSmall, .circularSmall, .graphicCorner:
                return 1
            case .modularLarge, .utilitarianLarge, .graphicCircular:
                return 2
            case .graphicRectangular:
                return 3
            case .graphicExtraLarge:
                return 4
            }
        }
    }

    enum ComplicationTemplate: String, Codable {
        case healthBar = "Полоса здоровья"
        case statsGrid = "Сетка статов"
        case monkeyIcon = "Иконка обезьяны"
        case moodDisplay = "Отображение настроения"
        case quickStatus = "Быстрый статус"
    }
}

struct WatchWorkout: Codable {
    let id = UUID()
    let startDate: Date
    var endDate: Date?
    var steps: Int
    var distance: Double // meters
    var caloriesBurned: Int
    var rewardsEarned: WorkoutRewards

    struct WorkoutRewards: Codable {
        var coins: Int
        var experience: Int
        var items: [String]
    }

    var isActive: Bool {
        endDate == nil
    }

    var duration: TimeInterval {
        if let end = endDate {
            return end.timeIntervalSince(startDate)
        }
        return Date().timeIntervalSince(startDate)
    }

    mutating func calculateRewards() {
        rewardsEarned.coins = steps / 10 // 1 coin per 10 steps
        rewardsEarned.experience = Int(distance / 50) // 1 XP per 50 meters
        rewardsEarned.coins += caloriesBurned / 5 // 1 coin per 5 calories
    }

    static func fromHealthKit(steps: Int, distance: Double, calories: Int) -> WatchWorkout {
        var workout = WatchWorkout(
            startDate: Date().addingTimeInterval(-3600), // 1 hour ago
            endDate: Date(),
            steps: steps,
            distance: distance,
            caloriesBurned: calories,
            rewardsEarned: WorkoutRewards(coins: 0, experience: 0, items: [])
        )
        workout.calculateRewards()
        return workout
    }
}

// MARK: - Watch Mini-Game

struct WatchMiniGame {
    let name: String
    var difficulty: GameDifficulty
    var score: Int = 0
    var isActive: Bool = false

    enum WatchGameType {
        case tapRhythm      // Tap in rhythm
        case catchBanana    // Catch falling bananas
        case quickMatch     // Quick matching game

        var icon: String {
            switch self {
            case .tapRhythm: return "metronome"
            case .catchBanana: return "hand.raised"
            case .quickMatch: return "square.grid.2x2"
            }
        }

        var maxDuration: TimeInterval {
            switch self {
            case .tapRhythm: return 60
            case .catchBanana: return 45
            case .quickMatch: return 90
            }
        }
    }

    var rewards: GameRewards {
        let baseReward = score / 10
        return GameRewards(
            coins: Int(Double(baseReward) * difficulty.multiplier),
            experience: Int(Double(baseReward) * difficulty.multiplier * 2)
        )
    }

    struct GameRewards {
        let coins: Int
        let experience: Int
    }
}

// MARK: - Watch Notifications

struct WatchNotification: Codable {
    let id = UUID()
    let title: String
    let message: String
    let category: NotificationCategory
    let timestamp: Date
    var actions: [NotificationAction]

    enum NotificationCategory: String, Codable {
        case urgent = "Срочно"
        case reminder = "Напоминание"
        case achievement = "Достижение"
        case social = "Социальное"

        var priority: Int {
            switch self {
            case .urgent: return 3
            case .reminder: return 2
            case .achievement: return 1
            case .social: return 1
            }
        }

        var icon: String {
            switch self {
            case .urgent: return "exclamationmark.triangle.fill"
            case .reminder: return "bell.fill"
            case .achievement: return "star.fill"
            case .social: return "person.2.fill"
            }
        }
    }

    struct NotificationAction: Codable {
        let id: String
        let title: String
        let destructive: Bool

        static let quickFeed = NotificationAction(id: "feed", title: "Покормить", destructive: false)
        static let dismiss = NotificationAction(id: "dismiss", title: "Закрыть", destructive: false)
        static let viewApp = NotificationAction(id: "view", title: "Открыть", destructive: false)
    }
}
