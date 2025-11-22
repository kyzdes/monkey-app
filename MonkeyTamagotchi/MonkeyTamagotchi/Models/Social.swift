import Foundation
import SwiftUI

// MARK: - Clan System

struct Clan: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var leaderID: UUID
    var members: [ClanMember]
    var level: Int
    var experience: Int
    var totalTrophies: Int
    var createdAt: Date
    var badge: ClanBadge
    var joinRequirement: JoinRequirement

    var memberCount: Int {
        members.count
    }

    var maxMembers: Int {
        30 + (level * 5) // Base 30, +5 per level
    }

    var experienceToNextLevel: Int {
        level * 10000
    }

    var currentProgress: Double {
        Double(experience) / Double(experienceToNextLevel)
    }

    enum JoinRequirement: String, Codable {
        case open = "Открытый"
        case requestOnly = "По заявке"
        case inviteOnly = "По приглашению"
    }

    struct ClanBadge: Codable {
        var icon: String
        var primaryColor: String
        var secondaryColor: String
    }

    mutating func addMember(_ userID: UUID, username: String) {
        let member = ClanMember(
            userID: userID,
            username: username,
            role: .member,
            joinedAt: Date(),
            contributedTrophies: 0,
            contributedExperience: 0
        )
        members.append(member)
    }

    mutating func removeMember(_ userID: UUID) {
        members.removeAll { $0.userID == userID }
    }

    mutating func promoteMember(_ userID: UUID, to role: ClanRole) {
        if let index = members.firstIndex(where: { $0.userID == userID }) {
            members[index].role = role
        }
    }
}

struct ClanMember: Codable, Identifiable {
    var id: UUID { userID }
    let userID: UUID
    var username: String
    var role: ClanRole
    let joinedAt: Date
    var contributedTrophies: Int
    var contributedExperience: Int
    var lastActive: Date?

    var isOnline: Bool {
        guard let lastActive = lastActive else { return false }
        return Date().timeIntervalSince(lastActive) < 300
    }
}

enum ClanRole: String, Codable, CaseIterable {
    case leader = "Лидер"
    case coLeader = "Со-лидер"
    case elder = "Старейшина"
    case member = "Участник"

    var permissions: [ClanPermission] {
        switch self {
        case .leader:
            return [.invite, .kick, .promote, .demote, .editInfo, .startWar]
        case .coLeader:
            return [.invite, .kick, .promote, .startWar]
        case .elder:
            return [.invite, .kick]
        case .member:
            return []
        }
    }

    var color: Color {
        switch self {
        case .leader: return .yellow
        case .coLeader: return .orange
        case .elder: return .purple
        case .member: return .gray
        }
    }

    enum ClanPermission {
        case invite, kick, promote, demote, editInfo, startWar
    }
}

// MARK: - Clan Wars

struct ClanWar: Codable, Identifiable {
    let id = UUID()
    let clan1: ClanWarInfo
    let clan2: ClanWarInfo
    let startDate: Date
    let endDate: Date
    var battles: [Battle]

    struct ClanWarInfo: Codable {
        let clanID: UUID
        let clanName: String
        var score: Int
        var participants: [UUID]
    }

    struct Battle: Codable, Identifiable {
        let id = UUID()
        let attackerID: UUID
        let defenderID: UUID
        let result: BattleResult
        let timestamp: Date

        enum BattleResult: Codable {
            case attackerWin(stars: Int)
            case defenderWin
            case draw
        }
    }

    var isActive: Bool {
        Date() >= startDate && Date() <= endDate
    }

    var winner: UUID? {
        guard !isActive else { return nil }
        if clan1.score > clan2.score {
            return clan1.clanID
        } else if clan2.score > clan1.score {
            return clan2.clanID
        }
        return nil
    }

    var timeRemaining: TimeInterval {
        max(endDate.timeIntervalSinceNow, 0)
    }
}

// MARK: - Chat System

struct ChatMessage: Codable, Identifiable {
    let id = UUID()
    let senderID: UUID
    let senderName: String
    var content: String
    let timestamp: Date
    var type: MessageType
    var reactions: [Reaction]
    var isRead: Bool

    enum MessageType: Codable {
        case text
        case sticker(String)
        case emoji(String)
        case gift(String)
        case system(String)
    }

    struct Reaction: Codable {
        let userID: UUID
        let emoji: String
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct ChatChannel: Codable, Identifiable {
    let id = UUID()
    var name: String
    var type: ChannelType
    var participants: [UUID]
    var messages: [ChatMessage]
    var lastMessageAt: Date?

    enum ChannelType: String, Codable {
        case direct = "Личный"
        case group = "Группа"
        case clan = "Клан"
        case global = "Глобальный"

        var maxParticipants: Int {
            switch self {
            case .direct: return 2
            case .group: return 50
            case .clan: return 100
            case .global: return Int.max
            }
        }
    }

    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        lastMessageAt = message.timestamp
    }

    var unreadCount: Int {
        messages.filter { !$0.isRead }.count
    }
}

struct MonkeySticker: Identifiable {
    let id: String
    let name: String
    let category: StickerCategory
    var isUnlocked: Bool

    enum StickerCategory: String, CaseIterable {
        case emotions = "Эмоции"
        case actions = "Действия"
        case reactions = "Реакции"
        case special = "Особые"

        var stickers: [String] {
            switch self {
            case .emotions: return ["😊", "😂", "😍", "😢", "😡", "😱"]
            case .actions: return ["👋", "👏", "🙌", "💪", "🤝", "👊"]
            case .reactions: return ["👍", "👎", "❤️", "🔥", "⭐", "💯"]
            case .special: return ["🎉", "🎊", "🎁", "🏆", "💎", "🌈"]
            }
        }
    }

    static func allStickers() -> [MonkeySticker] {
        var stickers: [MonkeySticker] = []
        for category in StickerCategory.allCases {
            for (index, emoji) in category.stickers.enumerated() {
                stickers.append(MonkeySticker(
                    id: "\(category.rawValue)_\(index)",
                    name: emoji,
                    category: category,
                    isUnlocked: index < 2 // First 2 unlocked by default
                ))
            }
        }
        return stickers
    }
}

// MARK: - Social Hub (Jungle Square)

struct SocialHub: Identifiable {
    let id = UUID()
    var activeUsers: [ActiveUser]
    var interactiveZones: [InteractiveZone]
    var currentEvents: [HubEvent]
    var bulletin: [BulletinPost]

    struct ActiveUser: Identifiable {
        let id: UUID
        let username: String
        let monkeyType: MonkeyType
        var position: Position
        var currentAction: HubAction

        struct Position {
            var x: Double
            var y: Double
        }

        enum HubAction: String {
            case idle = "Стоит"
            case walking = "Идёт"
            case dancing = "Танцует"
            case chatting = "Общается"
            case playing = "Играет"
        }
    }

    struct InteractiveZone: Identifiable {
        let id = UUID()
        let name: String
        let type: ZoneType
        let position: CGPoint
        var activeUsers: Int

        enum ZoneType: String {
            case fountain = "Фонтан"
            case stage = "Сцена"
            case playground = "Площадка"
            case shop = "Магазин"
            case arena = "Арена"
            case garden = "Сад"

            var icon: String {
                switch self {
                case .fountain: return "drop.fill"
                case .stage: return "music.note"
                case .playground: return "figure.play"
                case .shop: return "bag.fill"
                case .arena: return "shield.fill"
                case .garden: return "leaf.fill"
                }
            }

            var color: Color {
                switch self {
                case .fountain: return .blue
                case .stage: return .purple
                case .playground: return .green
                case .shop: return .yellow
                case .arena: return .red
                case .garden: return .mint
                }
            }
        }
    }

    struct HubEvent: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let type: EventType
        let startTime: Date
        let duration: TimeInterval
        var participants: [UUID]

        enum EventType: String {
            case concert = "Концерт"
            case tournament = "Турнир"
            case party = "Вечеринка"
            case contest = "Конкурс"
            case meeting = "Встреча"

            var icon: String {
                switch self {
                case .concert: return "music.note.list"
                case .tournament: return "trophy"
                case .party: return "party.popper"
                case .contest: return "star"
                case .meeting: return "person.3"
                }
            }
        }

        var isActive: Bool {
            let now = Date()
            let endTime = startTime.addingTimeInterval(duration)
            return now >= startTime && now <= endTime
        }

        var timeUntilStart: TimeInterval {
            max(startTime.timeIntervalSinceNow, 0)
        }
    }

    struct BulletinPost: Identifiable, Codable {
        let id = UUID()
        let authorID: UUID
        let authorName: String
        let title: String
        let content: String
        let category: PostCategory
        let postedAt: Date
        var likes: Int
        var comments: [Comment]

        enum PostCategory: String, Codable {
            case announcement = "Объявление"
            case event = "Событие"
            case discussion = "Обсуждение"
            case guide = "Гайд"
            case showcase = "Демонстрация"
        }

        struct Comment: Codable, Identifiable {
            let id = UUID()
            let authorID: UUID
            let authorName: String
            let content: String
            let timestamp: Date
        }
    }
}

// MARK: - Global Events

struct GlobalEvent: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    let type: EventType
    let startDate: Date
    let endDate: Date
    var participants: Int
    var rewards: [EventReward]
    var leaderboard: [LeaderboardEntry]

    enum EventType: String, Codable {
        case weeklyTournament = "Еженедельный турнир"
        case seasonalEvent = "Сезонное событие"
        case holiday = "Праздник"
        case challenge = "Челлендж"
        case communityGoal = "Общая цель"

        var color: Color {
            switch self {
            case .weeklyTournament: return .red
            case .seasonalEvent: return .blue
            case .holiday: return .yellow
            case .challenge: return .purple
            case .communityGoal: return .green
            }
        }

        var icon: String {
            switch self {
            case .weeklyTournament: return "trophy.fill"
            case .seasonalEvent: return "calendar"
            case .holiday: return "party.popper.fill"
            case .challenge: return "target"
            case .communityGoal: return "person.3.fill"
            }
        }
    }

    struct EventReward: Codable {
        let rank: Int
        let coins: Int
        let items: [String]
        let exclusiveTitle: String?
    }

    struct LeaderboardEntry: Codable, Identifiable {
        let id = UUID()
        let userID: UUID
        let username: String
        let score: Int
        var rank: Int
    }

    var isActive: Bool {
        Date() >= startDate && Date() <= endDate
    }

    var timeRemaining: TimeInterval {
        max(endDate.timeIntervalSinceNow, 0)
    }

    var progress: Double {
        let total = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        return min(max(elapsed / total, 0), 1)
    }
}
