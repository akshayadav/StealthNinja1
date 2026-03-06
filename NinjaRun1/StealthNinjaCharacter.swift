//
//  StealthNinjaCharacter.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import SpriteKit

class StealthNinjaCharacter: SKSpriteNode {
    
    var currentState: StealthNinjaState = .idle
    var currentHidingPointIndex: Int = -1
    var targetHidingPointIndex: Int = 0
    var isInHidingZone: Bool = false
    
    init() {
        // Create a simple ninja representation (will be replaced with sprite)
        let texture = SKTexture(imageNamed: "ninja")
        super.init(texture: texture, color: .black, size: CGSize(width: 40, height: 60))
        
        // Fallback if no texture is available
        if texture.size() == .zero {
            self.color = .black
            self.size = CGSize(width: 40, height: 60)
        }
        
        self.name = "ninja"
        self.zPosition = 10
        
        // Add a simple animation for idle state
        setupIdleAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIdleAnimation() {
        let breathe = SKAction.sequence([
            SKAction.scaleY(to: 0.98, duration: 1.0),
            SKAction.scaleY(to: 1.0, duration: 1.0)
        ])
        run(SKAction.repeatForever(breathe), withKey: "idle")
    }
    
    func moveTo(point: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        currentState = .moving
        removeAction(forKey: "idle")
        
        // Add a subtle scale effect during movement
        let scaleUp = SKAction.scaleX(to: 1.1, duration: 0.2)
        let move = SKAction.move(to: point, duration: duration)
        let scaleDown = SKAction.scaleX(to: 1.0, duration: 0.2)
        
        let sequence = SKAction.sequence([
            scaleUp,
            move,
            scaleDown,
            SKAction.run(completion)
        ])
        
        run(sequence, withKey: "movement")
    }
    
    func hide() {
        currentState = .hiding
        removeAction(forKey: "movement")
        
        if isInHidingZone {
            // Successful hide - make semi-transparent to show stealth
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.3)
            run(fadeOut, withKey: "hiding")
        } else {
            // Not in hiding zone - remain visible
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.3),
                SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            ])
            run(SKAction.repeatForever(pulse), withKey: "exposed")
        }
        
        setupIdleAnimation()
    }
    
    func reveal() {
        removeAction(forKey: "hiding")
        removeAction(forKey: "exposed")
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        run(fadeIn)
    }
    
    func detected() {
        currentState = .detected
        removeAllActions()
        
        // Flash red to indicate detection
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 5), withKey: "detected")
    }
}
