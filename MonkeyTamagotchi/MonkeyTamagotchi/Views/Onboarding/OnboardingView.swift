import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedType: MonkeyType = .gorilla
    @State private var monkeyName: String = ""
    @State private var showNameInput = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                if !showNameInput {
                    monkeySelectionView
                } else {
                    nameInputView
                }
            }
            .padding()
        }
    }

    private var monkeySelectionView: some View {
        VStack(spacing: 30) {
            Text("Выберите своего питомца")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(MonkeyType.allCases, id: \.self) { type in
                        MonkeyCardView(
                            type: type,
                            isSelected: selectedType == type
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedType = type
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(selectedType.rawValue)
                    .font(.title)
                    .fontWeight(.bold)

                Text(selectedType.description)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                Text(selectedType.specialAbility)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 5)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)

            Button(action: {
                withAnimation {
                    showNameInput = true
                    HapticManager.shared.impact(style: .medium)
                }
            }) {
                Text("Выбрать")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedType.primaryColor)
                    .cornerRadius(15)
            }
        }
    }

    private var nameInputView: some View {
        VStack(spacing: 30) {
            Text("Дайте имя питомцу")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text(selectedType.rawValue)
                .font(.system(size: 80))
                .scaleEffect(1.2)

            TextField("Имя питомца", text: $monkeyName)
                .font(.title2)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(15)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()

            VStack(spacing: 15) {
                Button(action: {
                    if !monkeyName.isEmpty {
                        gameManager.createMonkey(name: monkeyName, type: selectedType)
                        HapticManager.shared.notification(type: .success)
                    }
                }) {
                    Text("Начать приключение!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(monkeyName.isEmpty ? Color.gray : selectedType.primaryColor)
                        .cornerRadius(15)
                }
                .disabled(monkeyName.isEmpty)

                Button(action: {
                    withAnimation {
                        showNameInput = false
                        HapticManager.shared.impact(style: .light)
                    }
                }) {
                    Text("Назад")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

struct MonkeyCardView: View {
    let type: MonkeyType
    let isSelected: Bool

    var body: some View {
        VStack {
            Text(monkeyEmoji)
                .font(.system(size: 80))
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.spring(), value: isSelected)

            Text(type.rawValue)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 150, height: 180)
        .background(isSelected ? type.primaryColor : Color.white.opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
        )
        .shadow(color: isSelected ? type.primaryColor.opacity(0.5) : .clear, radius: 10)
    }

    private var monkeyEmoji: String {
        switch type {
        case .gorilla: return "🦍"
        case .orangutan: return "🦧"
        case .baboon: return "🐵"
        case .gibbon: return "🐒"
        }
    }
}
