import Foundation
import Combine

class CloudSyncService: ObservableObject {
    static let shared = CloudSyncService()

    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?

    private let gameManager = GameManager.shared
    private let authService = AuthenticationService.shared

    private init() {
        loadLastSyncDate()
    }

    // MARK: - Sync Operations

    func syncToCloud() async -> Bool {
        guard authService.isAuthenticated, let user = authService.currentUser else {
            syncError = "Пользователь не авторизован"
            return false
        }

        isSyncing = true
        syncError = nil

        // Prepare data
        let cloudSave = prepareCloudSave(userID: user.id)

        // Simulate cloud upload
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Save to UserDefaults as mock cloud storage
        if let encoded = try? JSONEncoder().encode(cloudSave) {
            UserDefaults.standard.set(encoded, forKey: "cloudSave_\(user.id)")
        }

        lastSyncDate = Date()
        saveLastSyncDate()
        isSyncing = false

        return true
    }

    func syncFromCloud() async -> Bool {
        guard authService.isAuthenticated, let user = authService.currentUser else {
            syncError = "Пользователь не авторизован"
            return false
        }

        isSyncing = true
        syncError = nil

        // Simulate cloud download
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Load from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: "cloudSave_\(user.id)"),
              let cloudSave = try? JSONDecoder().decode(CloudSave.self, from: data) else {
            syncError = "Нет сохраненных данных в облаке"
            isSyncing = false
            return false
        }

        // Restore data
        restoreFromCloudSave(cloudSave)

        lastSyncDate = Date()
        saveLastSyncDate()
        isSyncing = false

        return true
    }

    func autoSync() async {
        // Auto-sync every 5 minutes if premium
        guard authService.currentUser?.isPremium == true else { return }

        if let lastSync = lastSyncDate {
            let timeSinceLastSync = Date().timeIntervalSince(lastSync)
            if timeSinceLastSync < 300 { return } // 5 minutes
        }

        _ = await syncToCloud()
    }

    // MARK: - Data Preparation

    private func prepareCloudSave(userID: UUID) -> CloudSave {
        var monkeysData: [CloudSave.MonkeyData] = []

        if let monkey = gameManager.currentMonkey {
            let monkeyData = CloudSave.MonkeyData(
                id: monkey.id,
                type: monkey.type.rawValue,
                name: monkey.name,
                stats: [
                    "health": monkey.stats.health,
                    "hunger": monkey.stats.hunger,
                    "happiness": monkey.stats.happiness,
                    "energy": monkey.stats.energy
                ],
                items: monkey.inventory.map { $0.id.uuidString },
                age: monkey.age,
                level: monkey.level
            )
            monkeysData.append(monkeyData)
        }

        let settings = CloudSave.GameSettingsData(
            difficulty: "normal",
            theme: "default",
            language: authService.currentUser?.preferredLanguage ?? "ru"
        )

        return CloudSave(
            id: UUID(),
            userID: userID,
            monkeys: monkeysData,
            inventory: [],
            achievements: gameManager.achievements.filter { $0.isUnlocked }.map { $0.id },
            settings: settings,
            lastSync: Date(),
            version: "2.0.0"
        )
    }

    private func restoreFromCloudSave(_ cloudSave: CloudSave) {
        // Restore monkey data
        if let monkeyData = cloudSave.monkeys.first {
            // Create or update monkey
            // This is simplified - in real app would be more complex
            print("Restored monkey: \(monkeyData.name)")
        }

        // Restore achievements
        for achievementID in cloudSave.achievements {
            if let achievement = gameManager.achievements.first(where: { $0.id == achievementID }) {
                achievement.isUnlocked = true
            }
        }

        gameManager.saveGame()
    }

    // MARK: - Conflict Resolution

    func resolveConflict(local: CloudSave, remote: CloudSave) -> CloudSave {
        // Use most recent version
        if local.lastSync > remote.lastSync {
            return local
        } else {
            return remote
        }
    }

    // MARK: - Persistence

    private func saveLastSyncDate() {
        if let date = lastSyncDate {
            UserDefaults.standard.set(date, forKey: "lastSyncDate")
        }
    }

    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }
}
