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
            4: createLevel4(),
            5: createLevel5(),
            6: createLevel6(),
            // Add more levels here as you create them!
            // 7: createLevel7(),
            // 8: createLevel8(),
        ]
    }
    
    /// Get total number of levels available
    func getTotalLevels() -> Int {
        return levelDatabase.keys.max() ?? 3
    }
    
    // MARK: - New Level Definitions
    
    private func createLevel4() -> LevelData {
        // Night Mission - Low visibility
        let levelWidth: CGFloat = 2800
        
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 300, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 600, y: 220), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 900, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1300, y: 240), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1700, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 2100, y: 180), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2400, y: 220), size: CGSize(width: 70, height: 70), isLightDependent: false)
        ]
        
        let npcs = [
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 450, y: 250),
                patrolPoints: [
                    CGPoint(x: 400, y: 250),
                    CGPoint(x: 600, y: 250)
                ],
                visionRange: 180,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1000, y: 280),
                patrolPoints: [
                    CGPoint(x: 900, y: 280),
                    CGPoint(x: 1100, y: 280)
                ],
                visionRange: 200,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1500, y: 250),
                patrolPoints: [
                    CGPoint(x: 1400, y: 250),
                    CGPoint(x: 1800, y: 250),
                    CGPoint(x: 1800, y: 350),
                    CGPoint(x: 1400, y: 350)
                ],
                visionRange: 190,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 2200, y: 280),
                patrolPoints: [
                    CGPoint(x: 2100, y: 280),
                    CGPoint(x: 2300, y: 280)
                ],
                visionRange: 220,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            )
        ]
        
        return LevelData(
            levelNumber: 4,
            startPosition: CGPoint(x: 100, y: 180),
            endPosition: CGPoint(x: 2600, y: 220),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
    }
    
    private func createLevel5() -> LevelData {
        // Rooftop Chase - Vertical movement
        let levelWidth: CGFloat = 2400
        
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 250, y: 300), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 500, y: 150), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 750, y: 280), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1000, y: 180), size: CGSize(width: 65, height: 65), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1300, y: 320), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1600, y: 200), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1900, y: 270), size: CGSize(width: 65, height: 65), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2100, y: 190), size: CGSize(width: 65, height: 65), isLightDependent: false)
        ]
        
        let npcs = [
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 380, y: 220),
                patrolPoints: [
                    CGPoint(x: 350, y: 200),
                    CGPoint(x: 450, y: 300)
                ],
                visionRange: 210,
                visionAngle: CGFloat.pi / 2.8,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 650, y: 230),
                patrolPoints: [
                    CGPoint(x: 600, y: 200),
                    CGPoint(x: 800, y: 280),
                    CGPoint(x: 650, y: 320)
                ],
                visionRange: 195,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1150, y: 260),
                patrolPoints: [
                    CGPoint(x: 1050, y: 250),
                    CGPoint(x: 1250, y: 280)
                ],
                visionRange: 230,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1450, y: 240),
                patrolPoints: [
                    CGPoint(x: 1400, y: 200),
                    CGPoint(x: 1550, y: 300)
                ],
                visionRange: 200,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1750, y: 240),
                patrolPoints: [
                    CGPoint(x: 1700, y: 220),
                    CGPoint(x: 1900, y: 260),
                    CGPoint(x: 1750, y: 310)
                ],
                visionRange: 220,
                visionAngle: CGFloat.pi / 2.7,
                isHostile: true
            )
        ]
        
        return LevelData(
            levelNumber: 5,
            startPosition: CGPoint(x: 100, y: 300),
            endPosition: CGPoint(x: 2250, y: 190),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
    }
    
    private func createLevel6() -> LevelData {
        // The Gauntlet - Maximum difficulty
        let levelWidth: CGFloat = 3500
        
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 280, y: 220), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 520, y: 180), size: CGSize(width: 60, height: 60), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 800, y: 260), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1100, y: 200), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1450, y: 240), size: CGSize(width: 60, height: 60), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1750, y: 190), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2050, y: 270), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2400, y: 210), size: CGSize(width: 60, height: 60), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 2700, y: 250), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 3000, y: 200), size: CGSize(width: 60, height: 60), isLightDependent: false)
        ]
        
        let npcs = [
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 400, y: 240),
                patrolPoints: [
                    CGPoint(x: 350, y: 220),
                    CGPoint(x: 550, y: 260)
                ],
                visionRange: 240,
                visionAngle: CGFloat.pi / 2.3,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 680, y: 230),
                patrolPoints: [
                    CGPoint(x: 650, y: 200),
                    CGPoint(x: 850, y: 280)
                ],
                visionRange: 220,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 950, y: 250),
                patrolPoints: [
                    CGPoint(x: 900, y: 230),
                    CGPoint(x: 1050, y: 270)
                ],
                visionRange: 230,
                visionAngle: CGFloat.pi / 2.4,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1280, y: 240),
                patrolPoints: [
                    CGPoint(x: 1200, y: 220),
                    CGPoint(x: 1400, y: 260),
                    CGPoint(x: 1280, y: 300)
                ],
                visionRange: 210,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1600, y: 250),
                patrolPoints: [
                    CGPoint(x: 1550, y: 220),
                    CGPoint(x: 1800, y: 280)
                ],
                visionRange: 250,
                visionAngle: CGFloat.pi / 2.2,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1920, y: 240),
                patrolPoints: [
                    CGPoint(x: 1850, y: 220),
                    CGPoint(x: 2100, y: 280)
                ],
                visionRange: 230,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 2250, y: 250),
                patrolPoints: [
                    CGPoint(x: 2150, y: 230),
                    CGPoint(x: 2450, y: 270)
                ],
                visionRange: 240,
                visionAngle: CGFloat.pi / 2.3,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 2580, y: 240),
                patrolPoints: [
                    CGPoint(x: 2500, y: 220),
                    CGPoint(x: 2750, y: 270)
                ],
                visionRange: 230,
                visionAngle: CGFloat.pi / 2.4,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 2850, y: 250),
                patrolPoints: [
                    CGPoint(x: 2800, y: 230),
                    CGPoint(x: 3050, y: 270)
                ],
                visionRange: 250,
                visionAngle: CGFloat.pi / 2.2,
                isHostile: true
            )
        ]
        
        return LevelData(
            levelNumber: 6,
            startPosition: CGPoint(x: 100, y: 220),
            endPosition: CGPoint(x: 3300, y: 200),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
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
        
        return LevelData(
            levelNumber: levelNumber,
            startPosition: CGPoint(x: 100, y: 200),
            endPosition: CGPoint(x: levelWidth - 200, y: 200),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
    }
}
