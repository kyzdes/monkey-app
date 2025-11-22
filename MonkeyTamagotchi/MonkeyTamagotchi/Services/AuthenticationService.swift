import Foundation
import Combine

class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()

    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {
        loadUser()
    }

    // MARK: - Authentication

    func signUp(username: String, email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Validate
        guard !username.isEmpty, !email.isEmpty, password.count >= 6 else {
            errorMessage = "Проверьте введенные данные"
            isLoading = false
            return false
        }

        // Create user
        let user = UserProfile(username: username, email: email)
        currentUser = user
        isAuthenticated = true
        saveUser(user)

        isLoading = false
        return true
    }

    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Введите email и пароль"
            isLoading = false
            return false
        }

        // Mock successful login
        let user = UserProfile(username: "TestUser", email: email)
        currentUser = user
        isAuthenticated = true
        saveUser(user)

        isLoading = false
        return true
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    func deleteAccount() async -> Bool {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 500_000_000)

        signOut()
        return true
    }

    // MARK: - User Management

    func updateProfile(username: String? = nil, avatarURL: String? = nil) {
        guard var user = currentUser else { return }

        if let username = username {
            user.username = username
        }
        if let avatarURL = avatarURL {
            user.avatarURL = avatarURL
        }

        user.lastActive = Date()
        currentUser = user
        saveUser(user)
    }

    func addExperience(_ amount: Int) {
        guard var user = currentUser else { return }

        user.totalExperience += amount
        let newLevel = 1 + (user.totalExperience / 1000)
        if newLevel > user.level {
            user.level = newLevel
            NotificationManager.shared.scheduleNotification(
                title: "Новый уровень!",
                body: "Поздравляем! Вы достигли уровня \(newLevel)",
                timeInterval: 1,
                identifier: "level_up_\(newLevel)"
            )
        }

        currentUser = user
        saveUser(user)
    }

    func addReputation(_ amount: Int) {
        guard var user = currentUser else { return }

        let oldTier = user.reputationTier
        user.reputation += amount
        let newTier = user.reputationTier

        if newTier != oldTier {
            NotificationManager.shared.scheduleNotification(
                title: "Новый ранг репутации!",
                body: "Вы достигли ранга \(newTier.rawValue)",
                timeInterval: 1,
                identifier: "reputation_\(newTier.rawValue)"
            )
        }

        currentUser = user
        saveUser(user)
    }

    // MARK: - Premium

    func subscribeToPremium() async -> Bool {
        guard var user = currentUser else { return false }

        // Simulate purchase
        try? await Task.sleep(nanoseconds: 500_000_000)

        user.isPremium = true
        user.premiumExpiryDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())

        currentUser = user
        saveUser(user)

        return true
    }

    func purchaseBattlePass() async -> Bool {
        guard var user = currentUser else { return false }

        // Simulate purchase
        try? await Task.sleep(nanoseconds: 500_000_000)

        user.hasActivePass = true

        currentUser = user
        saveUser(user)

        return true
    }

    // MARK: - Persistence

    private func saveUser(_ user: UserProfile) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            currentUser = user
            isAuthenticated = true
        }
    }
}
