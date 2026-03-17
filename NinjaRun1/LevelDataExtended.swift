//
//  LevelDataExtended.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import CoreGraphics

/// Extended level system that's easy to add new levels to
extension LevelManager {
    
    /// Get level data - now supports unlimited levels!
    func getLevelDataExtended(levelNumber: Int) -> LevelData {
        // Try to get custom level first
        if let level = levelDatabase[levelNumber] {
            return level
        }
        
        // Fallback to procedural generation
        return generateProceduralLevel(levelNumber: levelNumber)
    }
    
    /// Database of custom levels (easy to add more!)
    private var levelDatabase: [Int: LevelData] {
        return [
            1: createLevel1Meadow(),
            2: createLevel2Meadow(),
            3: createLevel3Farm(),
            4: createLevel4River(),
            5: createLevel5Harbor(),
            6: createLevel6Festival(),
            7: createLevel7NightGarden(),
        ]
    }
    
    /// Get total number of levels available
    func getTotalLevels() -> Int {
        return levelDatabase.keys.max() ?? 3
    }
    
    // MARK: - Level 1: Morning Meadow (Tutorial)
    // A gentle rolling meadow with wildflowers. Just a gardener and an old dog.
    private func createLevel1Meadow() -> LevelData {
        let levelWidth: CGFloat = 2000
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 200, y: 180), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 500, y: 200), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 800, y: 170), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1200, y: 190), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1600, y: 180), size: CGSize(width: 80, height: 80), isLightDependent: false),
        ]
        let npcs = [
            // Flower gardener tending wildflowers — slow, gentle
            LevelData.NPCConfig(startPosition: CGPoint(x: 400, y: 220),
                patrolPoints: [CGPoint(x: 350, y: 220), CGPoint(x: 500, y: 240)],
                visionRange: 150, visionAngle: .pi / 3,
                isHostile: false, detectionSensitivity: 3,
                npcType: .flowerGardener, behavior: .sweeping),
            // Sleeping dog near a fence — wakes fast if close
            LevelData.NPCConfig(startPosition: CGPoint(x: 1000, y: 190),
                patrolPoints: [CGPoint(x: 980, y: 190), CGPoint(x: 1020, y: 195)],
                visionRange: 120, visionAngle: .pi / 2,
                isHostile: true, detectionSensitivity: 8,
                npcType: .sleepingDog, behavior: .sleeping),
        ]
        return LevelData(levelNumber: 1, startPosition: CGPoint(x: 100, y: 180),
            endPosition: CGPoint(x: 1800, y: 180), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .meadowPath)
    }

    // MARK: - Level 2: Meadow Stream
    // Longer meadow with a stream crossing. An elderly walker and a gardener.
    private func createLevel2Meadow() -> LevelData {
        let levelWidth: CGFloat = 2500
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 250, y: 190), size: CGSize(width: 75, height: 75), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 550, y: 210), size: CGSize(width: 75, height: 75), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 850, y: 180), size: CGSize(width: 75, height: 75), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1200, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1550, y: 190), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1900, y: 210), size: CGSize(width: 75, height: 75), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2150, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: false),
        ]
        let npcs = [
            // Elderly walker on morning stroll — slow, wide vision
            LevelData.NPCConfig(startPosition: CGPoint(x: 400, y: 230),
                patrolPoints: [CGPoint(x: 350, y: 230), CGPoint(x: 600, y: 240)],
                visionRange: 180, visionAngle: .pi / 2.5,
                isHostile: false, detectionSensitivity: 3,
                npcType: .elderlyWalker, behavior: .patrol),
            // Flower gardener at garden patch
            LevelData.NPCConfig(startPosition: CGPoint(x: 900, y: 250),
                patrolPoints: [CGPoint(x: 850, y: 240), CGPoint(x: 1000, y: 260)],
                visionRange: 160, visionAngle: .pi / 3,
                isHostile: false, detectionSensitivity: 3,
                npcType: .flowerGardener, behavior: .farming),
            // Guard dog at the bridge
            LevelData.NPCConfig(startPosition: CGPoint(x: 1400, y: 200),
                patrolPoints: [CGPoint(x: 1300, y: 200), CGPoint(x: 1500, y: 210)],
                visionRange: 150, visionAngle: .pi / 2.2,
                isHostile: true, detectionSensitivity: 7,
                npcType: .guardDog, behavior: .patrol),
        ]
        return LevelData(levelNumber: 2, startPosition: CGPoint(x: 100, y: 190),
            endPosition: CGPoint(x: 2300, y: 190), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .meadowPath)
    }

    // MARK: - Level 3: Village Farm (top-down)
    // A cozy Stardew-style farm with crop rows, a barn, and a chicken coop.
    private func createLevel3Farm() -> LevelData {
        let levelWidth: CGFloat = 2800
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 200, y: 200), size: CGSize(width: 75, height: 75), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 500, y: 240), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 850, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1200, y: 220), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1550, y: 260), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1900, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2250, y: 230), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2500, y: 190), size: CGSize(width: 70, height: 70), isLightDependent: false),
        ]
        let npcs = [
            // Farmer working in crop rows
            LevelData.NPCConfig(startPosition: CGPoint(x: 400, y: 270),
                patrolPoints: [CGPoint(x: 350, y: 260), CGPoint(x: 550, y: 290), CGPoint(x: 450, y: 310)],
                visionRange: 160, visionAngle: .pi / 2.5,
                isHostile: false, detectionSensitivity: 3,
                npcType: .villageFarmer, behavior: .farming),
            // Playing child near the barn
            LevelData.NPCConfig(startPosition: CGPoint(x: 750, y: 230),
                patrolPoints: [CGPoint(x: 700, y: 220), CGPoint(x: 800, y: 250), CGPoint(x: 750, y: 270), CGPoint(x: 700, y: 240)],
                visionRange: 130, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 4,
                npcType: .playingChild, behavior: .playing),
            // Sleeping dog outside farmhouse
            LevelData.NPCConfig(startPosition: CGPoint(x: 1100, y: 200),
                patrolPoints: [CGPoint(x: 1080, y: 200), CGPoint(x: 1120, y: 205)],
                visionRange: 110, visionAngle: .pi / 1.8,
                isHostile: true, detectionSensitivity: 9,
                npcType: .sleepingDog, behavior: .sleeping),
            // Another farmer further along
            LevelData.NPCConfig(startPosition: CGPoint(x: 1650, y: 260),
                patrolPoints: [CGPoint(x: 1600, y: 250), CGPoint(x: 1750, y: 280)],
                visionRange: 155, visionAngle: .pi / 3,
                isHostile: false, detectionSensitivity: 3,
                npcType: .villageFarmer, behavior: .farming),
            // Guard at farm exit
            LevelData.NPCConfig(startPosition: CGPoint(x: 2350, y: 230),
                patrolPoints: [CGPoint(x: 2250, y: 220), CGPoint(x: 2450, y: 240)],
                visionRange: 190, visionAngle: .pi / 2.8,
                isHostile: true, detectionSensitivity: 5,
                npcType: .samuraiGuard, behavior: .patrol),
        ]
        return LevelData(levelNumber: 3, startPosition: CGPoint(x: 100, y: 200),
            endPosition: CGPoint(x: 2600, y: 200), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .villageFarm)
    }

    // MARK: - Level 4: River Crossing (side-view)
    // Willow-lined riverbanks with wooden bridges. Fishermen sit by the water.
    private func createLevel4River() -> LevelData {
        let levelWidth: CGFloat = 2800
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 250, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 550, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 900, y: 190), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1250, y: 210), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1600, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1950, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2350, y: 190), size: CGSize(width: 70, height: 70), isLightDependent: false),
        ]
        let npcs = [
            // Fisherman sitting by the river — narrow forward vision
            LevelData.NPCConfig(startPosition: CGPoint(x: 400, y: 260),
                patrolPoints: [CGPoint(x: 390, y: 260), CGPoint(x: 410, y: 265)],
                visionRange: 170, visionAngle: .pi / 4,
                isHostile: false, detectionSensitivity: 4,
                npcType: .fisherman, behavior: .fishing),
            // Farmer walking along riverbank
            LevelData.NPCConfig(startPosition: CGPoint(x: 750, y: 230),
                patrolPoints: [CGPoint(x: 650, y: 220), CGPoint(x: 900, y: 250)],
                visionRange: 170, visionAngle: .pi / 3,
                isHostile: false, detectionSensitivity: 4,
                npcType: .villageFarmer, behavior: .patrol),
            // Guard dog patrolling the bridge
            LevelData.NPCConfig(startPosition: CGPoint(x: 1150, y: 200),
                patrolPoints: [CGPoint(x: 1050, y: 195), CGPoint(x: 1250, y: 210)],
                visionRange: 160, visionAngle: .pi / 2.2,
                isHostile: true, detectionSensitivity: 8,
                npcType: .guardDog, behavior: .patrol),
            // Another fisherman downstream
            LevelData.NPCConfig(startPosition: CGPoint(x: 1500, y: 270),
                patrolPoints: [CGPoint(x: 1490, y: 270), CGPoint(x: 1510, y: 275)],
                visionRange: 165, visionAngle: .pi / 4,
                isHostile: false, detectionSensitivity: 4,
                npcType: .fisherman, behavior: .fishing),
            // Elderly walker on the far path
            LevelData.NPCConfig(startPosition: CGPoint(x: 2100, y: 230),
                patrolPoints: [CGPoint(x: 2000, y: 220), CGPoint(x: 2250, y: 240)],
                visionRange: 190, visionAngle: .pi / 2.5,
                isHostile: false, detectionSensitivity: 3,
                npcType: .elderlyWalker, behavior: .patrol),
        ]
        return LevelData(levelNumber: 4, startPosition: CGPoint(x: 100, y: 190),
            endPosition: CGPoint(x: 2600, y: 200), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .riverCrossing)
    }

    // MARK: - Level 5: Harbor Town (top-down)
    // Fishing village with docks, market stalls, and boats.
    private func createLevel5Harbor() -> LevelData {
        let levelWidth: CGFloat = 3000
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 250, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 550, y: 220), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 900, y: 190), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1250, y: 240), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1600, y: 200), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1950, y: 230), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2300, y: 190), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2650, y: 210), size: CGSize(width: 65, height: 65), isLightDependent: false),
        ]
        let npcs = [
            // Merchant at stall — stationary, wide vision watching for customers
            LevelData.NPCConfig(startPosition: CGPoint(x: 400, y: 250),
                patrolPoints: [CGPoint(x: 390, y: 250), CGPoint(x: 410, y: 255)],
                visionRange: 190, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 5,
                npcType: .merchantVendor, behavior: .stationary),
            // Fisherman at dock
            LevelData.NPCConfig(startPosition: CGPoint(x: 750, y: 270),
                patrolPoints: [CGPoint(x: 740, y: 270), CGPoint(x: 760, y: 275)],
                visionRange: 160, visionAngle: .pi / 4,
                isHostile: false, detectionSensitivity: 4,
                npcType: .fisherman, behavior: .fishing),
            // Playing child in town square
            LevelData.NPCConfig(startPosition: CGPoint(x: 1100, y: 230),
                patrolPoints: [CGPoint(x: 1050, y: 220), CGPoint(x: 1150, y: 250), CGPoint(x: 1100, y: 270), CGPoint(x: 1050, y: 240)],
                visionRange: 130, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 5,
                npcType: .playingChild, behavior: .playing),
            // Guard at town entrance
            LevelData.NPCConfig(startPosition: CGPoint(x: 1450, y: 240),
                patrolPoints: [CGPoint(x: 1350, y: 230), CGPoint(x: 1550, y: 250)],
                visionRange: 210, visionAngle: .pi / 2.5,
                isHostile: true, detectionSensitivity: 6,
                npcType: .samuraiGuard, behavior: .patrol),
            // Another merchant
            LevelData.NPCConfig(startPosition: CGPoint(x: 1800, y: 260),
                patrolPoints: [CGPoint(x: 1790, y: 260), CGPoint(x: 1810, y: 265)],
                visionRange: 180, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 5,
                npcType: .merchantVendor, behavior: .stationary),
            // Guard dog near warehouses
            LevelData.NPCConfig(startPosition: CGPoint(x: 2200, y: 210),
                patrolPoints: [CGPoint(x: 2100, y: 200), CGPoint(x: 2300, y: 220)],
                visionRange: 170, visionAngle: .pi / 2,
                isHostile: true, detectionSensitivity: 8,
                npcType: .guardDog, behavior: .patrol),
        ]
        return LevelData(levelNumber: 5, startPosition: CGPoint(x: 100, y: 210),
            endPosition: CGPoint(x: 2800, y: 200), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .harborTown)
    }

    // MARK: - Level 6: Cherry Blossom Festival (top-down)
    // Lantern-lit festival with food stalls and cherry blossoms. Bustling but peaceful.
    private func createLevel6Festival() -> LevelData {
        let levelWidth: CGFloat = 3200
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 300, y: 210), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 600, y: 240), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 950, y: 190), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1300, y: 220), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1650, y: 250), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2000, y: 200), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2350, y: 230), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2700, y: 210), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2950, y: 190), size: CGSize(width: 60, height: 60), isLightDependent: false),
        ]
        let npcs = [
            // Gossip Granny eavesdropping near entrance — slow, wide vision
            LevelData.NPCConfig(startPosition: CGPoint(x: 450, y: 240),
                patrolPoints: [CGPoint(x: 400, y: 230), CGPoint(x: 600, y: 250)],
                visionRange: 175, visionAngle: .pi / 2.5,
                isHostile: false, detectionSensitivity: 3,
                npcType: .gossipGranny, behavior: .patrol),
            // Playing child chasing between stalls
            LevelData.NPCConfig(startPosition: CGPoint(x: 800, y: 230),
                patrolPoints: [CGPoint(x: 750, y: 220), CGPoint(x: 900, y: 250), CGPoint(x: 850, y: 270)],
                visionRange: 120, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 5,
                npcType: .playingChild, behavior: .playing),
            // Chef Kappa at food stall — Tanuki's minion, using recipe as napkin
            LevelData.NPCConfig(startPosition: CGPoint(x: 1150, y: 250),
                patrolPoints: [CGPoint(x: 1140, y: 250), CGPoint(x: 1160, y: 255)],
                visionRange: 185, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 5,
                npcType: .chefKappa, behavior: .stationary),
            // Guard patrolling festival perimeter
            LevelData.NPCConfig(startPosition: CGPoint(x: 1500, y: 240),
                patrolPoints: [CGPoint(x: 1400, y: 230), CGPoint(x: 1700, y: 260)],
                visionRange: 200, visionAngle: .pi / 2.5,
                isHostile: true, detectionSensitivity: 6,
                npcType: .samuraiGuard, behavior: .patrol),
            // Another child
            LevelData.NPCConfig(startPosition: CGPoint(x: 1900, y: 220),
                patrolPoints: [CGPoint(x: 1850, y: 210), CGPoint(x: 1950, y: 240), CGPoint(x: 1880, y: 250)],
                visionRange: 125, visionAngle: .pi / 2,
                isHostile: false, detectionSensitivity: 4,
                npcType: .playingChild, behavior: .playing),
            // Flower gardener tending decorations
            LevelData.NPCConfig(startPosition: CGPoint(x: 2200, y: 250),
                patrolPoints: [CGPoint(x: 2150, y: 240), CGPoint(x: 2300, y: 260)],
                visionRange: 155, visionAngle: .pi / 3,
                isHostile: false, detectionSensitivity: 3,
                npcType: .flowerGardener, behavior: .sweeping),
            // Guard at festival exit
            LevelData.NPCConfig(startPosition: CGPoint(x: 2600, y: 230),
                patrolPoints: [CGPoint(x: 2500, y: 220), CGPoint(x: 2700, y: 240)],
                visionRange: 210, visionAngle: .pi / 2.5,
                isHostile: true, detectionSensitivity: 6,
                npcType: .samuraiGuard, behavior: .patrol),
        ]
        return LevelData(levelNumber: 6, startPosition: CGPoint(x: 100, y: 210),
            endPosition: CGPoint(x: 3000, y: 200), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .festivalGrounds)
    }

    // MARK: - Level 7: Moonlit Garden (side-view)
    // A peaceful botanical garden at night. Lavender tones, fireflies, a zen pond.
    private func createLevel7NightGarden() -> LevelData {
        let levelWidth: CGFloat = 3000
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 250, y: 190), size: CGSize(width: 70, height: 70), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 550, y: 210), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 900, y: 180), size: CGSize(width: 65, height: 65), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1250, y: 200), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1600, y: 220), size: CGSize(width: 65, height: 65), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1950, y: 190), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2300, y: 210), size: CGSize(width: 65, height: 65), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 2600, y: 190), size: CGSize(width: 65, height: 65), isLightDependent: false),
        ]
        let npcs = [
            // Night gardener with lantern — slow sweeping
            LevelData.NPCConfig(startPosition: CGPoint(x: 400, y: 240),
                patrolPoints: [CGPoint(x: 350, y: 230), CGPoint(x: 500, y: 250)],
                visionRange: 170, visionAngle: .pi / 3,
                isHostile: false, detectionSensitivity: 4,
                npcType: .flowerGardener, behavior: .sweeping),
            // Guard patrolling the garden path
            LevelData.NPCConfig(startPosition: CGPoint(x: 800, y: 220),
                patrolPoints: [CGPoint(x: 700, y: 210), CGPoint(x: 950, y: 240)],
                visionRange: 200, visionAngle: .pi / 2.5,
                isHostile: true, detectionSensitivity: 6,
                npcType: .samuraiGuard, behavior: .patrol),
            // Sleeping dog near the garden gate
            LevelData.NPCConfig(startPosition: CGPoint(x: 1200, y: 195),
                patrolPoints: [CGPoint(x: 1180, y: 195), CGPoint(x: 1220, y: 200)],
                visionRange: 130, visionAngle: .pi / 1.8,
                isHostile: true, detectionSensitivity: 9,
                npcType: .sleepingDog, behavior: .sleeping),
            // Elderly walker enjoying moonlit garden
            LevelData.NPCConfig(startPosition: CGPoint(x: 1700, y: 240),
                patrolPoints: [CGPoint(x: 1600, y: 230), CGPoint(x: 1850, y: 250)],
                visionRange: 180, visionAngle: .pi / 2.5,
                isHostile: false, detectionSensitivity: 3,
                npcType: .elderlyWalker, behavior: .patrol),
            // Another guard near the end
            LevelData.NPCConfig(startPosition: CGPoint(x: 2400, y: 230),
                patrolPoints: [CGPoint(x: 2300, y: 220), CGPoint(x: 2550, y: 245)],
                visionRange: 210, visionAngle: .pi / 2.5,
                isHostile: true, detectionSensitivity: 7,
                npcType: .samuraiGuard, behavior: .patrol),
            // Grand Master Tanuki — sleeping on a bench near the endpoint
            LevelData.NPCConfig(startPosition: CGPoint(x: 2700, y: 200),
                patrolPoints: [CGPoint(x: 2690, y: 200), CGPoint(x: 2710, y: 205)],
                visionRange: 100, visionAngle: .pi / 1.5,
                isHostile: false, detectionSensitivity: 9,
                npcType: .tanuki, behavior: .sleeping),
        ]
        return LevelData(levelNumber: 7, startPosition: CGPoint(x: 100, y: 190),
            endPosition: CGPoint(x: 2800, y: 200), hidingPoints: hidingPoints,
            npcs: npcs, levelWidth: levelWidth, theme: .nightGarden)
    }

    // MARK: - Procedural Level Generation
    
    /// Generate a level procedurally for endless gameplay
    private func generateProceduralLevel(levelNumber: Int) -> LevelData {
        let levelWidth: CGFloat = 2000 + CGFloat(levelNumber * 500)
        let difficulty = min(levelNumber, 10) // Cap difficulty at 10
        
        // Generate hiding points
        var hidingPoints: [LevelData.HidingPointConfig] = []
        let numHidingPoints = 5 + difficulty
        let spacing = levelWidth / CGFloat(numHidingPoints + 1)
        
        for i in 1...numHidingPoints {
            let x = spacing * CGFloat(i)
            let y = CGFloat.random(in: 150...300)
            let size = CGFloat(70 - difficulty * 2) // Smaller as difficulty increases
            let isLight = Bool.random() && difficulty > 3
            
            hidingPoints.append(LevelData.HidingPointConfig(
                position: CGPoint(x: x, y: y),
                size: CGSize(width: size, height: size),
                isLightDependent: isLight
            ))
        }
        
        // Generate NPCs
        var npcs: [LevelData.NPCConfig] = []
        let numNPCs = 2 + (difficulty / 2)
        
        for i in 0..<numNPCs {
            let x = levelWidth * (CGFloat(i + 1) / CGFloat(numNPCs + 1))
            let y = CGFloat.random(in: 200...300)
            let patrolDistance = CGFloat.random(in: 100...200)
            
            let isHostile = i % 2 == 0 && difficulty > 2
            
            npcs.append(LevelData.NPCConfig(
                startPosition: CGPoint(x: x, y: y),
                patrolPoints: [
                    CGPoint(x: x - patrolDistance, y: y),
                    CGPoint(x: x + patrolDistance, y: y)
                ],
                visionRange: 180 + CGFloat(difficulty * 10),
                visionAngle: CGFloat.pi / (2.0 + CGFloat(difficulty) * 0.1),
                isHostile: isHostile
            ))
        }
        
        // Cycle through themes for variety
        let themes: [LevelData.LevelTheme] = [.meadowPath, .villageFarm, .riverCrossing, .harborTown, .festivalGrounds, .nightGarden]
        let theme = themes[(levelNumber - 1) % themes.count]

        return LevelData(
            levelNumber: levelNumber,
            startPosition: CGPoint(x: 100, y: 200),
            endPosition: CGPoint(x: levelWidth - 200, y: 200),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth,
            theme: theme
        )
    }
}
