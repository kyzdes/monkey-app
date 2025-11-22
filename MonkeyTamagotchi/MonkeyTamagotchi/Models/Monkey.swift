import Foundation

class Monkey: Codable, Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String
    @Published var type: MonkeyType
    @Published var stats: MonkeyStats
    @Published var age: Int // в днях
    @Published var level: Int
    @Published var experience: Int
    @Published var coins: Int
    @Published var mood: Mood
    @Published var stage: GrowthStage
    @Published var personalityTraits: [PersonalityTrait]
    @Published var learnedTricks: [Trick]
    @Published var inventory: [Item]
    @Published var equippedItems: [ItemSlot: Item]
    @Published var habitatStyle: HabitatStyle
    @Published var lastFed: Date
    @Published var lastPlayed: Date
    @Published var lastCleaned: Date
    @Published var lastSlept: Date
    @Published var isSleeping: Bool
    @Published var currentActivity: Activity?

    enum CodingKeys: String, CodingKey {
        case id, name, type, stats, age, level, experience, coins
        case mood, stage, personalityTraits, learnedTricks, inventory
        case equippedItems, habitatStyle, lastFed, lastPlayed
        case lastCleaned, lastSlept, isSleeping, currentActivity
    }

    init(name: String, type: MonkeyType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.stats = type.baseStats
        self.age = 0
        self.level = 1
        self.experience = 0
        self.coins = 100
        self.mood = .happy
        self.stage = .baby
        self.personalityTraits = []
        self.learnedTricks = []
        self.inventory = []
        self.equippedItems = [:]
        self.habitatStyle = .jungle
        self.lastFed = Date()
        self.lastPlayed = Date()
        self.lastCleaned = Date()
        self.lastSlept = Date()
        self.isSleeping = false
        self.currentActivity = nil
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(MonkeyType.self, forKey: .type)
        stats = try container.decode(MonkeyStats.self, forKey: .stats)
        age = try container.decode(Int.self, forKey: .age)
        level = try container.decode(Int.self, forKey: .level)
        experience = try container.decode(Int.self, forKey: .experience)
        coins = try container.decode(Int.self, forKey: .coins)
        mood = try container.decode(Mood.self, forKey: .mood)
        stage = try container.decode(GrowthStage.self, forKey: .stage)
        personalityTraits = try container.decode([PersonalityTrait].self, forKey: .personalityTraits)
        learnedTricks = try container.decode([Trick].self, forKey: .learnedTricks)
        inventory = try container.decode([Item].self, forKey: .inventory)
        equippedItems = try container.decode([ItemSlot: Item].self, forKey: .equippedItems)
        habitatStyle = try container.decode(HabitatStyle.self, forKey: .habitatStyle)
        lastFed = try container.decode(Date.self, forKey: .lastFed)
        lastPlayed = try container.decode(Date.self, forKey: .lastPlayed)
        lastCleaned = try container.decode(Date.self, forKey: .lastCleaned)
        lastSlept = try container.decode(Date.self, forKey: .lastSlept)
        isSleeping = try container.decode(Bool.self, forKey: .isSleeping)
        currentActivity = try container.decodeIfPresent(Activity.self, forKey: .currentActivity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(stats, forKey: .stats)
        try container.encode(age, forKey: .age)
        try container.encode(level, forKey: .level)
        try container.encode(experience, forKey: .experience)
        try container.encode(coins, forKey: .coins)
        try container.encode(mood, forKey: .mood)
        try container.encode(stage, forKey: .stage)
        try container.encode(personalityTraits, forKey: .personalityTraits)
        try container.encode(learnedTricks, forKey: .learnedTricks)
        try container.encode(inventory, forKey: .inventory)
        try container.encode(equippedItems, forKey: .equippedItems)
        try container.encode(habitatStyle, forKey: .habitatStyle)
        try container.encode(lastFed, forKey: .lastFed)
        try container.encode(lastPlayed, forKey: .lastPlayed)
        try container.encode(lastCleaned, forKey: .lastCleaned)
        try container.encode(lastSlept, forKey: .lastSlept)
        try container.encode(isSleeping, forKey: .isSleeping)
        try container.encode(currentActivity, forKey: .currentActivity)
    }

    func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }

    private func checkLevelUp() {
        let requiredXP = level * 100
        if experience >= requiredXP {
            level += 1
            experience -= requiredXP
            // Награда за уровень
            coins += level * 10
        }
    }

    func updateMood() {
        mood = Mood.determineMood(from: stats)
    }

    func checkGrowthStage() {
        let newStage: GrowthStage
        if age < 3 {
            newStage = .baby
        } else if age < 7 {
            newStage = .child
        } else if age < 15 {
            newStage = .teen
        } else {
            newStage = .adult
        }

        if newStage != stage {
            stage = newStage
        }
    }
}

enum GrowthStage: String, Codable {
    case baby = "Малыш"
    case child = "Ребенок"
    case teen = "Подросток"
    case adult = "Взрослый"

    var sizeMultiplier: Double {
        switch self {
        case .baby: return 0.6
        case .child: return 0.8
        case .teen: return 0.9
        case .adult: return 1.0
        }
    }
}

enum PersonalityTrait: String, Codable, CaseIterable {
    case brave = "Храбрый"
    case shy = "Застенчивый"
    case curious = "Любопытный"
    case lazy = "Ленивый"
    case energetic = "Энергичный"
    case smart = "Умный"
    case funny = "Веселый"
    case serious = "Серьезный"
    case friendly = "Дружелюбный"
    case independent = "Независимый"

    var description: String {
        switch self {
        case .brave: return "Не боится новых вызовов"
        case .shy: return "Медленно привыкает к новому"
        case .curious: return "Любит исследовать"
        case .lazy: return "Предпочитает отдых активности"
        case .energetic: return "Полон энергии"
        case .smart: return "Быстро учится"
        case .funny: return "Любит веселиться"
        case .serious: return "Сосредоточен на деле"
        case .friendly: return "Любит общаться"
        case .independent: return "Самостоятельный"
        }
    }
}

enum HabitatStyle: String, Codable, CaseIterable {
    case jungle = "Джунгли"
    case treehouse = "Домик на дереве"
    case cave = "Пещера"
    case bambooForest = "Бамбуковый лес"
    case tropical = "Тропики"

    var cost: Int {
        switch self {
        case .jungle: return 0
        case .treehouse: return 500
        case .cave: return 300
        case .bambooForest: return 400
        case .tropical: return 600
        }
    }
}

struct Activity: Codable {
    let type: ActivityType
    let startTime: Date
    let duration: TimeInterval

    var isComplete: Bool {
        Date().timeIntervalSince(startTime) >= duration
    }
}

enum ActivityType: String, Codable {
    case eating = "Ест"
    case playing = "Играет"
    case sleeping = "Спит"
    case bathing = "Купается"
    case training = "Тренируется"
    case performing = "Выступает"
}
