//
//  AudioManager.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/16/26.
//

import Foundation
import AVFoundation
import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private let defaults = UserDefaults.standard
    private var backgroundMusicPlayer: AVAudioPlayer?

    private init() {}

    // MARK: - Settings

    var isSoundEnabled: Bool {
        get {
            if defaults.object(forKey: "soundEnabled") == nil {
                return true
            }
            return defaults.bool(forKey: "soundEnabled")
        }
        set {
            defaults.set(newValue, forKey: "soundEnabled")
        }
    }

    var isMusicEnabled: Bool {
        get {
            if defaults.object(forKey: "musicEnabled") == nil {
                return true
            }
            return defaults.bool(forKey: "musicEnabled")
        }
        set {
            defaults.set(newValue, forKey: "musicEnabled")
            if !newValue {
                stopBackgroundMusic()
            }
        }
    }

    // MARK: - Background Music

    func playBackgroundMusic(theme: LevelData.LevelTheme) {
        guard isMusicEnabled else { return }

        let themeName: String
        switch theme {
        case .meadowPath: themeName = "music_meadow"
        case .villageFarm: themeName = "music_village"
        case .riverCrossing: themeName = "music_river"
        case .harborTown: themeName = "music_harbor"
        case .festivalGrounds: themeName = "music_festival"
        case .nightGarden: themeName = "music_night_garden"
        case .nightCastle: themeName = "music_night_castle"
        case .sunnyVillage: themeName = "music_sunny"
        }

        // Try to load the audio file; gracefully handle missing files
        guard let url = Bundle.main.url(forResource: themeName, withExtension: "mp3")
                ?? Bundle.main.url(forResource: themeName, withExtension: "m4a")
                ?? Bundle.main.url(forResource: themeName, withExtension: "wav") else {
            // Audio file not found — this is expected until audio assets are added
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = 0.3
            backgroundMusicPlayer?.play()
        } catch {
            print("AudioManager: Could not play background music - \(error.localizedDescription)")
        }
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }

    // MARK: - Sound Effects

    func playSFX(_ name: String, on node: SKNode) {
        guard isSoundEnabled else { return }

        // Gracefully handle missing sound files
        if Bundle.main.url(forResource: name, withExtension: "wav") != nil
            || Bundle.main.url(forResource: name, withExtension: "mp3") != nil
            || Bundle.main.url(forResource: name, withExtension: "m4a") != nil {

            let ext = Bundle.main.url(forResource: name, withExtension: "wav") != nil ? "wav"
                : Bundle.main.url(forResource: name, withExtension: "mp3") != nil ? "mp3" : "m4a"
            let action = SKAction.playSoundFileNamed("\(name).\(ext)", waitForCompletion: false)
            node.run(action)
        }
        // If file not found, silently do nothing
    }

    // MARK: - Convenience Methods

    func playDetectionAlert(on node: SKNode? = nil) {
        guard let node = node else { return }
        playSFX("sfx_detection_alert", on: node)
    }

    func playHideSuccess(on node: SKNode? = nil) {
        guard let node = node else { return }
        playSFX("sfx_hide_success", on: node)
    }

    func playLevelComplete(on node: SKNode? = nil) {
        guard let node = node else { return }
        playSFX("sfx_level_complete", on: node)
    }

    func playGameOver(on node: SKNode? = nil) {
        guard let node = node else { return }
        playSFX("sfx_game_over", on: node)
    }

    func playButtonTap(on node: SKNode? = nil) {
        guard let node = node else { return }
        playSFX("sfx_button_tap", on: node)
    }
}
