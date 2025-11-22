import Foundation
import AVFoundation
import SwiftUI

// MARK: - Audio System

struct AudioTrack: Identifiable {
    let id: String
    let name: String
    let category: AudioCategory
    let filename: String
    var duration: TimeInterval
    var volume: Float

    enum AudioCategory: String, CaseIterable {
        case music = "Музыка"
        case sfx = "Звуковые эффекты"
        case voice = "Голос"
        case ambient = "Окружение"

        var icon: String {
            switch self {
            case .music: return "music.note"
            case .sfx: return "waveform"
            case .voice: return "person.wave.2"
            case .ambient: return "sparkles"
            }
        }
    }
}

struct AdaptiveMusic {
    var currentTrack: MusicTrack
    var mood: Mood
    var location: Location
    var timeOfDay: TimeOfDay
    var intensity: Float // 0.0 - 1.0

    enum MusicTrack: String, CaseIterable {
        case jungle_calm = "Спокойные джунгли"
        case jungle_active = "Активные джунгли"
        case home_cozy = "Уютный дом"
        case adventure = "Приключение"
        case battle = "Битва"
        case celebration = "Праздник"
        case night = "Ночь"
        case morning = "Утро"

        var filename: String {
            "\(self.rawValue).mp3"
        }

        var mood: Mood {
            switch self {
            case .jungle_calm, .home_cozy, .night: return .calm
            case .jungle_active, .adventure, .morning: return .energetic
            case .battle: return .excited
            case .celebration: return .happy
            }
        }

        var baseVolume: Float {
            switch self {
            case .jungle_calm, .night: return 0.5
            case .jungle_active, .adventure: return 0.7
            case .battle: return 0.9
            case .celebration: return 0.8
            case .home_cozy, .morning: return 0.6
            }
        }
    }

    enum Location: String {
        case home = "Дом"
        case jungle = "Джунгли"
        case social = "Социальная зона"
        case minigame = "Мини-игра"
        case shop = "Магазин"
    }

    enum TimeOfDay: String {
        case dawn = "Рассвет"
        case morning = "Утро"
        case afternoon = "День"
        case evening = "Вечер"
        case night = "Ночь"

        static func current() -> TimeOfDay {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 5...7: return .dawn
            case 8...11: return .morning
            case 12...17: return .afternoon
            case 18...20: return .evening
            default: return .night
            }
        }

        var ambientSounds: [String] {
            switch self {
            case .dawn: return ["birds_chirping", "morning_breeze"]
            case .morning: return ["birds_singing", "wind_rustle"]
            case .afternoon: return ["jungle_sounds", "water_flowing"]
            case .evening: return ["crickets", "evening_birds"]
            case .night: return ["night_sounds", "owl_hooting"]
            }
        }
    }

    mutating func adaptToContext(mood: Mood, location: Location) {
        self.mood = mood
        self.location = location

        // Select appropriate track based on context
        currentTrack = selectTrack(for: mood, location: location, time: timeOfDay)
    }

    private func selectTrack(for mood: Mood, location: Location, time: TimeOfDay) -> MusicTrack {
        switch (location, time, mood) {
        case (.home, .night, _):
            return .night
        case (.home, .morning, _):
            return .morning
        case (.home, _, .calm):
            return .home_cozy
        case (.jungle, _, .calm):
            return .jungle_calm
        case (.jungle, _, .energetic):
            return .jungle_active
        case (.minigame, _, _):
            return .battle
        case (.social, _, .happy):
            return .celebration
        case (_, _, .excited):
            return .adventure
        default:
            return .jungle_calm
        }
    }

    func calculateVolume() -> Float {
        var volume = currentTrack.baseVolume
        volume *= intensity
        return min(max(volume, 0.0), 1.0)
    }
}

// MARK: - Sound Effects

struct SoundEffect: Identifiable {
    let id: String
    let name: String
    let type: SFXType
    let filename: String
    var volume: Float

    enum SFXType: String, CaseIterable {
        case ui = "UI"
        case action = "Действие"
        case notification = "Уведомление"
        case achievement = "Достижение"
        case error = "Ошибка"

        var defaultVolume: Float {
            switch self {
            case .ui: return 0.5
            case .action: return 0.7
            case .notification: return 0.8
            case .achievement: return 1.0
            case .error: return 0.6
            }
        }
    }

    static let allSFX = [
        // UI sounds
        SoundEffect(id: "tap", name: "Тап", type: .ui, filename: "tap.wav", volume: 0.5),
        SoundEffect(id: "swipe", name: "Свайп", type: .ui, filename: "swipe.wav", volume: 0.4),
        SoundEffect(id: "button", name: "Кнопка", type: .ui, filename: "button.wav", volume: 0.6),

        // Action sounds
        SoundEffect(id: "feed", name: "Кормление", type: .action, filename: "feed.wav", volume: 0.7),
        SoundEffect(id: "play", name: "Игра", type: .action, filename: "play.wav", volume: 0.7),
        SoundEffect(id: "clean", name: "Чистка", type: .action, filename: "clean.wav", volume: 0.7),

        // Notification sounds
        SoundEffect(id: "alert", name: "Оповещение", type: .notification, filename: "alert.wav", volume: 0.8),
        SoundEffect(id: "message", name: "Сообщение", type: .notification, filename: "message.wav", volume: 0.7),

        // Achievement sounds
        SoundEffect(id: "level_up", name: "Новый уровень", type: .achievement, filename: "level_up.wav", volume: 1.0),
        SoundEffect(id: "achievement", name: "Достижение", type: .achievement, filename: "achievement.wav", volume: 1.0),
        SoundEffect(id: "coin", name: "Монета", type: .achievement, filename: "coin.wav", volume: 0.6),

        // Error sounds
        SoundEffect(id: "error", name: "Ошибка", type: .error, filename: "error.wav", volume: 0.6),
        SoundEffect(id: "fail", name: "Провал", type: .error, filename: "fail.wav", volume: 0.5)
    ]
}

// MARK: - Monkey Voice

struct MonkeyVoice {
    let monkeyType: MonkeyType
    var pitch: Float // 0.5 - 2.0
    var speed: Float // 0.5 - 2.0

    enum VoiceEmotion: String, CaseIterable {
        case happy = "Счастливый"
        case sad = "Грустный"
        case excited = "Возбужденный"
        case tired = "Усталый"
        case angry = "Злой"
        case playful = "Игривый"

        var soundFile: String {
            "monkey_\(self.rawValue).wav"
        }

        var pitchModifier: Float {
            switch self {
            case .happy: return 1.2
            case .sad: return 0.8
            case .excited: return 1.5
            case .tired: return 0.7
            case .angry: return 1.1
            case .playful: return 1.3
            }
        }
    }

    func voiceSettings(for emotion: VoiceEmotion) -> (pitch: Float, speed: Float) {
        let emotionPitch = emotion.pitchModifier
        let finalPitch = pitch * emotionPitch

        return (pitch: finalPitch, speed: speed)
    }

    static func forType(_ type: MonkeyType) -> MonkeyVoice {
        switch type {
        case .gorilla:
            return MonkeyVoice(pitch: 0.7, speed: 0.8) // Deep, slow
        case .orangutan:
            return MonkeyVoice(pitch: 0.9, speed: 0.9) // Medium
        case .baboon:
            return MonkeyVoice(pitch: 1.2, speed: 1.3) // Higher, faster
        case .gibbon:
            return MonkeyVoice(pitch: 1.5, speed: 1.2) // High, moderate
        case .marmoset:
            return MonkeyVoice(pitch: 1.6, speed: 1.5) // Very high, fast
        case .macaque:
            return MonkeyVoice(pitch: 1.1, speed: 1.0) // Slightly high
        case .tamarin:
            return MonkeyVoice(pitch: 1.7, speed: 1.4) // Very high
        case .capuchin:
            return MonkeyVoice(pitch: 1.3, speed: 1.2) // High, moderate
        case .howler:
            return MonkeyVoice(pitch: 0.6, speed: 0.7) // Very deep, slow
        case .golden:
            return MonkeyVoice(pitch: 1.4, speed: 1.0) // High, normal
        }
    }
}

// MARK: - Audio Settings

struct AudioSettings: Codable {
    var masterVolume: Float
    var musicVolume: Float
    var sfxVolume: Float
    var voiceVolume: Float
    var ambientVolume: Float

    var musicEnabled: Bool
    var sfxEnabled: Bool
    var voiceEnabled: Bool
    var ambientEnabled: Bool

    var spatialAudioEnabled: Bool
    var adaptiveMusicEnabled: Bool

    static let `default` = AudioSettings(
        masterVolume: 0.8,
        musicVolume: 0.7,
        sfxVolume: 0.8,
        voiceVolume: 0.6,
        ambientVolume: 0.4,
        musicEnabled: true,
        sfxEnabled: true,
        voiceEnabled: true,
        ambientEnabled: true,
        spatialAudioEnabled: false,
        adaptiveMusicEnabled: true
    )

    func effectiveVolume(for category: AudioTrack.AudioCategory) -> Float {
        let categoryVolume: Float
        let categoryEnabled: Bool

        switch category {
        case .music:
            categoryVolume = musicVolume
            categoryEnabled = musicEnabled
        case .sfx:
            categoryVolume = sfxVolume
            categoryEnabled = sfxEnabled
        case .voice:
            categoryVolume = voiceVolume
            categoryEnabled = voiceEnabled
        case .ambient:
            categoryVolume = ambientVolume
            categoryEnabled = ambientEnabled
        }

        return categoryEnabled ? (masterVolume * categoryVolume) : 0.0
    }
}

// MARK: - Spatial Audio

struct SpatialAudioSource {
    let id: UUID
    var position: SIMD3<Float>
    var sound: AudioTrack
    var isPlaying: Bool

    func distanceFrom(listener: SIMD3<Float>) -> Float {
        return distance(position, listener)
    }

    func calculateVolume(listenerPosition: SIMD3<Float>) -> Float {
        let dist = distanceFrom(listener: listenerPosition)
        let maxDistance: Float = 10.0

        if dist >= maxDistance {
            return 0.0
        }

        // Inverse square law for volume falloff
        let volume = 1.0 - (dist / maxDistance)
        return volume * volume
    }
}

// MARK: - Playlist

struct Playlist: Identifiable, Codable {
    let id = UUID()
    var name: String
    var tracks: [String] // Track IDs
    var shuffled: Bool
    var looping: Bool
    var currentIndex: Int

    mutating func next() -> String? {
        guard !tracks.isEmpty else { return nil }

        if shuffled {
            currentIndex = Int.random(in: 0..<tracks.count)
        } else {
            currentIndex = (currentIndex + 1) % tracks.count
        }

        return tracks[currentIndex]
    }

    static let ambient = Playlist(
        name: "Ambient Jungle",
        tracks: ["jungle_calm", "forest_sounds", "water_flowing"],
        shuffled: false,
        looping: true,
        currentIndex: 0
    )

    static let upbeat = Playlist(
        name: "Upbeat",
        tracks: ["jungle_active", "adventure", "celebration"],
        shuffled: true,
        looping: true,
        currentIndex: 0
    )
}
