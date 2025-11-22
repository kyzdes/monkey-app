import SwiftUI

struct CustomizationView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Одежда").tag(0)
                    Text("Трюки").tag(1)
                    Text("Жилище").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    ClothingView()
                } else if selectedTab == 1 {
                    TricksView()
                } else {
                    HabitatView()
                }
            }
            .navigationTitle("Кастомизация")
        }
    }
}

struct ClothingView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let monkey = gameManager.currentMonkey {
                    VStack {
                        Text("Экипировано")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ForEach(ItemSlot.allCases, id: \.self) { slot in
                            EquippedSlotView(slot: slot, item: monkey.equippedItems[slot])
                        }
                    }

                    Divider()

                    VStack {
                        Text("Инвентарь")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                            ForEach(monkey.inventory.filter { $0.type == .clothing || $0.type == .accessory }) { item in
                                InventoryItemView(item: item) {
                                    gameManager.equipItem(item)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct EquippedSlotView: View {
    let slot: ItemSlot
    let item: Item?
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        HStack {
            Text(slot.rawValue)
                .font(.subheadline)
                .frame(width: 100, alignment: .leading)

            if let item = item {
                HStack {
                    Text(item.iconName)
                        .font(.title2)
                    Text(item.name)
                        .font(.subheadline)
                    Spacer()
                    Button(action: {
                        gameManager.unequipItem(slot: slot)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            } else {
                Text("Пусто")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

struct InventoryItemView: View {
    let item: Item
    let onUse: () -> Void

    var body: some View {
        Button(action: onUse) {
            VStack {
                Text(item.iconName)
                    .font(.title)

                Text(item.name)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 100)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

struct TricksView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: Trick.TrickCategory = .acrobatic

    var body: some View {
        VStack {
            categoryPicker

            ScrollView {
                VStack(spacing: 15) {
                    if let monkey = gameManager.currentMonkey {
                        ForEach(Trick.availableTricks.filter { $0.category == selectedCategory }) { trick in
                            let isLearned = monkey.learnedTricks.contains(where: { $0.id == trick.id })
                            TrickCardView(trick: trick, isLearned: isLearned) {
                                if isLearned {
                                    gameManager.performTrick(trick)
                                } else {
                                    gameManager.learnTrick(trick)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Trick.TrickCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                            HapticManager.shared.selection()
                        }
                    }) {
                        Text(category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct TrickCardView: View {
    let trick: Trick
    let isLearned: Bool
    let action: () -> Void
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(trick.name)
                        .font(.headline)

                    Spacer()

                    if isLearned {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                Text(trick.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text(trick.difficulty.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(difficultyColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)

                    Text("Ур. \(trick.requiredLevel)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if isLearned {
                        Text("Выполнено: \(trick.timesPerformed)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: action) {
                if isLearned {
                    Text("Выполнить")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(canPerform ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    VStack {
                        Text("🍌 \(trick.unlockCost)")
                            .font(.caption)
                        Text("Купить")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(canLearn ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .disabled(isLearned ? !canPerform : !canLearn)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var difficultyColor: Color {
        switch trick.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        case .expert: return .purple
        }
    }

    private var canPerform: Bool {
        guard let monkey = gameManager.currentMonkey else { return false }
        return monkey.stats.energy > 15
    }

    private var canLearn: Bool {
        guard let monkey = gameManager.currentMonkey else { return false }
        return monkey.coins >= trick.unlockCost && monkey.level >= trick.requiredLevel
    }
}

struct HabitatView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let monkey = gameManager.currentMonkey {
                    Text("Текущее жилище: \(monkey.habitatStyle.rawValue)")
                        .font(.headline)

                    ForEach(HabitatStyle.allCases, id: \.self) { style in
                        HabitatCard(style: style, isCurrent: monkey.habitatStyle == style) {
                            if monkey.coins >= style.cost {
                                monkey.coins -= style.cost
                                monkey.habitatStyle = style
                                gameManager.saveGame()
                                HapticManager.shared.notification(type: .success)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct HabitatCard: View {
    let style: HabitatStyle
    let isCurrent: Bool
    let action: () -> Void
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(habitatEmoji)
                    .font(.largeTitle)

                VStack(alignment: .leading) {
                    Text(style.rawValue)
                        .font(.headline)

                    if style.cost > 0 {
                        Text("🍌 \(style.cost)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Бесплатно")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                if isCurrent {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else if canAfford {
                    Button(action: action) {
                        Text("Купить")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(isCurrent ? Color.green.opacity(0.2) : Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }

    private var habitatEmoji: String {
        switch style {
        case .jungle: return "🌴"
        case .treehouse: return "🏡"
        case .cave: return "🏔️"
        case .bambooForest: return "🎋"
        case .tropical: return "🌺"
        }
    }

    private var canAfford: Bool {
        guard let monkey = gameManager.currentMonkey else { return false }
        return monkey.coins >= style.cost
    }
}
