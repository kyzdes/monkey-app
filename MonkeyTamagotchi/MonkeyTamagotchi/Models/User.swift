import Foundation
import SwiftUI

// MARK: - User Profile

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var username: String
    var email: String
    var avatarURL: String?
    var createdAt: Date
    var lastActive: Date
    var level: Int
    var totalExperience: Int
    var reputation: Int

    // Social
    var friendsCount: Int
    var clanID: UUID?
    var clanName: String?

    // Stats
    var totalPlayTime: TimeInterval
    var monkeysOwned: Int
    var achievementsUnlocked: Int

    // Premium
    var isPremium: Bool
    var premiumExpiryDate: Date?
    var hasActivePass: Bool

    // Preferences
    var preferredLanguage: String
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var musicEnabled: Bool

    init(id: UUID = UUID(), username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
        self.createdAt = Date()
        self.lastActive = Date()
        self.level = 1
        self.totalExperience = 0
        self.reputation = 0
        self.friendsCount = 0
        self.totalPlayTime = 0
        self.monkeysOwned = 0
        self.achievementsUnlocked = 0
        self.isPremium = false
        self.hasActivePass = false
        self.preferredLanguage = "ru"
        self.notificationsEnabled = true
        self.soundEnabled = true
        self.musicEnabled = true
    }

    var isOnline: Bool {
        Date().timeIntervalSince(lastActive) < 300 // 5 minutes
    }

    var reputationTier: ReputationTier {
        switch reputation {
        case 0..<100: return .beginner
        case 100..<500: return .experienced
        case 500..<1500: return .expert
        case 1500..<5000: return .master
        default: return .legend
        }
    }
}

enum ReputationTier: String, Codable {
    case beginner = "Новичок"
    case experienced = "Опытный"
    case expert = "Эксперт"
    case master = "Мастер"
    case legend = "Легенда"

    var icon: String {
        switch self {
        case .beginner: return "star"
        case .experienced: return "star.fill"
        case .expert: return "star.leadinghalf.filled"
        case .master: return "crown"
        case .legend: return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .beginner: return .gray
        case .experienced: return .blue
        case .expert: return .purple
        case .master: return .orange
        case .legend: return .yellow
        }
    }
}

// MARK: - Cloud Save

struct CloudSave: Codable {
    let id: UUID
    let userID: UUID
    var monkeys: [MonkeyData]
    var inventory: [ItemData]
    var achievements: [String]
    var settings: GameSettingsData
    var lastSync: Date
    var version: String

    struct MonkeyData: Codable {
        let id: UUID
        let type: String
        let name: String
        let stats: [String: Int]
        let items: [String]
        let age: Int
        let level: Int
    }

    struct ItemData: Codable {
        let id: String
        let type: String
        let quantity: Int
    }

    struct GameSettingsData: Codable {
        var difficulty: String
        var theme: String
        var language: String
    }
}

// MARK: - Subscription

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "Free"
    case banaPlus = "Banana Plus"

    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .banaPlus: return 4.99
        }
    }

    var benefits: [String] {
        switch self {
        case .free:
            return ["Базовые функции", "Реклама"]
        case .banaPlus:
            return [
                "Без рекламы",
                "x2 бананы",
                "Эксклюзивные предметы",
                "Облачные сохранения",
                "Ранний доступ к фичам",
                "Premium бейдж"
            ]
        }
    }
}

// MARK: - Battle Pass

struct BattlePass: Codable, Identifiable {
    let id: UUID
    var season: Int
    var seasonName: String
    var startDate: Date
    var endDate: Date
    var currentLevel: Int
    var isPremium: Bool

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
    }

    var isActive: Bool {
        Date() >= startDate && Date() <= endDate
    }

    func reward(for level: Int) -> BattlePassReward {
        BattlePassReward.rewards[level] ?? BattlePassReward(
            level: level,
            freeReward: "100 бананов",
            premiumReward: nil
        )
    }
}

struct BattlePassReward: Codable {
    let level: Int
    let freeReward: String
    let premiumReward: String?

    static let rewards: [Int: BattlePassReward] = [
        1: BattlePassReward(level: 1, freeReward: "100 🍌", premiumReward: "Эксклюзивная шляпа"),
        5: BattlePassReward(level: 5, freeReward: "250 🍌", premiumReward: "Редкий костюм"),
        10: BattlePassReward(level: 10, freeReward: "500 🍌", premiumReward: "Легендарный питомец"),
        25: BattlePassReward(level: 25, freeReward: "1000 🍌", premiumReward: "Уникальная эволюция"),
        50: BattlePassReward(level: 50, freeReward: "2500 🍌", premiumReward: "Эксклюзивная обезьяна"),
        100: BattlePassReward(level: 100, freeReward: "10000 🍌", premiumReward: "Золотая обезьяна")
    ]
}
