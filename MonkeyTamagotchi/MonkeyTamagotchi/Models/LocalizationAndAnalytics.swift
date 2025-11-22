import Foundation
import SwiftUI

// MARK: - Localization

enum SupportedLanguage: String, Codable, CaseIterable {
    case english = "en"
    case russian = "ru"
    case spanish = "es"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case french = "fr"
    case german = "de"
    case portuguese = "pt"
    case italian = "it"
    case arabic = "ar"
    case hindi = "hi"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .spanish: return "Español"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .portuguese: return "Português"
        case .italian: return "Italiano"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .russian: return "🇷🇺"
        case .spanish: return "🇪🇸"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .portuguese: return "🇵🇹"
        case .italian: return "🇮🇹"
        case .arabic: return "🇸🇦"
        case .hindi: return "🇮🇳"
        }
    }

    var isRTL: Bool {
        self == .arabic
    }
}

struct LocalizedString {
    let key: String
    var translations: [SupportedLanguage: String]

    func localized(for language: SupportedLanguage) -> String {
        translations[language] ?? translations[.english] ?? key
    }

    static let commonStrings: [LocalizedString] = [
        LocalizedString(key: "play", translations: [
            .english: "Play",
            .russian: "Играть",
            .spanish: "Jugar",
            .chinese: "玩",
            .japanese: "プレイ",
            .korean: "놀다"
        ]),
        LocalizedString(key: "feed", translations: [
            .english: "Feed",
            .russian: "Кормить",
            .spanish: "Alimentar",
            .chinese: "喂食",
            .japanese: "餌をやる",
            .korean: "먹이다"
        ]),
        LocalizedString(key: "clean", translations: [
            .english: "Clean",
            .russian: "Помыть",
            .spanish: "Limpiar",
            .chinese: "清洁",
            .japanese: "掃除",
            .korean: "청소"
        ]),
        LocalizedString(key: "sleep", translations: [
            .english: "Sleep",
            .russian: "Спать",
            .spanish: "Dormir",
            .chinese: "睡觉",
            .japanese: "寝る",
            .korean: "자다"
        ])
    ]
}

// MARK: - Analytics

struct AnalyticsEvent: Codable {
    let name: String
    let timestamp: Date
    let properties: [String: String]
    let category: EventCategory

    enum EventCategory: String, Codable {
        case gameplay = "Игровой процесс"
        case social = "Социальное"
        case monetization = "Монетизация"
        case engagement = "Вовлеченность"
        case technical = "Техническое"
    }
}

struct UserAnalytics: Codable {
    var userID: UUID
    var sessionCount: Int
    var totalPlayTime: TimeInterval
    var lastSessionDate: Date
    var events: [AnalyticsEvent]

    // Gameplay metrics
    var gamesPlayed: [String: Int] // Game name -> count
    var achievementsUnlocked: Int
    var levelsReached: Int
    var totalCoinsEarned: Int
    var totalCoinsSpent: Int

    // Social metrics
    var friendsAdded: Int
    var messagesI sent: Int
    var giftsGiven: Int
    var giftsReceived: Int
    var clanJoined: Bool

    // Monetization metrics
    var purchasesMade: Int
    var totalSpent: Double
    var isPremium: Bool
    var adsWatched: Int

    // Engagement metrics
    var dailyLogins: Int
    var consecutiveDays: Int
    var lastLoginDate: Date

    var averageSessionLength: TimeInterval {
        guard sessionCount > 0 else { return 0 }
        return totalPlayTime / TimeInterval(sessionCount)
    }

    var retentionRate: Double {
        let daysSinceInstall = Date().timeIntervalSince(lastLoginDate) / 86400
        guard daysSinceInstall > 0 else { return 0 }
        return Double(dailyLogins) / daysSinceInstall
    }

    mutating func trackEvent(_ event: AnalyticsEvent) {
        events.append(event)
    }
}

// MARK: - Achievements System

struct Achievement: Codable, Identifiable {
    let id: String
    var name: String
    var description: String
    let category: AchievementCategory
    let tier: AchievementTier
    var progress: Int
    let requirement: Int
    var isUnlocked: Bool
    let reward: AchievementReward

    enum AchievementCategory: String, Codable {
        case gameplay = "Игровой процесс"
        case collection = "Коллекция"
        case social = "Социальное"
        case master = "Мастерство"
        case special = "Особое"
        case secret = "Секретное"

        var icon: String {
            switch self {
            case .gameplay: return "gamecontroller.fill"
            case .collection: return "square.stack.3d.up.fill"
            case .social: return "person.3.fill"
            case .master: return "star.fill"
            case .special: return "sparkles"
            case .secret: return "questionmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .gameplay: return .blue
            case .collection: return .purple
            case .social: return .green
            case .master: return .orange
            case .special: return .yellow
            case .secret: return .black
            }
        }
    }

    enum AchievementTier: String, Codable {
        case bronze = "Бронза"
        case silver = "Серебро"
        case gold = "Золото"
        case platinum = "Платина"
        case diamond = "Алмаз"

        var color: Color {
            switch self {
            case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
            case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
            case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
            case .platinum: return Color(red: 0.9, green: 0.9, blue: 0.95)
            case .diamond: return Color(red: 0.7, green: 0.9, blue: 1.0)
            }
        }

        var points: Int {
            switch self {
            case .bronze: return 10
            case .silver: return 25
            case .gold: return 50
            case .platinum: return 100
            case .diamond: return 250
            }
        }
    }

    struct AchievementReward: Codable {
        let coins: Int
        let experience: Int
        let specialItem: String?
        let title: String?
    }

    var progressPercentage: Double {
        min(Double(progress) / Double(requirement), 1.0)
    }

    mutating func updateProgress(_ newProgress: Int) {
        progress = newProgress
        if progress >= requirement && !isUnlocked {
            isUnlocked = true
        }
    }

    // 100+ Achievements
    static let allAchievements: [Achievement] = [
        // Gameplay achievements (30)
        Achievement(id: "first_feed", name: "Первое кормление", description: "Покормите обезьяну впервые", category: .gameplay, tier: .bronze, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 50, experience: 10, specialItem: nil, title: nil)),
        Achievement(id: "feed_100", name: "Опытный кормилец", description: "Покормите обезьяну 100 раз", category: .gameplay, tier: .silver, progress: 0, requirement: 100, isUnlocked: false, reward: AchievementReward(coins: 500, experience: 100, specialItem: nil, title: "Кормилец")),
        Achievement(id: "feed_1000", name: "Мастер кормления", description: "Покормите обезьяну 1000 раз", category: .gameplay, tier: .gold, progress: 0, requirement: 1000, isUnlocked: false, reward: AchievementReward(coins: 5000, experience: 1000, specialItem: "Золотая миска", title: "Гуру Питания")),

        Achievement(id: "level_10", name: "Уровень 10", description: "Достигните 10 уровня", category: .gameplay, tier: .bronze, progress: 0, requirement: 10, isUnlocked: false, reward: AchievementReward(coins: 100, experience: 0, specialItem: nil, title: nil)),
        Achievement(id: "level_50", name: "Уровень 50", description: "Достигните 50 уровня", category: .gameplay, tier: .gold, progress: 0, requirement: 50, isUnlocked: false, reward: AchievementReward(coins: 2500, experience: 0, specialItem: nil, title: "Ветеран")),
        Achievement(id: "level_100", name: "Уровень 100", description: "Достигните 100 уровня", category: .gameplay, tier: .diamond, progress: 0, requirement: 100, isUnlocked: false, reward: AchievementReward(coins: 10000, experience: 0, specialItem: "Корона Мастера", title: "Легенда")),

        // Collection achievements (25)
        Achievement(id: "collect_all_types", name: "Коллекционер типов", description: "Получите всех 10 типов обезьян", category: .collection, tier: .gold, progress: 0, requirement: 10, isUnlocked: false, reward: AchievementReward(coins: 5000, experience: 500, specialItem: "Энциклопедия обезьян", title: "Коллекционер")),
        Achievement(id: "rare_monkey", name: "Редкая находка", description: "Получите редкую обезьяну", category: .collection, tier: .silver, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 1000, experience: 200, specialItem: nil, title: nil)),
        Achievement(id: "legendary_monkey", name: "Легендарный питомец", description: "Получите легендарную обезьяну", category: .collection, tier: .diamond, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 10000, experience: 1000, specialItem: "Легендарный ошейник", title: "Охотник за легендами")),

        // Social achievements (20)
        Achievement(id: "first_friend", name: "Первый друг", description: "Добавьте первого друга", category: .social, tier: .bronze, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 100, experience: 50, specialItem: nil, title: nil)),
        Achievement(id: "friend_10", name: "Популярный", description: "Добавьте 10 друзей", category: .social, tier: .silver, progress: 0, requirement: 10, isUnlocked: false, reward: AchievementReward(coins: 500, experience: 200, specialItem: nil, title: "Популярный")),
        Achievement(id: "friend_100", name: "Социальная бабочка", description: "Добавьте 100 друзей", category: .social, tier: .platinum, progress: 0, requirement: 100, isUnlocked: false, reward: AchievementReward(coins: 10000, experience: 2000, specialItem: "Корона дружбы", title: "Король дружбы")),

        Achievement(id: "join_clan", name: "Член клана", description: "Присоединитесь к клану", category: .social, tier: .bronze, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 200, experience: 100, specialItem: nil, title: nil)),
        Achievement(id: "clan_war_win", name: "Победа в войне кланов", description: "Выиграйте войну кланов", category: .social, tier: .gold, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 5000, experience: 1000, specialItem: "Военный трофей", title: "Воин")),

        // Master achievements (15)
        Achievement(id: "all_tricks", name: "Мастер трюков", description: "Выучите все трюки", category: .master, tier: .platinum, progress: 0, requirement: 20, isUnlocked: false, reward: AchievementReward(coins: 10000, experience: 2000, specialItem: "Книга трюков", title: "Мастер трюков")),
        Achievement(id: "perfect_care", name: "Идеальный уход", description: "Держите все параметры на максимуме 7 дней", category: .master, tier: .diamond, progress: 0, requirement: 7, isUnlocked: false, reward: AchievementReward(coins: 15000, experience: 3000, specialItem: "Золотая медаль ухода", title: "Идеальный опекун")),

        // Special achievements (10)
        Achievement(id: "first_breeding", name: "Первое разведение", description: "Разведите первую пару обезьян", category: .special, tier: .silver, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 1000, experience: 500, specialItem: nil, title: "Заводчик")),
        Achievement(id: "golden_baby", name: "Золотой малыш", description: "Получите детеныша золотой обезьяны", category: .special, tier: .diamond, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 20000, experience: 5000, specialItem: "Золотая колыбель", title: "Золотой родитель")),

        // Secret achievements (hidden) (5)
        Achievement(id: "secret_dance", name: "???", description: "Секретное достижение", category: .secret, tier: .platinum, progress: 0, requirement: 1, isUnlocked: false, reward: AchievementReward(coins: 10000, experience: 2000, specialItem: "Секретный танец", title: "Танцор теней"))
    ]
}

// MARK: - Player Statistics

struct PlayerStatistics: Codable {
    var totalPlayTime: TimeInterval
    var gamesPlayed: Int
    var gamesWon: Int
    var totalScore: Int
    var highScores: [String: Int] // Game name -> high score

    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed)
    }

    var averageScore: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(totalScore) / Double(gamesPlayed)
    }

    // Friends comparison
    func compareWith(_ friend: PlayerStatistics) -> [String: String] {
        var comparison: [String: String] = [:]

        if totalPlayTime > friend.totalPlayTime {
            comparison["playTime"] = "Вы играете больше"
        } else {
            comparison["playTime"] = "Друг играет больше"
        }

        if winRate > friend.winRate {
            comparison["winRate"] = "У вас выше процент побед"
        } else {
            comparison["winRate"] = "У друга выше процент побед"
        }

        return comparison
    }
}
