//
//  StealthHidingPoint.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import SpriteKit

class StealthHidingPoint: SKSpriteNode {
    
    let config: LevelData.HidingPointConfig
    var isActive: Bool = false
    private var glowNode: SKShapeNode?
    
    init(config: LevelData.HidingPointConfig) {
        self.config = config
        
        // Create visual representation of hiding point
        let textureName = config.isLightDependent ? "hidingspot_shadow" : "hidingspot"
        let texture = SKTexture(imageNamed: textureName)
        super.init(texture: texture, color: PastelPalette.sageGreen.withAlphaComponent(0.6), size: config.size)

        // Fallback if no texture is available
        if texture.size() == .zero {
            self.color = PastelPalette.sageGreen.withAlphaComponent(0.6)
            self.size = config.size
        }
        
        self.position = config.position
        self.alpha = 0.4
        self.name = "hidingPoint"
        self.zPosition = 1
        
        // Add visual effects
        setupVisualEffects()
        
        // Add a subtle pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.5),
            SKAction.fadeAlpha(to: 0.5, duration: 1.5)
        ])
        run(SKAction.repeatForever(pulse))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVisualEffects() {
        // Outer glow effect
        let glowSize = CGSize(width: config.size.width + 10, height: config.size.height + 10)
        glowNode = SKShapeNode(rectOf: glowSize, cornerRadius: 8)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = config.isLightDependent ?
            PastelPalette.softGold.withAlphaComponent(0.5) :
            PastelPalette.sageGreen.withAlphaComponent(0.5)
        glowNode?.lineWidth = 3
        glowNode?.glowWidth = 5
        glowNode?.zPosition = -1
        if let glow = glowNode {
            addChild(glow)
        }
        
        // Border with rounded corners
        let border = SKShapeNode(rectOf: config.size, cornerRadius: 6)
        border.strokeColor = config.isLightDependent ?
            PastelPalette.softGold.withAlphaComponent(0.8) :
            PastelPalette.sageGreen.withAlphaComponent(0.8)
        border.fillColor = .clear
        border.lineWidth = 2
        border.zPosition = 1
        addChild(border)
        
        // Add icon indicator
        let iconLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        iconLabel.text = config.isLightDependent ? "🌿" : "🌸"
        iconLabel.fontSize = 20
        iconLabel.alpha = 0.7
        iconLabel.verticalAlignmentMode = .center
        iconLabel.zPosition = 2
        addChild(iconLabel)
        
        // Add corner decorations
        addCornerDecorations()
    }
    
    private func addCornerDecorations() {
        let cornerSize: CGFloat = 8
        let offset = config.size.width / 2 - cornerSize / 2
        let positions = [
            CGPoint(x: offset, y: offset),
            CGPoint(x: -offset, y: offset),
            CGPoint(x: offset, y: -offset),
            CGPoint(x: -offset, y: -offset)
        ]
        
        for pos in positions {
            let corner = SKShapeNode(circleOfRadius: cornerSize / 2)
            corner.fillColor = config.isLightDependent ?
                PastelPalette.softGold.withAlphaComponent(0.6) :
                PastelPalette.sageGreen.withAlphaComponent(0.6)
            corner.strokeColor = .clear
            corner.position = pos
            corner.zPosition = 1
            addChild(corner)
        }
    }
    
    func activate() {
        isActive = true
        
        // Brighten and add scale effect
        let brighten = SKAction.fadeAlpha(to: 0.8, duration: 0.3)
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.3)
        let group = SKAction.group([brighten, scaleUp])
        run(group, withKey: "activate")
        
        // Enhanced glow
        glowNode?.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
    }
    
    func deactivate() {
        isActive = false
        
        // Dim and return to normal scale
        let dim = SKAction.fadeAlpha(to: 0.4, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let group = SKAction.group([dim, scaleDown])
        run(group, withKey: "deactivate")
        
        // Normal glow
        glowNode?.run(SKAction.fadeAlpha(to: 0.6, duration: 0.3))
    }
    
    func contains(point: CGPoint) -> Bool {
        let rect = CGRect(
            x: position.x - size.width / 2,
            y: position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
        return rect.contains(point)
    }
}
