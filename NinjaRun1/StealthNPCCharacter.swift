//
//  StealthNPCCharacter.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import SpriteKit

class StealthNPCCharacter: SKSpriteNode {
    
    let config: LevelData.NPCConfig
    var currentPatrolIndex: Int = 0
    var visionCone: SKShapeNode?
    var detectionTimer: Timer?

    // Detection tracking
    var detectionAccumulator: CGFloat = 0.0
    var detectionThreshold: CGFloat = 0.0

    // Tracks the direction the NPC is facing (radians, 0 = east, π/2 = north)
    private var facingAngle: CGFloat = -CGFloat.pi / 2  // default: facing south

    // Visual indicator for sensitivity
    var sensitivityIndicator: SKLabelNode?

    init(config: LevelData.NPCConfig) {
        self.config = config

        // Sensitivity 1 = 2.0 seconds to detect, Sensitivity 10 = 0.1 seconds
        self.detectionThreshold = 2.1 - (CGFloat(config.detectionSensitivity) * 0.2)

        let isQuadruped = (config.npcType == .guardDog || config.npcType == .blackPanther)
        let size = isQuadruped ? CGSize(width: 50, height: 36) : CGSize(width: 40, height: 50)

        // Load south-facing sprite as the starting texture
        let initialTextureName = "\(config.npcType.textureName)_south"
        let texture = SKTexture(imageNamed: initialTextureName)
        let fallbackColor: SKColor = config.isHostile ? .red : .blue
        super.init(texture: texture, color: fallbackColor, size: size)

        if texture.size() == .zero {
            self.color = fallbackColor
        }

        self.position = config.startPosition
        self.name = config.isHostile ? "hostile_npc" : "neutral_npc"
        self.zPosition = 5

        setupVisionCone()
        startPatrol()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVisionCone() {
        let path = CGMutablePath()
        path.move(to: .zero)
        
        // Create arc for vision cone
        // The cone initially points UP (π/2), because the sprite rotates by (angle - π/2)
        // This makes the cone align with the sprite's visual forward direction
        let halfAngle = config.visionAngle / 2
        let baseAngle = CGFloat.pi / 2 // Point up initially
        
        path.addArc(
            center: .zero,
            radius: config.visionRange,
            startAngle: baseAngle - halfAngle,
            endAngle: baseAngle + halfAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        visionCone = SKShapeNode(path: path)
        visionCone?.fillColor = config.isHostile ? .red : .yellow
        visionCone?.alpha = 0.15
        visionCone?.strokeColor = .clear
        visionCone?.zPosition = -1
        
        if let cone = visionCone {
            addChild(cone)
        }
    }
    
    private func setupSensitivityIndicator() {
        // Create a small label showing detection level
        sensitivityIndicator = SKLabelNode(fontNamed: "Arial-BoldMT")
        sensitivityIndicator?.text = "\(config.detectionSensitivity)"
        sensitivityIndicator?.fontSize = 14
        sensitivityIndicator?.fontColor = getSensitivityColor()
        sensitivityIndicator?.position = CGPoint(x: 0, y: 30)
        sensitivityIndicator?.zPosition = 10
        
        // Add background circle for visibility
        let background = SKShapeNode(circleOfRadius: 10)
        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = getSensitivityColor()
        background.lineWidth = 2
        background.position = CGPoint(x: 0, y: 35)
        background.zPosition = 9
        background.name = "sensitivityBackground"
        
        if let indicator = sensitivityIndicator {
            addChild(background)
            addChild(indicator)
        }
    }
    
    private func getSensitivityColor() -> SKColor {
        // Color code sensitivity level
        switch config.detectionSensitivity {
        case 1...3:
            return .green      // Lenient
        case 4...6:
            return .yellow     // Medium
        case 7...8:
            return .orange     // Strict
        case 9...10:
            return .red        // Very strict
        default:
            return .white
        }
    }
    
    func startPatrol() {
        guard config.patrolPoints.count > 1 else { return }
        
        moveToNextPatrolPoint()
    }
    
    private func moveToNextPatrolPoint() {
        guard config.patrolPoints.count > 1 else { return }

        currentPatrolIndex = (currentPatrolIndex + 1) % config.patrolPoints.count
        let targetPoint = config.patrolPoints[currentPatrolIndex]

        let distance = hypot(targetPoint.x - position.x, targetPoint.y - position.y)
        let duration = TimeInterval(distance / 50.0)

        let angle = atan2(targetPoint.y - position.y, targetPoint.x - position.x)

        // Update facing direction: swap texture + rotate vision cone (don't rotate sprite)
        let updateDirectionAction = SKAction.run { [weak self] in
            self?.updateFacing(angle: angle)
        }

        let moveAction = SKAction.move(to: targetPoint, duration: duration)
        let waitAction = SKAction.wait(forDuration: 1.0)

        let sequence = SKAction.sequence([
            updateDirectionAction,
            moveAction,
            waitAction,
            SKAction.run { [weak self] in
                self?.moveToNextPatrolPoint()
            }
        ])

        run(sequence, withKey: "patrol")
    }

    private func updateFacing(angle: CGFloat) {
        facingAngle = angle

        // Swap to the directional texture for this movement angle
        let dirName = directionName(for: angle)
        let textureName = "\(config.npcType.textureName)_\(dirName)"
        let newTexture = SKTexture(imageNamed: textureName)
        if newTexture.size() != .zero {
            texture = newTexture
        }

        // Rotate the vision cone to match facing direction (cone base points up = π/2)
        visionCone?.zRotation = angle - CGFloat.pi / 2
    }

    private func directionName(for angle: CGFloat) -> String {
        // angle: 0 = east, π/2 = north, ±π = west, -π/2 = south
        var deg = angle * 180.0 / .pi
        if deg < 0 { deg += 360 }
        switch deg {
        case 337.5..<360, 0..<22.5: return "east"
        case 22.5..<67.5:           return "north_east"
        case 67.5..<112.5:          return "north"
        case 112.5..<157.5:         return "north_west"
        case 157.5..<202.5:         return "west"
        case 202.5..<247.5:         return "south_west"
        case 247.5..<292.5:         return "south"
        default:                    return "south_east"  // 292.5..<337.5
        }
    }
    
    func canSee(point: CGPoint) -> Bool {
        guard parent != nil else { return false }

        // Calculate vector from NPC to ninja
        let dx = point.x - position.x
        let dy = point.y - position.y
        let distance = hypot(dx, dy)
        
        // Check if ninja is within vision range
        guard distance <= config.visionRange else { return false }
        
        // Calculate angle to ninja (in world coordinates)
        let angleToNinja = atan2(dy, dx)

        // Use tracked facingAngle (updated whenever the NPC changes direction)
        let npcFacingAngle = facingAngle
        
        // Calculate the difference between where NPC is facing and where ninja is
        var angleDiff = angleToNinja - npcFacingAngle
        
        // Normalize angle difference to -π to π range
        while angleDiff > CGFloat.pi { angleDiff -= 2 * CGFloat.pi }
        while angleDiff < -CGFloat.pi { angleDiff += 2 * CGFloat.pi }
        
        // Check if ninja is within the vision cone angle
        let halfVisionAngle = config.visionAngle / 2
        return abs(angleDiff) <= halfVisionAngle
    }
    
    /// Update detection accumulator when seeing ninja
    /// Returns true if detection threshold is reached
    func updateDetection(deltaTime: TimeInterval, seeingNinja: Bool) -> Bool {
        if seeingNinja {
            // Accumulate detection time
            detectionAccumulator += CGFloat(deltaTime)
            
            // Update indicator to show detection progress
            updateSensitivityIndicator(progress: detectionAccumulator / detectionThreshold)
            
            // Check if threshold reached
            if detectionAccumulator >= detectionThreshold {
                return true
            }
        } else {
            // Decay detection when not seeing ninja
            detectionAccumulator = max(0, detectionAccumulator - CGFloat(deltaTime) * 0.5)
            updateSensitivityIndicator(progress: detectionAccumulator / detectionThreshold)
        }
        
        return false
    }
    
    /// Reset detection accumulator
    func resetDetection() {
        detectionAccumulator = 0.0
        updateSensitivityIndicator(progress: 0.0)
    }
    
    /// Update the visual indicator based on detection progress
    private func updateSensitivityIndicator(progress: CGFloat) {
        guard let indicator = sensitivityIndicator else { return }
        guard let background = childNode(withName: "sensitivityBackground") as? SKShapeNode else { return }
        
        // Change color based on detection progress
        if progress > 0.7 {
            background.fillColor = SKColor.red.withAlphaComponent(0.7)
            indicator.fontColor = .red
        } else if progress > 0.3 {
            background.fillColor = SKColor.orange.withAlphaComponent(0.7)
            indicator.fontColor = .orange
        } else {
            background.fillColor = SKColor.black.withAlphaComponent(0.7)
            indicator.fontColor = getSensitivityColor()
        }
        
        // Pulse when detecting
        if progress > 0 {
            if background.action(forKey: "detectionPulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.3, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
                background.run(SKAction.repeatForever(pulse), withKey: "detectionPulse")
            }
        } else {
            background.removeAction(forKey: "detectionPulse")
            background.setScale(1.0)
        }
    }
    
    func stopPatrol() {
        removeAction(forKey: "patrol")
    }
    
    func resumePatrol() {
        startPatrol()
    }
}
