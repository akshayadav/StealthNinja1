# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Stealth Ninja** is an iOS portrait-mode stealth game built with SpriteKit. The player controls a ninja moving from Point A to Point B while avoiding detection by patrolling NPCs. Core mechanic: tap-and-hold to move, release to hide.

## Build & Run

This is an Xcode project using `PBXFileSystemSynchronizedRootGroup` — new files in `NinjaRun1/` are auto-discovered by Xcode (no pbxproj editing needed).

- **Run:** Open `NinjaRun1.xcodeproj` in Xcode, select an iPhone simulator, press `Cmd+R`
- **CLI Build:** `xcodebuild -project NinjaRun1.xcodeproj -scheme NinjaRun1 -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- **Test:** `Cmd+U` in Xcode (unit and UI tests exist but are minimal stubs)
- **Deployment target:** iOS 15+, Swift 5.7+, portrait orientation only

## Architecture

### Scene Flow

`GameViewController` → `MainMenuScene` → `GameScene` (gameplay) / `LevelSelectScene` / `SettingsScene`

### Core Files

| File | Lines | Role |
|------|-------|------|
| `GameScene.swift` | ~510 | Thin orchestrator: setup, game logic, touch handling, update loop |
| `GameScene+Background.swift` | ~1240 | All 8 theme background renderers + props + markers |
| `GameScene+HUD.swift` | ~310 | HUD setup, detection indicator, progress bar updates |
| `GameScene+AmbientLife.swift` | ~525 | Ambient life system: butterflies, cats, chickens, owls, etc. |
| `StealthNPCCharacter.swift` | 539 | NPC node: patrol, detection, vision cone |
| `StealthNinjaCharacter.swift` | 227 | Player character node |
| `StealthHidingPoint.swift` | 146 | Safe zone node |
| `LevelData.swift` | 325 | Level structs, configs, levels 1-3, NPCType/NPCBehavior enums |
| `LevelDataExtended.swift` | 446 | Levels 4-7 + procedural generation |
| `StealthGameTypes.swift` | 39 | Enums + PastelPalette colors |
| `MainMenuScene.swift` | ~220 | Title screen with Play/LevelSelect/Settings buttons |
| `LevelSelectScene.swift` | ~210 | Scrollable level grid with lock/star states |
| `SettingsScene.swift` | ~180 | Sound/music toggles |
| `AudioManager.swift` | ~130 | Singleton audio manager (AVAudioPlayer + SKAction SFX) |
| `GameProgressManager.swift` | ~80 | UserDefaults-backed save system (stars, times, unlocks) |

### Node Classes

| Class | File | Role |
|---|---|---|
| `StealthNinjaCharacter` | `StealthNinjaCharacter.swift` | Player SKSpriteNode; tracks hiding state, 8-dir facing, walk/idle/crouch animations |
| `StealthNPCCharacter` | `StealthNPCCharacter.swift` | Enemy/civilian SKSpriteNode; owns patrol actions, vision cone, detection accumulator |
| `StealthHidingPoint` | `StealthHidingPoint.swift` | Safe zone SKSpriteNode; `isLightDependent` controls border color |

### State Enums (`StealthGameTypes.swift`)

- `StealthNinjaState`: `.idle`, `.moving`, `.hiding`, `.detected`
- `StealthGamePlayState`: `.playing`, `.paused`, `.completed`, `.failed`

### Level System

- 7 handcrafted levels across 8 themes + procedural generation for level 8+
- 10 NPC types with 7 behavior patterns
- `LevelData.swift` — struct + `LevelManager` singleton with levels 1-3
- `LevelDataExtended.swift` — levels 4-7 in `levelDatabase` + `generateProceduralLevel()`

### Level Themes

`.meadowPath` (L1-2), `.villageFarm` (L3), `.riverCrossing` (L4), `.harborTown` (L5), `.festivalGrounds` (L6), `.nightGarden` (L7), `.nightCastle`, `.sunnyVillage`

### NPC Detection

`NPCConfig.detectionSensitivity` (1–10) maps to `detectionThreshold`: `2.1 - (sensitivity * 0.2)` seconds. Each frame the ninja is in an NPC's vision cone while visible, `detectionAccumulator` increments.

### Scoring System

- `GameProgressManager` saves completion, best times, star ratings per level
- 3 stars: under par time, 2 stars: under 1.5x par, 1 star: completed
- Par time: `30 + level * 10` seconds
- Level N+1 unlocks when level N is completed

### Audio System

`AudioManager` singleton handles background music per theme and SFX. Gracefully handles missing audio files. Audio files not yet added — system is wired up and ready.

### Sprite Assets

340+ pixel art sprites in `Assets.xcassets`. All node classes fall back gracefully to colored shapes if textures are missing.

### Stale Documentation

Old .md files moved to `NinjaRun1/docs/` — not part of the build.
