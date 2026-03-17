//
//  GameScene+AmbientLife.swift
//  NinjaRun1
//
//  Ambient life system: decorative creatures and villagers.
//

import SpriteKit

extension GameScene {

    func addAmbientLife() {
        let w = currentLevel.levelWidth
        let theme = currentLevel.theme

        let isDaytime = (theme != .nightCastle && theme != .nightGarden)
        if isDaytime {
            let butterflyCount = Int.random(in: 3...5)
            for _ in 0..<butterflyCount {
                spawnButterfly(in: CGRect(x: 40, y: 100, width: w - 80, height: 280))
            }
        }

        if theme == .meadowPath || theme == .villageFarm || theme == .sunnyVillage || theme == .harborTown {
            let catCount = Int.random(in: 1...2)
            for _ in 0..<catCount {
                let x = CGFloat.random(in: 80...(w - 80))
                let y = CGFloat.random(in: 90...130)
                spawnIdleCritter(textureName: "cat", at: CGPoint(x: x, y: y), size: CGSize(width: 24, height: 24))
            }
        }

        if theme == .meadowPath || theme == .villageFarm || theme == .sunnyVillage {
            let chickenCount = Int.random(in: 2...4)
            for _ in 0..<chickenCount {
                let x = CGFloat.random(in: 60...(w - 60))
                let y: CGFloat = Bool.random() ? CGFloat.random(in: 85...130) : CGFloat.random(in: 280...330)
                spawnPeckingChicken(at: CGPoint(x: x, y: y))
            }
        }

        if theme == .nightGarden || theme == .nightCastle {
            let owlCount = Int.random(in: 1...3)
            for _ in 0..<owlCount {
                let x = CGFloat.random(in: 100...(w - 100))
                let y = CGFloat.random(in: 320...380)
                spawnOwl(at: CGPoint(x: x, y: y))
            }
        }

        if theme == .nightGarden || theme == .nightCastle {
            for _ in 0..<Int.random(in: 8...15) {
                let x = CGFloat.random(in: 20...(w - 20))
                let y = CGFloat.random(in: 80...380)
                spawnFirefly(at: CGPoint(x: x, y: y))
            }
        }

        if theme == .festivalGrounds || theme == .sunnyVillage {
            let x = CGFloat.random(in: 100...(w - 100))
            spawnWanderingVillager(textureName: "monk", at: CGPoint(x: x, y: CGFloat.random(in: 280...320)), size: CGSize(width: 32, height: 40))
        }

        if theme == .festivalGrounds || theme == .harborTown {
            let x = CGFloat.random(in: 100...(w - 100))
            spawnWanderingVillager(textureName: "kimono_lady", at: CGPoint(x: x, y: CGFloat.random(in: 100...140)), size: CGSize(width: 32, height: 40))
        }

        if theme == .meadowPath || theme == .villageFarm || theme == .sunnyVillage {
            let rabbitCount = Int.random(in: 1...2)
            for _ in 0..<rabbitCount {
                let x = CGFloat.random(in: 60...(w - 60))
                let y = CGFloat.random(in: 280...340)
                spawnHoppingRabbit(at: CGPoint(x: x, y: y))
            }
        }

        if theme == .riverCrossing || theme == .nightGarden {
            let frogCount = Int.random(in: 1...3)
            for _ in 0..<frogCount {
                let x = CGFloat.random(in: 60...(w - 60))
                let y = CGFloat.random(in: 70...120)
                spawnFrog(at: CGPoint(x: x, y: y))
            }
        }

        if theme == .meadowPath || theme == .villageFarm {
            for _ in 0..<Int.random(in: 3...6) {
                let tex = SKTexture(imageNamed: "wildflowers")
                guard tex.size() != .zero else { break }
                let flowers = SKSpriteNode(texture: tex, size: CGSize(width: 36, height: 24))
                flowers.position = CGPoint(
                    x: CGFloat.random(in: 50...(w - 50)),
                    y: Bool.random() ? CGFloat.random(in: 70...120) : CGFloat.random(in: 290...340)
                )
                flowers.zPosition = 3
                flowers.alpha = 0.9
                worldNode.addChild(flowers)
            }
        }

        let signTex = SKTexture(imageNamed: "signpost")
        if signTex.size() != .zero {
            let sign = SKSpriteNode(texture: signTex, size: CGSize(width: 24, height: 36))
            sign.position = CGPoint(x: currentLevel.startPosition.x + 50, y: currentLevel.startPosition.y - 30)
            sign.zPosition = 5
            worldNode.addChild(sign)
        }
    }

    // MARK: - Ambient Creature Spawners

    private func spawnButterfly(in area: CGRect) {
        let tex = SKTexture(imageNamed: "butterfly_south")
        let sprite: SKSpriteNode
        if tex.size() != .zero {
            sprite = SKSpriteNode(texture: tex, size: CGSize(width: 18, height: 18))
        } else {
            sprite = SKSpriteNode(color: PastelPalette.softPeach, size: CGSize(width: 8, height: 6))
        }
        let startX = CGFloat.random(in: area.minX...area.maxX)
        let startY = CGFloat.random(in: area.minY...area.maxY)
        sprite.position = CGPoint(x: startX, y: startY)
        sprite.zPosition = 15
        sprite.alpha = 0.85
        worldNode.addChild(sprite)

        let flutterDirs = ["east", "south", "west"]
        var flutterFrames: [String: [SKTexture]] = [:]
        for dir in flutterDirs {
            let frames = (1...6).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "butterfly_flutter_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { flutterFrames[dir] = frames }
        }

        let buildLeg: () -> SKAction = {
            let dx = CGFloat.random(in: -60...60)
            let dy = CGFloat.random(in: -25...25)
            let dur = TimeInterval.random(in: 2.5...4.0)
            let dir: String = dx > 15 ? "east" : (dx < -15 ? "west" : "south")
            return SKAction.group([
                SKAction.moveBy(x: dx, y: dy, duration: dur),
                SKAction.run {
                    if let frames = flutterFrames[dir] {
                        let anim = SKAction.animate(with: frames, timePerFrame: 0.08)
                        sprite.run(SKAction.repeatForever(anim), withKey: "flutter")
                    }
                }
            ])
        }

        if let southFrames = flutterFrames["south"] ?? flutterFrames.values.first {
            let anim = SKAction.animate(with: southFrames, timePerFrame: 0.08)
            sprite.run(SKAction.repeatForever(anim), withKey: "flutter")
        }

        let wander = SKAction.repeatForever(SKAction.sequence([
            buildLeg(),
            buildLeg(),
            buildLeg()
        ]))
        sprite.run(wander)
    }

    private func spawnIdleCritter(textureName: String, at pos: CGPoint, size: CGSize) {
        let tex = SKTexture(imageNamed: "\(textureName)_south")
        guard tex.size() != .zero else { return }
        let sprite = SKSpriteNode(texture: tex, size: size)
        sprite.position = pos
        sprite.zPosition = 8
        worldNode.addChild(sprite)

        var idleFrames: [String: [SKTexture]] = [:]
        for dir in ["south", "east", "north", "west"] {
            let frames = (1...8).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "\(textureName)_idle_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { idleFrames[dir] = frames }
        }

        let hasIdleAnim = !idleFrames.isEmpty

        let directions = ["south", "east", "west"]
        let lookAround = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 3...7)),
            SKAction.run {
                let dir = directions.randomElement()!
                if let frames = idleFrames[dir] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.15)
                    sprite.run(SKAction.repeat(anim, count: 2), withKey: "idleAnim")
                } else {
                    let t = SKTexture(imageNamed: "\(textureName)_\(dir)")
                    if t.size() != .zero { sprite.texture = t }
                }
            },
            SKAction.wait(forDuration: TimeInterval.random(in: 1...3)),
            SKAction.run {
                sprite.removeAction(forKey: "idleAnim")
                if let frames = idleFrames["south"] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.2)
                    sprite.run(SKAction.repeatForever(anim), withKey: "idleAnim")
                } else {
                    let t = SKTexture(imageNamed: "\(textureName)_south")
                    if t.size() != .zero { sprite.texture = t }
                }
            }
        ]))
        sprite.run(lookAround)

        if let southFrames = idleFrames["south"] {
            let anim = SKAction.animate(with: southFrames, timePerFrame: 0.2)
            sprite.run(SKAction.repeatForever(anim), withKey: "idleAnim")
        }

        if !hasIdleAnim {
            let breathe = SKAction.repeatForever(SKAction.sequence([
                SKAction.scaleY(to: 1.03, duration: 1.0),
                SKAction.scaleY(to: 0.97, duration: 1.0)
            ]))
            sprite.run(breathe)
        }
    }

    private func spawnPeckingChicken(at pos: CGPoint) {
        let tex = SKTexture(imageNamed: "chicken_south")
        guard tex.size() != .zero else { return }
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 20, height: 20))
        sprite.position = pos
        sprite.zPosition = 8
        worldNode.addChild(sprite)

        var chickenWalk: [String: [SKTexture]] = [:]
        for dir in ["south", "east", "north"] {
            let frames = (1...4).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "chicken_walk_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { chickenWalk[dir] = frames }
        }

        let peck = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 1...3)),
            SKAction.scaleY(to: 0.7, duration: 0.15),
            SKAction.scaleY(to: 1.0, duration: 0.15),
            SKAction.wait(forDuration: 0.3),
            SKAction.scaleY(to: 0.7, duration: 0.15),
            SKAction.scaleY(to: 1.0, duration: 0.15)
        ])

        let wander = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 3...6)),
            SKAction.run {
                let dx = CGFloat.random(in: -25...25)
                let dir: String = dx > 5 ? "east" : (dx < -5 ? "east" : "south")
                if let frames = chickenWalk[dir] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.1)
                    sprite.run(SKAction.repeat(anim, count: 3), withKey: "chickenWalk")
                }
                if dx > 5 {
                    sprite.xScale = -abs(sprite.xScale)
                } else if dx < -5 {
                    sprite.xScale = abs(sprite.xScale)
                }
                let t = SKTexture(imageNamed: "chicken_\(dir)")
                if t.size() != .zero { sprite.texture = t }
                sprite.run(SKAction.moveBy(x: dx, y: CGFloat.random(in: -10...10), duration: 1.0))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run {
                sprite.removeAction(forKey: "chickenWalk")
                sprite.xScale = abs(sprite.xScale)
                let t = SKTexture(imageNamed: "chicken_south")
                if t.size() != .zero { sprite.texture = t }
            }
        ])
        sprite.run(SKAction.repeatForever(peck))
        sprite.run(SKAction.repeatForever(wander))
    }

    private func spawnOwl(at pos: CGPoint) {
        let tex = SKTexture(imageNamed: "owl_south")
        guard tex.size() != .zero else { return }
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 22, height: 22))
        sprite.position = pos
        sprite.zPosition = 15
        worldNode.addChild(sprite)

        var owlWalk: [String: [SKTexture]] = [:]
        for dir in ["south", "east", "north", "west"] {
            let frames = (1...4).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "owl_walk_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { owlWalk[dir] = frames }
        }

        let blink = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 4...8)),
            SKAction.scaleY(to: 0.85, duration: 0.1),
            SKAction.scaleY(to: 1.0, duration: 0.1)
        ])

        let headTurn = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 5...10)),
            SKAction.run {
                let dir = ["east", "west"].randomElement()!
                if let frames = owlWalk[dir] {
                    let shuffle = SKAction.animate(with: frames, timePerFrame: 0.15)
                    sprite.run(shuffle, withKey: "owlShuffle")
                } else {
                    let t = SKTexture(imageNamed: "owl_\(dir)")
                    if t.size() != .zero { sprite.texture = t }
                }
            },
            SKAction.wait(forDuration: TimeInterval.random(in: 2...4)),
            SKAction.run {
                if let frames = owlWalk["south"] {
                    let shuffle = SKAction.animate(with: frames, timePerFrame: 0.15)
                    sprite.run(shuffle, withKey: "owlShuffle")
                } else {
                    let t = SKTexture(imageNamed: "owl_south")
                    if t.size() != .zero { sprite.texture = t }
                }
            }
        ])
        sprite.run(SKAction.repeatForever(blink))
        sprite.run(SKAction.repeatForever(headTurn))

        let glow = SKShapeNode(circleOfRadius: 16)
        glow.fillColor = SKColor(red: 1, green: 0.95, blue: 0.7, alpha: 0.08)
        glow.strokeColor = .clear
        glow.position = pos
        glow.zPosition = 14
        worldNode.addChild(glow)
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.04, duration: 2),
            SKAction.fadeAlpha(to: 0.12, duration: 2)
        ]))
        glow.run(pulse)
    }

    private func spawnFirefly(at pos: CGPoint) {
        let dot = SKShapeNode(circleOfRadius: 2)
        dot.fillColor = SKColor(red: 1, green: 0.95, blue: 0.5, alpha: 1)
        dot.strokeColor = .clear
        dot.position = pos
        dot.zPosition = 16
        dot.alpha = 0
        worldNode.addChild(dot)

        let fadeIn = SKAction.fadeAlpha(to: CGFloat.random(in: 0.4...0.8), duration: TimeInterval.random(in: 0.5...1.5))
        let hold = SKAction.wait(forDuration: TimeInterval.random(in: 0.5...2.0))
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: TimeInterval.random(in: 0.5...1.5))
        let wait = SKAction.wait(forDuration: TimeInterval.random(in: 1...4))
        let drift = SKAction.moveBy(x: CGFloat.random(in: -15...15), y: CGFloat.random(in: -10...10), duration: 3)
        let blink = SKAction.repeatForever(SKAction.sequence([fadeIn, hold, fadeOut, wait]))
        let wander = SKAction.repeatForever(SKAction.sequence([drift, drift.reversed()]))
        dot.run(blink)
        dot.run(wander)
    }

    private func spawnHoppingRabbit(at pos: CGPoint) {
        let tex = SKTexture(imageNamed: "rabbit_south")
        guard tex.size() != .zero else { return }
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 20, height: 20))
        sprite.position = pos
        sprite.zPosition = 8
        worldNode.addChild(sprite)

        var rabbitWalk: [String: [SKTexture]] = [:]
        for dir in ["south", "east", "west"] {
            let frames = (1...4).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "rabbit_walk_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { rabbitWalk[dir] = frames }
        }

        let hop = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 2...5)),
            SKAction.run {
                let dx = CGFloat.random(in: -30...30)
                let dir: String = dx > 5 ? "east" : (dx < -5 ? "west" : "south")
                if let frames = rabbitWalk[dir] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.08)
                    sprite.run(anim, withKey: "rabbitHop")
                }
                let t = SKTexture(imageNamed: "rabbit_\(dir)")
                if t.size() != .zero { sprite.texture = t }
                sprite.run(SKAction.group([
                    SKAction.moveBy(x: dx, y: CGFloat.random(in: -10...10), duration: 0.4),
                    SKAction.sequence([
                        SKAction.scaleY(to: 1.3, duration: 0.15),
                        SKAction.scaleY(to: 1.0, duration: 0.25)
                    ])
                ]))
            },
            SKAction.wait(forDuration: TimeInterval.random(in: 1...3)),
            SKAction.run {
                let t = SKTexture(imageNamed: "rabbit_south")
                if t.size() != .zero { sprite.texture = t }
            }
        ])
        sprite.run(SKAction.repeatForever(hop))
    }

    private func spawnFrog(at pos: CGPoint) {
        let tex = SKTexture(imageNamed: "frog_south")
        guard tex.size() != .zero else { return }
        let sprite = SKSpriteNode(texture: tex, size: CGSize(width: 18, height: 18))
        sprite.position = pos
        sprite.zPosition = 8
        worldNode.addChild(sprite)

        var frogIdle: [String: [SKTexture]] = [:]
        for dir in ["south", "east", "north"] {
            let frames = (1...8).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "frog_idle_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { frogIdle[dir] = frames }
        }

        let croak = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 4...10)),
            SKAction.run {
                let dir = ["south", "east"].randomElement()!
                if let frames = frogIdle[dir] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.12)
                    sprite.run(anim, withKey: "frogCroak")
                } else {
                    let puff = SKAction.sequence([
                        SKAction.scaleX(to: 1.15, duration: 0.2),
                        SKAction.scaleX(to: 1.0, duration: 0.2)
                    ])
                    sprite.run(SKAction.repeat(puff, count: 2))
                }
            }
        ])

        let hop = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 6...12)),
            SKAction.run {
                let dx = CGFloat.random(in: -20...20)
                let dir: String = dx > 5 ? "east" : "south"
                let t = SKTexture(imageNamed: "frog_\(dir)")
                if t.size() != .zero { sprite.texture = t }
                if let frames = frogIdle[dir] {
                    let hopAnim = SKAction.animate(with: Array(frames.prefix(4)), timePerFrame: 0.06)
                    sprite.run(hopAnim, withKey: "frogCroak")
                }
            },
            SKAction.group([
                SKAction.moveBy(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -8...8), duration: 0.3),
                SKAction.sequence([
                    SKAction.scaleY(to: 1.25, duration: 0.1),
                    SKAction.scaleY(to: 1.0, duration: 0.2)
                ])
            ])
        ])
        sprite.run(SKAction.repeatForever(croak))
        sprite.run(SKAction.repeatForever(hop))
    }

    private func spawnWanderingVillager(textureName: String, at pos: CGPoint, size: CGSize) {
        let tex = SKTexture(imageNamed: "\(textureName)_south")
        guard tex.size() != .zero else { return }
        let sprite = SKSpriteNode(texture: tex, size: size)
        sprite.position = pos
        sprite.zPosition = 7
        sprite.alpha = 0.9
        worldNode.addChild(sprite)

        var villagerWalk: [String: [SKTexture]] = [:]
        for dir in ["east", "south", "west"] {
            let frames = (1...4).compactMap { i -> SKTexture? in
                let t = SKTexture(imageNamed: "\(textureName)_walk_\(dir)_\(i)")
                return t.size() != .zero ? t : nil
            }
            if !frames.isEmpty { villagerWalk[dir] = frames }
        }

        let walkDist: CGFloat = CGFloat.random(in: 40...80)
        let walkDuration = TimeInterval.random(in: 4...7)
        let wander = SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
                if let frames = villagerWalk["east"] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.18)
                    sprite.run(SKAction.repeatForever(anim), withKey: "villagerWalk")
                } else {
                    let t = SKTexture(imageNamed: "\(textureName)_east")
                    if t.size() != .zero { sprite.texture = t }
                }
                sprite.xScale = abs(sprite.xScale)
            },
            SKAction.moveBy(x: walkDist, y: 0, duration: walkDuration),
            SKAction.run {
                sprite.removeAction(forKey: "villagerWalk")
                let t = SKTexture(imageNamed: "\(textureName)_south")
                if t.size() != .zero { sprite.texture = t }
            },
            SKAction.wait(forDuration: TimeInterval.random(in: 2...5)),
            SKAction.run {
                if let frames = villagerWalk["west"] {
                    let anim = SKAction.animate(with: frames, timePerFrame: 0.18)
                    sprite.run(SKAction.repeatForever(anim), withKey: "villagerWalk")
                } else {
                    let t = SKTexture(imageNamed: "\(textureName)_west")
                    if t.size() != .zero { sprite.texture = t }
                }
            },
            SKAction.moveBy(x: -walkDist, y: 0, duration: walkDuration),
            SKAction.run {
                sprite.removeAction(forKey: "villagerWalk")
                let t = SKTexture(imageNamed: "\(textureName)_south")
                if t.size() != .zero { sprite.texture = t }
            },
            SKAction.wait(forDuration: TimeInterval.random(in: 2...5))
        ]))
        sprite.run(wander)
    }
}
