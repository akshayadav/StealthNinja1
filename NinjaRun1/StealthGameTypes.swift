//
//  StealthGameTypes.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import SpriteKit

/// Enum representing the current state of the ninja
enum StealthNinjaState {
    case idle
    case moving
    case hiding
    case detected
}

/// Enum representing the overall game state
enum StealthGamePlayState {
    case playing
    case paused
    case completed
    case failed
}

/// Soothing pastel color palette inspired by Stardew Valley
struct PastelPalette {
    static let sageGreen    = SKColor(red: 0.55, green: 0.73, blue: 0.55, alpha: 1)
    static let warmCream    = SKColor(red: 0.98, green: 0.95, blue: 0.87, alpha: 1)
    static let softPeach    = SKColor(red: 0.98, green: 0.80, blue: 0.72, alpha: 1)
    static let lavender     = SKColor(red: 0.75, green: 0.70, blue: 0.85, alpha: 1)
    static let skyBlue      = SKColor(red: 0.68, green: 0.85, blue: 0.95, alpha: 1)
    static let dustyRose    = SKColor(red: 0.85, green: 0.65, blue: 0.68, alpha: 1)
    static let warmBrown    = SKColor(red: 0.60, green: 0.48, blue: 0.35, alpha: 1)
    static let softGold     = SKColor(red: 0.92, green: 0.82, blue: 0.55, alpha: 1)
    static let darkPanel    = SKColor(red: 0.25, green: 0.22, blue: 0.20, alpha: 0.75)
    static let safeGreen    = SKColor(red: 0.45, green: 0.78, blue: 0.50, alpha: 1)
}
