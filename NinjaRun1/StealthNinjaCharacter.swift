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

    // Idle animations by direction (4 frames each)
    private let idleDirections = ["south", "south_west", "north_west"]
    private var idleTextures: [String: [SKTexture]] = [:]

    // Crouch animations by direction (6 frames each) — used when hiding
    private let crouchDirections = ["south", "south_west", "south_east", "north_east", "north_west"]  // Note: south_east uses south frames mirrored
    private var crouchTextures: [String: [SKTexture]] = [:]

    init() {
        let texture = SKTexture(imageNamed: "ninja_south")
        super.init(texture: texture, color: .clear, size: CGSize(width: 40, height: 50))
        self.name = "ninja"
        self.zPosition = 10

        // Pre-load idle textures
        for dir in idleDirections {
            let frames = (1...4).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "ninja_idle_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { idleTextures[dir] = frames }
        }

        // Pre-load crouch textures
        for dir in crouchDirections {
            let frames = (1...6).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "ninja_crouch_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { crouchTextures[dir] = frames }
        }
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
        removeAction(forKey: "idleAnim")
        removeAction(forKey: "crouchAnim")

        let angle = atan2(point.y - position.y, point.x - position.x)
        updateFacing(angle: angle)

        // Flip walk frames based on horizontal direction
        // Walk textures face left by default, so negate when moving right
        xScale = (point.x < position.x) ? abs(xScale) : -abs(xScale)

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

    /// Returns the best idle direction key for the current facing angle
    private func bestIdleDirection() -> String? {
        let dir = directionName(for: facingAngle)
        if idleTextures[dir] != nil { return dir }
        // Fallback mapping: try related directions
        let fallbacks: [String: [String]] = [
            "south": ["south"],
            "south_west": ["south_west", "south"],
            "south_east": ["south_west", "south"],  // mirror
            "west": ["south_west", "north_west", "south"],
            "north_west": ["north_west", "south_west"],
            "north": ["north_west"],
            "north_east": ["north_west"],  // mirror
            "east": ["south_west", "south"]  // mirror
        ]
        for fb in (fallbacks[dir] ?? ["south"]) {
            if idleTextures[fb] != nil { return fb }
        }
        return idleTextures.keys.first
    }

    /// Returns the best crouch direction key for the current facing angle
    private func bestCrouchDirection() -> String? {
        let dir = directionName(for: facingAngle)
        if crouchTextures[dir] != nil { return dir }
        let fallbacks: [String: [String]] = [
            "south": ["south"],
            "south_west": ["south_west", "south"],
            "south_east": ["south_east", "south"],
            "west": ["south_west", "north_west", "south"],
            "north_west": ["north_west", "south_west"],
            "north": ["north_west", "north_east"],
            "north_east": ["north_east", "north_west"],
            "east": ["south_east", "north_east", "south"]
        ]
        for fb in (fallbacks[dir] ?? ["south"]) {
            if crouchTextures[fb] != nil { return fb }
        }
        return crouchTextures.keys.first
    }

    private func startIdleAnimation() {
        guard let dir = bestIdleDirection(), let frames = idleTextures[dir] else { return }
        let facingDir = directionName(for: facingAngle)
        // Mirror for east-side directions
        let shouldMirror = ["east", "south_east", "north_east"].contains(facingDir)
        xScale = shouldMirror ? -abs(xScale) : abs(xScale)

        let anim = SKAction.animate(with: frames, timePerFrame: 0.35)
        run(SKAction.repeatForever(anim), withKey: "idleAnim")
    }

    private func startCrouchAnimation() {
        guard let dir = bestCrouchDirection(), let frames = crouchTextures[dir] else { return }
        let facingDir = directionName(for: facingAngle)
        let shouldMirror = ["east", "south_east", "north_east"].contains(facingDir)
        xScale = shouldMirror ? -abs(xScale) : abs(xScale)

        // Play crouch-down once, then hold last frame
        let crouchDown = SKAction.animate(with: frames, timePerFrame: 0.08)
        let holdBreath = SKAction.repeatForever(SKAction.sequence([
            SKAction.scaleY(to: 0.97, duration: 1.0),
            SKAction.scaleY(to: 1.0, duration: 1.0)
        ]))
        run(SKAction.sequence([crouchDown, SKAction.run { [weak self] in
            self?.run(holdBreath, withKey: "crouchBreathing")
        }]), withKey: "crouchAnim")
    }

    func hide() {
        currentState = .hiding
        removeAction(forKey: "movement")
        removeAction(forKey: "walkAnimation")
        removeAction(forKey: "idleAnim")

        if isInHidingZone {
            // Play crouch animation when actually hiding
            startCrouchAnimation()
            run(SKAction.fadeAlpha(to: 0.3, duration: 0.3), withKey: "hiding")
        } else {
            xScale = abs(xScale)
            updateFacing(angle: facingAngle)
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
        removeAction(forKey: "crouchAnim")
        removeAction(forKey: "crouchBreathing")
        setScale(1.0)  // Reset any crouch scale
        xScale = abs(xScale) // Reset flip
        updateFacing(angle: facingAngle)
        run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))
        // Start idle animation when standing still
        startIdleAnimation()
    }

    func detected() {
        currentState = .detected
        removeAllActions()
        updateFacing(angle: facingAngle)
        let flash = SKAction.sequence([
            SKAction.colorize(with: PastelPalette.dustyRose, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 5), withKey: "detected")
    }
}
