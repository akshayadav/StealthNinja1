# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Stealth Ninja** is an iOS portrait-mode stealth game built with SpriteKit. The player controls a ninja moving from Point A to Point B while avoiding detection by patrolling NPCs. Core mechanic: tap-and-hold to move, release to hide.

## Build & Run

This is an Xcode project. There is no CLI build script.

- **Run:** Open `NinjaRun1.xcodeproj` in Xcode, select an iPhone simulator, press `Cmd+R`
- **Test:** `Cmd+U` in Xcode (unit and UI tests exist but are minimal stubs)
- **Deployment target:** iOS 15+, Swift 5.7+, portrait orientation only

## Architecture

### Core Game Loop

`GameScene.swift` is the central orchestrator. It owns and coordinates all game objects, handles touch input, runs the detection check loop in `update()`, and manages the camera follow system. All game objects are added to a `worldNode` (for camera-relative scrolling), while UI elements are attached to `cameraNode`.

### Node Classes

| Class | File | Role |
|---|---|---|
| `StealthNinjaCharacter` | `StealthNinjaCharacter.swift` | Player SKSpriteNode; tracks `currentHidingPointIndex`, `targetHidingPointIndex`, `isInHidingZone`; manages standing/running animations |
| `StealthNPCCharacter` | `StealthNPCCharacter.swift` | Enemy/civilian SKSpriteNode; owns its own patrol actions, vision cone (`SKShapeNode`), and a `detectionAccumulator` that fills based on `detectionSensitivity` (1–10) |
| `StealthHidingPoint` | `StealthHidingPoint.swift` | Safe zone SKSpriteNode; `isLightDependent` controls border color (yellow vs. green) |

### State Enums (`StealthGameTypes.swift`)

- `StealthNinjaState`: `.idle`, `.moving`, `.hiding`, `.detected`
- `StealthGamePlayState`: `.playing`, `.paused`, `.completed`, `.failed`

### Level System

- `LevelData.swift` — `LevelData` struct (hiding points, NPC configs, level dimensions) + `LevelManager` singleton with levels 1–3
- `LevelDataExtended.swift` — Extension on `LevelManager` adding levels 4–6 in a `levelDatabase` dictionary, plus `generateProceduralLevel()` for any level beyond 6
- To add a new level: implement `createLevel7()` in `LevelDataExtended.swift` and register it in `levelDatabase`

### NPC Detection

`NPCConfig.detectionSensitivity` (1–10) maps to a `detectionThreshold` in seconds: `2.1 - (sensitivity * 0.2)`. Each frame the ninja is in a NPC's vision cone, `detectionAccumulator` increments; when it exceeds `detectionThreshold`, detection triggers.

### Sprite Assets

Sprites live in `Assets.xcassets`. All node classes fall back gracefully to colored shapes if a texture is missing.

| Asset name | Used by |
|---|---|
| `SouthStanding` | Ninja idle |
| `EastAnimation1`–`EastAnimation6` | Ninja run animation frames |
| `guard` | Hostile NPC |
| `civilian` | Neutral NPC |
| `hidingspot` | `StealthHidingPoint` |

### Deprecated Files (kept to avoid build conflicts, do not use)

- `GameState.swift` — replaced by `StealthGameTypes.swift`
- `NinjaNode.swift` — replaced by `StealthNinjaCharacter.swift`
- `NPCNode.swift` — replaced by `StealthNPCCharacter.swift`
- `HidingPoint.swift` — replaced by `StealthHidingPoint.swift`
- `GameState 2.swift`, `NinjaNode 2.swift`, `NPCNode 2.swift` — duplicate stubs, ignore
