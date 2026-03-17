//
//  GameScene+Background.swift
//  NinjaRun1
//
//  Background rendering for all level themes.
//

import SpriteKit

extension GameScene {

    func createBackground() {
        switch currentLevel.theme {
        case .sunnyVillage:
            createSunnyVillageBackground()
            return
        case .meadowPath:
            createMeadowPathBackground()
            return
        case .villageFarm:
            createVillageFarmBackground()
            return
        case .riverCrossing:
            createRiverCrossingBackground()
            return
        case .harborTown:
            createHarborTownBackground()
            return
        case .festivalGrounds:
            createFestivalGroundsBackground()
            return
        case .nightGarden:
            createNightGardenBackground()
            return
        case .nightCastle:
            break  // fall through to default night castle rendering
        }

        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        // ── 1. Parallax background layers ──────────────────────────────
        parallaxLayers.removeAll()

        func addParallaxLayer(textureName: String, tileH: CGFloat, yCenter: CGFloat,
                              zPos: CGFloat, speed: CGFloat, tint: SKColor? = nil,
                              alpha: CGFloat = 1.0) {
            let container = SKNode()
            container.zPosition = zPos
            let tex = SKTexture(imageNamed: textureName)
            tex.filteringMode = .nearest
            let aspect = tex.size().width / tex.size().height
            let tileW = tileH * aspect
            let coverW = w + size.width
            for bx in stride(from: CGFloat(-size.width / 2), through: coverW, by: tileW) {
                let sprite = SKSpriteNode(texture: tex, size: CGSize(width: tileW, height: tileH))
                sprite.position = CGPoint(x: bx + tileW / 2, y: yCenter)
                sprite.alpha = alpha
                if let tint = tint {
                    sprite.color = tint
                    sprite.colorBlendFactor = 0.5
                }
                container.addChild(sprite)
            }
            addChild(container)
            parallaxLayers.append((node: container, speed: speed))
        }

        addParallaxLayer(textureName: "parallax_sky", tileH: 500, yCenter: 550,
                         zPos: -30, speed: 0.05)
        addParallaxLayer(textureName: "parallax_mountains", tileH: 350, yCenter: 420,
                         zPos: -28, speed: 0.15)
        addParallaxLayer(textureName: "parallax_trees", tileH: 300, yCenter: 380,
                         zPos: -26, speed: 0.35)
        addParallaxLayer(textureName: "parallax_foreground", tileH: 250, yCenter: 360,
                         zPos: -24, speed: 0.55)

        // ── Wang tile extraction helper ───────────────────────────────
        let wangPositions: [Int: (x: Int, y: Int)] = [
             0: (64, 32),   1: (96, 32),   2: (64, 64),   3: (32, 64),
             4: (64, 0),    5: (96, 64),   6: (0, 32),    7: (96, 96),
             8: (32, 32),   9: (64, 96),  10: (32, 0),   11: (0, 64),
            12: (96, 0),   13: (0, 0),    14: (32, 96),  15: (0, 96)
        ]
        func wangTile(atlas: SKTexture, wangID: Int) -> SKTexture {
            guard let pos = wangPositions[wangID] else { return atlas }
            let uvRect = CGRect(x: CGFloat(pos.x) / 128.0,
                                y: 1.0 - CGFloat(pos.y + 32) / 128.0,
                                width: 0.25, height: 0.25)
            let sub = SKTexture(rect: uvRect, in: atlas)
            sub.filteringMode = .nearest
            return sub
        }

        let stoneGrassAtlas = SKTexture(imageNamed: "tileset_stone_grass")
        stoneGrassAtlas.filteringMode = .nearest
        let stoneDirtAtlas = SKTexture(imageNamed: "tileset_stone_dirt")
        stoneDirtAtlas.filteringMode = .nearest
        let riceGrassAtlas = SKTexture(imageNamed: "tileset_rice_grass")
        riceGrassAtlas.filteringMode = .nearest

        let pureStone = wangTile(atlas: stoneGrassAtlas, wangID: 0)
        let pureGrass = wangTile(atlas: stoneGrassAtlas, wangID: 15)
        let grassTopStoneBot = wangTile(atlas: stoneGrassAtlas, wangID: 12)
        let stoneTopGrassBot = wangTile(atlas: stoneGrassAtlas, wangID: 3)
        let pureDirt = wangTile(atlas: stoneDirtAtlas, wangID: 15)
        let stoneToDirtTop = wangTile(atlas: stoneDirtAtlas, wangID: 12)
        let stoneToDirtBot = wangTile(atlas: stoneDirtAtlas, wangID: 3)
        let pureRice = wangTile(atlas: riceGrassAtlas, wangID: 0)
        let riceTopGrassBot = wangTile(atlas: riceGrassAtlas, wangID: 3)
        let grassTopRiceBot = wangTile(atlas: riceGrassAtlas, wangID: 12)

        // ── 2. Rice paddy fields (top & bottom) ────────────────────────
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let trans = SKSpriteNode(texture: grassTopRiceBot, size: CGSize(width: ts, height: ts))
            trans.position = CGPoint(x: gx + ts / 2, y: 380 + ts / 2)
            trans.zPosition = -12
            worldNode.addChild(trans)
            for y in stride(from: CGFloat(412), through: CGFloat(480), by: ts) {
                let tile = SKSpriteNode(texture: pureRice, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -12
                worldNode.addChild(tile)
            }
        }

        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let trans = SKSpriteNode(texture: riceTopGrassBot, size: CGSize(width: ts, height: ts))
            trans.position = CGPoint(x: gx + ts / 2, y: 68 + ts / 2)
            trans.zPosition = -12
            worldNode.addChild(trans)
            let tile = SKSpriteNode(texture: pureRice, size: CGSize(width: ts, height: ts))
            tile.position = CGPoint(x: gx + ts / 2, y: 36 + ts / 2)
            tile.zPosition = -12
            worldNode.addChild(tile)
        }

        // ── 3. Grass areas ─────────────────────────────────────────────
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let g = SKSpriteNode(texture: pureGrass, size: CGSize(width: ts, height: ts))
            g.position = CGPoint(x: gx + ts / 2, y: 348 + ts / 2)
            g.zPosition = -11
            worldNode.addChild(g)
        }
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let g = SKSpriteNode(texture: pureGrass, size: CGSize(width: ts, height: ts))
            g.position = CGPoint(x: gx + ts / 2, y: 100 + ts / 2)
            g.zPosition = -11
            worldNode.addChild(g)
        }

        // ── 4. Stone courtyard with Wang tile transitions ───────────────
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: grassTopStoneBot, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 316 + ts / 2)
            t.zPosition = -10
            worldNode.addChild(t)
        }
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            for y in stride(from: CGFloat(140), through: CGFloat(284), by: ts) {
                let tile = SKSpriteNode(texture: pureStone, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -10
                worldNode.addChild(tile)
            }
        }
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: stoneTopGrassBot, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 132 + ts / 2)
            t.zPosition = -10
            worldNode.addChild(t)
        }

        // ── 5. Dirt path with transitions ───────────────────────────────
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: stoneToDirtTop, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 236 + ts / 2)
            t.zPosition = -9
            worldNode.addChild(t)
        }
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            for y in stride(from: CGFloat(172), through: CGFloat(204), by: ts) {
                let tile = SKSpriteNode(texture: pureDirt, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -9
                worldNode.addChild(tile)
            }
        }
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: stoneToDirtBot, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 140 + ts / 2)
            t.zPosition = -9
            worldNode.addChild(t)
        }

        // ── 6. Stone wall & fence borders ───────────────────────────────
        let wallTex = SKTexture(imageNamed: "stone_wall")
        wallTex.filteringMode = .nearest
        for gx in stride(from: CGFloat(0), through: w, by: 96) {
            let wall = SKSpriteNode(texture: wallTex, size: CGSize(width: 96, height: 48))
            wall.position = CGPoint(x: gx + 48, y: 370)
            wall.zPosition = -8
            worldNode.addChild(wall)
        }

        let fenceTex = SKTexture(imageNamed: "japanese_fence")
        fenceTex.filteringMode = .nearest
        for gx in stride(from: CGFloat(0), through: w, by: 96) {
            let fence = SKSpriteNode(texture: fenceTex, size: CGSize(width: 96, height: 36))
            fence.position = CGPoint(x: gx + 48, y: 95)
            fence.alpha = 0.85
            fence.zPosition = -7
            worldNode.addChild(fence)
        }

        // ── 7. Decorative world props ────────────────────────────────────
        addWorldProps()
    }

    // MARK: - Sunny Village Theme
    private func createSunnyVillageBackground() {
        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        let bgTex = SKTexture(imageNamed: "sunny_village_bg")
        bgTex.filteringMode = .nearest
        let bgHeight: CGFloat = 500
        let bgAspect = bgTex.size().width / max(bgTex.size().height, 1)
        let bgTileW = bgHeight * bgAspect
        for bx in stride(from: CGFloat(0), through: w, by: bgTileW) {
            let bg = SKSpriteNode(texture: bgTex, size: CGSize(width: bgTileW, height: bgHeight))
            bg.position = CGPoint(x: bx + bgTileW / 2, y: 520)
            bg.zPosition = -20
            worldNode.addChild(bg)
        }

        let sunTint = SKSpriteNode(color: SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 0.12),
                                   size: CGSize(width: w, height: 600))
        sunTint.position = CGPoint(x: w / 2, y: 300)
        sunTint.zPosition = -18
        worldNode.addChild(sunTint)

        let grassColor = SKColor(red: 0.35, green: 0.62, blue: 0.18, alpha: 1)
        let grassBase = SKSpriteNode(color: grassColor, size: CGSize(width: w, height: 400))
        grassBase.position = CGPoint(x: w / 2, y: 220)
        grassBase.zPosition = -12
        worldNode.addChild(grassBase)

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        if grassTex.size() != .zero {
            for x in stride(from: CGFloat(0), through: w, by: ts) {
                for y in stride(from: CGFloat(60), through: CGFloat(400), by: ts) {
                    let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                    g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                    g.alpha = 0.15
                    g.color = PastelPalette.sageGreen
                    g.colorBlendFactor = 0.6
                    g.zPosition = -11
                    worldNode.addChild(g)
                }
            }
        }

        let riceTex = SKTexture(imageNamed: "rice_field_tile")
        riceTex.filteringMode = .nearest
        let ricePlantTex = SKTexture(imageNamed: "rice_plant_tile")
        ricePlantTex.filteringMode = .nearest

        for y in stride(from: CGFloat(340), through: CGFloat(400), by: ts) {
            for gx in stride(from: CGFloat(0), through: w, by: ts) {
                let tile = SKSpriteNode(texture: riceTex, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -10
                worldNode.addChild(tile)
            }
        }
        for y in stride(from: CGFloat(350), through: CGFloat(390), by: ts) {
            for gx in stride(from: CGFloat(0), through: w, by: ts * 1.5) {
                let plant = SKSpriteNode(texture: ricePlantTex, size: CGSize(width: ts, height: ts))
                plant.position = CGPoint(x: gx + CGFloat.random(in: 0...ts),
                                         y: y + CGFloat.random(in: -8...8))
                plant.alpha = CGFloat.random(in: 0.5...0.8)
                plant.zPosition = -9
                worldNode.addChild(plant)
            }
        }

        let dirtTex = SKTexture(imageNamed: "dirt_path_tile")
        dirtTex.filteringMode = .nearest
        let pathColor = SKColor(red: 0.55, green: 0.42, blue: 0.28, alpha: 1)
        let pathBase = SKSpriteNode(color: pathColor, size: CGSize(width: w, height: 100))
        pathBase.position = CGPoint(x: w / 2, y: 195)
        pathBase.zPosition = -9
        worldNode.addChild(pathBase)

        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let dirt = SKSpriteNode(texture: dirtTex, size: CGSize(width: ts, height: ts))
            dirt.position = CGPoint(x: gx + ts / 2, y: 195)
            dirt.alpha = 0.6
            dirt.zPosition = -8
            worldNode.addChild(dirt)
        }

        for yEdge: CGFloat in [145, 245] {
            let edge = SKSpriteNode(color: SKColor(red: 0.45, green: 0.55, blue: 0.22, alpha: 0.5),
                                    size: CGSize(width: w, height: 4))
            edge.position = CGPoint(x: w / 2, y: yEdge)
            edge.zPosition = -7
            worldNode.addChild(edge)
        }

        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let tile = SKSpriteNode(texture: riceTex, size: CGSize(width: ts, height: ts))
            tile.position = CGPoint(x: gx + ts / 2, y: 50)
            tile.zPosition = -10
            worldNode.addChild(tile)
        }

        addSunnyVillageProps()
    }

    private func addSunnyVillageProps() {
        let w = currentLevel.levelWidth

        var hx: CGFloat = 250
        while hx < w - 200 {
            let house = SKSpriteNode(imageNamed: "farmhouse")
            house.size = CGSize(width: 80, height: 80)
            house.position = CGPoint(x: hx, y: 330 + CGFloat.random(in: -10...10))
            house.zPosition = 6
            worldNode.addChild(house)
            hx += 600 + CGFloat.random(in: -80...80)
        }

        var cx: CGFloat = 150
        while cx < w - 100 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 72, height: 72)
            let cy: CGFloat = Bool.random() ? (310 + CGFloat.random(in: -15...15)) : (90 + CGFloat.random(in: -10...10))
            cherry.position = CGPoint(x: cx, y: cy)
            cherry.zPosition = 6
            worldNode.addChild(cherry)

            let pinkGlow = SKShapeNode(circleOfRadius: 30)
            pinkGlow.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 0.08)
            pinkGlow.strokeColor = .clear
            pinkGlow.position = CGPoint(x: cx, y: cy - 10)
            pinkGlow.zPosition = 2
            worldNode.addChild(pinkGlow)

            cx += 500 + CGFloat.random(in: -70...70)
        }

        var cartX: CGFloat = 400
        while cartX < w - 300 {
            let cart = SKSpriteNode(imageNamed: "hay_cart")
            cart.size = CGSize(width: 48, height: 36)
            cart.position = CGPoint(x: cartX + CGFloat.random(in: -30...30),
                                    y: 290 + CGFloat.random(in: -10...10))
            cart.zPosition = 4
            worldNode.addChild(cart)
            cartX += 700 + CGFloat.random(in: -80...80)
        }

        var cowX: CGFloat = 500
        while cowX < w - 300 {
            let cow = SKSpriteNode(imageNamed: "village_cow_south")
            cow.size = CGSize(width: 44, height: 32)
            cow.position = CGPoint(x: cowX + CGFloat.random(in: -40...40),
                                   y: 320 + CGFloat.random(in: -20...20))
            cow.zPosition = 5
            worldNode.addChild(cow)

            let sway = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -8...8), y: 0, duration: Double.random(in: 3...6)),
                SKAction.moveBy(x: CGFloat.random(in: -8...8), y: 0, duration: Double.random(in: 3...6))
            ])
            cow.run(SKAction.repeatForever(sway))

            cowX += 800 + CGFloat.random(in: -100...100)
        }

        var kidX: CGFloat = 350
        while kidX < w - 300 {
            let child = SKSpriteNode(imageNamed: "village_child_south")
            child.size = CGSize(width: 24, height: 28)
            child.position = CGPoint(x: kidX + CGFloat.random(in: -30...30),
                                     y: 280 + CGFloat.random(in: -15...15))
            child.zPosition = 5
            worldNode.addChild(child)

            let runRadius: CGFloat = CGFloat.random(in: 15...30)
            let runDuration = Double.random(in: 3...5)
            let circle = SKAction.customAction(withDuration: runDuration) { node, elapsed in
                let t = elapsed / CGFloat(runDuration)
                let angle = t * CGFloat.pi * 2
                node.position = CGPoint(
                    x: node.position.x + cos(angle) * 0.3,
                    y: node.position.y + sin(angle) * 0.3
                )
            }
            child.run(SKAction.repeatForever(circle))

            kidX += 900 + CGFloat.random(in: -100...100)
        }

        var bx: CGFloat = 120
        while bx < w - 80 {
            let bamboo = SKSpriteNode(imageNamed: "bamboo_cluster")
            bamboo.size = CGSize(width: 44, height: 52)
            bamboo.position = CGPoint(x: bx, y: 85 + CGFloat.random(in: -8...8))
            bamboo.zPosition = 5
            worldNode.addChild(bamboo)
            bx += 400 + CGFloat.random(in: -60...60)
        }

        let pondX = w / 2 + CGFloat.random(in: -200...200)
        let pond = SKSpriteNode(imageNamed: "koi_pond")
        pond.size = CGSize(width: 64, height: 56)
        pond.position = CGPoint(x: pondX, y: 60)
        pond.zPosition = 4
        worldNode.addChild(pond)

        let bridge = SKSpriteNode(imageNamed: "wooden_bridge")
        bridge.size = CGSize(width: 52, height: 52)
        bridge.position = CGPoint(x: pondX, y: 65)
        bridge.zPosition = 5
        worldNode.addChild(bridge)

        var lx: CGFloat = 200
        while lx < w - 100 {
            let lantern = SKSpriteNode(imageNamed: "stone_lantern")
            lantern.size = CGSize(width: 28, height: 38)
            let ly: CGFloat = Bool.random() ? 260 : 130
            lantern.position = CGPoint(x: lx, y: ly)
            lantern.zPosition = 4
            worldNode.addChild(lantern)
            lx += 450 + CGFloat.random(in: -50...50)
        }

        var rx: CGFloat = 300
        while rx < w - 100 {
            let prop = SKSpriteNode(imageNamed: Bool.random() ? "barrel" : "crate")
            prop.size = CGSize(width: 30, height: 30)
            prop.position = CGPoint(x: rx, y: 300 + CGFloat.random(in: -15...15))
            prop.zPosition = 4
            worldNode.addChild(prop)
            rx += 500 + CGFloat.random(in: -60...60)
        }

        for hp in currentLevel.hidingPoints {
            if Bool.random() {
                let crate = SKSpriteNode(imageNamed: "crate")
                crate.size = CGSize(width: 28, height: 28)
                let offset: CGFloat = Bool.random() ? 35 : -35
                crate.position = CGPoint(x: hp.position.x + offset, y: hp.position.y - 15)
                crate.zPosition = 3
                worldNode.addChild(crate)
            }
        }
    }

    // MARK: - Meadow Path Theme (Side-view)
    private func createMeadowPathBackground() {
        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        parallaxLayers.removeAll()
        func addParallaxLayer(textureName: String, tileH: CGFloat, yCenter: CGFloat,
                              zPos: CGFloat, speed: CGFloat, fallbackColor: SKColor) {
            let container = SKNode()
            container.zPosition = zPos
            let tex = SKTexture(imageNamed: textureName)
            tex.filteringMode = .nearest
            if tex.size() != .zero {
                let aspect = tex.size().width / tex.size().height
                let tileW = tileH * aspect
                let coverW = w + size.width
                for bx in stride(from: CGFloat(-size.width / 2), through: coverW, by: tileW) {
                    let sprite = SKSpriteNode(texture: tex, size: CGSize(width: tileW, height: tileH))
                    sprite.position = CGPoint(x: bx + tileW / 2, y: yCenter)
                    container.addChild(sprite)
                }
            } else {
                let fill = SKSpriteNode(color: fallbackColor, size: CGSize(width: w + size.width, height: tileH))
                fill.position = CGPoint(x: w / 2, y: yCenter)
                container.addChild(fill)
            }
            addChild(container)
            parallaxLayers.append((node: container, speed: speed))
        }

        addParallaxLayer(textureName: "pastel_sky", tileH: 500, yCenter: 550,
                         zPos: -30, speed: 0.05, fallbackColor: PastelPalette.skyBlue)
        addParallaxLayer(textureName: "pastel_hills_far", tileH: 350, yCenter: 420,
                         zPos: -28, speed: 0.15, fallbackColor: PastelPalette.sageGreen.withAlphaComponent(0.4))
        addParallaxLayer(textureName: "pastel_hills_near", tileH: 300, yCenter: 380,
                         zPos: -26, speed: 0.35, fallbackColor: PastelPalette.sageGreen.withAlphaComponent(0.6))

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        let grassBase = SKSpriteNode(color: PastelPalette.sageGreen, size: CGSize(width: w, height: 400))
        grassBase.position = CGPoint(x: w / 2, y: 220)
        grassBase.zPosition = -12
        worldNode.addChild(grassBase)

        if grassTex.size() != .zero {
            for x in stride(from: CGFloat(0), through: w, by: ts) {
                for y in stride(from: CGFloat(60), through: CGFloat(400), by: ts) {
                    let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                    g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                    g.alpha = 0.15
                    g.color = PastelPalette.sageGreen
                    g.colorBlendFactor = 0.6
                    g.zPosition = -11
                    worldNode.addChild(g)
                }
            }
        }

        let dirtTex = SKTexture(imageNamed: "dirt_path_tile")
        dirtTex.filteringMode = .nearest
        let pathBase = SKSpriteNode(color: PastelPalette.warmBrown.withAlphaComponent(0.7),
                                    size: CGSize(width: w, height: 90))
        pathBase.position = CGPoint(x: w / 2, y: 195)
        pathBase.zPosition = -9
        worldNode.addChild(pathBase)

        if dirtTex.size() != .zero {
            for gx in stride(from: CGFloat(0), through: w, by: ts) {
                let dirt = SKSpriteNode(texture: dirtTex, size: CGSize(width: ts, height: ts))
                dirt.position = CGPoint(x: gx + ts / 2, y: 195)
                dirt.alpha = 0.3
                dirt.color = PastelPalette.warmBrown
                dirt.colorBlendFactor = 0.4
                dirt.zPosition = -8
                worldNode.addChild(dirt)
            }
        }

        addMeadowProps()
    }

    private func addMeadowProps() {
        let w = currentLevel.levelWidth

        let fenceTex = SKTexture(imageNamed: "picket_fence")
        fenceTex.filteringMode = .nearest
        for gx in stride(from: CGFloat(0), through: w, by: 96) {
            for fy: CGFloat in [140, 250] {
                let fence = SKSpriteNode(texture: fenceTex, size: CGSize(width: 96, height: 36))
                fence.position = CGPoint(x: gx + 48, y: fy)
                fence.alpha = fenceTex.size() == .zero ? 0 : 0.85
                fence.zPosition = -7
                worldNode.addChild(fence)
            }
        }

        var fx: CGFloat = 180
        while fx < w - 100 {
            let bush = SKSpriteNode(imageNamed: "flower_bush")
            bush.size = CGSize(width: 56, height: 42)
            let fy: CGFloat = Bool.random() ? (310 + CGFloat.random(in: -10...10)) : (90 + CGFloat.random(in: -8...8))
            bush.position = CGPoint(x: fx, y: fy)
            bush.zPosition = 5
            worldNode.addChild(bush)

            let glow = SKShapeNode(circleOfRadius: 22)
            glow.fillColor = PastelPalette.softPeach.withAlphaComponent(0.06)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: fx, y: fy - 5)
            glow.zPosition = 2
            worldNode.addChild(glow)

            fx += 350 + CGFloat.random(in: -50...50)
        }

        var cx: CGFloat = 250
        while cx < w - 150 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 72, height: 72)
            cherry.position = CGPoint(x: cx, y: 320 + CGFloat.random(in: -10...10))
            cherry.zPosition = 6
            worldNode.addChild(cherry)
            cx += 500 + CGFloat.random(in: -80...80)
        }

        var wx: CGFloat = 400
        while wx < w - 200 {
            let willow = SKSpriteNode(imageNamed: "willow_tree")
            willow.size = CGSize(width: 80, height: 96)
            willow.position = CGPoint(x: wx, y: 340 + CGFloat.random(in: -10...10))
            willow.zPosition = 6
            worldNode.addChild(willow)

            let sway = SKAction.sequence([
                SKAction.rotate(byAngle: 0.02, duration: 2.5),
                SKAction.rotate(byAngle: -0.02, duration: 2.5)
            ])
            willow.run(SKAction.repeatForever(sway))

            wx += 600 + CGFloat.random(in: -80...80)
        }
    }

    // MARK: - Village Farm Theme (Top-down)
    private func createVillageFarmBackground() {
        let w = currentLevel.levelWidth

        let skyTint = SKSpriteNode(color: PastelPalette.skyBlue.withAlphaComponent(0.3),
                                   size: CGSize(width: w, height: 600))
        skyTint.position = CGPoint(x: w / 2, y: 300)
        skyTint.zPosition = -20
        worldNode.addChild(skyTint)

        createSunnyVillageBackground()
    }

    // MARK: - River Crossing Theme (Side-view)
    private func createRiverCrossingBackground() {
        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        parallaxLayers.removeAll()
        func addParallax(name: String, h: CGFloat, y: CGFloat, z: CGFloat, spd: CGFloat, fallback: SKColor) {
            let container = SKNode()
            container.zPosition = z
            let tex = SKTexture(imageNamed: name)
            tex.filteringMode = .nearest
            if tex.size() != .zero {
                let aspect = tex.size().width / tex.size().height
                let tileW = h * aspect
                for bx in stride(from: CGFloat(-size.width / 2), through: w + size.width, by: tileW) {
                    let s = SKSpriteNode(texture: tex, size: CGSize(width: tileW, height: h))
                    s.position = CGPoint(x: bx + tileW / 2, y: y)
                    container.addChild(s)
                }
            } else {
                let fill = SKSpriteNode(color: fallback, size: CGSize(width: w + size.width, height: h))
                fill.position = CGPoint(x: w / 2, y: y)
                container.addChild(fill)
            }
            addChild(container)
            parallaxLayers.append((node: container, speed: spd))
        }

        addParallax(name: "pastel_sky", h: 500, y: 550, z: -30, spd: 0.05, fallback: PastelPalette.skyBlue)
        addParallax(name: "pastel_hills_far", h: 350, y: 420, z: -28, spd: 0.15,
                    fallback: PastelPalette.sageGreen.withAlphaComponent(0.3))

        let grassBase = SKSpriteNode(color: PastelPalette.sageGreen, size: CGSize(width: w, height: 400))
        grassBase.position = CGPoint(x: w / 2, y: 220)
        grassBase.zPosition = -12
        worldNode.addChild(grassBase)

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        if grassTex.size() != .zero {
            for x in stride(from: CGFloat(0), through: w, by: ts) {
                for y in stride(from: CGFloat(60), through: CGFloat(400), by: ts) {
                    let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                    g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                    g.alpha = 0.15
                    g.color = PastelPalette.sageGreen
                    g.colorBlendFactor = 0.6
                    g.zPosition = -11
                    worldNode.addChild(g)
                }
            }
        }

        let riverColor = SKColor(red: 0.55, green: 0.78, blue: 0.92, alpha: 1)
        let river = SKSpriteNode(color: riverColor, size: CGSize(width: w, height: 80))
        river.position = CGPoint(x: w / 2, y: 200)
        river.zPosition = -9
        worldNode.addChild(river)

        let shimmer = SKAction.sequence([
            SKAction.colorize(with: PastelPalette.skyBlue, colorBlendFactor: 0.3, duration: 2.0),
            SKAction.colorize(with: riverColor, colorBlendFactor: 0.0, duration: 2.0)
        ])
        river.run(SKAction.repeatForever(shimmer))

        var bx: CGFloat = 300
        while bx < w - 200 {
            let bridge = SKSpriteNode(imageNamed: "wooden_bridge")
            bridge.size = CGSize(width: 72, height: 72)
            bridge.position = CGPoint(x: bx, y: 200)
            bridge.zPosition = -8
            worldNode.addChild(bridge)
            bx += 500 + CGFloat.random(in: -80...80)
        }

        var wx: CGFloat = 150
        while wx < w - 100 {
            let willow = SKSpriteNode(imageNamed: "willow_tree")
            willow.size = CGSize(width: 80, height: 96)
            let wy: CGFloat = Bool.random() ? (300 + CGFloat.random(in: -15...15)) : (100 + CGFloat.random(in: -10...10))
            willow.position = CGPoint(x: wx, y: wy)
            willow.zPosition = 6
            worldNode.addChild(willow)
            let sway = SKAction.sequence([
                SKAction.rotate(byAngle: 0.015, duration: 3), SKAction.rotate(byAngle: -0.015, duration: 3)
            ])
            willow.run(SKAction.repeatForever(sway))
            wx += 400 + CGFloat.random(in: -60...60)
        }

        var fx: CGFloat = 200
        while fx < w - 100 {
            let bush = SKSpriteNode(imageNamed: "flower_bush")
            bush.size = CGSize(width: 48, height: 36)
            let fy: CGFloat = Bool.random() ? 280 : 120
            bush.position = CGPoint(x: fx, y: fy + CGFloat.random(in: -8...8))
            bush.zPosition = 5
            worldNode.addChild(bush)
            fx += 350 + CGFloat.random(in: -40...40)
        }
    }

    // MARK: - Harbor Town Theme (Top-down)
    private func createHarborTownBackground() {
        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        let waterColor = SKColor(red: 0.60, green: 0.82, blue: 0.93, alpha: 1)
        let waterBase = SKSpriteNode(color: waterColor, size: CGSize(width: w, height: 600))
        waterBase.position = CGPoint(x: w / 2, y: 300)
        waterBase.zPosition = -15
        worldNode.addChild(waterBase)

        let shimmer = SKAction.sequence([
            SKAction.colorize(with: PastelPalette.skyBlue, colorBlendFactor: 0.2, duration: 3),
            SKAction.colorize(with: waterColor, colorBlendFactor: 0.0, duration: 3)
        ])
        waterBase.run(SKAction.repeatForever(shimmer))

        let dockColor = PastelPalette.warmBrown
        let dock = SKSpriteNode(color: dockColor, size: CGSize(width: w, height: 120))
        dock.position = CGPoint(x: w / 2, y: 200)
        dock.zPosition = -10
        worldNode.addChild(dock)

        for gx in stride(from: CGFloat(0), through: w, by: 48) {
            let plank = SKShapeNode(rectOf: CGSize(width: 1, height: 120))
            plank.fillColor = SKColor.black.withAlphaComponent(0.1)
            plank.strokeColor = .clear
            plank.position = CGPoint(x: gx, y: 200)
            plank.zPosition = -9
            worldNode.addChild(plank)
        }

        let landBase = SKSpriteNode(color: PastelPalette.sageGreen, size: CGSize(width: w, height: 160))
        landBase.position = CGPoint(x: w / 2, y: 360)
        landBase.zPosition = -12
        worldNode.addChild(landBase)

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        if grassTex.size() != .zero {
            for x in stride(from: CGFloat(0), through: w, by: ts) {
                for y in stride(from: CGFloat(280), through: CGFloat(440), by: ts) {
                    let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                    g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                    g.alpha = 0.15
                    g.color = PastelPalette.sageGreen
                    g.colorBlendFactor = 0.6
                    g.zPosition = -11
                    worldNode.addChild(g)
                }
            }
        }

        var sx: CGFloat = 250
        while sx < w - 200 {
            let stall = SKSpriteNode(imageNamed: "market_stall")
            stall.size = CGSize(width: 72, height: 72)
            stall.position = CGPoint(x: sx, y: 310 + CGFloat.random(in: -10...10))
            stall.zPosition = 6
            worldNode.addChild(stall)
            sx += 450 + CGFloat.random(in: -60...60)
        }

        var rx: CGFloat = 150
        while rx < w - 100 {
            let prop = SKSpriteNode(imageNamed: Bool.random() ? "barrel" : "crate")
            prop.size = CGSize(width: 28, height: 28)
            prop.position = CGPoint(x: rx, y: 150 + CGFloat.random(in: -10...10))
            prop.zPosition = 4
            worldNode.addChild(prop)
            rx += 300 + CGFloat.random(in: -40...40)
        }
    }

    // MARK: - Festival Grounds Theme (Top-down)
    private func createFestivalGroundsBackground() {
        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        let grassBase = SKSpriteNode(color: PastelPalette.sageGreen.withAlphaComponent(0.8),
                                     size: CGSize(width: w, height: 500))
        grassBase.position = CGPoint(x: w / 2, y: 250)
        grassBase.zPosition = -15
        worldNode.addChild(grassBase)

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        if grassTex.size() != .zero {
            for x in stride(from: CGFloat(0), through: w, by: ts) {
                for y in stride(from: CGFloat(40), through: CGFloat(440), by: ts) {
                    let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                    g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                    g.alpha = 0.15
                    g.color = PastelPalette.sageGreen
                    g.colorBlendFactor = 0.6
                    g.zPosition = -14
                    worldNode.addChild(g)
                }
            }
        }

        let dirtTex = SKTexture(imageNamed: "dirt_path_tile")
        dirtTex.filteringMode = .nearest
        let pathBase = SKSpriteNode(color: PastelPalette.warmBrown.withAlphaComponent(0.6),
                                    size: CGSize(width: w, height: 80))
        pathBase.position = CGPoint(x: w / 2, y: 200)
        pathBase.zPosition = -10
        worldNode.addChild(pathBase)

        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let dirt = SKSpriteNode(texture: dirtTex, size: CGSize(width: ts, height: ts))
            dirt.position = CGPoint(x: gx + ts / 2, y: 200)
            dirt.alpha = 0.45
            dirt.zPosition = -9
            worldNode.addChild(dirt)
        }

        let lanternTex = SKTexture(imageNamed: "lantern_string")
        lanternTex.filteringMode = .nearest
        for gx in stride(from: CGFloat(0), through: w, by: 128) {
            let lanterns = SKSpriteNode(texture: lanternTex, size: CGSize(width: 128, height: 48))
            lanterns.position = CGPoint(x: gx + 64, y: 350)
            lanterns.zPosition = 7
            if lanternTex.size() != .zero {
                worldNode.addChild(lanterns)
            }
            let glow = SKShapeNode(rectOf: CGSize(width: 128, height: 20), cornerRadius: 10)
            glow.fillColor = PastelPalette.softGold.withAlphaComponent(0.06)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: gx + 64, y: 340)
            glow.zPosition = 2
            worldNode.addChild(glow)
        }

        var cx: CGFloat = 200
        while cx < w - 150 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 72, height: 72)
            cherry.position = CGPoint(x: cx, y: 320 + CGFloat.random(in: -15...15))
            cherry.zPosition = 6
            worldNode.addChild(cherry)

            let pinkGlow = SKShapeNode(circleOfRadius: 28)
            pinkGlow.fillColor = PastelPalette.dustyRose.withAlphaComponent(0.05)
            pinkGlow.strokeColor = .clear
            pinkGlow.position = CGPoint(x: cx, y: 310)
            pinkGlow.zPosition = 2
            worldNode.addChild(pinkGlow)

            cx += 400 + CGFloat.random(in: -60...60)
        }

        var sx: CGFloat = 300
        while sx < w - 200 {
            let stall = SKSpriteNode(imageNamed: "market_stall")
            stall.size = CGSize(width: 72, height: 72)
            stall.position = CGPoint(x: sx, y: 120 + CGFloat.random(in: -10...10))
            stall.zPosition = 6
            worldNode.addChild(stall)
            sx += 500 + CGFloat.random(in: -60...60)
        }

        var lx: CGFloat = 150
        while lx < w - 100 {
            let lantern = SKSpriteNode(imageNamed: "stone_lantern")
            lantern.size = CGSize(width: 28, height: 38)
            let ly: CGFloat = Bool.random() ? 260 : 140
            lantern.position = CGPoint(x: lx, y: ly)
            lantern.zPosition = 4
            worldNode.addChild(lantern)

            let glow = SKShapeNode(circleOfRadius: 20)
            glow.fillColor = PastelPalette.softGold.withAlphaComponent(0.08)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: lx, y: ly)
            glow.zPosition = 3
            worldNode.addChild(glow)

            lx += 350 + CGFloat.random(in: -40...40)
        }
    }

    // MARK: - Night Garden Theme (Side-view)
    private func createNightGardenBackground() {
        let w = currentLevel.levelWidth
        let ts: CGFloat = 64

        parallaxLayers.removeAll()
        func addParallax(name: String, h: CGFloat, y: CGFloat, z: CGFloat, spd: CGFloat, fallback: SKColor) {
            let container = SKNode()
            container.zPosition = z
            let tex = SKTexture(imageNamed: name)
            tex.filteringMode = .nearest
            if tex.size() != .zero {
                let aspect = tex.size().width / tex.size().height
                let tileW = h * aspect
                for bx in stride(from: CGFloat(-size.width / 2), through: w + size.width, by: tileW) {
                    let s = SKSpriteNode(texture: tex, size: CGSize(width: tileW, height: h))
                    s.position = CGPoint(x: bx + tileW / 2, y: y)
                    container.addChild(s)
                }
            } else {
                let fill = SKSpriteNode(color: fallback, size: CGSize(width: w + size.width, height: h))
                fill.position = CGPoint(x: w / 2, y: y)
                container.addChild(fill)
            }
            addChild(container)
            parallaxLayers.append((node: container, speed: spd))
        }

        addParallax(name: "pastel_night_sky", h: 500, y: 550, z: -30, spd: 0.05,
                    fallback: SKColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1))
        addParallax(name: "pastel_hills_far", h: 300, y: 420, z: -28, spd: 0.15,
                    fallback: SKColor(red: 0.2, green: 0.18, blue: 0.3, alpha: 1))

        let gardenGreen = SKColor(red: 0.18, green: 0.28, blue: 0.15, alpha: 1)
        let grassBase = SKSpriteNode(color: gardenGreen, size: CGSize(width: w, height: 400))
        grassBase.position = CGPoint(x: w / 2, y: 220)
        grassBase.zPosition = -12
        worldNode.addChild(grassBase)

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        for x in stride(from: CGFloat(0), through: w, by: ts) {
            for y in stride(from: CGFloat(60), through: CGFloat(400), by: ts) {
                let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                g.alpha = 0.2
                g.color = SKColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1)
                g.colorBlendFactor = 0.5
                g.zPosition = -11
                worldNode.addChild(g)
            }
        }

        let pathBase = SKSpriteNode(color: SKColor(red: 0.3, green: 0.28, blue: 0.25, alpha: 1),
                                    size: CGSize(width: w, height: 80))
        pathBase.position = CGPoint(x: w / 2, y: 195)
        pathBase.zPosition = -9
        worldNode.addChild(pathBase)

        var lx: CGFloat = 120
        var side = false
        while lx < w - 80 {
            let lantern = SKSpriteNode(imageNamed: "stone_lantern")
            lantern.size = CGSize(width: 32, height: 44)
            let ly: CGFloat = side ? 270 : 120
            lantern.position = CGPoint(x: lx, y: ly)
            lantern.zPosition = 4
            worldNode.addChild(lantern)

            let glow = SKShapeNode(circleOfRadius: 50)
            glow.fillColor = PastelPalette.softGold.withAlphaComponent(0.06)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: lx, y: ly)
            glow.zPosition = 3
            worldNode.addChild(glow)

            let innerGlow = SKShapeNode(circleOfRadius: 22)
            innerGlow.fillColor = PastelPalette.softGold.withAlphaComponent(0.1)
            innerGlow.strokeColor = .clear
            innerGlow.position = CGPoint(x: lx, y: ly + 8)
            innerGlow.zPosition = 3
            let flicker = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.05, duration: Double.random(in: 1.2...2.0)),
                SKAction.fadeAlpha(to: 0.12, duration: Double.random(in: 1.2...2.0))
            ])
            innerGlow.run(SKAction.repeatForever(flicker))
            worldNode.addChild(innerGlow)

            lx += 250 + CGFloat.random(in: -30...30)
            side.toggle()
        }

        var cx: CGFloat = 200
        while cx < w - 120 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 80, height: 80)
            cherry.color = SKColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 1)
            cherry.colorBlendFactor = 0.3
            cherry.position = CGPoint(x: cx, y: 340 + CGFloat.random(in: -8...8))
            cherry.zPosition = 6
            worldNode.addChild(cherry)

            let moonGlow = SKShapeNode(circleOfRadius: 35)
            moonGlow.fillColor = PastelPalette.lavender.withAlphaComponent(0.04)
            moonGlow.strokeColor = .clear
            moonGlow.position = CGPoint(x: cx, y: 330)
            moonGlow.zPosition = 2
            worldNode.addChild(moonGlow)

            cx += 400 + CGFloat.random(in: -50...50)
        }

        for _ in 0..<Int(w / 80) {
            let firefly = SKShapeNode(circleOfRadius: 2)
            firefly.fillColor = PastelPalette.softGold
            firefly.strokeColor = .clear
            firefly.position = CGPoint(x: CGFloat.random(in: 0...w),
                                       y: CGFloat.random(in: 100...350))
            firefly.zPosition = 8
            firefly.alpha = 0

            let fadeIn = SKAction.fadeAlpha(to: CGFloat.random(in: 0.4...0.8), duration: Double.random(in: 0.5...1.5))
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: Double.random(in: 0.5...1.5))
            let wait = SKAction.wait(forDuration: Double.random(in: 1...4))
            let drift = SKAction.moveBy(x: CGFloat.random(in: -20...20),
                                        y: CGFloat.random(in: -10...10),
                                        duration: Double.random(in: 2...4))
            let cycle = SKAction.sequence([wait, fadeIn, drift, fadeOut])
            firefly.run(SKAction.repeatForever(cycle))
            worldNode.addChild(firefly)
        }

        var kx: CGFloat = 400
        while kx < w - 200 {
            let pond = SKSpriteNode(imageNamed: "koi_pond")
            pond.size = CGSize(width: 64, height: 56)
            pond.position = CGPoint(x: kx, y: 80)
            pond.zPosition = 4
            worldNode.addChild(pond)

            let pondShimmer = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 3), SKAction.fadeAlpha(to: 1.0, duration: 3)
            ])
            pond.run(SKAction.repeatForever(pondShimmer))

            kx += 600 + CGFloat.random(in: -80...80)
        }
    }

    // MARK: - Night Castle Props
    private func addWorldProps() {
        let w = currentLevel.levelWidth

        var lx: CGFloat = 160
        var lanternSide = false
        while lx < w - 100 {
            let lantern = SKSpriteNode(imageNamed: "stone_lantern")
            lantern.size = CGSize(width: 32, height: 44)
            let ly: CGFloat = lanternSide ? 270 : 120
            lantern.position = CGPoint(x: lx, y: ly)
            lantern.zPosition = 4
            worldNode.addChild(lantern)

            let glow = SKShapeNode(circleOfRadius: 44)
            glow.fillColor = SKColor(red: 1.0, green: 0.72, blue: 0.2, alpha: 0.08)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: lx, y: ly)
            glow.zPosition = 3
            worldNode.addChild(glow)

            let innerGlow = SKShapeNode(circleOfRadius: 18)
            innerGlow.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 0.12)
            innerGlow.strokeColor = .clear
            innerGlow.position = CGPoint(x: lx, y: ly + 8)
            innerGlow.zPosition = 3
            let flicker = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.06, duration: Double.random(in: 1.0...2.0)),
                SKAction.fadeAlpha(to: 0.14, duration: Double.random(in: 1.0...2.0))
            ])
            innerGlow.run(SKAction.repeatForever(flicker))
            worldNode.addChild(innerGlow)

            lx += 300 + CGFloat.random(in: -40...40)
            lanternSide.toggle()
        }

        var cx: CGFloat = 200
        while cx < w - 120 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 80, height: 80)
            cherry.position = CGPoint(x: cx, y: 345 + CGFloat.random(in: -8...8))
            cherry.zPosition = 6
            worldNode.addChild(cherry)

            let pinkGlow = SKShapeNode(circleOfRadius: 35)
            pinkGlow.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 0.05)
            pinkGlow.strokeColor = .clear
            pinkGlow.position = CGPoint(x: cx, y: 335)
            pinkGlow.zPosition = 2
            worldNode.addChild(pinkGlow)

            cx += 450 + CGFloat.random(in: -60...60)
        }

        var bx: CGFloat = 100
        while bx < w - 80 {
            let bamboo = SKSpriteNode(imageNamed: "bamboo_cluster")
            bamboo.size = CGSize(width: 48, height: 56)
            bamboo.position = CGPoint(x: bx, y: 80 + CGFloat.random(in: -6...6))
            bamboo.zPosition = 5
            worldNode.addChild(bamboo)
            bx += 350 + CGFloat.random(in: -50...50)
        }

        for gateX in [CGFloat(100), w - 100] {
            let gate = SKSpriteNode(imageNamed: "shrine_gate")
            gate.size = CGSize(width: 72, height: 52)
            gate.position = CGPoint(x: gateX, y: 310)
            gate.zPosition = 6
            worldNode.addChild(gate)

            let redGlow = SKShapeNode(circleOfRadius: 30)
            redGlow.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 0.06)
            redGlow.strokeColor = .clear
            redGlow.position = CGPoint(x: gateX, y: 300)
            redGlow.zPosition = 2
            worldNode.addChild(redGlow)
        }

        var kx: CGFloat = 350
        while kx < w - 200 {
            let pondX = kx + CGFloat.random(in: -20...20)
            let pond = SKSpriteNode(imageNamed: "koi_pond")
            pond.size = CGSize(width: 64, height: 56)
            pond.position = CGPoint(x: pondX, y: 50)
            pond.zPosition = 4
            worldNode.addChild(pond)

            let shimmer = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: Double.random(in: 2.0...3.5)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 2.0...3.5))
            ])
            pond.run(SKAction.repeatForever(shimmer))

            let bridge = SKSpriteNode(imageNamed: "wooden_bridge")
            bridge.size = CGSize(width: 52, height: 52)
            bridge.position = CGPoint(x: pondX, y: 55)
            bridge.zPosition = 5
            worldNode.addChild(bridge)

            kx += 500 + CGFloat.random(in: -60...60)
        }

        var rx: CGFloat = 300
        while rx < w - 100 {
            let isRock = Bool.random()
            let prop = SKSpriteNode(imageNamed: isRock ? "rock" : "barrel")
            prop.size = isRock ? CGSize(width: 32, height: 28) : CGSize(width: 36, height: 36)
            let ry: CGFloat = Bool.random() ? (110 + CGFloat.random(in: -8...8)) : (290 + CGFloat.random(in: -8...8))
            prop.position = CGPoint(x: rx, y: ry)
            prop.zPosition = 4
            worldNode.addChild(prop)
            rx += 380 + CGFloat.random(in: -50...50)
        }

        for hp in currentLevel.hidingPoints {
            if Bool.random() {
                let crate = SKSpriteNode(imageNamed: "crate")
                crate.size = CGSize(width: 32, height: 32)
                let offset: CGFloat = Bool.random() ? 40 : -40
                crate.position = CGPoint(x: hp.position.x + offset, y: hp.position.y - 20)
                crate.zPosition = 3
                worldNode.addChild(crate)
            }
        }
    }

    func createMarker(at position: CGPoint, color: SKColor, label: String) {
        let glowRing = SKShapeNode(circleOfRadius: 40)
        glowRing.fillColor = .clear
        glowRing.strokeColor = color
        glowRing.lineWidth = 3
        glowRing.alpha = 0.5
        glowRing.position = position
        glowRing.zPosition = 2
        worldNode.addChild(glowRing)

        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.3, duration: 1.0),
                SKAction.fadeAlpha(to: 0.2, duration: 1.0)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 1.0),
                SKAction.fadeAlpha(to: 0.5, duration: 1.0)
            ])
        ])
        glowRing.run(SKAction.repeatForever(pulse))

        let marker = SKShapeNode(circleOfRadius: 35)
        marker.fillColor = color.withAlphaComponent(0.6)
        marker.strokeColor = color
        marker.lineWidth = 3
        marker.glowWidth = 5
        marker.position = position
        marker.zPosition = 3
        worldNode.addChild(marker)

        let innerCircle = SKShapeNode(circleOfRadius: 25)
        innerCircle.fillColor = .clear
        innerCircle.strokeColor = .white
        innerCircle.lineWidth = 2
        innerCircle.alpha = 0.6
        marker.addChild(innerCircle)

        let labelBg = SKShapeNode(rectOf: CGSize(width: 80, height: 25), cornerRadius: 12)
        labelBg.fillColor = SKColor.black.withAlphaComponent(0.8)
        labelBg.strokeColor = color
        labelBg.lineWidth = 2
        labelBg.position = CGPoint(x: 0, y: -55)
        marker.addChild(labelBg)

        let markerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        markerLabel.text = label
        markerLabel.fontSize = 14
        markerLabel.fontColor = color
        markerLabel.verticalAlignmentMode = .center
        markerLabel.position = CGPoint(x: 0, y: -55)
        marker.addChild(markerLabel)
    }

    func addAtmosphericEffects() {
        // intentionally empty — vignette removed (it used a full-view bounding box that blocked touches)
    }
}
