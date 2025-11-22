import Foundation
import SwiftUI

// MARK: - Profession System

enum Profession: String, Codable, CaseIterable {
    case musician = "Музыкант"
    case athlete = "Спортсмен"
    case explorer = "Исследователь"
    case artist = "Артист"
    case scientist = "Ученый"
    case chef = "Повар"

    var description: String {
        switch self {
        case .musician:
            return "Создает музыку и выступает на концертах"
        case .athlete:
            return "Участвует в спортивных соревнованиях"
        case .explorer:
            return "Исследует мир и находит сокровища"
        case .artist:
            return "Рисует картины и создает искусство"
        case .scientist:
            return "Проводит эксперименты и открывает новое"
        case .chef:
            return "Готовит вкусные блюда"
        }
    }

    var icon: String {
        switch self {
        case .musician: return "music.note"
        case .athlete: return "figure.run"
        case .explorer: return "location.magnifyingglass"
        case .artist: return "paintpalette"
        case .scientist: return "flask"
        case .chef: return "fork.knife"
        }
    }

    var primaryStat: String {
        switch self {
        case .musician: return "Creativity"
        case .athlete: return "Strength"
        case .explorer: return "Agility"
        case .artist: return "Creativity"
        case .scientist: return "Intelligence"
        case .chef: return "Intelligence"
        }
    }

    var color: Color {
        switch self {
        case .musician: return .purple
        case .athlete: return .red
        case .explorer: return .green
        case .artist: return .orange
        case .scientist: return .blue
        case .chef: return .yellow
        }
    }

    var unlockLevel: Int {
        switch self {
        case .musician: return 5
        case .athlete: return 5
        case .explorer: return 10
        case .artist: return 10
        case .scientist: return 15
        case .chef: return 15
        }
    }

    var dailyEarnings: Int {
        switch self {
        case .musician: return 50
        case .athlete: return 75
        case .explorer: return 100
        case .artist: return 60
        case .scientist: return 80
        case .chef: return 65
        }
    }
}

// MARK: - Career Progress

struct CareerProgress: Codable {
    var profession: Profession
    var level: Int
    var experience: Int
    var totalEarnings: Int
    var achievements: [CareerAchievement]
    var currentProject: CareerProject?

    var experienceToNextLevel: Int {
        level * 1000
    }

    var currentProgress: Double {
        Double(experience) / Double(experienceToNextLevel)
    }

    var rank: CareerRank {
        switch level {
        case 1...5: return .novice
        case 6...10: return .apprentice
        case 11...20: return .professional
        case 21...30: return .expert
        default: return .master
        }
    }

    enum CareerRank: String, Codable {
        case novice = "Новичок"
        case apprentice = "Подмастерье"
        case professional = "Профессионал"
        case expert = "Эксперт"
        case master = "Мастер"

        var bonus: Double {
            switch self {
            case .novice: return 1.0
            case .apprentice: return 1.2
            case .professional: return 1.5
            case .expert: return 2.0
            case .master: return 3.0
            }
        }
    }

    mutating func addExperience(_ amount: Int) {
        experience += amount
        while experience >= experienceToNextLevel {
            experience -= experienceToNextLevel
            level += 1
        }
    }

    mutating func completeProject() {
        guard let project = currentProject else { return }
        let earnings = Int(Double(project.reward) * rank.bonus)
        totalEarnings += earnings
        addExperience(project.experience)
        currentProject = nil
    }
}

struct CareerAchievement: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var isUnlocked: Bool
    let reward: Int

    static let musicianAchievements = [
        CareerAchievement(title: "Первый концерт", description: "Провести первое выступление", isUnlocked: false, reward: 100),
        CareerAchievement(title: "Золотой диск", description: "Записать альбом", isUnlocked: false, reward: 500),
        CareerAchievement(title: "Мировой тур", description: "Провести 50 концертов", isUnlocked: false, reward: 1000)
    ]

    static let athleteAchievements = [
        CareerAchievement(title: "Первая победа", description: "Выиграть соревнование", isUnlocked: false, reward: 100),
        CareerAchievement(title: "Чемпион", description: "Выиграть 10 соревнований", isUnlocked: false, reward: 500),
        CareerAchievement(title: "Легенда спорта", description: "Выиграть 50 соревнований", isUnlocked: false, reward: 1000)
    ]

    static let explorerAchievements = [
        CareerAchievement(title: "Первая находка", description: "Найти сокровище", isUnlocked: false, reward: 100),
        CareerAchievement(title: "Искатель приключений", description: "Посетить 20 локаций", isUnlocked: false, reward: 500),
        CareerAchievement(title: "Легендарный исследователь", description: "Найти все секреты", isUnlocked: false, reward: 1000)
    ]
}

struct CareerProject: Codable {
    let id = UUID()
    let profession: Profession
    let title: String
    let description: String
    let duration: TimeInterval
    let reward: Int
    let experience: Int
    let startDate: Date

    var isComplete: Bool {
        Date().timeIntervalSince(startDate) >= duration
    }

    var progress: Double {
        min(Date().timeIntervalSince(startDate) / duration, 1.0)
    }

    var timeRemaining: TimeInterval {
        max(duration - Date().timeIntervalSince(startDate), 0)
    }

    static func random(for profession: Profession) -> CareerProject {
        switch profession {
        case .musician:
            return CareerProject(
                profession: .musician,
                title: ["Запись песни", "Концерт", "Репетиция"].randomElement()!,
                description: "Музыкальный проект",
                duration: TimeInterval.random(in: 3600...14400),
                reward: Int.random(in: 50...200),
                experience: Int.random(in: 100...300),
                startDate: Date()
            )
        case .athlete:
            return CareerProject(
                profession: .athlete,
                title: ["Тренировка", "Соревнование", "Марафон"].randomElement()!,
                description: "Спортивное мероприятие",
                duration: TimeInterval.random(in: 3600...14400),
                reward: Int.random(in: 75...250),
                experience: Int.random(in: 150...350),
                startDate: Date()
            )
        case .explorer:
            return CareerProject(
                profession: .explorer,
                title: ["Экспедиция", "Поиск сокровищ", "Исследование"].randomElement()!,
                description: "Исследовательская миссия",
                duration: TimeInterval.random(in: 7200...21600),
                reward: Int.random(in: 100...300),
                experience: Int.random(in: 200...400),
                startDate: Date()
            )
        case .artist:
            return CareerProject(
                profession: .artist,
                title: ["Картина", "Выставка", "Перформанс"].randomElement()!,
                description: "Художественный проект",
                duration: TimeInterval.random(in: 3600...14400),
                reward: Int.random(in: 60...220),
                experience: Int.random(in: 120...320),
                startDate: Date()
            )
        case .scientist:
            return CareerProject(
                profession: .scientist,
                title: ["Эксперимент", "Исследование", "Открытие"].randomElement()!,
                description: "Научный проект",
                duration: TimeInterval.random(in: 7200...18000),
                reward: Int.random(in: 80...280),
                experience: Int.random(in: 180...380),
                startDate: Date()
            )
        case .chef:
            return CareerProject(
                profession: .chef,
                title: ["Новое блюдо", "Банкет", "Кулинарное шоу"].randomElement()!,
                description: "Кулинарный проект",
                duration: TimeInterval.random(in: 3600...10800),
                reward: Int.random(in: 65...240),
                experience: Int.random(in: 140...340),
                startDate: Date()
            )
        }
    }
}
