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
    
    // Textures for different states
    private var standingTexture: SKTexture!
    private var movingTextures: [SKTexture] = []
    
    init() {
        // Load the standing texture
        standingTexture = SKTexture(imageNamed: "SouthStanding")
        
        // Debug: Check if standing texture loaded
        print("🥷 Standing texture size: \(standingTexture.size())")
        
        // Load moving animation frames from the GIF
        // Note: You'll need to extract frames from EastAnimation.gif
        // For now, we'll try to load them as separate images
        movingTextures = StealthNinjaCharacter.loadMovingTextures()
        
        // Debug: Check how many animation frames loaded
        print("🥷 Number of moving textures loaded: \(movingTextures.count)")
        
        // Initialize with standing texture
        super.init(texture: standingTexture, color: .clear, size: CGSize(width: 40, height: 60))
        
        // Fallback if no texture is available
        if standingTexture.size() == .zero {
            self.color = .black
            self.size = CGSize(width: 40, height: 60)
            print("⚠️ Standing texture not found! Using fallback black square.")
        } else {
            print("✅ Standing texture loaded successfully!")
        }
        
        self.name = "ninja"
        self.zPosition = 10
        
        // Add a simple animation for idle state
        setupIdleAnimation()
    }
    
    /// Load moving animation textures
    /// Strictly loads EastAnimation1 through EastAnimation6
    private static func loadMovingTextures() -> [SKTexture] {
        var textures: [SKTexture] = []
        
        // Load frames 1-6 (1-indexed as requested)
        print("🔍 Loading EastAnimation1 through EastAnimation6...")
        for frameIndex in 1...6 {
            let textureName = "EastAnimation\(frameIndex)"
            let texture = SKTexture(imageNamed: textureName)
            
            if texture.size() != .zero {
                textures.append(texture)
                print("✅ Loaded: \(textureName) - Size: \(texture.size())")
            } else {
                print("❌ Failed to load: \(textureName)")
                print("⚠️ Make sure you have an image set named '\(textureName)' in Assets.xcassets")
            }
        }
        
        if textures.count == 6 {
            print("✅ Successfully loaded all 6 animation frames (EastAnimation1-6)!")
        } else if textures.isEmpty {
            print("❌ ERROR: No animation frames loaded!")
            print("💡 You need to create 6 image sets in Assets.xcassets:")
            print("   - EastAnimation1")
            print("   - EastAnimation2")
            print("   - EastAnimation3")
            print("   - EastAnimation4")
            print("   - EastAnimation5")
            print("   - EastAnimation6")
        } else {
            print("⚠️ Warning: Only loaded \(textures.count) out of 6 frames")
        }
        
        return textures
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIdleAnimation() {
        // Use standing texture for idle
        texture = standingTexture
        
        // Subtle breathing animation
        let breathe = SKAction.sequence([
            SKAction.scaleY(to: 0.98, duration: 1.0),
            SKAction.scaleY(to: 1.0, duration: 1.0)
        ])
        run(SKAction.repeatForever(breathe), withKey: "idle")
    }
    
    func moveTo(point: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        currentState = .moving
        removeAction(forKey: "idle")
        
        // Start movement animation if we have frames
        if !movingTextures.isEmpty {
            print("🏃 Starting walk animation with \(movingTextures.count) frames")
            let timePerFrame = 0.1 // 10 frames per second
            let animateAction = SKAction.animate(with: movingTextures, timePerFrame: timePerFrame)
            run(SKAction.repeatForever(animateAction), withKey: "walkAnimation")
        } else {
            print("⚠️ No moving textures available - animation will not play!")
        }
        
        // Calculate direction for flipping sprite
        let dx = point.x - position.x
        if dx < 0 {
            // Moving left - flip sprite
            xScale = -abs(xScale)
            print("👈 Moving left")
        } else if dx > 0 {
            // Moving right - normal orientation
            xScale = abs(xScale)
            print("👉 Moving right")
        }
        
        // Move to target
        let move = SKAction.move(to: point, duration: duration)
        
        let sequence = SKAction.sequence([
            move,
            SKAction.run { [weak self] in
                self?.removeAction(forKey: "walkAnimation")
                print("🛑 Movement complete, stopping animation")
                completion()
            }
        ])
        
        run(sequence, withKey: "movement")
    }
    
    func hide() {
        currentState = .hiding
        removeAction(forKey: "movement")
        removeAction(forKey: "walkAnimation")
        
        // Switch back to standing texture
        texture = standingTexture
        
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
        removeAction(forKey: "walkAnimation")
        
        // Switch back to standing texture
        texture = standingTexture
        
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        run(fadeIn)
    }
    
    func detected() {
        currentState = .detected
        removeAllActions()
        
        // Switch back to standing texture
        texture = standingTexture
        
        // Flash red to indicate detection
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 5), withKey: "detected")
    }
}
