import Foundation

struct Item: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let type: ItemType
    let rarity: Rarity
    let cost: Int
    let effects: [ItemEffect]
    let slot: ItemSlot?
    let iconName: String

    init(name: String, description: String, type: ItemType, rarity: Rarity, cost: Int, effects: [ItemEffect], slot: ItemSlot? = nil, iconName: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.type = type
        self.rarity = rarity
        self.cost = cost
        self.effects = effects
        self.slot = slot
        self.iconName = iconName
    }
}

enum ItemType: String, Codable {
    case clothing = "Одежда"
    case accessory = "Аксессуар"
    case toy = "Игрушка"
    case food = "Еда"
    case medicine = "Лекарство"
    case decoration = "Украшение"
    case tool = "Инструмент"
}

enum ItemSlot: String, Codable, CaseIterable {
    case head = "Голова"
    case body = "Тело"
    case hands = "Руки"
    case feet = "Ноги"
    case accessory1 = "Аксессуар 1"
    case accessory2 = "Аксессуар 2"
}

enum Rarity: String, Codable {
    case common = "Обычный"
    case uncommon = "Необычный"
    case rare = "Редкий"
    case epic = "Эпический"
    case legendary = "Легендарный"

    var multiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.0
        case .epic: return 3.0
        case .legendary: return 5.0
        }
    }
}

struct ItemEffect: Codable, Hashable {
    let stat: StatType
    let value: Double

    enum StatType: String, Codable {
        case health
        case hunger
        case happiness
        case energy
        case cleanliness
        case strength
        case intelligence
        case creativity
        case agility
    }
}

// Предустановленные предметы
extension Item {
    static let commonItems: [Item] = [
        Item(
            name: "Банан",
            description: "Вкусный желтый банан",
            type: .food,
            rarity: .common,
            cost: 10,
            effects: [ItemEffect(stat: .hunger, value: -30)],
            iconName: "🍌"
        ),
        Item(
            name: "Кокос",
            description: "Свежий кокос с соком",
            type: .food,
            rarity: .uncommon,
            cost: 25,
            effects: [
                ItemEffect(stat: .hunger, value: -40),
                ItemEffect(stat: .happiness, value: 10)
            ],
            iconName: "🥥"
        ),
        Item(
            name: "Мячик",
            description: "Веселый мячик для игр",
            type: .toy,
            rarity: .common,
            cost: 50,
            effects: [
                ItemEffect(stat: .happiness, value: 20),
                ItemEffect(stat: .energy, value: -10)
            ],
            iconName: "⚽️"
        ),
        Item(
            name: "Барабан",
            description: "Музыкальный барабан",
            type: .toy,
            rarity: .rare,
            cost: 200,
            effects: [
                ItemEffect(stat: .happiness, value: 30),
                ItemEffect(stat: .creativity, value: 15)
            ],
            iconName: "🥁"
        ),
        Item(
            name: "Шапка пирата",
            description: "Стильная пиратская шапка",
            type: .clothing,
            rarity: .rare,
            cost: 150,
            effects: [ItemEffect(stat: .happiness, value: 15)],
            slot: .head,
            iconName: "🏴‍☠️"
        ),
        Item(
            name: "Солнечные очки",
            description: "Крутые очки для крутой обезьяны",
            type: .accessory,
            rarity: .uncommon,
            cost: 100,
            effects: [ItemEffect(stat: .happiness, value: 10)],
            slot: .accessory1,
            iconName: "🕶️"
        ),
        Item(
            name: "Лекарство",
            description: "Восстанавливает здоровье",
            type: .medicine,
            rarity: .common,
            cost: 75,
            effects: [ItemEffect(stat: .health, value: 50)],
            iconName: "💊"
        ),
        Item(
            name: "Энергетический напиток",
            description: "Восстанавливает энергию",
            type: .food,
            rarity: .uncommon,
            cost: 60,
            effects: [ItemEffect(stat: .energy, value: 40)],
            iconName: "⚡️"
        )
    ]
}
