import Foundation

struct Trick: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let difficulty: Difficulty
    let requiredLevel: Int
    let unlockCost: Int
    let category: TrickCategory
    var timesPerformed: Int

    init(name: String, description: String, difficulty: Difficulty, requiredLevel: Int, unlockCost: Int, category: TrickCategory) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.requiredLevel = requiredLevel
        self.unlockCost = unlockCost
        self.category = category
        self.timesPerformed = 0
    }

    enum Difficulty: String, Codable {
        case easy = "Легкий"
        case medium = "Средний"
        case hard = "Сложный"
        case expert = "Эксперт"

        var experienceReward: Int {
            switch self {
            case .easy: return 10
            case .medium: return 25
            case .hard: return 50
            case .expert: return 100
            }
        }
    }

    enum TrickCategory: String, Codable, CaseIterable {
        case acrobatic = "Акробатика"
        case dance = "Танцы"
        case music = "Музыка"
        case social = "Социальные"
        case strength = "Силовые"
        case intelligence = "Интеллектуальные"
    }
}

extension Trick {
    static let availableTricks: [Trick] = [
        // Акробатические
        Trick(
            name: "Сальто",
            description: "Делает сальто вперед",
            difficulty: .medium,
            requiredLevel: 3,
            unlockCost: 100,
            category: .acrobatic
        ),
        Trick(
            name: "Колесо",
            description: "Делает колесо",
            difficulty: .easy,
            requiredLevel: 2,
            unlockCost: 50,
            category: .acrobatic
        ),
        Trick(
            name: "Стойка на руках",
            description: "Стоит на руках",
            difficulty: .hard,
            requiredLevel: 5,
            unlockCost: 200,
            category: .acrobatic
        ),
        Trick(
            name: "Двойное сальто",
            description: "Делает двойное сальто",
            difficulty: .expert,
            requiredLevel: 10,
            unlockCost: 500,
            category: .acrobatic
        ),

        // Танцы
        Trick(
            name: "Танец счастья",
            description: "Танцует веселый танец",
            difficulty: .easy,
            requiredLevel: 1,
            unlockCost: 30,
            category: .dance
        ),
        Trick(
            name: "Лунная походка",
            description: "Делает лунную походку",
            difficulty: .medium,
            requiredLevel: 4,
            unlockCost: 150,
            category: .dance
        ),
        Trick(
            name: "Брейк-данс",
            description: "Танцует брейк-данс",
            difficulty: .hard,
            requiredLevel: 7,
            unlockCost: 300,
            category: .dance
        ),

        // Музыкальные
        Trick(
            name: "Игра на барабанах",
            description: "Играет ритм на барабанах",
            difficulty: .medium,
            requiredLevel: 3,
            unlockCost: 100,
            category: .music
        ),
        Trick(
            name: "Пение",
            description: "Поет песню",
            difficulty: .easy,
            requiredLevel: 2,
            unlockCost: 75,
            category: .music
        ),
        Trick(
            name: "Джаз-импровизация",
            description: "Импровизирует джазовую мелодию",
            difficulty: .expert,
            requiredLevel: 12,
            unlockCost: 600,
            category: .music
        ),

        // Социальные
        Trick(
            name: "Воздушный поцелуй",
            description: "Шлет воздушный поцелуй",
            difficulty: .easy,
            requiredLevel: 1,
            unlockCost: 25,
            category: .social
        ),
        Trick(
            name: "Обнимашки",
            description: "Обнимает тебя",
            difficulty: .easy,
            requiredLevel: 1,
            unlockCost: 20,
            category: .social
        ),
        Trick(
            name: "Дай пять",
            description: "Дает пять",
            difficulty: .easy,
            requiredLevel: 1,
            unlockCost: 15,
            category: .social
        ),
        Trick(
            name: "Смешная рожица",
            description: "Строит смешную рожицу",
            difficulty: .easy,
            requiredLevel: 2,
            unlockCost: 40,
            category: .social
        ),

        // Силовые
        Trick(
            name: "Показать мускулы",
            description: "Демонстрирует силу",
            difficulty: .easy,
            requiredLevel: 2,
            unlockCost: 50,
            category: .strength
        ),
        Trick(
            name: "Поднятие тяжестей",
            description: "Поднимает тяжелый предмет",
            difficulty: .medium,
            requiredLevel: 5,
            unlockCost: 150,
            category: .strength
        ),
        Trick(
            name: "Удар грудью",
            description: "Бьет себя в грудь",
            difficulty: .medium,
            requiredLevel: 4,
            unlockCost: 100,
            category: .strength
        ),

        // Интеллектуальные
        Trick(
            name: "Решение головоломки",
            description: "Решает простую головоломку",
            difficulty: .medium,
            requiredLevel: 3,
            unlockCost: 120,
            category: .intelligence
        ),
        Trick(
            name: "Подсчет предметов",
            description: "Считает предметы",
            difficulty: .hard,
            requiredLevel: 6,
            unlockCost: 250,
            category: .intelligence
        ),
        Trick(
            name: "Жонглирование",
            description: "Жонглирует предметами",
            difficulty: .hard,
            requiredLevel: 8,
            unlockCost: 350,
            category: .intelligence
        )
    ]
}
