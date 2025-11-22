import Foundation
import SwiftUI

// MARK: - Breeding System

struct BreedingPair: Identifiable {
    let id = UUID()
    let parent1: Monkey
    let parent2: Monkey
    var breedingStartDate: Date
    var expectedBabyDate: Date

    var progress: Double {
        let total = expectedBabyDate.timeIntervalSince(breedingStartDate)
        let elapsed = Date().timeIntervalSince(breedingStartDate)
        return min(elapsed / total, 1.0)
    }

    var isReady: Bool {
        Date() >= expectedBabyDate
    }

    var timeRemaining: TimeInterval {
        max(expectedBabyDate.timeIntervalSinceNow, 0)
    }

    init(parent1: Monkey, parent2: Monkey) {
        self.parent1 = parent1
        self.parent2 = parent2
        self.breedingStartDate = Date()
        self.expectedBabyDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
    }
}

// MARK: - Genetics System

struct GeneticTraits: Codable {
    var dominantType: MonkeyType
    var recessiveType: MonkeyType?
    var colorGene: ColorGene
    var personalityGene: PersonalityGene
    var sizeGene: SizeGene
    var rarityGene: RarityGene

    enum ColorGene: String, Codable, CaseIterable {
        case brown, golden, silver, white, black, spotted

        var color: Color {
            switch self {
            case .brown: return .brown
            case .golden: return .yellow
            case .silver: return .gray
            case .white: return .white
            case .black: return .black
            case .spotted: return .orange
            }
        }
    }

    enum PersonalityGene: String, Codable, CaseIterable {
        case playful, calm, energetic, shy, brave, curious

        var description: String {
            switch self {
            case .playful: return "Игривый"
            case .calm: return "Спокойный"
            case .energetic: return "Энергичный"
            case .shy: return "Застенчивый"
            case .brave: return "Смелый"
            case .curious: return "Любопытный"
            }
        }

        var statModifier: [String: Int] {
            switch self {
            case .playful: return ["happiness": 10, "energy": 5]
            case .calm: return ["health": 10, "intelligence": 5]
            case .energetic: return ["energy": 15, "agility": 5]
            case .shy: return ["intelligence": 5, "creativity": 10]
            case .brave: return ["strength": 10, "health": 5]
            case .curious: return ["intelligence": 10, "creativity": 5]
            }
        }
    }

    enum SizeGene: String, Codable, CaseIterable {
        case tiny, small, medium, large, giant

        var multiplier: Double {
            switch self {
            case .tiny: return 0.6
            case .small: return 0.8
            case .medium: return 1.0
            case .large: return 1.2
            case .giant: return 1.5
            }
        }

        var description: String {
            switch self {
            case .tiny: return "Крошечный"
            case .small: return "Маленький"
            case .medium: return "Средний"
            case .large: return "Большой"
            case .giant: return "Гигантский"
            }
        }
    }

    enum RarityGene: String, Codable, CaseIterable {
        case common, uncommon, rare, epic, legendary

        var chance: Double {
            switch self {
            case .common: return 0.50
            case .uncommon: return 0.30
            case .rare: return 0.15
            case .epic: return 0.04
            case .legendary: return 0.01
            }
        }

        var color: Color {
            switch self {
            case .common: return .gray
            case .uncommon: return .green
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .yellow
            }
        }

        var description: String {
            switch self {
            case .common: return "Обычный"
            case .uncommon: return "Необычный"
            case .rare: return "Редкий"
            case .epic: return "Эпический"
            case .legendary: return "Легендарный"
            }
        }
    }

    static func inherit(from parent1: GeneticTraits, and parent2: GeneticTraits) -> GeneticTraits {
        // Mendelian genetics simulation
        let dominantType = Bool.random() ? parent1.dominantType : parent2.dominantType
        let recessiveType = Bool.random() ? parent1.recessiveType : parent2.recessiveType

        // Color inheritance with mutation chance
        var colorGene = Bool.random() ? parent1.colorGene : parent2.colorGene
        if Double.random(in: 0...1) < 0.05 { // 5% mutation chance
            colorGene = ColorGene.allCases.randomElement() ?? colorGene
        }

        let personalityGene = Bool.random() ? parent1.personalityGene : parent2.personalityGene
        let sizeGene = inheritSize(from: parent1.sizeGene, and: parent2.sizeGene)
        let rarityGene = inheritRarity(from: parent1.rarityGene, and: parent2.rarityGene)

        return GeneticTraits(
            dominantType: dominantType,
            recessiveType: recessiveType,
            colorGene: colorGene,
            personalityGene: personalityGene,
            sizeGene: sizeGene,
            rarityGene: rarityGene
        )
    }

    private static func inheritSize(from size1: SizeGene, and size2: SizeGene) -> SizeGene {
        let avg = (size1.multiplier + size2.multiplier) / 2
        let variation = Double.random(in: -0.2...0.2)
        let result = avg + variation

        switch result {
        case ...0.7: return .tiny
        case 0.7...0.9: return .small
        case 0.9...1.1: return .medium
        case 1.1...1.3: return .large
        default: return .giant
        }
    }

    private static func inheritRarity(from rarity1: RarityGene, and rarity2: RarityGene) -> RarityGene {
        // Higher rarity parents increase chance of rare offspring
        let baseChance = (rarity1.chance + rarity2.chance) / 2
        let roll = Double.random(in: 0...1)

        if roll < 0.01 * (1 + baseChance) { return .legendary }
        if roll < 0.05 * (1 + baseChance) { return .epic }
        if roll < 0.20 * (1 + baseChance) { return .rare }
        if roll < 0.50 { return .uncommon }
        return .common
    }
}

// MARK: - Family Tree

struct FamilyTree: Codable {
    var members: [FamilyMember]

    struct FamilyMember: Codable, Identifiable {
        let id: UUID
        let name: String
        let type: MonkeyType
        var parentIDs: [UUID]
        var childrenIDs: [UUID]
        let generation: Int
        let birthDate: Date
        let traits: GeneticTraits

        var isOriginal: Bool {
            parentIDs.isEmpty
        }
    }

    mutating func addMember(_ monkey: Monkey, parents: [UUID] = []) {
        let generation = parents.isEmpty ? 1 : (members.filter { parents.contains($0.id) }.map { $0.generation }.max() ?? 0) + 1

        let member = FamilyMember(
            id: monkey.id,
            name: monkey.name,
            type: monkey.type,
            parentIDs: parents,
            childrenIDs: [],
            generation: generation,
            birthDate: Date(),
            traits: monkey.genetics ?? GeneticTraits(
                dominantType: monkey.type,
                recessiveType: nil,
                colorGene: .brown,
                personalityGene: .playful,
                sizeGene: .medium,
                rarityGene: .common
            )
        )

        members.append(member)

        // Update parents' children lists
        for parentID in parents {
            if let index = members.firstIndex(where: { $0.id == parentID }) {
                members[index].childrenIDs.append(monkey.id)
            }
        }
    }

    func getAncestors(of memberID: UUID, depth: Int = 3) -> [FamilyMember] {
        guard let member = members.first(where: { $0.id == memberID }), depth > 0 else {
            return []
        }

        var ancestors: [FamilyMember] = []
        for parentID in member.parentIDs {
            if let parent = members.first(where: { $0.id == parentID }) {
                ancestors.append(parent)
                ancestors.append(contentsOf: getAncestors(of: parentID, depth: depth - 1))
            }
        }

        return ancestors
    }

    func getDescendants(of memberID: UUID) -> [FamilyMember] {
        guard let member = members.first(where: { $0.id == memberID }) else {
            return []
        }

        var descendants: [FamilyMember] = []
        for childID in member.childrenIDs {
            if let child = members.first(where: { $0.id == childID }) {
                descendants.append(child)
                descendants.append(contentsOf: getDescendants(of: childID))
            }
        }

        return descendants
    }

    var totalGenerations: Int {
        members.map { $0.generation }.max() ?? 0
    }

    var totalMembers: Int {
        members.count
    }
}

// MARK: - Baby Monkey

struct BabyMonkey {
    let id = UUID()
    var name: String
    let type: MonkeyType
    let traits: GeneticTraits
    var age: Int = 0 // In hours
    let parentIDs: [UUID]

    var isGrown: Bool {
        age >= 72 // 3 days
    }

    var growthStage: GrowthStage {
        switch age {
        case 0..<24: return .newborn
        case 24..<48: return .infant
        case 48..<72: return .toddler
        default: return .child
        }
    }

    enum GrowthStage: String {
        case newborn = "Новорожденный"
        case infant = "Младенец"
        case toddler = "Малыш"
        case child = "Ребенок"

        var sizeMultiplier: Double {
            switch self {
            case .newborn: return 0.3
            case .infant: return 0.5
            case .toddler: return 0.7
            case .child: return 0.9
            }
        }
    }

    func toAdultMonkey() -> Monkey {
        var stats = type.baseStats

        // Apply genetic modifiers
        for (stat, bonus) in traits.personalityGene.statModifier {
            switch stat {
            case "health": stats.health += bonus
            case "happiness": stats.happiness += bonus
            case "energy": stats.energy += bonus
            case "strength": stats.strength += bonus
            case "intelligence": stats.intelligence += bonus
            case "creativity": stats.creativity += bonus
            case "agility": stats.agility += bonus
            default: break
            }
        }

        let monkey = Monkey(
            name: name,
            type: type,
            stats: stats
        )

        monkey.genetics = traits

        return monkey
    }
}
