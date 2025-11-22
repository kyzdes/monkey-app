import UIKit

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // Game-specific haptic patterns

    func playFeedback() {
        impact(style: .light)
    }

    func feedFeedback() {
        impact(style: .medium)
    }

    func cleanFeedback() {
        impact(style: .medium)
    }

    func sleepFeedback() {
        impact(style: .soft)
    }

    func levelUpFeedback() {
        notification(type: .success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impact(style: .heavy)
        }
    }

    func achievementFeedback() {
        notification(type: .success)
    }

    func petFeedback() {
        impact(style: .light)
    }
}
