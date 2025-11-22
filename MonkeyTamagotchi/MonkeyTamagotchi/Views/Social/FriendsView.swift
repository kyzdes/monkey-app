import SwiftUI

struct FriendsListView: View {
    @StateObject private var friendManager = FriendManager.shared
    @State private var showAddFriend = false
    @State private var showGifts = false
    @State private var selectedFriend: Friend?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Статистика
                statsCard

                // Кнопки действий
                HStack(spacing: 15) {
                    ActionButton(
                        icon: "person.badge.plus",
                        title: "Добавить",
                        color: .blue
                    ) {
                        showAddFriend = true
                    }

                    ActionButton(
                        icon: "gift.fill",
                        title: "Подарки (\(friendManager.unopenedGifts))",
                        color: .purple
                    ) {
                        showGifts = true
                    }
                }
                .padding(.horizontal)

                // Список друзей
                if friendManager.friends.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 15) {
                        ForEach(friendManager.friends) { friend in
                            FriendCard(friend: friend) {
                                selectedFriend = friend
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Активности друзей
                if !friendManager.activities.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Активность друзей")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(friendManager.activities.prefix(5)) { activity in
                            ActivityRow(activity: activity)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showAddFriend) {
            AddFriendView()
        }
        .sheet(isPresented: $showGifts) {
            GiftsView()
        }
        .sheet(item: $selectedFriend) { friend in
            FriendDetailView(friend: friend)
        }
    }

    private var statsCard: some View {
        HStack(spacing: 30) {
            StatBadge(icon: "person.2.fill", value: "\(friendManager.totalFriends)", label: "Друзей")
            StatBadge(icon: "bell.fill", value: "\(friendManager.pendingRequests)", label: "Запросов")
            StatBadge(icon: "gift.fill", value: "\(friendManager.unopenedGifts)", label: "Подарков")
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("У вас пока нет друзей")
                .font(.headline)

            Text("Добавьте друзей, чтобы обмениваться подарками и делиться достижениями!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Добавить друга") {
                showAddFriend = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(12)
        }
    }
}

struct FriendCard: View {
    let friend: Friend
    let action: () -> Void
    @StateObject private var friendManager = FriendManager.shared

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Аватар обезьяны
                ZStack {
                    Circle()
                        .fill(friend.monkeyType.primaryColor.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Text(monkeyEmoji(for: friend.monkeyType))
                        .font(.system(size: 35))

                    if friend.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 20, y: 20)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.username)
                        .font(.headline)

                    Text(friend.monkeyName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Ур. \(friend.level)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)

                        Text(friend.statusText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    Button(action: {
                        friendManager.likeFriend(friend)
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }

                    Button(action: {
                        friendManager.visitFriend(friend)
                    }) {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.blue)
                    }
                }
                .font(.title3)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }

    private func monkeyEmoji(for type: MonkeyType) -> String {
        switch type {
        case .gorilla: return "🦍"
        case .orangutan: return "🦧"
        case .baboon: return "🐵"
        case .gibbon: return "🐒"
        }
    }
}

struct ActivityRow: View {
    let activity: FriendActivity

    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)

            Text(activity.friendUsername)
                .fontWeight(.semibold)

            Text(activity.activityType.description)
                .foregroundColor(.secondary)

            Spacer()

            Text(activity.timestamp.timeAgo())
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// MARK: - Add Friend View

struct AddFriendView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var friendManager = FriendManager.shared
    @State private var searchText = ""
    @State private var searchResults: [Friend] = []

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: performSearch)
                    .padding()

                if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)

                        Text("Пользователи не найдены")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(searchResults) { user in
                                SearchResultCard(user: user) {
                                    friendManager.sendFriendRequest(username: user.username)
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .navigationTitle("Добавить друга")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func performSearch() {
        searchResults = friendManager.searchUsers(query: searchText)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Имя пользователя или питомца", text: $text, onCommit: onSearch)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct SearchResultCard: View {
    let user: Friend
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Text(monkeyEmoji(for: user.monkeyType))
                .font(.system(size: 40))

            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.headline)

                Text(user.monkeyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Уровень \(user.level)")
                    .font(.caption)
            }

            Spacer()

            Button(action: onAdd) {
                Text("Добавить")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func monkeyEmoji(for type: MonkeyType) -> String {
        switch type {
        case .gorilla: return "🦍"
        case .orangutan: return "🦧"
        case .baboon: return "🐵"
        case .gibbon: return "🐒"
        }
    }
}

// MARK: - Friend Detail View

struct FriendDetailView: View {
    let friend: Friend
    @Environment(\.dismiss) var dismiss
    @StateObject private var friendManager = FriendManager.shared
    @State private var showSendGift = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Аватар
                    ZStack {
                        Circle()
                            .fill(friend.monkeyType.primaryColor.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Text(monkeyEmoji(for: friend.monkeyType))
                            .font(.system(size: 80))
                    }

                    Text(friend.username)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(friend.monkeyName)
                        .font(.title3)
                        .foregroundColor(.secondary)

                    // Статистика
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(friend.level)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Уровень")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text("\(friend.friendshipLevel)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Дружба")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack {
                            Text(friend.monkeyType.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Тип")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)

                    // Действия
                    VStack(spacing: 12) {
                        Button(action: {
                            showSendGift = true
                        }) {
                            HStack {
                                Image(systemName: "gift.fill")
                                Text("Отправить подарок")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            friendManager.visitFriend(friend)
                        }) {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("Посетить")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            friendManager.removeFriend(friend)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "person.fill.xmark")
                                Text("Удалить из друзей")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Профиль друга")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSendGift) {
                SendGiftView(friend: friend)
            }
        }
    }

    private func monkeyEmoji(for type: MonkeyType) -> String {
        switch type {
        case .gorilla: return "🦍"
        case .orangutan: return "🦧"
        case .baboon: return "🐵"
        case .gibbon: return "🐒"
        }
    }
}

// MARK: - Send Gift View

struct SendGiftView: View {
    let friend: Friend
    @Environment(\.dismiss) var dismiss
    @StateObject private var friendManager = FriendManager.shared
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedItem: Item?
    @State private var message = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Выберите подарок для \(friend.username)")
                    .font(.headline)
                    .padding()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                        ForEach(Item.commonItems) { item in
                            GiftItemCard(item: item, isSelected: selectedItem?.id == item.id) {
                                selectedItem = item
                            }
                        }
                    }
                    .padding()
                }

                VStack(spacing: 12) {
                    TextField("Сообщение (опционально)", text: $message)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button(action: sendGift) {
                        Text("Отправить подарок")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedItem != nil ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(selectedItem == nil)
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Отправить подарок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func sendGift() {
        guard let item = selectedItem else { return }
        friendManager.sendGift(to: friend, item: item, message: message)
        dismiss()
    }
}

struct GiftItemCard: View {
    let item: Item
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(item.iconName)
                    .font(.system(size: 40))

                Text(item.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text("🍌 \(item.cost)")
                    .font(.caption2)
            }
            .frame(width: 100, height: 100)
            .background(isSelected ? Color.purple.opacity(0.2) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
            .shadow(radius: 2)
        }
    }
}

// MARK: - Gifts View

struct GiftsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var friendManager = FriendManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                if friendManager.gifts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "gift")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("У вас нет подарков")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(spacing: 15) {
                        ForEach(friendManager.gifts) { gift in
                            GiftCard(gift: gift)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Подарки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct GiftCard: View {
    let gift: Gift
    @StateObject private var friendManager = FriendManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(gift.fromUsername)
                    .font(.headline)

                Spacer()

                Text(gift.timestamp.timeAgo())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text(gift.item.iconName)
                    .font(.system(size: 40))

                VStack(alignment: .leading) {
                    Text(gift.item.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if !gift.message.isEmpty {
                        Text("\"\(gift.message)\"")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                Spacer()

                if !gift.isOpened {
                    Button(action: {
                        friendManager.openGift(gift)
                    }) {
                        Text("Открыть")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(gift.isOpened ? Color.gray.opacity(0.1) : Color.purple.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
