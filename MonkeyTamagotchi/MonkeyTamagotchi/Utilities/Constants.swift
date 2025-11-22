import Foundation
import SwiftUI

enum Constants {
    // MARK: - App Info
    enum App {
        static let name = "Monkey Tamagotchi"
        static let version = "1.0.0"
        static let bundleIdentifier = "com.monkeytamagotchi.app"
    }

    // MARK: - Game Balance
    enum Balance {
        static let hungerIncreasePerMinute: Double = 0.5
        static let energyDecreasePerMinute: Double = 0.3
        static let cleanlinessDecreasePerMinute: Double = 0.2
        static let happinessDecreasePerMinute: Double = 0.1

        static let sleepEnergyRestorePerMinute: Double = 2.0
        static let lowHealthThreshold: Double = 40
        static let criticalHungerThreshold: Double = 80
        static let lowEnergyThreshold: Double = 30

        static let experiencePerLevel = 100
        static let coinsPerLevel = 10

        static let petHappinessBonus: Double = 2
        static let playHappinessBonus: Double = 20
        static let playEnergyCost: Double = 15
    }

    // MARK: - Notifications
    enum Notifications {
        static let hungerWarningInterval: TimeInterval = 3600 // 1 hour
        static let energyWarningInterval: TimeInterval = 7200 // 2 hours
        static let cleanlinessWarningInterval: TimeInterval = 10800 // 3 hours
        static let playReminderInterval: TimeInterval = 14400 // 4 hours
        static let dailyTasksInterval: TimeInterval = 86400 // 24 hours
    }

    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDampingFraction: Double = 0.7
    }

    // MARK: - UI
    enum UI {
        static let cornerRadius: CGFloat = 15
        static let buttonHeight: CGFloat = 50
        static let cardPadding: CGFloat = 16
        static let spacing: CGFloat = 20

        static let smallIconSize: CGFloat = 24
        static let mediumIconSize: CGFloat = 48
        static let largeIconSize: CGFloat = 80
    }

    // MARK: - Colors
    enum Colors {
        static let primaryGreen = Color(hex: "4CAF50")
        static let secondaryBlue = Color(hex: "2196F3")
        static let accentYellow = Color(hex: "FFC107")
        static let dangerRed = Color(hex: "F44336")
        static let warningOrange = Color(hex: "FF9800")
    }
}
