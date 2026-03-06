//
//  NPCNode.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import SpriteKit

class NPCNode: SKSpriteNode {
    
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
        let halfAngle = config.visionAngle / 2
        path.addArc(
            center: .zero,
            radius: config.visionRange,
            startAngle: -halfAngle,
            endAngle: halfAngle,
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
        let rotateAction = SKAction.rotate(toAngle: angle - .pi / 2, duration: 0.3, shortestUnitArc: true)
        
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
        // Convert point to NPC's coordinate system
        let localPoint = convert(point, from: parent!)
        
        // Check if point is within vision range
        let distance = hypot(localPoint.x, localPoint.y)
        guard distance <= config.visionRange else { return false }
        
        // Check if point is within vision angle
        let angle = atan2(localPoint.y, localPoint.x)
        let halfAngle = config.visionAngle / 2
        
        return angle >= -halfAngle && angle <= halfAngle
    }
    
    func stopPatrol() {
        removeAction(forKey: "patrol")
    }
    
    func resumePatrol() {
        startPatrol()
    }
}
