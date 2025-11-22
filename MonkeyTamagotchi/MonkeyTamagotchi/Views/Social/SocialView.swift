import SwiftUI

struct SocialView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Друзья").tag(0)
                    Text("Достижения").tag(1)
                    Text("Задания").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    FriendsListView()
                } else if selectedTab == 1 {
                    AchievementsView()
                } else {
                    DailyTasksView()
                }
            }
            .navigationTitle("Социальное")
        }
    }
}

struct FriendsListView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.2.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
                .padding()

            Text("Друзья")
                .font(.title2)
                .fontWeight(.bold)

            Text("Социальные функции будут доступны в следующем обновлении")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()

            Text("Скоро вы сможете:")
                .font(.headline)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "person.2.fill", text: "Добавлять друзей")
                FeatureRow(icon: "gift.fill", text: "Обмениваться подарками")
                FeatureRow(icon: "gamecontroller.fill", text: "Играть вместе")
                FeatureRow(icon: "heart.fill", text: "Лайкать питомцев друзей")
            }
            .padding()

            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            Text(text)
                .font(.subheadline)
        }
    }
}

struct AchievementsView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                statsHeader

                ForEach(gameManager.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding()
        }
    }

    private var statsHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 30) {
                StatItem(
                    icon: "trophy.fill",
                    value: "\(gameManager.achievements.filter { $0.isUnlocked }.count)",
                    label: "Достижений"
                )

                StatItem(
                    icon: "star.fill",
                    value: "\(gameManager.currentMonkey?.level ?? 0)",
                    label: "Уровень"
                )

                StatItem(
                    icon: "flame.fill",
                    value: "\(gameManager.currentMonkey?.age ?? 0)",
                    label: "Дней"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)

                Text(achievement.icon)
                    .font(.system(size: 30))
                    .grayscale(achievement.isUnlocked ? 0 : 1)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress, total: achievement.requirement.progressTarget)
                        .tint(.blue)

                    Text("\(Int(achievement.progress)) / \(Int(achievement.requirement.progressTarget))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Разблокировано!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            if !achievement.isUnlocked {
                VStack {
                    Text("🍌")
                    Text("\(achievement.reward)")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .opacity(achievement.isUnlocked ? 1.0 : 0.8)
    }
}

struct DailyTasksView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if gameManager.dailyTasks.isEmpty {
                    EmptyTasksView()
                } else {
                    ForEach(gameManager.dailyTasks) { task in
                        DailyTaskCard(task: task)
                    }
                }
            }
            .padding()
        }
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Все задания выполнены!")
                .font(.title2)
                .fontWeight(.bold)

            Text("Приходите завтра за новыми заданиями")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct DailyTaskCard: View {
    let task: DailyTask

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)

                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    VStack {
                        Text("🍌")
                        Text("\(task.reward)")
                            .font(.caption)
                    }
                }
            }

            if !task.isCompleted {
                VStack(alignment: .leading, spacing: 5) {
                    ProgressView(value: task.progressPercent)
                        .tint(.blue)

                    Text("\(task.progress) / \(task.targetProgress)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(task.isCompleted ? Color.green.opacity(0.1) : Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
