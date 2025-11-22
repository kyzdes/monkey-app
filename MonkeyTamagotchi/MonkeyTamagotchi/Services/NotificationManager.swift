import Foundation
import Combine
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }

    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval, identifier: String) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Game-specific notifications

    func scheduleHungerNotification(monkeyName: String) {
        scheduleNotification(
            title: "\(monkeyName) голоден!",
            body: "Пора покормить вашего питомца",
            timeInterval: 3600, // 1 час
            identifier: "hunger_notification"
        )
    }

    func scheduleEnergyNotification(monkeyName: String) {
        scheduleNotification(
            title: "\(monkeyName) устал",
            body: "Ваш питомец нуждается в отдыхе",
            timeInterval: 7200, // 2 часа
            identifier: "energy_notification"
        )
    }

    func scheduleCleanlinessNotification(monkeyName: String) {
        scheduleNotification(
            title: "\(monkeyName) нуждается в купании",
            body: "Пора помыть вашего питомца",
            timeInterval: 10800, // 3 часа
            identifier: "cleanliness_notification"
        )
    }

    func schedulePlayNotification(monkeyName: String) {
        scheduleNotification(
            title: "\(monkeyName) скучает!",
            body: "Поиграйте с вашим питомцем",
            timeInterval: 14400, // 4 часа
            identifier: "play_notification"
        )
    }

    func scheduleDailyTasksNotification() {
        scheduleNotification(
            title: "Новые ежедневные задания!",
            body: "Выполните задания и получите награды",
            timeInterval: 86400, // 24 часа
            identifier: "daily_tasks_notification"
        )
    }
}
