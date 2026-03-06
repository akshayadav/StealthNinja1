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
    
    init(config: LevelData.HidingPointConfig) {
        self.config = config
        
        // Create visual representation of hiding point
        let texture = SKTexture(imageNamed: "hidingspot")
        super.init(texture: texture, color: .darkGray, size: config.size)
        
        // Fallback if no texture is available
        if texture.size() == .zero {
            self.color = .darkGray
            self.size = config.size
        }
        
        self.position = config.position
        self.alpha = 0.3 // Semi-transparent to show it's a special zone
        self.name = "hidingPoint"
        self.zPosition = 1
        
        // Add a subtle pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 1.5),
            SKAction.fadeAlpha(to: 0.4, duration: 1.5)
        ])
        run(SKAction.repeatForever(pulse))
        
        // Add border for visibility during development
        addBorderEffect()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBorderEffect() {
        let border = SKShapeNode(rectOf: config.size)
        border.strokeColor = config.isLightDependent ? .yellow : .green
        border.lineWidth = 2
        border.alpha = 0.5
        border.zPosition = 1
        addChild(border)
    }
    
    func activate() {
        isActive = true
        let brighten = SKAction.fadeAlpha(to: 0.6, duration: 0.3)
        run(brighten, withKey: "activate")
    }
    
    func deactivate() {
        isActive = false
        let dim = SKAction.fadeAlpha(to: 0.3, duration: 0.3)
        run(dim, withKey: "deactivate")
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
