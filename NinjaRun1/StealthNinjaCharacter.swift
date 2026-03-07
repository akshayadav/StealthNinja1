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

    private var facingAngle: CGFloat = -CGFloat.pi / 2  // default: facing south

    private let walkTextures: [SKTexture] = (1...6).map { SKTexture(imageNamed: "ninja_walk_\($0)") }

    init() {
        let texture = SKTexture(imageNamed: "ninja_south")
        super.init(texture: texture, color: .clear, size: CGSize(width: 40, height: 50))
        self.name = "ninja"
        self.zPosition = 10
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Facing

    private func updateFacing(angle: CGFloat) {
        facingAngle = angle
        let dirName = directionName(for: angle)
        let tex = SKTexture(imageNamed: "ninja_\(dirName)")
        if tex.size() != .zero { texture = tex }
    }

    private func directionName(for angle: CGFloat) -> String {
        var deg = angle * 180.0 / .pi
        if deg < 0 { deg += 360 }
        switch deg {
        case 337.5..<360, 0..<22.5:  return "east"
        case 22.5..<67.5:            return "north_east"
        case 67.5..<112.5:           return "north"
        case 112.5..<157.5:          return "north_west"
        case 157.5..<202.5:          return "west"
        case 202.5..<247.5:          return "south_west"
        case 247.5..<292.5:          return "south"
        default:                     return "south_east"
        }
    }

    // MARK: - Actions

    func moveTo(point: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        currentState = .moving
        removeAction(forKey: "idle")

        let angle = atan2(point.y - position.y, point.x - position.x)
        updateFacing(angle: angle)

        // Flip walk frames based on horizontal direction
        xScale = (point.x < position.x) ? -abs(xScale) : abs(xScale)

        if !walkTextures.isEmpty {
            let anim = SKAction.animate(with: walkTextures, timePerFrame: 0.1)
            run(SKAction.repeatForever(anim), withKey: "walkAnimation")
        }

        let sequence = SKAction.sequence([
            SKAction.move(to: point, duration: duration),
            SKAction.run { [weak self] in
                self?.removeAction(forKey: "walkAnimation")
                completion()
            }
        ])
        run(sequence, withKey: "movement")
    }

    func hide() {
        currentState = .hiding
        removeAction(forKey: "movement")
        removeAction(forKey: "walkAnimation")
        updateFacing(angle: facingAngle)

        if isInHidingZone {
            run(SKAction.fadeAlpha(to: 0.3, duration: 0.3), withKey: "hiding")
        } else {
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.3),
                SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            ])
            run(SKAction.repeatForever(pulse), withKey: "exposed")
        }
    }

    func reveal() {
        removeAction(forKey: "hiding")
        removeAction(forKey: "exposed")
        removeAction(forKey: "walkAnimation")
        updateFacing(angle: facingAngle)
        run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
    }

    func detected() {
        currentState = .detected
        removeAllActions()
        updateFacing(angle: facingAngle)
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 5), withKey: "detected")
    }
}
