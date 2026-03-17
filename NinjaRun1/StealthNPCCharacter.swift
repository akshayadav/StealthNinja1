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

    // Walk animation textures keyed by direction (e.g. "south" -> [frame1, frame2, ...])
    private var walkTextures: [String: [SKTexture]] = [:]
    private var hasWalkAnimation: Bool { !walkTextures.isEmpty }

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
        let fallbackColor: SKColor = config.isHostile ? PastelPalette.dustyRose : PastelPalette.lavender
        super.init(texture: texture, color: fallbackColor, size: size)

        if texture.size() == .zero {
            self.color = fallbackColor
        }

        self.position = config.startPosition
        self.name = config.isHostile ? "hostile_npc" : "neutral_npc"
        self.zPosition = 5

        loadWalkTextures()
        setupVisionCone()
        startPatrol()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadWalkTextures() {
        let baseName = config.npcType.textureName
        let directions = ["south", "east", "north", "west"]
        for dir in directions {
            // Try 4-frame and 6-frame walk cycles
            let maxFrames = 6
            var frames: [SKTexture] = []
            for i in 1...maxFrames {
                let t = SKTexture(imageNamed: "\(baseName)_walk_\(dir)_\(i)")
                if t.size() != .zero {
                    frames.append(t)
                } else {
                    break
                }
            }
            if !frames.isEmpty {
                walkTextures[dir] = frames
            }
        }
    }

    private func startWalkAnimation(forAngle angle: CGFloat) {
        let dir = directionName(for: angle)
        // Try exact direction, then fall back to nearest
        let tryDirs: [String]
        switch dir {
        case "north_east": tryDirs = ["east", "north"]
        case "north_west": tryDirs = ["west", "north"]
        case "south_east": tryDirs = ["east", "south"]
        case "south_west": tryDirs = ["west", "south"]
        default:           tryDirs = [dir, "south"]
        }

        var frames: [SKTexture]?
        for d in tryDirs {
            if let f = walkTextures[d] {
                frames = f
                break
            }
        }

        if let frames = frames {
            let anim = SKAction.animate(with: frames, timePerFrame: 0.12)
            run(SKAction.repeatForever(anim), withKey: "walkAnim")
        } else {
            // No walk frames — use a subtle step-bob during movement
            let bob = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 1.5, duration: 0.18),
                SKAction.moveBy(x: 0, y: -1.5, duration: 0.18)
            ])
            run(SKAction.repeatForever(bob), withKey: "walkAnim")
        }
    }

    private func stopWalkAnimation() {
        removeAction(forKey: "walkAnim")
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
        visionCone?.fillColor = config.isHostile ? PastelPalette.dustyRose : PastelPalette.softGold
        visionCone?.alpha = 0.12
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
            return PastelPalette.sageGreen   // Lenient
        case 4...6:
            return PastelPalette.softGold    // Medium
        case 7...8:
            return PastelPalette.softPeach   // Strict
        case 9...10:
            return PastelPalette.dustyRose   // Very strict
        default:
            return .white
        }
    }
    
    func startPatrol() {
        switch config.behavior {
        case .patrol:
            guard config.patrolPoints.count > 1 else { return }
            moveToNextPatrolPoint()
        case .stationary:
            startStationaryBehavior()
        case .farming:
            startFarmingBehavior()
        case .fishing:
            startFishingBehavior()
        case .playing:
            startPlayingBehavior()
        case .sleeping:
            startSleepingBehavior()
        case .sweeping:
            startSweepingBehavior()
        }
    }
    
    private func moveToNextPatrolPoint() {
        guard config.patrolPoints.count > 1 else { return }

        currentPatrolIndex = (currentPatrolIndex + 1) % config.patrolPoints.count
        let targetPoint = config.patrolPoints[currentPatrolIndex]

        let distance = hypot(targetPoint.x - position.x, targetPoint.y - position.y)

        // Vary speed by NPC type for natural feel
        let baseSpeed: CGFloat
        switch config.npcType {
        case .guardDog, .blackPanther:  baseSpeed = CGFloat.random(in: 65...80)
        case .samuraiGuard:             baseSpeed = CGFloat.random(in: 38...52)
        case .villageFarmer:            baseSpeed = CGFloat.random(in: 28...40)
        case .fisherman, .sleepingDog:  baseSpeed = CGFloat.random(in: 18...25)
        case .flowerGardener:           baseSpeed = CGFloat.random(in: 22...32)
        case .merchantVendor:           baseSpeed = CGFloat.random(in: 25...35)
        case .elderlyWalker:            baseSpeed = CGFloat.random(in: 15...22)
        case .playingChild:             baseSpeed = CGFloat.random(in: 55...70)
        case .tanuki:                   baseSpeed = CGFloat.random(in: 12...18)
        case .chefKappa:                baseSpeed = CGFloat.random(in: 20...28)
        case .gossipGranny:             baseSpeed = CGFloat.random(in: 14...20)
        }
        let duration = TimeInterval(distance / baseSpeed)

        let angle = atan2(targetPoint.y - position.y, targetPoint.x - position.x)

        let updateDirectionAction = SKAction.run { [weak self] in
            self?.updateFacing(angle: angle)
            self?.startWalkAnimation(forAngle: angle)
        }

        let moveAction = SKAction.move(to: targetPoint, duration: duration)

        // Random pause duration + natural look-around
        let pauseDuration = Double.random(in: 0.4...2.2)
        let lookAround = buildLookAroundAction(near: angle)

        let sequence = SKAction.sequence([
            updateDirectionAction,
            moveAction,
            SKAction.run { [weak self] in self?.stopWalkAnimation() },
            SKAction.wait(forDuration: pauseDuration * 0.3),
            lookAround,
            SKAction.wait(forDuration: pauseDuration * 0.4),
            SKAction.run { [weak self] in
                self?.moveToNextPatrolPoint()
            }
        ])

        run(sequence, withKey: "patrol")
    }

    /// Builds a short look-around action: glances left and right from current facing
    private func buildLookAroundAction(near baseAngle: CGFloat) -> SKAction {
        let offsets: [CGFloat] = [0.4, -0.5, 0.2, -0.3]
        var actions: [SKAction] = []
        for offset in offsets {
            let glanceAngle = baseAngle + offset
            actions.append(SKAction.run { [weak self] in self?.updateFacing(angle: glanceAngle) })
            actions.append(SKAction.wait(forDuration: Double.random(in: 0.25...0.45)))
        }
        // Return to original direction
        actions.append(SKAction.run { [weak self] in self?.updateFacing(angle: baseAngle) })
        return SKAction.sequence(actions)
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
    
    // MARK: - Contextual Behaviors

    private func startStationaryBehavior() {
        let baseAngle = facingAngle
        let lookAround = buildLookAroundAction(near: baseAngle)
        let sequence = SKAction.sequence([
            lookAround,
            SKAction.wait(forDuration: Double.random(in: 1.5...3.5)),
            SKAction.run { [weak self] in self?.startStationaryBehavior() }
        ])
        run(sequence, withKey: "patrol")
    }

    private func startFarmingBehavior() {
        // Bend down (scale squish), pause, stand up, step to next crop spot
        let bendDown = SKAction.scaleY(to: 0.7, duration: 0.4)
        let bendUp = SKAction.scaleY(to: 1.0, duration: 0.3)
        let work = SKAction.wait(forDuration: Double.random(in: 1.5...3.0))

        // Small step to next crop position
        let stepDist: CGFloat = CGFloat.random(in: 20...40)
        let stepDir: CGFloat = Bool.random() ? 1 : -1
        let stepMove = SKAction.moveBy(x: stepDist * stepDir, y: 0, duration: 0.6)
        let updateDir = SKAction.run { [weak self] in
            self?.updateFacing(angle: stepDir > 0 ? 0 : CGFloat.pi)
        }

        let sequence = SKAction.sequence([
            SKAction.run { [weak self] in self?.updateFacing(angle: -CGFloat.pi / 2) },
            bendDown, work, bendUp,
            SKAction.wait(forDuration: 0.5),
            updateDir, stepMove,
            SKAction.wait(forDuration: Double.random(in: 0.5...1.0)),
            SKAction.run { [weak self] in self?.startFarmingBehavior() }
        ])
        run(sequence, withKey: "patrol")
    }

    private func startFishingBehavior() {
        // Sit facing water (south), occasionally cast line (small bob)
        updateFacing(angle: -CGFloat.pi / 2)
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -3, duration: 0.3),
            SKAction.moveBy(x: 0, y: 3, duration: 0.3)
        ])
        let wait = SKAction.wait(forDuration: Double.random(in: 3.0...6.0))
        let cast = SKAction.sequence([bob, bob])
        let lookAround = buildLookAroundAction(near: -CGFloat.pi / 2)

        let sequence = SKAction.sequence([
            wait, cast, wait,
            lookAround,
            SKAction.run { [weak self] in self?.startFishingBehavior() }
        ])
        run(sequence, withKey: "patrol")
    }

    private func startPlayingBehavior() {
        // Run in small circles around start position
        let center = config.startPosition
        let radius: CGFloat = CGFloat.random(in: 25...45)
        let runDuration: TimeInterval = Double.random(in: 2.0...3.5)

        var actions: [SKAction] = []
        let steps = 8
        actions.append(SKAction.run { [weak self] in
            self?.startWalkAnimation(forAngle: CGFloat.pi / CGFloat(steps) * 2)
        })
        for i in 0..<steps {
            let nextAngle = CGFloat(i + 1) / CGFloat(steps) * CGFloat.pi * 2
            let target = CGPoint(x: center.x + cos(nextAngle) * radius,
                                 y: center.y + sin(nextAngle) * radius)
            actions.append(SKAction.run { [weak self] in self?.updateFacing(angle: nextAngle) })
            actions.append(SKAction.move(to: target, duration: runDuration / Double(steps)))
        }

        // Pause, then run again
        actions.append(SKAction.run { [weak self] in self?.stopWalkAnimation() })
        let pause = SKAction.wait(forDuration: Double.random(in: 1.0...2.5))
        actions.append(pause)
        actions.append(SKAction.run { [weak self] in self?.startPlayingBehavior() })

        run(SKAction.sequence(actions), withKey: "patrol")
    }

    private func startSleepingBehavior() {
        // Stay still, slight breathing animation, wake on proximity (handled by detection)
        // Slowly rotate vision cone to simulate light sleep awareness
        let breatheIn = SKAction.scaleY(to: 1.05, duration: 1.2)
        let breatheOut = SKAction.scaleY(to: 0.95, duration: 1.2)
        let breathe = SKAction.repeatForever(SKAction.sequence([breatheIn, breatheOut]))
        run(breathe, withKey: "sleepBreathing")

        // Make vision cone visible and slowly sweep around (dog senses surroundings)
        visionCone?.alpha = 0.18
        let sweepCone = SKAction.sequence([
            SKAction.run { [weak self] in self?.updateFacing(angle: -CGFloat.pi / 2 - 0.4) },
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self] in self?.updateFacing(angle: -CGFloat.pi / 2 + 0.4) },
            SKAction.wait(forDuration: 3.0)
        ])
        run(SKAction.repeatForever(sweepCone), withKey: "patrol")
    }

    private func startSweepingBehavior() {
        // Slow back-and-forth in a small area
        let sweepDist: CGFloat = CGFloat.random(in: 30...50)
        let sweepLeft = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.updateFacing(angle: CGFloat.pi)
                self?.startWalkAnimation(forAngle: CGFloat.pi)
            },
            SKAction.moveBy(x: -sweepDist, y: 0, duration: 1.5),
            SKAction.run { [weak self] in self?.stopWalkAnimation() }
        ])
        let sweepRight = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.updateFacing(angle: 0)
                self?.startWalkAnimation(forAngle: 0)
            },
            SKAction.moveBy(x: sweepDist, y: 0, duration: 1.5),
            SKAction.run { [weak self] in self?.stopWalkAnimation() }
        ])
        let pause = SKAction.wait(forDuration: Double.random(in: 0.3...0.8))
        let lookAround = buildLookAroundAction(near: facingAngle)

        let sequence = SKAction.sequence([
            sweepLeft, pause, sweepRight, pause,
            lookAround,
            SKAction.wait(forDuration: Double.random(in: 0.5...1.5)),
            SKAction.run { [weak self] in self?.startSweepingBehavior() }
        ])
        run(sequence, withKey: "patrol")
    }

    func stopPatrol() {
        removeAction(forKey: "patrol")
    }
    
    func resumePatrol() {
        startPatrol()
    }
}
