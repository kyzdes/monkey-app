import Foundation
import Combine

class GameManager: ObservableObject {
    static let shared = GameManager()

    @Published var currentMonkey: Monkey?
    @Published var settings: GameSettings
    @Published var achievements: [Achievement]
    @Published var dailyTasks: [DailyTask]
    @Published var lastUpdateTime: Date

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let persistence = PersistenceController.shared
    private let updateInterval: TimeInterval = 60 // обновление каждую минуту

    private init() {
        self.settings = GameSettings.default
        self.achievements = Achievement.defaultAchievements
        self.dailyTasks = []
        self.lastUpdateTime = Date()

        loadGame()
        startGameLoop()
        checkDailyTasks()
    }

    // MARK: - Game Loop

    private func startGameLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }

    private func updateGame() {
        guard let monkey = currentMonkey else { return }

        let timePassed = Date().timeIntervalSince(lastUpdateTime)
        let minutesPassed = timePassed / 60

        // Обновление показателей со временем
        monkey.stats.hunger += minutesPassed * 0.5
        monkey.stats.energy -= minutesPassed * 0.3
        monkey.stats.cleanliness -= minutesPassed * 0.2
        monkey.stats.happiness -= minutesPassed * 0.1

        // Если питомец спит, восстанавливаем энергию
        if monkey.isSleeping {
            monkey.stats.energy += minutesPassed * 2
            if monkey.stats.energy >= 100 {
                monkey.isSleeping = false
            }
        }

        // Проверка активности
        if let activity = monkey.currentActivity, activity.isComplete {
            completeActivity(activity.type)
            monkey.currentActivity = nil
        }

        // Здоровье падает, если показатели критические
        if monkey.stats.hunger > 80 || monkey.stats.energy < 20 {
            monkey.stats.health -= minutesPassed * 0.5
        }

        monkey.stats.clamp()
        monkey.updateMood()

        lastUpdateTime = Date()
        saveGame()

        // Планирование уведомлений
        scheduleNotifications()
    }

    // MARK: - Save/Load

    func saveGame() {
        if let monkey = currentMonkey {
            persistence.saveMonkey(monkey)
        }

        // Сохранение настроек и других данных
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "GameSettings")
        }

        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "Achievements")
        }

        if let encoded = try? JSONEncoder().encode(dailyTasks) {
            UserDefaults.standard.set(encoded, forKey: "DailyTasks")
        }

        UserDefaults.standard.set(lastUpdateTime, forKey: "LastUpdateTime")
    }

    func loadGame() {
        currentMonkey = persistence.loadMonkey()

        if let data = UserDefaults.standard.data(forKey: "GameSettings"),
           let decoded = try? JSONDecoder().decode(GameSettings.self, from: data) {
            settings = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "Achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        }

        if let data = UserDefaults.standard.data(forKey: "DailyTasks"),
           let decoded = try? JSONDecoder().decode([DailyTask].self, from: data) {
            dailyTasks = decoded
        }

        if let lastUpdate = UserDefaults.standard.object(forKey: "LastUpdateTime") as? Date {
            lastUpdateTime = lastUpdate
            // Обновляем игру на время отсутствия
            updateGame()
        }
    }

    // MARK: - Monkey Creation

    func createMonkey(name: String, type: MonkeyType) {
        currentMonkey = Monkey(name: name, type: type)
        dailyTasks = DailyTask.generateDailyTasks()
        saveGame()
    }

    // MARK: - Actions

    func feedMonkey(food: FoodType) {
        guard let monkey = currentMonkey else { return }

        let isFavorite = monkey.type.favoriteFoods.contains(food)
        let hungerReduction = Double(food.nutritionValue) * (isFavorite ? 1.5 : 1.0)

        monkey.stats.hunger -= hungerReduction
        monkey.stats.happiness += isFavorite ? 10 : 5
        monkey.stats.clamp()

        monkey.lastFed = Date()
        monkey.addExperience(10)

        updateDailyTask(type: .feed)
        checkAchievements()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.impact(style: .medium)
        }
    }

    func playWithMonkey() {
        guard let monkey = currentMonkey else { return }
        guard monkey.stats.energy > 20 else { return }

        monkey.stats.happiness += 20
        monkey.stats.energy -= 15
        monkey.stats.clamp()

        monkey.lastPlayed = Date()
        monkey.addExperience(15)

        updateDailyTask(type: .play)
        checkAchievements()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.impact(style: .light)
        }
    }

    func cleanMonkey() {
        guard let monkey = currentMonkey else { return }

        monkey.stats.cleanliness = 100
        monkey.stats.happiness += 10
        monkey.stats.health += 5
        monkey.stats.clamp()

        monkey.lastCleaned = Date()
        monkey.addExperience(10)

        updateDailyTask(type: .clean)
        checkAchievements()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.impact(style: .medium)
        }
    }

    func putMonkeyToSleep() {
        guard let monkey = currentMonkey else { return }

        monkey.isSleeping = true
        monkey.lastSlept = Date()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.impact(style: .soft)
        }
    }

    func wakeMonkey() {
        guard let monkey = currentMonkey else { return }

        monkey.isSleeping = false
        monkey.stats.happiness += 5
        monkey.stats.clamp()
        saveGame()
    }

    func performTrick(_ trick: Trick) {
        guard let monkey = currentMonkey else { return }
        guard monkey.stats.energy > 15 else { return }

        monkey.stats.energy -= 15
        monkey.stats.happiness += 15
        monkey.stats.clamp()

        if let index = monkey.learnedTricks.firstIndex(where: { $0.id == trick.id }) {
            monkey.learnedTricks[index].timesPerformed += 1
        }

        monkey.addExperience(trick.difficulty.experienceReward)

        updateDailyTask(type: .trick)
        checkAchievements()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.notification(type: .success)
        }
    }

    func learnTrick(_ trick: Trick) {
        guard let monkey = currentMonkey else { return }
        guard monkey.coins >= trick.unlockCost else { return }
        guard monkey.level >= trick.requiredLevel else { return }
        guard !monkey.learnedTricks.contains(where: { $0.id == trick.id }) else { return }

        monkey.coins -= trick.unlockCost
        monkey.learnedTricks.append(trick)

        updateDailyTask(type: .trick)
        checkAchievements()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.notification(type: .success)
        }
    }

    func buyItem(_ item: Item) {
        guard let monkey = currentMonkey else { return }
        guard monkey.coins >= item.cost else { return }

        monkey.coins -= item.cost
        monkey.inventory.append(item)

        checkAchievements()
        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.notification(type: .success)
        }
    }

    func useItem(_ item: Item) {
        guard let monkey = currentMonkey else { return }
        guard let index = monkey.inventory.firstIndex(where: { $0.id == item.id }) else { return }

        // Применение эффектов предмета
        for effect in item.effects {
            switch effect.stat {
            case .health: monkey.stats.health += effect.value
            case .hunger: monkey.stats.hunger += effect.value
            case .happiness: monkey.stats.happiness += effect.value
            case .energy: monkey.stats.energy += effect.value
            case .cleanliness: monkey.stats.cleanliness += effect.value
            case .strength: monkey.stats.strength += effect.value
            case .intelligence: monkey.stats.intelligence += effect.value
            case .creativity: monkey.stats.creativity += effect.value
            case .agility: monkey.stats.agility += effect.value
            }
        }

        monkey.stats.clamp()

        // Удаление предмета, если это расходник
        if item.type == .food || item.type == .medicine {
            monkey.inventory.remove(at: index)
        }

        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.impact(style: .medium)
        }
    }

    func equipItem(_ item: Item) {
        guard let monkey = currentMonkey, let slot = item.slot else { return }

        if monkey.equippedItems[slot] != nil {
            unequipItem(slot: slot)
        }

        monkey.equippedItems[slot] = item
        saveGame()
    }

    func unequipItem(slot: ItemSlot) {
        guard let monkey = currentMonkey else { return }
        monkey.equippedItems.removeValue(forKey: slot)
        saveGame()
    }

    // MARK: - Daily Tasks

    private func checkDailyTasks() {
        let lastCheck = UserDefaults.standard.object(forKey: "LastDailyTaskCheck") as? Date ?? Date.distantPast
        let calendar = Calendar.current

        if !calendar.isDateInToday(lastCheck) {
            dailyTasks = DailyTask.generateDailyTasks()
            UserDefaults.standard.set(Date(), forKey: "LastDailyTaskCheck")
            saveGame()

            NotificationManager.shared.scheduleDailyTasksNotification()
        }
    }

    private func updateDailyTask(type: DailyTask.TaskType) {
        for i in 0..<dailyTasks.count {
            if dailyTasks[i].type == type && !dailyTasks[i].isCompleted {
                dailyTasks[i].progress += 1

                if dailyTasks[i].progress >= dailyTasks[i].targetProgress {
                    completeDailyTask(at: i)
                }
            }
        }
        saveGame()
    }

    private func completeDailyTask(at index: Int) {
        guard index < dailyTasks.count else { return }
        guard let monkey = currentMonkey else { return }

        dailyTasks[index].isCompleted = true
        monkey.coins += dailyTasks[index].reward
        monkey.addExperience(dailyTasks[index].reward / 2)

        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.notification(type: .success)
        }
    }

    // MARK: - Achievements

    private func checkAchievements() {
        guard let monkey = currentMonkey else { return }

        for i in 0..<achievements.count {
            if !achievements[i].isUnlocked {
                var shouldUnlock = false
                var progress: Double = 0

                switch achievements[i].requirement {
                case .reachLevel(let level):
                    progress = Double(monkey.level)
                    shouldUnlock = monkey.level >= level

                case .feedTimes(let times):
                    // Требуется отслеживание
                    break

                case .playTimes(let times):
                    // Требуется отслеживание
                    break

                case .learnTricks(let count):
                    progress = Double(monkey.learnedTricks.count)
                    shouldUnlock = monkey.learnedTricks.count >= count

                case .collectCoins(let amount):
                    progress = Double(monkey.coins)
                    shouldUnlock = monkey.coins >= amount

                case .daysAlive(let days):
                    progress = Double(monkey.age)
                    shouldUnlock = monkey.age >= days

                case .ownItems(let count):
                    progress = Double(monkey.inventory.count)
                    shouldUnlock = monkey.inventory.count >= count

                case .maxStat(let stat, let value):
                    switch stat {
                    case "strength": progress = monkey.stats.strength
                    case "intelligence": progress = monkey.stats.intelligence
                    case "agility": progress = monkey.stats.agility
                    default: break
                    }
                    shouldUnlock = progress >= value

                default:
                    break
                }

                achievements[i].progress = progress

                if shouldUnlock {
                    unlockAchievement(at: i)
                }
            }
        }

        saveGame()
    }

    private func unlockAchievement(at index: Int) {
        guard index < achievements.count else { return }
        guard let monkey = currentMonkey else { return }

        achievements[index].isUnlocked = true
        monkey.coins += achievements[index].reward

        saveGame()

        if settings.hapticFeedbackEnabled {
            HapticManager.shared.notification(type: .success)
        }
    }

    // MARK: - Notifications

    private func scheduleNotifications() {
        guard let monkey = currentMonkey, settings.notificationsEnabled else { return }

        if monkey.stats.hunger > 70 {
            NotificationManager.shared.scheduleHungerNotification(monkeyName: monkey.name)
        }

        if monkey.stats.energy < 30 {
            NotificationManager.shared.scheduleEnergyNotification(monkeyName: monkey.name)
        }

        if monkey.stats.cleanliness < 40 {
            NotificationManager.shared.scheduleCleanlinessNotification(monkeyName: monkey.name)
        }
    }

    private func completeActivity(_ type: ActivityType) {
        // Обработка завершения активности
    }
}
