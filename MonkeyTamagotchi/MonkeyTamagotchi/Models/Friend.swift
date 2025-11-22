import Foundation

struct Friend: Codable, Identifiable, Hashable {
    let id: UUID
    var username: String
    var monkeyType: MonkeyType
    var monkeyName: String
    var level: Int
    var lastActive: Date
    var friendshipLevel: Int
    var equippedItems: [ItemSlot: Item]

    init(username: String, monkeyType: MonkeyType, monkeyName: String, level: Int) {
        self.id = UUID()
        self.username = username
        self.monkeyType = monkeyType
        self.monkeyName = monkeyName
        self.level = level
        self.lastActive = Date()
        self.friendshipLevel = 1
        self.equippedItems = [:]
    }

    var isOnline: Bool {
        Date().timeIntervalSince(lastActive) < 300 // 5 минут
    }

    var statusText: String {
        if isOnline {
            return "В сети"
        } else {
            return "Был(а) \(lastActive.timeAgo())"
        }
    }
}

struct FriendRequest: Codable, Identifiable {
    let id: UUID
    let fromUserId: UUID
    let fromUsername: String
    let monkeyType: MonkeyType
    let monkeyName: String
    let level: Int
    let timestamp: Date
    var status: RequestStatus

    init(fromUserId: UUID, fromUsername: String, monkeyType: MonkeyType, monkeyName: String, level: Int) {
        self.id = UUID()
        self.fromUserId = fromUserId
        self.fromUsername = fromUsername
        self.monkeyType = monkeyType
        self.monkeyName = monkeyName
        self.level = level
        self.timestamp = Date()
        self.status = .pending
    }

    enum RequestStatus: String, Codable {
        case pending = "Ожидает"
        case accepted = "Принят"
        case declined = "Отклонен"
    }
}

struct Gift: Codable, Identifiable {
    let id: UUID
    let fromFriendId: UUID
    let fromUsername: String
    let item: Item
    let message: String
    let timestamp: Date
    var isOpened: Bool

    init(fromFriendId: UUID, fromUsername: String, item: Item, message: String) {
        self.id = UUID()
        self.fromFriendId = fromFriendId
        self.fromUsername = fromUsername
        self.item = item
        self.message = message
        self.timestamp = Date()
        self.isOpened = false
    }
}

struct FriendActivity: Codable, Identifiable {
    let id: UUID
    let friendId: UUID
    let friendUsername: String
    let activityType: ActivityType
    let timestamp: Date

    init(friendId: UUID, friendUsername: String, activityType: ActivityType) {
        self.id = UUID()
        self.friendId = friendId
        self.friendUsername = friendUsername
        self.activityType = activityType
        self.timestamp = Date()
    }

    enum ActivityType: Codable {
        case levelUp(Int)
        case achievementUnlocked(String)
        case trickLearned(String)
        case evolutionStage(GrowthStage)

        var description: String {
            switch self {
            case .levelUp(let level):
                return "достиг(ла) \(level) уровня!"
            case .achievementUnlocked(let achievement):
                return "получил(а) достижение: \(achievement)"
            case .trickLearned(let trick):
                return "выучил(а) трюк: \(trick)"
            case .evolutionStage(let stage):
                return "вырос(ла) до стадии: \(stage.rawValue)"
            }
        }
    }
}

// Моковые данные для демонстрации
extension Friend {
    static let mockFriends: [Friend] = [
        Friend(username: "BananaLover", monkeyType: .gorilla, monkeyName: "Кинг Конг", level: 15),
        Friend(username: "JungleKing", monkeyType: .orangutan, monkeyName: "Мудрец", level: 22),
        Friend(username: "MonkeyMaster", monkeyType: .baboon, monkeyName: "Шустрик", level: 18),
        Friend(username: "TreeHugger", monkeyType: .gibbon, monkeyName: "Акробат", level: 12),
        Friend(username: "FruitFan", monkeyType: .gorilla, monkeyName: "Геркулес", level: 25)
    ]
}
