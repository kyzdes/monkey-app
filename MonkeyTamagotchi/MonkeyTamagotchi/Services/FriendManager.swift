import Foundation
import Combine

class FriendManager: ObservableObject {
    static let shared = FriendManager()

    @Published var friends: [Friend] = []
    @Published var friendRequests: [FriendRequest] = []
    @Published var gifts: [Gift] = []
    @Published var activities: [FriendActivity] = []

    private init() {
        loadData()
        // В демо режиме добавляем моковых друзей
        if friends.isEmpty {
            friends = Friend.mockFriends
        }
    }

    // MARK: - Friend Management

    func sendFriendRequest(username: String) -> Bool {
        guard let currentMonkey = GameManager.shared.currentMonkey else { return false }

        // В реальном приложении здесь был бы API запрос
        // Сейчас создаем локальный запрос
        let request = FriendRequest(
            fromUserId: UUID(),
            fromUsername: username,
            monkeyType: currentMonkey.type,
            monkeyName: currentMonkey.name,
            level: currentMonkey.level
        )

        // Симулируем отправку
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // В демо режиме автоматически принимаем запрос
            self.acceptFriendRequest(request)
        }

        saveData()
        return true
    }

    func acceptFriendRequest(_ request: FriendRequest) {
        guard var updatedRequest = friendRequests.first(where: { $0.id == request.id }) else {
            // Если запроса нет, создаем нового друга
            let newFriend = Friend(
                username: request.fromUsername,
                monkeyType: request.monkeyType,
                monkeyName: request.monkeyName,
                level: request.level
            )
            friends.append(newFriend)
            saveData()
            HapticManager.shared.notification(type: .success)
            return
        }

        updatedRequest.status = .accepted

        let newFriend = Friend(
            username: request.fromUsername,
            monkeyType: request.monkeyType,
            monkeyName: request.monkeyName,
            level: request.level
        )

        friends.append(newFriend)
        friendRequests.removeAll { $0.id == request.id }

        saveData()
        HapticManager.shared.notification(type: .success)
    }

    func declineFriendRequest(_ request: FriendRequest) {
        friendRequests.removeAll { $0.id == request.id }
        saveData()
    }

    func removeFriend(_ friend: Friend) {
        friends.removeAll { $0.id == friend.id }
        saveData()
    }

    // MARK: - Gift Management

    func sendGift(to friend: Friend, item: Item, message: String) {
        guard let currentMonkey = GameManager.shared.currentMonkey else { return }
        guard currentMonkey.coins >= item.cost else { return }

        // Вычитаем стоимость
        currentMonkey.coins -= item.cost

        // В реальном приложении отправляем через сервер
        // Здесь симулируем получение подарка
        let gift = Gift(
            fromFriendId: friend.id,
            fromUsername: friend.username,
            item: item,
            message: message
        )

        // Симулируем получение подарка (в реальности другой пользователь получит)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Для демо добавляем в свой список
            self.receiveGift(gift)
        }

        GameManager.shared.saveGame()
        saveData()
        HapticManager.shared.notification(type: .success)
    }

    func receiveGift(_ gift: Gift) {
        gifts.append(gift)
        saveData()
    }

    func openGift(_ gift: Gift) {
        guard let index = gifts.firstIndex(where: { $0.id == gift.id }) else { return }
        guard !gifts[index].isOpened else { return }

        gifts[index].isOpened = true

        // Добавляем предмет в инвентарь
        if let monkey = GameManager.shared.currentMonkey {
            monkey.inventory.append(gift.item)
            GameManager.shared.saveGame()
        }

        saveData()
        HapticManager.shared.notification(type: .success)
    }

    func deleteGift(_ gift: Gift) {
        gifts.removeAll { $0.id == gift.id }
        saveData()
    }

    // MARK: - Activities

    func addActivity(_ activity: FriendActivity) {
        activities.insert(activity, at: 0)

        // Храним только последние 50 активностей
        if activities.count > 50 {
            activities = Array(activities.prefix(50))
        }

        saveData()
    }

    func visitFriend(_ friend: Friend) {
        // Увеличиваем уровень дружбы
        if let index = friends.firstIndex(where: { $0.id == friend.id }) {
            friends[index].friendshipLevel += 1

            // Награда за посещение друга
            if let monkey = GameManager.shared.currentMonkey {
                monkey.coins += 5
                monkey.stats.happiness = min(monkey.stats.happiness + 5, 100)
                GameManager.shared.saveGame()
            }

            saveData()
        }
    }

    func likeFriend(_ friend: Friend) {
        // Лайк друга дает небольшую награду
        if let monkey = GameManager.shared.currentMonkey {
            monkey.coins += 2
            GameManager.shared.saveGame()
        }

        HapticManager.shared.impact(style: .light)
    }

    // MARK: - Search

    func searchUsers(query: String) -> [Friend] {
        // В реальном приложении это был бы API запрос
        // Для демо возвращаем моковых пользователей
        return Friend.mockFriends.filter { friend in
            friend.username.lowercased().contains(query.lowercased()) ||
            friend.monkeyName.lowercased().contains(query.lowercased())
        }
    }

    // MARK: - Statistics

    var totalFriends: Int {
        friends.count
    }

    var pendingRequests: Int {
        friendRequests.filter { $0.status == .pending }.count
    }

    var unopenedGifts: Int {
        gifts.filter { !$0.isOpened }.count
    }

    // MARK: - Persistence

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: "Friends")
        }

        if let encoded = try? JSONEncoder().encode(friendRequests) {
            UserDefaults.standard.set(encoded, forKey: "FriendRequests")
        }

        if let encoded = try? JSONEncoder().encode(gifts) {
            UserDefaults.standard.set(encoded, forKey: "Gifts")
        }

        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: "FriendActivities")
        }
    }

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Friends"),
           let decoded = try? JSONDecoder().decode([Friend].self, from: data) {
            friends = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "FriendRequests"),
           let decoded = try? JSONDecoder().decode([FriendRequest].self, from: data) {
            friendRequests = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "Gifts"),
           let decoded = try? JSONDecoder().decode([Gift].self, from: data) {
            gifts = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "FriendActivities"),
           let decoded = try? JSONDecoder().decode([FriendActivity].self, from: data) {
            activities = decoded
        }
    }
}
