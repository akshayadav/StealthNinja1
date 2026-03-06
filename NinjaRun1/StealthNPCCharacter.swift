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
    
    init(config: LevelData.NPCConfig) {
        self.config = config
        
        // Create NPC representation
        let texture = SKTexture(imageNamed: config.isHostile ? "guard" : "civilian")
        let size = CGSize(width: 40, height: 50)
        super.init(texture: texture, color: config.isHostile ? .red : .blue, size: size)
        
        // Fallback if no texture is available
        if texture.size() == .zero {
            self.color = config.isHostile ? .red : .blue
            self.size = size
        }
        
        self.position = config.startPosition
        self.name = config.isHostile ? "hostile_npc" : "neutral_npc"
        self.zPosition = 5
        
        // Create vision cone
        setupVisionCone()
        
        // Start patrol
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
    
    func startPatrol() {
        guard config.patrolPoints.count > 1 else { return }
        
        moveToNextPatrolPoint()
    }
    
    private func moveToNextPatrolPoint() {
        guard config.patrolPoints.count > 1 else { return }
        
        currentPatrolIndex = (currentPatrolIndex + 1) % config.patrolPoints.count
        let targetPoint = config.patrolPoints[currentPatrolIndex]
        
        let distance = hypot(targetPoint.x - position.x, targetPoint.y - position.y)
        let duration = TimeInterval(distance / 50.0) // Speed: 50 points per second
        
        // Calculate rotation to face movement direction
        let angle = atan2(targetPoint.y - position.y, targetPoint.x - position.x)
        let rotateAction = SKAction.rotate(toAngle: angle - CGFloat.pi / 2, duration: 0.3, shortestUnitArc: true)
        
        let moveAction = SKAction.move(to: targetPoint, duration: duration)
        let waitAction = SKAction.wait(forDuration: 1.0)
        
        let sequence = SKAction.sequence([
            rotateAction,
            moveAction,
            waitAction,
            SKAction.run { [weak self] in
                self?.moveToNextPatrolPoint()
            }
        ])
        
        run(sequence, withKey: "patrol")
    }
    
    func canSee(point: CGPoint) -> Bool {
        // Get the ninja's position in world coordinates
        guard let parent = parent else { return false }
        
        // Calculate vector from NPC to ninja
        let dx = point.x - position.x
        let dy = point.y - position.y
        let distance = hypot(dx, dy)
        
        // Check if ninja is within vision range
        guard distance <= config.visionRange else { return false }
        
        // Calculate angle to ninja (in world coordinates)
        let angleToNinja = atan2(dy, dx)
        
        // Get NPC's facing direction (zRotation is in radians)
        // NPC rotates by (angle - π/2) when moving, so add π/2 back to get actual facing direction
        let npcFacingAngle = zRotation + CGFloat.pi / 2
        
        // Calculate the difference between where NPC is facing and where ninja is
        var angleDiff = angleToNinja - npcFacingAngle
        
        // Normalize angle difference to -π to π range
        while angleDiff > CGFloat.pi { angleDiff -= 2 * CGFloat.pi }
        while angleDiff < -CGFloat.pi { angleDiff += 2 * CGFloat.pi }
        
        // Check if ninja is within the vision cone angle
        let halfVisionAngle = config.visionAngle / 2
        return abs(angleDiff) <= halfVisionAngle
    }
    
    func stopPatrol() {
        removeAction(forKey: "patrol")
    }
    
    func resumePatrol() {
        startPatrol()
    }
}
