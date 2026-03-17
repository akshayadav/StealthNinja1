//
//  GameProgressManager.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/16/26.
//

import Foundation

class GameProgressManager {
    static let shared = GameProgressManager()

    private let defaults = UserDefaults.standard

    private let completedPrefix = "level_completed_"
    private let bestTimePrefix = "level_bestTime_"

    private init() {}

    // MARK: - Level Unlocking

    func isLevelUnlocked(_ level: Int) -> Bool {
        if level <= 1 { return true }
        return defaults.bool(forKey: "\(completedPrefix)\(level - 1)")
    }

    // MARK: - Level Completion

    func completeLevel(_ level: Int, time: TimeInterval) {
        defaults.set(true, forKey: "\(completedPrefix)\(level)")

        let existing = getBestTime(for: level)
        if existing == nil || time < existing! {
            defaults.set(time, forKey: "\(bestTimePrefix)\(level)")
        }
    }

    func isLevelCompleted(_ level: Int) -> Bool {
        return defaults.bool(forKey: "\(completedPrefix)\(level)")
    }

    // MARK: - Best Time

    func getBestTime(for level: Int) -> TimeInterval? {
        let value = defaults.double(forKey: "\(bestTimePrefix)\(level)")
        if value == 0 && !isLevelCompleted(level) {
            return nil
        }
        return value
    }

    // MARK: - Stars

    func getStars(for level: Int) -> Int {
        guard isLevelCompleted(level), let best = getBestTime(for: level) else {
            return 0
        }
        let par = parTime(for: level)
        if best <= par {
            return 3
        } else if best <= par * 1.5 {
            return 2
        } else {
            return 1
        }
    }

    func parTime(for level: Int) -> TimeInterval {
        return 30.0 + Double(level) * 10.0
    }

    // MARK: - Reset

    func resetProgress() {
        let totalLevels = LevelManager.shared.getTotalLevels()
        for level in 1...max(totalLevels, 100) {
            defaults.removeObject(forKey: "\(completedPrefix)\(level)")
            defaults.removeObject(forKey: "\(bestTimePrefix)\(level)")
        }
    }
}
