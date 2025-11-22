import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showActionMenu = false
    @State private var dragOffset: CGSize = .zero
    @State private var petAnimation = false

    var body: some View {
        ZStack {
            backgroundView

            VStack {
                topBar

                Spacer()

                if let monkey = gameManager.currentMonkey {
                    monkeyCharacterView(monkey: monkey)
                }

                Spacer()

                statsBar

                actionButtons
            }
            .padding()

            if showActionMenu {
                ActionMenuView(isPresented: $showActionMenu)
            }
        }
    }

    private var backgroundView: some View {
        Group {
            if let monkey = gameManager.currentMonkey {
                habitatBackground(for: monkey.habitatStyle)
            } else {
                Color.green.opacity(0.3)
            }
        }
        .ignoresSafeArea()
    }

    private func habitatBackground(for style: HabitatStyle) -> some View {
        LinearGradient(
            gradient: Gradient(colors: habitatColors(for: style)),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func habitatColors(for style: HabitatStyle) -> [Color] {
        switch style {
        case .jungle:
            return [Color.green.opacity(0.7), Color.green.opacity(0.4)]
        case .treehouse:
            return [Color.brown.opacity(0.5), Color.green.opacity(0.5)]
        case .cave:
            return [Color.gray.opacity(0.6), Color.brown.opacity(0.4)]
        case .bambooForest:
            return [Color.green.opacity(0.6), Color.mint.opacity(0.5)]
        case .tropical:
            return [Color.cyan.opacity(0.5), Color.green.opacity(0.6)]
        }
    }

    private var topBar: some View {
        HStack {
            if let monkey = gameManager.currentMonkey {
                VStack(alignment: .leading) {
                    Text(monkey.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        Text("Ур. \(monkey.level)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(8)

                        Text(monkey.mood.emoji)
                            .font(.title3)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    HStack {
                        Text("🍌")
                        Text("\(monkey.coins)")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(12)

                    Text(monkey.stage.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
    }

    private func monkeyCharacterView(monkey: Monkey) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 250, height: 250)
                .blur(radius: 20)

            VStack {
                Text(monkeyEmoji(for: monkey.type))
                    .font(.system(size: 120))
                    .scaleEffect(monkey.stage.sizeMultiplier * (petAnimation ? 1.1 : 1.0))
                    .animation(.spring(), value: petAnimation)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { _ in
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            }
                    )
                    .onTapGesture {
                        petMonkey()
                    }

                if monkey.isSleeping {
                    Text("💤")
                        .font(.title)
                        .offset(x: 40, y: -40)
                }
            }

            // Экипированные предметы
            ForEach(Array(monkey.equippedItems.values), id: \.id) { item in
                Text(item.iconName)
                    .font(.title)
                    .offset(itemOffset(for: item.slot))
            }
        }
    }

    private func itemOffset(for slot: ItemSlot?) -> CGSize {
        guard let slot = slot else { return .zero }
        switch slot {
        case .head: return CGSize(width: 0, height: -80)
        case .body: return CGSize(width: 0, height: 0)
        case .hands: return CGSize(width: 60, height: 20)
        case .feet: return CGSize(width: 0, height: 80)
        case .accessory1: return CGSize(width: -60, height: -40)
        case .accessory2: return CGSize(width: 60, height: -40)
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

    private func petMonkey() {
        guard let monkey = gameManager.currentMonkey else { return }
        guard !monkey.isSleeping else { return }

        petAnimation.toggle()
        monkey.stats.happiness = min(monkey.stats.happiness + 2, 100)
        HapticManager.shared.petFeedback()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            petAnimation.toggle()
        }
    }

    private var statsBar: some View {
        VStack(spacing: 10) {
            if let monkey = gameManager.currentMonkey {
                StatBarView(label: "❤️ Здоровье", value: monkey.stats.health, color: .red)
                StatBarView(label: "🍎 Голод", value: 100 - monkey.stats.hunger, color: .orange)
                StatBarView(label: "😊 Счастье", value: monkey.stats.happiness, color: .yellow)
                StatBarView(label: "⚡️ Энергия", value: monkey.stats.energy, color: .blue)
                StatBarView(label: "🛁 Чистота", value: monkey.stats.cleanliness, color: .cyan)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
    }

    private var actionButtons: some View {
        HStack(spacing: 15) {
            ActionButtonView(icon: "fork.knife", color: .orange) {
                showActionMenu = true
            }

            ActionButtonView(icon: "gamecontroller.fill", color: .purple) {
                gameManager.playWithMonkey()
            }

            ActionButtonView(icon: "bed.double.fill", color: .blue) {
                if let monkey = gameManager.currentMonkey {
                    if monkey.isSleeping {
                        gameManager.wakeMonkey()
                    } else {
                        gameManager.putMonkeyToSleep()
                    }
                }
            }

            ActionButtonView(icon: "shower.fill", color: .cyan) {
                gameManager.cleanMonkey()
            }
        }
        .padding()
    }
}

struct StatBarView: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(value))%")
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (value / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ActionButtonView: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(15)
        }
    }
}

struct ActionMenuView: View {
    @Binding isPresented: Bool
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            VStack(spacing: 20) {
                Text("Чем покормить?")
                    .font(.title2)
                    .fontWeight(.bold)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                        ForEach(FoodType.allCases, id: \.self) { food in
                            FoodItemView(food: food) {
                                gameManager.feedMonkey(food: food)
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)

                Button("Закрыть") {
                    withAnimation {
                        isPresented = false
                    }
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .padding(40)
        }
    }
}

struct FoodItemView: View {
    let food: FoodType
    let action: () -> Void
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        Button(action: action) {
            VStack {
                Text(food.icon)
                    .font(.system(size: 40))

                Text(food.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)

                Text("🍌 \(food.cost)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, height: 100)
            .background(canAfford ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
        .disabled(!canAfford)
    }

    private var canAfford: Bool {
        guard let monkey = gameManager.currentMonkey else { return false }
        return monkey.coins >= food.cost
    }
}
