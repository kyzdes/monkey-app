import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showActionMenu = false
    @State private var dragOffset: CGSize = .zero
    @State private var petAnimation = false
    @Namespace private var animation

    var body: some View {
        ZStack {
            // Фоновый градиент с материалами iOS 16+
            backgroundView

            VStack(spacing: 0) {
                // Верхняя панель с Material
                topBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer(minLength: 20)

                // Персонаж
                if let monkey = gameManager.currentMonkey {
                    monkeyCharacterView(monkey: monkey)
                        .transition(.scale.combined(with: .opacity))
                }

                Spacer(minLength: 20)

                // Статистика
                statsBar
                    .padding(.horizontal)

                // Кнопки действий
                actionButtons
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }

            // Меню действий
            if showActionMenu {
                ActionMenuView(isPresented: $showActionMenu)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showActionMenu)
    }

    // MARK: - Background

    private var backgroundView: some View {
        Group {
            if let monkey = gameManager.currentMonkey {
                habitatBackground(for: monkey.habitatStyle)
            } else {
                LinearGradient(
                    colors: [.green.opacity(0.4), .mint.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .ignoresSafeArea()
    }

    private func habitatBackground(for style: HabitatStyle) -> some View {
        LinearGradient(
            colors: habitatColors(for: style),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func habitatColors(for style: HabitatStyle) -> [Color] {
        switch style {
        case .jungle:
            return [.green.opacity(0.7), .mint.opacity(0.5), .green.opacity(0.4)]
        case .treehouse:
            return [.brown.opacity(0.5), .orange.opacity(0.3), .green.opacity(0.5)]
        case .cave:
            return [.gray.opacity(0.6), .indigo.opacity(0.4), .brown.opacity(0.4)]
        case .bambooForest:
            return [.green.opacity(0.6), .mint.opacity(0.6), .cyan.opacity(0.4)]
        case .tropical:
            return [.cyan.opacity(0.5), .teal.opacity(0.5), .green.opacity(0.6)]
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            if let monkey = gameManager.currentMonkey {
                // Информация о питомце
                VStack(alignment: .leading, spacing: 4) {
                    Text(monkey.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        // Уровень
                        Label("\(monkey.level)", systemImage: "star.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.blue.gradient, in: Capsule())

                        // Настроение
                        Text(monkey.mood.emoji)
                            .font(.title3)
                    }
                }

                Spacer()

                // Монеты
                Label {
                    Text("\(monkey.coins)")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                } icon: {
                    Text("🍌")
                        .font(.title3)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: Capsule())
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)

                // Стадия роста
                Text(monkey.stage.rawValue)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: Capsule())
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Character

    private func monkeyCharacterView(monkey: Monkey) -> some View {
        ZStack {
            // Тень персонажа
            Circle()
                .fill(.black.opacity(0.1))
                .frame(width: 200, height: 40)
                .blur(radius: 15)
                .offset(y: 120)

            // Персонаж с эффектами
            VStack(spacing: 0) {
                Text(monkeyEmoji(for: monkey.type))
                    .font(.system(size: 120))
                    .scaleEffect(monkey.stage.sizeMultiplier * (petAnimation ? 1.1 : 1.0))
                    .shadow(color: monkey.type.primaryColor.opacity(0.3), radius: 20)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.interactiveSpring()) {
                                    dragOffset = value.translation
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    dragOffset = .zero
                                }
                            }
                    )
                    .onTapGesture {
                        petMonkey()
                    }

                // Индикатор сна
                if monkey.isSleeping {
                    HStack(spacing: 4) {
                        Text("💤")
                        Text("💤")
                            .opacity(0.6)
                        Text("💤")
                            .opacity(0.3)
                    }
                    .font(.title)
                    .offset(x: 50, y: -80)
                }
            }

            // Экипированные предметы
            ForEach(Array(monkey.equippedItems.values), id: \.id) { item in
                Text(item.iconName)
                    .font(.title)
                    .offset(itemOffset(for: item.slot))
                    .shadow(radius: 2)
            }
        }
        .frame(height: 280)
    }

    private func itemOffset(for slot: ItemSlot?) -> CGSize {
        guard let slot = slot else { return .zero }
        switch slot {
        case .head: return CGSize(width: 0, height: -90)
        case .body: return CGSize(width: 0, height: 0)
        case .hands: return CGSize(width: 70, height: 20)
        case .feet: return CGSize(width: 0, height: 90)
        case .accessory1: return CGSize(width: -70, height: -50)
        case .accessory2: return CGSize(width: 70, height: -50)
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

        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            petAnimation = true
        }

        monkey.stats.happiness = min(monkey.stats.happiness + 2, 100)
        HapticManager.shared.petFeedback()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                petAnimation = false
            }
        }
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        VStack(spacing: 12) {
            if let monkey = gameManager.currentMonkey {
                ModernStatBar(
                    icon: "heart.fill",
                    label: "Здоровье",
                    value: monkey.stats.health,
                    color: .red,
                    gradient: Gradient(colors: [.red, .pink])
                )

                ModernStatBar(
                    icon: "fork.knife",
                    label: "Сытость",
                    value: 100 - monkey.stats.hunger,
                    color: .orange,
                    gradient: Gradient(colors: [.orange, .yellow])
                )

                ModernStatBar(
                    icon: "face.smiling",
                    label: "Счастье",
                    value: monkey.stats.happiness,
                    color: .yellow,
                    gradient: Gradient(colors: [.yellow, .orange])
                )

                ModernStatBar(
                    icon: "bolt.fill",
                    label: "Энергия",
                    value: monkey.stats.energy,
                    color: .blue,
                    gradient: Gradient(colors: [.blue, .cyan])
                )

                ModernStatBar(
                    icon: "sparkles",
                    label: "Чистота",
                    value: monkey.stats.cleanliness,
                    color: .cyan,
                    gradient: Gradient(colors: [.cyan, .mint])
                )
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            ModernActionButton(
                icon: "fork.knife.circle.fill",
                color: .orange,
                gradient: Gradient(colors: [.orange, .red])
            ) {
                withAnimation {
                    showActionMenu = true
                }
            }

            ModernActionButton(
                icon: "gamecontroller.fill",
                color: .purple,
                gradient: Gradient(colors: [.purple, .pink])
            ) {
                gameManager.playWithMonkey()
            }

            ModernActionButton(
                icon: monkey.isSleeping ? "moon.zzz.fill" : "bed.double.fill",
                color: .indigo,
                gradient: Gradient(colors: [.indigo, .blue])
            ) {
                if let monkey = gameManager.currentMonkey {
                    if monkey.isSleeping {
                        gameManager.wakeMonkey()
                    } else {
                        gameManager.putMonkeyToSleep()
                    }
                }
            }

            ModernActionButton(
                icon: "shower.fill",
                color: .cyan,
                gradient: Gradient(colors: [.cyan, .teal])
            ) {
                gameManager.cleanMonkey()
            }
        }
        .padding(.vertical, 8)
    }

    private var monkey: Monkey? {
        gameManager.currentMonkey
    }
}

// MARK: - Modern Components

struct ModernStatBar: View {
    let icon: String
    let label: String
    let value: Double
    let color: Color
    let gradient: Gradient

    var body: some View {
        HStack(spacing: 12) {
            // Иконка
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color.gradient)
                .frame(width: 24)

            // Название
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .frame(width: 80, alignment: .leading)

            // Прогресс бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Фон
                    Capsule()
                        .fill(.quaternary)

                    // Заполнение
                    Capsule()
                        .fill(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * (value / 100))
                }
            }
            .frame(height: 8)

            // Значение
            Text("\(Int(value))")
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

struct ModernActionButton: View {
    let icon: String
    let color: Color
    let gradient: Gradient
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.shared.impact(style: .medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .shadow(color: color.opacity(0.3), radius: isPressed ? 2 : 8, y: isPressed ? 1 : 4)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Action Menu

struct ActionMenuView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ZStack {
            // Затемнённый фон
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }

            // Меню
            VStack(spacing: 0) {
                // Заголовок
                HStack {
                    Text("Чем покормить?")
                        .font(.title3.weight(.bold))

                    Spacer()

                    Button {
                        withAnimation {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)

                Divider()

                // Список еды
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 100), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(FoodType.allCases, id: \.self) { food in
                            ModernFoodCard(food: food) {
                                gameManager.feedMonkey(food: food)
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 20)
            .padding(20)
        }
    }
}

struct ModernFoodCard: View {
    let food: FoodType
    let action: () -> Void
    @EnvironmentObject var gameManager: GameManager

    private var canAfford: Bool {
        guard let monkey = gameManager.currentMonkey else { return false }
        return monkey.coins >= food.cost
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(food.icon)
                    .font(.system(size: 44))

                Text(food.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Text("🍌")
                        .font(.caption2)
                    Text("\(food.cost)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(canAfford ? .green : .red)
                }
            }
            .frame(width: 100, height: 110)
            .background(
                canAfford ? Color.green.opacity(0.1) : Color.gray.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(canAfford ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .disabled(!canAfford)
        .buttonStyle(.plain)
    }
}

#Preview {
    MainGameView()
        .environmentObject(GameManager.shared)
}
