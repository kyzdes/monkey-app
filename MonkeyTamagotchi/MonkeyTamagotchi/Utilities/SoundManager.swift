import AVFoundation
import Foundation

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var musicPlayer: AVAudioPlayer?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Sound Effects

    func playSound(_ soundName: String, volume: Float = 1.0) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()

            audioPlayers[soundName] = player
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

    // MARK: - Music

    func playBackgroundMusic(_ musicName: String, volume: Float = 0.5) {
        guard let path = Bundle.main.path(forResource: musicName, ofType: "mp3") else {
            print("Music file not found: \(musicName)")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.volume = volume
            musicPlayer?.numberOfLoops = -1 // Loop indefinitely
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Failed to play music: \(error)")
        }
    }

    func stopBackgroundMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func setMusicVolume(_ volume: Float) {
        musicPlayer?.volume = volume
    }

    // MARK: - Game-specific sounds

    func playFeedSound() {
        playSound("feed", volume: 0.7)
    }

    func playPlaySound() {
        playSound("play", volume: 0.7)
    }

    func playCleanSound() {
        playSound("clean", volume: 0.7)
    }

    func playSleepSound() {
        playSound("sleep", volume: 0.5)
    }

    func playLevelUpSound() {
        playSound("levelup", volume: 0.8)
    }

    func playAchievementSound() {
        playSound("achievement", volume: 0.8)
    }

    func playPetSound() {
        playSound("pet", volume: 0.6)
    }

    func playMonkeySound(for type: MonkeyType) {
        switch type {
        case .gorilla:
            playSound("gorilla_sound", volume: 0.7)
        case .orangutan:
            playSound("orangutan_sound", volume: 0.7)
        case .baboon:
            playSound("baboon_sound", volume: 0.7)
        case .gibbon:
            playSound("gibbon_sound", volume: 0.7)
        }
    }
}
