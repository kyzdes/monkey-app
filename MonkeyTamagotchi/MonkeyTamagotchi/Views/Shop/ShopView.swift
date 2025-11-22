import SwiftUI

struct ShopView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: ItemType = .food

    var body: some View {
        NavigationView {
            VStack {
                coinBalance

                categoryPicker

                itemGrid

                Spacer()
            }
            .navigationTitle("Магазин")
        }
    }

    private var coinBalance: some View {
        HStack {
            Text("🍌")
                .font(.title)
            Text("\(gameManager.currentMonkey?.coins ?? 0)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(15)
        .padding()
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach([ItemType.food, .toy, .clothing, .accessory, .medicine, .decoration], id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation {
                            selectedCategory = category
                            HapticManager.shared.selection()
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                ForEach(Item.commonItems.filter { $0.type == selectedCategory }) { item in
                    ShopItemCard(item: item) {
                        gameManager.buyItem(item)
                    }
                }
            }
            .padding()
        }
    }
}

struct CategoryButton: View {
    let category: ItemType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(categoryIcon)
                    .font(.title2)
                Text(category.rawValue)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }

    private var categoryIcon: String {
        switch category {
        case .food: return "🍎"
        case .toy: return "🎾"
        case .clothing: return "👕"
        case .accessory: return "👑"
        case .medicine: return "💊"
        case .decoration: return "🏠"
        case .tool: return "🔧"
        }
    }
}

struct ShopItemCard: View {
    let item: Item
    let onBuy: () -> Void
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.iconName)
                    .font(.system(size: 40))
                Spacer()
                rarityBadge
            }

            Text(item.name)
                .font(.headline)
                .lineLimit(2)

            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)

            Spacer()

            Button(action: onBuy) {
                HStack {
                    Text("🍌 \(item.cost)")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "cart.fill")
                }
                .foregroundColor(.white)
                .padding()
                .background(canAfford ? Color.green : Color.gray)
                .cornerRadius(10)
            }
            .disabled(!canAfford)
        }
        .padding()
        .frame(height: 220)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }

    private var rarityBadge: some View {
        Text(item.rarity.rawValue)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(rarityColor)
            .foregroundColor(.white)
            .cornerRadius(6)
    }

    private var rarityColor: Color {
        switch item.rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }

    private var canAfford: Bool {
        guard let monkey = gameManager.currentMonkey else { return false }
        return monkey.coins >= item.cost
    }
}
