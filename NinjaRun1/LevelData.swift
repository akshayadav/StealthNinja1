//
//  LevelData.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import CoreGraphics

/// Structure to define level configuration
struct LevelData {
    let levelNumber: Int
    let startPosition: CGPoint
    let endPosition: CGPoint
    let hidingPoints: [HidingPointConfig]
    let npcs: [NPCConfig]
    let levelWidth: CGFloat

    enum NPCType {
        case samuraiGuard
        case villageFarmer
        case guardDog
        case blackPanther

        var textureName: String {
            switch self {
            case .samuraiGuard:  return "samurai_guard"
            case .villageFarmer: return "village_farmer"
            case .guardDog:      return "guard_dog"
            case .blackPanther:  return "black_panther"
            }
        }

        var isHostile: Bool {
            switch self {
            case .samuraiGuard, .guardDog, .blackPanther: return true
            case .villageFarmer: return false
            }
        }
    }

    struct HidingPointConfig {
        let position: CGPoint
        let size: CGSize
        let isLightDependent: Bool
    }

    struct NPCConfig {
        let startPosition: CGPoint
        let patrolPoints: [CGPoint]
        let visionRange: CGFloat
        let visionAngle: CGFloat
        let isHostile: Bool
        let detectionSensitivity: Int // 1-10, how quickly the NPC detects the player
        let npcType: NPCType

        init(startPosition: CGPoint, patrolPoints: [CGPoint], visionRange: CGFloat, visionAngle: CGFloat, isHostile: Bool, detectionSensitivity: Int = 5, npcType: NPCType? = nil) {
            self.startPosition = startPosition
            self.patrolPoints = patrolPoints
            self.visionRange = visionRange
            self.visionAngle = visionAngle
            self.isHostile = isHostile
            self.detectionSensitivity = detectionSensitivity
            self.npcType = npcType ?? (isHostile ? .samuraiGuard : .villageFarmer)
        }
    }
}

/// Level generator and storage
class LevelManager {
    static let shared = LevelManager()
    
    private init() {}
    
    /// Get level data for a specific level number
    func getLevelData(levelNumber: Int) -> LevelData {
        // Use extended system for better scalability
        return getLevelDataExtended(levelNumber: levelNumber)
    }
    
    // MARK: - Level Definitions
    
    private func createLevel1() -> LevelData {
        // Simple introductory level
        let levelWidth: CGFloat = 2000
        
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 200, y: 150), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 500, y: 150), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 800, y: 150), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1200, y: 150), size: CGSize(width: 80, height: 80), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1600, y: 150), size: CGSize(width: 80, height: 80), isLightDependent: false)
        ]
        
        let npcs = [
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 350, y: 200),
                patrolPoints: [
                    CGPoint(x: 350, y: 200),
                    CGPoint(x: 350, y: 400)
                ],
                visionRange: 180,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1000, y: 300),
                patrolPoints: [
                    CGPoint(x: 900, y: 300),
                    CGPoint(x: 1100, y: 300)
                ],
                visionRange: 200,
                visionAngle: CGFloat.pi / 4,
                isHostile: false
            )
        ]
        
        return LevelData(
            levelNumber: 1,
            startPosition: CGPoint(x: 100, y: 150),
            endPosition: CGPoint(x: 1800, y: 150),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
    }
    
    private func createLevel2() -> LevelData {
        // Medium difficulty with more NPCs
        let levelWidth: CGFloat = 2500
        
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 250, y: 150), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 500, y: 250), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 750, y: 150), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1100, y: 200), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1400, y: 150), size: CGSize(width: 70, height: 70), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1800, y: 250), size: CGSize(width: 70, height: 70), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2100, y: 150), size: CGSize(width: 70, height: 70), isLightDependent: false)
        ]
        
        let npcs = [
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 400, y: 200),
                patrolPoints: [
                    CGPoint(x: 400, y: 200),
                    CGPoint(x: 400, y: 350),
                    CGPoint(x: 550, y: 350),
                    CGPoint(x: 550, y: 200)
                ],
                visionRange: 200,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 900, y: 250),
                patrolPoints: [
                    CGPoint(x: 850, y: 250),
                    CGPoint(x: 1050, y: 250)
                ],
                visionRange: 220,
                visionAngle: CGFloat.pi / 4,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1600, y: 300),
                patrolPoints: [
                    CGPoint(x: 1500, y: 300),
                    CGPoint(x: 1700, y: 300),
                    CGPoint(x: 1700, y: 200),
                    CGPoint(x: 1500, y: 200)
                ],
                visionRange: 180,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            )
        ]
        
        return LevelData(
            levelNumber: 2,
            startPosition: CGPoint(x: 100, y: 150),
            endPosition: CGPoint(x: 2300, y: 150),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
    }
    
    private func createLevel3() -> LevelData {
        // Hard level with tight timing
        let levelWidth: CGFloat = 3000
        
        let hidingPoints = [
            LevelData.HidingPointConfig(position: CGPoint(x: 200, y: 200), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 450, y: 300), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 700, y: 150), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1000, y: 250), size: CGSize(width: 60, height: 60), isLightDependent: true),
            LevelData.HidingPointConfig(position: CGPoint(x: 1350, y: 180), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 1700, y: 300), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2000, y: 200), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2350, y: 250), size: CGSize(width: 60, height: 60), isLightDependent: false),
            LevelData.HidingPointConfig(position: CGPoint(x: 2650, y: 180), size: CGSize(width: 60, height: 60), isLightDependent: false)
        ]
        
        let npcs = [
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 350, y: 250),
                patrolPoints: [
                    CGPoint(x: 300, y: 250),
                    CGPoint(x: 500, y: 250)
                ],
                visionRange: 220,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 600, y: 200),
                patrolPoints: [
                    CGPoint(x: 600, y: 200),
                    CGPoint(x: 750, y: 300),
                    CGPoint(x: 600, y: 350)
                ],
                visionRange: 200,
                visionAngle: CGFloat.pi / 3,
                isHostile: false
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1150, y: 300),
                patrolPoints: [
                    CGPoint(x: 1050, y: 300),
                    CGPoint(x: 1250, y: 300)
                ],
                visionRange: 240,
                visionAngle: CGFloat.pi / 3,
                isHostile: true
            ),
            LevelData.NPCConfig(
                startPosition: CGPoint(x: 1500, y: 250),
                patrolPoints: [
                    CGPoint(x: 1400, y: 250),
                    CGPoint(x: 1600, y: 250),
                    CGPoint(x: 1600, y: 350),
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
                    CGPoint(x: 2400, y: 280)
                ],
                visionRange: 230,
                visionAngle: CGFloat.pi / 2.5,
                isHostile: true
            )
        ]
        
        return LevelData(
            levelNumber: 3,
            startPosition: CGPoint(x: 100, y: 200),
            endPosition: CGPoint(x: 2800, y: 180),
            hidingPoints: hidingPoints,
            npcs: npcs,
            levelWidth: levelWidth
        )
    }
}
