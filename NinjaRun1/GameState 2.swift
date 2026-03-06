//
//  GameState.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import Foundation

/// Enum representing the current state of the ninja
enum NinjaState {
    case idle
    case moving
    case hiding
    case detected
}

/// Enum representing the overall game state
enum GamePlayState {
    case playing
    case paused
    case completed
    case failed
}
