//
//  GameScene.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/5/26.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    // MARK: - Game Objects
    private var ninja: StealthNinjaCharacter!
    private var hidingPoints: [StealthHidingPoint] = []
    private var npcs: [StealthNPCCharacter] = []
    private var worldNode: SKNode!
    private var cameraNode: SKCameraNode!

    // Parallax background layers (back to front)
    private var parallaxLayers: [(node: SKNode, speed: CGFloat)] = []
    
    // MARK: - UI Elements
    private var moveButton: SKShapeNode!
    private var moveButtonLabel: SKLabelNode!
    private var progressBar: SKShapeNode!
    private var progressBarFill: SKShapeNode!
    private var progressNinjaIcon: SKLabelNode!
    private var detectionBar: SKShapeNode!
    private var detectionBarFill: SKShapeNode!
    private var detectionLabel: SKLabelNode!
    private var stealthBadge: SKShapeNode!
    private var stealthLabel: SKLabelNode!
    private var restartButton: SKShapeNode!
    private var levelLabel: SKLabelNode!
    
    // MARK: - Game State
    private var gameState: StealthGamePlayState = .playing
    private var currentLevel: LevelData!
    private var currentLevelNumber: Int = 1
    private var isButtonPressed: Bool = false
    private var detectionLevel: CGFloat = 0.0
    
    // Debug mode - set to true to see detection lines
    private let showDebugDetection: Bool = false
    
    // MARK: - Audio
    private var footstepPlayer: AVAudioPlayer?
    private var alertSoundPlayer: AVAudioPlayer?
    
    // MARK: - Constants
    private let buttonSize: CGFloat = 100
    private let uiPadding: CGFloat = 20
    
    override func didMove(to view: SKView) {
        setupScene()
        loadLevel(levelNumber: currentLevelNumber)
    }
    
    // MARK: - Setup
    private func setupScene() {
        backgroundColor = SKColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1.0)
        
        // Setup camera
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode

        // Setup world container
        worldNode = SKNode()
        addChild(worldNode)

        // Setup UI
        setupUI()
    }
    
    private func setupUI() {
        let W = size.width
        let H = size.height
        let topY = H / 2 - 52
        let btnY = -H / 2 + buttonSize / 2 + uiPadding + 10
        let amber = SKColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1)
        let darkPanel = SKColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 0.88)
        let safeGreen = SKColor(red: 0.2, green: 0.9, blue: 0.45, alpha: 1)

        // ── MOVE BUTTON ────────────────────────────────────────────────────
        // Outer shadow ring
        let shadowRing = SKShapeNode(circleOfRadius: buttonSize / 2 + 4)
        shadowRing.fillColor = SKColor.black.withAlphaComponent(0.4)
        shadowRing.strokeColor = .clear
        shadowRing.position = CGPoint(x: 0, y: btnY - 3)
        shadowRing.zPosition = 99
        cameraNode.addChild(shadowRing)

        moveButton = SKShapeNode(circleOfRadius: buttonSize / 2)
        moveButton.fillColor = SKColor(red: 0.10, green: 0.14, blue: 0.22, alpha: 0.95)
        moveButton.strokeColor = amber.withAlphaComponent(0.7)
        moveButton.lineWidth = 2.5
        moveButton.position = CGPoint(x: 0, y: btnY)
        moveButton.zPosition = 100
        moveButton.name = "moveButton"
        cameraNode.addChild(moveButton)

        // Inner accent ring
        let innerRing = SKShapeNode(circleOfRadius: buttonSize / 2 - 8)
        innerRing.fillColor = .clear
        innerRing.strokeColor = amber.withAlphaComponent(0.25)
        innerRing.lineWidth = 1.5
        moveButton.addChild(innerRing)

        // Ninja star icon above text
        let starLabel = SKLabelNode(text: "✦")
        starLabel.fontSize = 14
        starLabel.fontColor = amber.withAlphaComponent(0.7)
        starLabel.verticalAlignmentMode = .center
        starLabel.position = CGPoint(x: 0, y: 14)
        moveButton.addChild(starLabel)

        moveButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        moveButtonLabel.text = "MOVE"
        moveButtonLabel.fontSize = 18
        moveButtonLabel.fontColor = .white
        moveButtonLabel.verticalAlignmentMode = .center
        moveButtonLabel.position = CGPoint(x: 0, y: -8)
        moveButton.addChild(moveButtonLabel)

        // ── TOP PANEL BACKGROUND ───────────────────────────────────────────
        let topPanel = SKShapeNode(rectOf: CGSize(width: W, height: 72), cornerRadius: 0)
        topPanel.fillColor = darkPanel
        topPanel.strokeColor = .clear
        topPanel.position = CGPoint(x: 0, y: H / 2 - 36)
        topPanel.zPosition = 98
        cameraNode.addChild(topPanel)

        // Thin amber bottom border on panel
        let panelBorder = SKShapeNode(rectOf: CGSize(width: W, height: 1.5))
        panelBorder.fillColor = amber.withAlphaComponent(0.4)
        panelBorder.strokeColor = .clear
        panelBorder.position = CGPoint(x: 0, y: -35)
        topPanel.addChild(panelBorder)

        // ── LEVEL BADGE (top center) ───────────────────────────────────────
        let badgeBg = SKShapeNode(rectOf: CGSize(width: 110, height: 28), cornerRadius: 14)
        badgeBg.fillColor = SKColor(red: 0.15, green: 0.12, blue: 0.08, alpha: 1)
        badgeBg.strokeColor = amber.withAlphaComponent(0.6)
        badgeBg.lineWidth = 1.5
        badgeBg.position = CGPoint(x: 0, y: topY + 2)
        badgeBg.zPosition = 101
        cameraNode.addChild(badgeBg)

        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelLabel.text = "LEVEL \(currentLevelNumber)"
        levelLabel.fontSize = 16
        levelLabel.fontColor = amber
        levelLabel.verticalAlignmentMode = .center
        levelLabel.position = CGPoint(x: 0, y: topY + 2)
        levelLabel.zPosition = 102
        cameraNode.addChild(levelLabel)

        // ── PROGRESS BAR ───────────────────────────────────────────────────
        let barWidth: CGFloat = W * 0.52
        let barHeight: CGFloat = 8
        let barY = topY - 22

        // Track background
        let barTrack = SKShapeNode(rectOf: CGSize(width: barWidth + 6, height: barHeight + 6), cornerRadius: 7)
        barTrack.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1)
        barTrack.strokeColor = SKColor.white.withAlphaComponent(0.1)
        barTrack.lineWidth = 1
        barTrack.position = CGPoint(x: 0, y: barY)
        barTrack.zPosition = 100
        cameraNode.addChild(barTrack)

        progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        progressBar.fillColor = SKColor.white.withAlphaComponent(0.08)
        progressBar.strokeColor = .clear
        progressBar.position = CGPoint(x: 0, y: barY)
        progressBar.zPosition = 100
        cameraNode.addChild(progressBar)

        progressBarFill = SKShapeNode(rectOf: CGSize(width: 1, height: barHeight), cornerRadius: 4)
        progressBarFill.fillColor = safeGreen
        progressBarFill.strokeColor = .clear
        progressBarFill.position = CGPoint(x: -barWidth / 2, y: 0)
        progressBar.addChild(progressBarFill)

        // Ninja runner icon on progress bar
        progressNinjaIcon = SKLabelNode(text: "🥷")
        progressNinjaIcon.fontSize = 12
        progressNinjaIcon.verticalAlignmentMode = .center
        progressNinjaIcon.position = CGPoint(x: -barWidth / 2, y: barY + 10)
        progressNinjaIcon.zPosition = 101
        cameraNode.addChild(progressNinjaIcon)

        // Start & end dots on bar
        for (dx, col): (CGFloat, SKColor) in [(-barWidth / 2, .white), (barWidth / 2, amber)] {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.fillColor = col
            dot.strokeColor = .clear
            dot.position = CGPoint(x: dx, y: barY)
            dot.zPosition = 101
            cameraNode.addChild(dot)
        }

        // ── DETECTION METER (top right) ────────────────────────────────────
        let detW: CGFloat = 72
        let detH: CGFloat = 8
        let detX = W / 2 - detW / 2 - 14
        let detY = topY + 2

        let eyeLabel = SKLabelNode(text: "👁")
        eyeLabel.fontSize = 14
        eyeLabel.verticalAlignmentMode = .center
        eyeLabel.position = CGPoint(x: detX, y: detY + 16)
        eyeLabel.zPosition = 101
        cameraNode.addChild(eyeLabel)

        let detTrack = SKShapeNode(rectOf: CGSize(width: detW + 4, height: detH + 4), cornerRadius: 6)
        detTrack.fillColor = SKColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1)
        detTrack.strokeColor = SKColor.white.withAlphaComponent(0.1)
        detTrack.lineWidth = 1
        detTrack.position = CGPoint(x: detX, y: detY - 10)
        detTrack.zPosition = 100
        cameraNode.addChild(detTrack)

        detectionBar = SKShapeNode(rectOf: CGSize(width: detW, height: detH), cornerRadius: 4)
        detectionBar.fillColor = SKColor.white.withAlphaComponent(0.08)
        detectionBar.strokeColor = .clear
        detectionBar.position = CGPoint(x: detX, y: detY - 10)
        detectionBar.zPosition = 100
        cameraNode.addChild(detectionBar)

        detectionBarFill = SKShapeNode(rectOf: CGSize(width: 1, height: detH), cornerRadius: 4)
        detectionBarFill.fillColor = safeGreen
        detectionBarFill.strokeColor = .clear
        detectionBarFill.position = CGPoint(x: -detW / 2, y: 0)
        detectionBar.addChild(detectionBarFill)

        detectionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        detectionLabel.text = "SAFE"
        detectionLabel.fontSize = 10
        detectionLabel.fontColor = safeGreen
        detectionLabel.horizontalAlignmentMode = .center
        detectionLabel.verticalAlignmentMode = .center
        detectionLabel.position = CGPoint(x: detX, y: detY - 24)
        detectionLabel.zPosition = 101
        cameraNode.addChild(detectionLabel)

        // ── STEALTH BADGE (top left) ───────────────────────────────────────
        stealthBadge = SKShapeNode(rectOf: CGSize(width: 64, height: 28), cornerRadius: 14)
        stealthBadge.fillColor = SKColor(red: 0.05, green: 0.12, blue: 0.08, alpha: 1)
        stealthBadge.strokeColor = safeGreen.withAlphaComponent(0.5)
        stealthBadge.lineWidth = 1.5
        stealthBadge.position = CGPoint(x: -W / 2 + 46, y: topY + 2)
        stealthBadge.zPosition = 101
        cameraNode.addChild(stealthBadge)

        stealthLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        stealthLabel.text = "🌙 HIDE"
        stealthLabel.fontSize = 11
        stealthLabel.fontColor = safeGreen
        stealthLabel.verticalAlignmentMode = .center
        stealthLabel.position = .zero
        stealthBadge.addChild(stealthLabel)

        // ── RESTART BUTTON (top left corner) ─────────────────────────────
        restartButton = SKShapeNode(circleOfRadius: 16)
        restartButton.fillColor = SKColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 1)
        restartButton.strokeColor = SKColor.white.withAlphaComponent(0.3)
        restartButton.lineWidth = 1.5
        restartButton.position = CGPoint(x: -W / 2 + 28, y: topY - 24)
        restartButton.zPosition = 101
        restartButton.name = "restartButton"
        cameraNode.addChild(restartButton)

        let restartIcon = SKLabelNode(text: "↻")
        restartIcon.fontSize = 18
        restartIcon.fontColor = SKColor.white.withAlphaComponent(0.8)
        restartIcon.verticalAlignmentMode = .center
        restartIcon.horizontalAlignmentMode = .center
        restartIcon.position = CGPoint(x: 0, y: 1)
        restartButton.addChild(restartIcon)

        // ── BOTTOM PANEL ───────────────────────────────────────────────────
        let bottomPanel = SKShapeNode(rectOf: CGSize(width: W, height: buttonSize + uiPadding * 2 + 30))
        bottomPanel.fillColor = darkPanel
        bottomPanel.strokeColor = .clear
        bottomPanel.position = CGPoint(x: 0, y: -H / 2 + (buttonSize + uiPadding * 2 + 30) / 2)
        bottomPanel.zPosition = 98
        cameraNode.addChild(bottomPanel)

        let bottomBorder = SKShapeNode(rectOf: CGSize(width: W, height: 1.5))
        bottomBorder.fillColor = amber.withAlphaComponent(0.4)
        bottomBorder.strokeColor = .clear
        bottomBorder.position = CGPoint(x: 0, y: (buttonSize + uiPadding * 2 + 30) / 2 - 0.75)
        bottomPanel.addChild(bottomBorder)
    }
    
    private func loadLevel(levelNumber: Int) {
        // Clear existing level
        worldNode.removeAllChildren()
        hidingPoints.removeAll()
        npcs.removeAll()

        // Remove old parallax layers
        for (node, _) in parallaxLayers { node.removeFromParent() }
        parallaxLayers.removeAll()
        
        // Load level data
        currentLevel = LevelManager.shared.getLevelData(levelNumber: levelNumber)
        currentLevelNumber = levelNumber
        levelLabel.text = "LEVEL \(levelNumber)"

        // Set background color based on theme
        switch currentLevel.theme {
        case .nightCastle:
            backgroundColor = SKColor(red: 0.03, green: 0.05, blue: 0.12, alpha: 1.0)
        case .sunnyVillage:
            backgroundColor = SKColor(red: 0.45, green: 0.72, blue: 0.92, alpha: 1.0)
        }

        // Create background
        createBackground()
        
        // Create start and end markers
        createMarker(at: currentLevel.startPosition, color: .green, label: "START")
        createMarker(at: currentLevel.endPosition, color: .cyan, label: "END")
        
        // ⚠️ CRITICAL: Create START position as first hiding point (safe zone)
        // This ensures ninja is safe at spawn and not immediately detected
        let startHidingPoint = StealthHidingPoint(config: LevelData.HidingPointConfig(
            position: currentLevel.startPosition,
            size: CGSize(width: 80, height: 80),
            isLightDependent: false
        ))
        worldNode.addChild(startHidingPoint)
        hidingPoints.append(startHidingPoint)
        
        // Create hiding points
        for hpConfig in currentLevel.hidingPoints {
            let hp = StealthHidingPoint(config: hpConfig)
            worldNode.addChild(hp)
            hidingPoints.append(hp)
        }
        
        // Create NPCs
        for npcConfig in currentLevel.npcs {
            let npc = StealthNPCCharacter(config: npcConfig)
            worldNode.addChild(npc)
            npcs.append(npc)
        }
        
        // Create ninja
        ninja = StealthNinjaCharacter()
        ninja.position = currentLevel.startPosition
        worldNode.addChild(ninja)
        
        // ⚠️ CRITICAL: Set ninja to start in hiding zone (at start point)
        // This prevents immediate detection at level start
        ninja.isInHidingZone = true
        
        // Position camera at start
        updateCamera()
        
        // Reset game state
        gameState = .playing
        detectionLevel = 0.0
        updateDetectionIndicator()
    }
    
    private func createBackground() {
        switch currentLevel.theme {
        case .sunnyVillage:
            createSunnyVillageBackground()
            return
        case .nightCastle:
            break  // fall through to default night castle rendering
        }

        let w = currentLevel.levelWidth
        let ts: CGFloat = 64  // tile size

        // ── 1. Parallax background layers ──────────────────────────────
        // Each layer is added to the scene (not worldNode) and scrolls at
        // a fraction of the camera speed, creating depth.
        parallaxLayers.removeAll()

        // Helper to tile a texture across a parallax layer node
        func addParallaxLayer(textureName: String, tileH: CGFloat, yCenter: CGFloat,
                              zPos: CGFloat, speed: CGFloat, tint: SKColor? = nil,
                              alpha: CGFloat = 1.0) {
            let container = SKNode()
            container.zPosition = zPos
            let tex = SKTexture(imageNamed: textureName)
            tex.filteringMode = .nearest
            let aspect = tex.size().width / tex.size().height
            let tileW = tileH * aspect
            // Tile enough to cover viewport even with parallax offset
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

        // Layer 0: Night sky (barely moves — almost fixed)
        addParallaxLayer(textureName: "parallax_sky", tileH: 500, yCenter: 550,
                         zPos: -30, speed: 0.05)

        // Layer 1: Distant mountains (slow movement)
        addParallaxLayer(textureName: "parallax_mountains", tileH: 350, yCenter: 420,
                         zPos: -28, speed: 0.15)

        // Layer 2: Mid-distance forest (medium movement)
        addParallaxLayer(textureName: "parallax_trees", tileH: 300, yCenter: 380,
                         zPos: -26, speed: 0.35)

        // Layer 3: Near foreground silhouettes (faster movement)
        addParallaxLayer(textureName: "parallax_foreground", tileH: 250, yCenter: 360,
                         zPos: -24, speed: 0.55)

        // ── Wang tile extraction helper ───────────────────────────────
        // Extracts a single 32x32 tile from a 128x128 Wang tileset atlas.
        // Wang ID encodes corners: bit3=NW, bit2=NE, bit1=SW, bit0=SE
        // (upper=1, lower=0). The atlas layout maps each ID to a bounding box.
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

        // Load tileset atlases
        let stoneGrassAtlas = SKTexture(imageNamed: "tileset_stone_grass")
        stoneGrassAtlas.filteringMode = .nearest
        let stoneDirtAtlas = SKTexture(imageNamed: "tileset_stone_dirt")
        stoneDirtAtlas.filteringMode = .nearest
        let riceGrassAtlas = SKTexture(imageNamed: "tileset_rice_grass")
        riceGrassAtlas.filteringMode = .nearest

        // Extract the tiles we need for horizontal band layout
        let pureStone = wangTile(atlas: stoneGrassAtlas, wangID: 0)   // all lower
        let pureGrass = wangTile(atlas: stoneGrassAtlas, wangID: 15)  // all upper
        let grassTopStoneBot = wangTile(atlas: stoneGrassAtlas, wangID: 12)  // NW+NE=grass
        let stoneTopGrassBot = wangTile(atlas: stoneGrassAtlas, wangID: 3)   // SW+SE=grass
        let pureDirt = wangTile(atlas: stoneDirtAtlas, wangID: 15)  // all upper = dirt
        let stoneToDirtTop = wangTile(atlas: stoneDirtAtlas, wangID: 12)  // dirt on top edge
        let stoneToDirtBot = wangTile(atlas: stoneDirtAtlas, wangID: 3)   // dirt on bottom edge
        let pureRice = wangTile(atlas: riceGrassAtlas, wangID: 0)
        let riceTopGrassBot = wangTile(atlas: riceGrassAtlas, wangID: 3)
        let grassTopRiceBot = wangTile(atlas: riceGrassAtlas, wangID: 12)

        // ── 2. Rice paddy fields (top & bottom) ────────────────────────
        // Top rice field with grass transition
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            // Grass → rice transition row
            let trans = SKSpriteNode(texture: grassTopRiceBot, size: CGSize(width: ts, height: ts))
            trans.position = CGPoint(x: gx + ts / 2, y: 380 + ts / 2)
            trans.zPosition = -12
            worldNode.addChild(trans)
            // Pure rice rows above
            for y in stride(from: CGFloat(412), through: CGFloat(480), by: ts) {
                let tile = SKSpriteNode(texture: pureRice, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -12
                worldNode.addChild(tile)
            }
        }

        // Bottom rice field
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

        // ── 3. Grass areas (between rice and courtyard) ─────────────────
        // Top grass band
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let g = SKSpriteNode(texture: pureGrass, size: CGSize(width: ts, height: ts))
            g.position = CGPoint(x: gx + ts / 2, y: 348 + ts / 2)
            g.zPosition = -11
            worldNode.addChild(g)
        }
        // Bottom grass band
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let g = SKSpriteNode(texture: pureGrass, size: CGSize(width: ts, height: ts))
            g.position = CGPoint(x: gx + ts / 2, y: 100 + ts / 2)
            g.zPosition = -11
            worldNode.addChild(g)
        }

        // ── 4. Stone courtyard with Wang tile transitions ───────────────
        // Top transition: grass → stone
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: grassTopStoneBot, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 316 + ts / 2)
            t.zPosition = -10
            worldNode.addChild(t)
        }
        // Pure stone fill
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            for y in stride(from: CGFloat(140), through: CGFloat(284), by: ts) {
                let tile = SKSpriteNode(texture: pureStone, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -10
                worldNode.addChild(tile)
            }
        }
        // Bottom transition: stone → grass
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: stoneTopGrassBot, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 132 + ts / 2)
            t.zPosition = -10
            worldNode.addChild(t)
        }

        // ── 5. Dirt path with transitions ───────────────────────────────
        // Stone → dirt transition (top edge of path)
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let t = SKSpriteNode(texture: stoneToDirtTop, size: CGSize(width: ts, height: ts))
            t.position = CGPoint(x: gx + ts / 2, y: 236 + ts / 2)
            t.zPosition = -9
            worldNode.addChild(t)
        }
        // Pure dirt path
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            for y in stride(from: CGFloat(172), through: CGFloat(204), by: ts) {
                let tile = SKSpriteNode(texture: pureDirt, size: CGSize(width: ts, height: ts))
                tile.position = CGPoint(x: gx + ts / 2, y: y + ts / 2)
                tile.zPosition = -9
                worldNode.addChild(tile)
            }
        }
        // Dirt → stone transition (bottom edge of path)
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

        // ── 1. Bright sky background with village landscape ──────────────
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

        // Light warm tint for sunny atmosphere
        let sunTint = SKSpriteNode(color: SKColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 0.12),
                                   size: CGSize(width: w, height: 600))
        sunTint.position = CGPoint(x: w / 2, y: 300)
        sunTint.zPosition = -18
        worldNode.addChild(sunTint)

        // ── 2. Grass base covering the play area ─────────────────────────
        let grassColor = SKColor(red: 0.35, green: 0.62, blue: 0.18, alpha: 1)
        let grassBase = SKSpriteNode(color: grassColor, size: CGSize(width: w, height: 400))
        grassBase.position = CGPoint(x: w / 2, y: 220)
        grassBase.zPosition = -12
        worldNode.addChild(grassBase)

        let grassTex = SKTexture(imageNamed: "grass_tile")
        grassTex.filteringMode = .nearest
        for x in stride(from: CGFloat(0), through: w, by: ts) {
            for y in stride(from: CGFloat(60), through: CGFloat(400), by: ts) {
                let g = SKSpriteNode(texture: grassTex, size: CGSize(width: ts, height: ts))
                g.position = CGPoint(x: x + ts / 2, y: y + ts / 2)
                g.alpha = 0.5
                g.zPosition = -11
                worldNode.addChild(g)
            }
        }

        // ── 3. Rice paddies along top ────────────────────────────────────
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

        // ── 4. Dirt path (walkway) ───────────────────────────────────────
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

        // Path edge — lighter grass blending
        for yEdge: CGFloat in [145, 245] {
            let edge = SKSpriteNode(color: SKColor(red: 0.45, green: 0.55, blue: 0.22, alpha: 0.5),
                                    size: CGSize(width: w, height: 4))
            edge.position = CGPoint(x: w / 2, y: yEdge)
            edge.zPosition = -7
            worldNode.addChild(edge)
        }

        // ── 5. Bottom rice paddy / water edge ───────────────────────────
        for gx in stride(from: CGFloat(0), through: w, by: ts) {
            let tile = SKSpriteNode(texture: riceTex, size: CGSize(width: ts, height: ts))
            tile.position = CGPoint(x: gx + ts / 2, y: 50)
            tile.zPosition = -10
            worldNode.addChild(tile)
        }

        // ── 6. Decorative village props ──────────────────────────────────
        addSunnyVillageProps()
    }

    private func addSunnyVillageProps() {
        let w = currentLevel.levelWidth

        // ── Farmhouses scattered along the upper area ────────────────────
        var hx: CGFloat = 250
        while hx < w - 200 {
            let house = SKSpriteNode(imageNamed: "farmhouse")
            house.size = CGSize(width: 80, height: 80)
            house.position = CGPoint(x: hx, y: 330 + CGFloat.random(in: -10...10))
            house.zPosition = 6
            worldNode.addChild(house)
            hx += 600 + CGFloat.random(in: -80...80)
        }

        // ── Cherry blossom trees ─────────────────────────────────────────
        var cx: CGFloat = 150
        while cx < w - 100 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 72, height: 72)
            let cy: CGFloat = Bool.random() ? (310 + CGFloat.random(in: -15...15)) : (90 + CGFloat.random(in: -10...10))
            cherry.position = CGPoint(x: cx, y: cy)
            cherry.zPosition = 6
            worldNode.addChild(cherry)

            // Soft pink shadow
            let pinkGlow = SKShapeNode(circleOfRadius: 30)
            pinkGlow.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 0.08)
            pinkGlow.strokeColor = .clear
            pinkGlow.position = CGPoint(x: cx, y: cy - 10)
            pinkGlow.zPosition = 2
            worldNode.addChild(pinkGlow)

            cx += 500 + CGFloat.random(in: -70...70)
        }

        // ── Hay carts near farmhouses ────────────────────────────────────
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

        // ── Decorative cows (non-NPC, just scenery) ──────────────────────
        var cowX: CGFloat = 500
        while cowX < w - 300 {
            let cow = SKSpriteNode(imageNamed: "village_cow_south")
            cow.size = CGSize(width: 44, height: 32)
            cow.position = CGPoint(x: cowX + CGFloat.random(in: -40...40),
                                   y: 320 + CGFloat.random(in: -20...20))
            cow.zPosition = 5
            worldNode.addChild(cow)

            // Gentle idle sway
            let sway = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -8...8), y: 0, duration: Double.random(in: 3...6)),
                SKAction.moveBy(x: CGFloat.random(in: -8...8), y: 0, duration: Double.random(in: 3...6))
            ])
            cow.run(SKAction.repeatForever(sway))

            cowX += 800 + CGFloat.random(in: -100...100)
        }

        // ── Playing children (non-NPC scenery) ──────────────────────────
        var kidX: CGFloat = 350
        while kidX < w - 300 {
            let child = SKSpriteNode(imageNamed: "village_child_south")
            child.size = CGSize(width: 24, height: 28)
            child.position = CGPoint(x: kidX + CGFloat.random(in: -30...30),
                                     y: 280 + CGFloat.random(in: -15...15))
            child.zPosition = 5
            worldNode.addChild(child)

            // Children run around in small circles
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

        // ── Bamboo clusters along edges ──────────────────────────────────
        var bx: CGFloat = 120
        while bx < w - 80 {
            let bamboo = SKSpriteNode(imageNamed: "bamboo_cluster")
            bamboo.size = CGSize(width: 44, height: 52)
            bamboo.position = CGPoint(x: bx, y: 85 + CGFloat.random(in: -8...8))
            bamboo.zPosition = 5
            worldNode.addChild(bamboo)
            bx += 400 + CGFloat.random(in: -60...60)
        }

        // ── Koi pond ─────────────────────────────────────────────────────
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

        // ── Stone lanterns at path edges (fewer, warm daylight glow) ─────
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

        // ── Barrels and crates near farmhouses ───────────────────────────
        var rx: CGFloat = 300
        while rx < w - 100 {
            let prop = SKSpriteNode(imageNamed: Bool.random() ? "barrel" : "crate")
            prop.size = CGSize(width: 30, height: 30)
            prop.position = CGPoint(x: rx, y: 300 + CGFloat.random(in: -15...15))
            prop.zPosition = 4
            worldNode.addChild(prop)
            rx += 500 + CGFloat.random(in: -60...60)
        }

        // ── Crates near hiding spots ─────────────────────────────────────
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

    // MARK: - Night Castle Props
    private func addWorldProps() {
        let w = currentLevel.levelWidth

        // ── Stone lanterns with warm glow along the path ─────────────────
        var lx: CGFloat = 160
        var lanternSide = false
        while lx < w - 100 {
            let lantern = SKSpriteNode(imageNamed: "stone_lantern")
            lantern.size = CGSize(width: 32, height: 44)
            let ly: CGFloat = lanternSide ? 270 : 120
            lantern.position = CGPoint(x: lx, y: ly)
            lantern.zPosition = 4
            worldNode.addChild(lantern)

            // Warm glow around each lantern
            let glow = SKShapeNode(circleOfRadius: 44)
            glow.fillColor = SKColor(red: 1.0, green: 0.72, blue: 0.2, alpha: 0.08)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: lx, y: ly)
            glow.zPosition = 3
            worldNode.addChild(glow)

            // Inner bright glow with flicker
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

        // ── Cherry blossom trees — along the upper garden ────────────────
        var cx: CGFloat = 200
        while cx < w - 120 {
            let cherry = SKSpriteNode(imageNamed: "cherry_blossom")
            cherry.size = CGSize(width: 80, height: 80)
            cherry.position = CGPoint(x: cx, y: 345 + CGFloat.random(in: -8...8))
            cherry.zPosition = 6
            worldNode.addChild(cherry)

            // Subtle pink glow beneath the tree
            let pinkGlow = SKShapeNode(circleOfRadius: 35)
            pinkGlow.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 0.05)
            pinkGlow.strokeColor = .clear
            pinkGlow.position = CGPoint(x: cx, y: 335)
            pinkGlow.zPosition = 2
            worldNode.addChild(pinkGlow)

            cx += 450 + CGFloat.random(in: -60...60)
        }

        // ── Bamboo clusters — along bottom edge ──────────────────────────
        var bx: CGFloat = 100
        while bx < w - 80 {
            let bamboo = SKSpriteNode(imageNamed: "bamboo_cluster")
            bamboo.size = CGSize(width: 48, height: 56)
            bamboo.position = CGPoint(x: bx, y: 80 + CGFloat.random(in: -6...6))
            bamboo.zPosition = 5
            worldNode.addChild(bamboo)
            bx += 350 + CGFloat.random(in: -50...50)
        }

        // ── Shrine gates — one near start, one near end ──────────────────
        for gateX in [CGFloat(100), w - 100] {
            let gate = SKSpriteNode(imageNamed: "shrine_gate")
            gate.size = CGSize(width: 72, height: 52)
            gate.position = CGPoint(x: gateX, y: 310)
            gate.zPosition = 6
            worldNode.addChild(gate)

            // Red glow beneath gate
            let redGlow = SKShapeNode(circleOfRadius: 30)
            redGlow.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 0.06)
            redGlow.strokeColor = .clear
            redGlow.position = CGPoint(x: gateX, y: 300)
            redGlow.zPosition = 2
            worldNode.addChild(redGlow)
        }

        // ── Koi ponds with wooden bridges — in the bottom garden ─────────
        var kx: CGFloat = 350
        while kx < w - 200 {
            let pondX = kx + CGFloat.random(in: -20...20)
            let pond = SKSpriteNode(imageNamed: "koi_pond")
            pond.size = CGSize(width: 64, height: 56)
            pond.position = CGPoint(x: pondX, y: 50)
            pond.zPosition = 4
            worldNode.addChild(pond)

            // Water shimmer effect
            let shimmer = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: Double.random(in: 2.0...3.5)),
                SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 2.0...3.5))
            ])
            pond.run(SKAction.repeatForever(shimmer))

            // Wooden bridge over pond
            let bridge = SKSpriteNode(imageNamed: "wooden_bridge")
            bridge.size = CGSize(width: 52, height: 52)
            bridge.position = CGPoint(x: pondX, y: 55)
            bridge.zPosition = 5
            worldNode.addChild(bridge)

            kx += 500 + CGFloat.random(in: -60...60)
        }

        // ── Rocks & barrels along courtyard edges ────────────────────────
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

        // ── Crates near hiding spots ─────────────────────────────────────
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

    private func createMarker(at position: CGPoint, color: SKColor, label: String) {
        // Outer glow ring
        let glowRing = SKShapeNode(circleOfRadius: 40)
        glowRing.fillColor = .clear
        glowRing.strokeColor = color
        glowRing.lineWidth = 3
        glowRing.alpha = 0.5
        glowRing.position = position
        glowRing.zPosition = 2
        worldNode.addChild(glowRing)
        
        // Pulse animation for glow
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
        
        // Main marker
        let marker = SKShapeNode(circleOfRadius: 35)
        marker.fillColor = color.withAlphaComponent(0.6)
        marker.strokeColor = color
        marker.lineWidth = 3
        marker.glowWidth = 5
        marker.position = position
        marker.zPosition = 3
        worldNode.addChild(marker)
        
        // Inner detail circle
        let innerCircle = SKShapeNode(circleOfRadius: 25)
        innerCircle.fillColor = .clear
        innerCircle.strokeColor = .white
        innerCircle.lineWidth = 2
        innerCircle.alpha = 0.6
        marker.addChild(innerCircle)
        
        // Label with background
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
    
    // Add atmospheric effects
    private func addAtmosphericEffects() {
        // intentionally empty — vignette removed (it used a full-view bounding box that blocked touches)
    }
    
    // MARK: - Game Logic
    private func moveNinja() {
        guard gameState == .playing else { return }
        guard ninja.currentState != .moving else { return }
        
        // ⚠️ CRITICAL: DO NOT USE guard STATEMENT HERE!
        // The ninja MUST be able to move beyond the last hiding point to reach the endpoint.
        // Using guard nextIndex < hidingPoints.count will cause the bug where ninja gets stuck!
        
        let nextIndex = ninja.targetHidingPointIndex
        
        // Determine target position: either next hiding point OR the endpoint
        let targetPosition: CGPoint
        if nextIndex < hidingPoints.count {
            // Still have hiding points to visit
            targetPosition = hidingPoints[nextIndex].position
        } else {
            // Past all hiding points - move to endpoint to complete level
            targetPosition = currentLevel.endPosition
        }
        
        let distance = hypot(targetPosition.x - ninja.position.x,
                            targetPosition.y - ninja.position.y)
        let duration = TimeInterval(distance / 100.0) // Speed: 100 points per second
        
        ninja.reveal()
        ninja.moveTo(point: targetPosition, duration: duration) { [weak self] in
            self?.onNinjaReachedPoint()
        }
        
        moveButton.fillColor = SKColor(red: 0.55, green: 0.15, blue: 0.08, alpha: 0.95)
        moveButtonLabel.text = "STOP"
    }

    private func stopNinja() {
        guard ninja.currentState == .moving else { return }

        ninja.removeAction(forKey: "movement")
        ninja.hide()

        checkHidingZone()

        moveButton.fillColor = SKColor(red: 0.10, green: 0.14, blue: 0.22, alpha: 0.95)
        moveButtonLabel.text = "MOVE"
    }
    
    private func onNinjaReachedPoint() {
        ninja.targetHidingPointIndex += 1
        
        // ⚠️ CRITICAL: Check if ninja has reached the endpoint
        // When index exceeds hiding points count, ninja is at endpoint
        if ninja.targetHidingPointIndex > hidingPoints.count {
            // Ninja reached the endpoint - complete the level!
            checkLevelComplete()
            moveButton.fillColor = SKColor(red: 0.10, green: 0.14, blue: 0.22, alpha: 0.95)
            moveButtonLabel.text = "MOVE"
            return
        }
        
        if isButtonPressed {
            moveNinja()
        } else {
            ninja.hide()
            checkHidingZone()
            moveButton.fillColor = SKColor(red: 0.10, green: 0.14, blue: 0.22, alpha: 0.95)
            moveButtonLabel.text = "MOVE"
        }
    }
    
    private func checkHidingZone() {
        ninja.isInHidingZone = false
        
        for hp in hidingPoints {
            if hp.contains(point: ninja.position) {
                ninja.isInHidingZone = true
                hp.activate()
            } else {
                hp.deactivate()
            }
        }
    }
    
    private func checkLevelComplete() {
        let distance = hypot(ninja.position.x - currentLevel.endPosition.x,
                            ninja.position.y - currentLevel.endPosition.y)
        
        if distance < 50 {
            levelComplete()
        }
    }
    
    private func levelComplete() {
        gameState = .completed
        
        // Stop all NPCs
        for npc in npcs {
            npc.stopPatrol()
        }
        
        // Show completion message
        let message = SKLabelNode(fontNamed: "Arial-BoldMT")
        message.text = "LEVEL COMPLETE!"
        message.fontSize = 40
        message.fontColor = .green
        message.position = CGPoint(x: 0, y: 0)
        message.zPosition = 200
        message.alpha = 0
        cameraNode.addChild(message)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, SKAction.run { [weak self] in
            message.removeFromParent()
            self?.loadNextLevel()
        }])
        message.run(sequence)
    }
    
    private func loadNextLevel() {
        currentLevelNumber += 1
        let totalLevels = LevelManager.shared.getTotalLevels()
        
        if currentLevelNumber > totalLevels {
            // All designed levels complete - now procedural endless mode!
            showEndlessMode()
        } else {
            loadLevel(levelNumber: currentLevelNumber)
        }
    }
    
    private func showEndlessMode() {
        let message = SKLabelNode(fontNamed: "Arial-BoldMT")
        message.text = "ENTERING ENDLESS MODE!"
        message.fontSize = 32
        message.fontColor = .yellow
        message.position = CGPoint(x: 0, y: 50)
        message.zPosition = 200
        message.alpha = 0
        cameraNode.addChild(message)

        let subMessage = SKLabelNode(fontNamed: "Arial")
        subMessage.text = "Procedurally generated levels"
        subMessage.fontSize = 18
        subMessage.fontColor = .white
        subMessage.position = CGPoint(x: 0, y: 10)
        subMessage.zPosition = 200
        subMessage.alpha = 0
        cameraNode.addChild(subMessage)

        let levelInfo = SKLabelNode(fontNamed: "Arial-BoldMT")
        levelInfo.text = "Level \(currentLevelNumber)"
        levelInfo.fontSize = 24
        levelInfo.fontColor = .cyan
        levelInfo.position = CGPoint(x: 0, y: -30)
        levelInfo.zPosition = 200
        levelInfo.alpha = 0
        cameraNode.addChild(levelInfo)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 2.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, SKAction.run { [weak self] in
            message.removeFromParent()
            subMessage.removeFromParent()
            levelInfo.removeFromParent()
            self?.loadLevel(levelNumber: self?.currentLevelNumber ?? 1)
        }])
        
        message.run(sequence)
        subMessage.run(sequence)
        levelInfo.run(sequence)
    }
    
    private func showGameComplete() {
        let message = SKLabelNode(fontNamed: "Arial-BoldMT")
        message.text = "ALL LEVELS COMPLETE!"
        message.fontSize = 36
        message.fontColor = .cyan
        message.position = CGPoint(x: 0, y: 50)
        message.zPosition = 200
        cameraNode.addChild(message)

        let restartMessage = SKLabelNode(fontNamed: "Arial")
        restartMessage.text = "Tap ↻ to restart"
        restartMessage.fontSize = 20
        restartMessage.fontColor = .white
        restartMessage.position = CGPoint(x: 0, y: -50)
        restartMessage.zPosition = 200
        cameraNode.addChild(restartMessage)
        
        gameState = .completed
    }
    
    private func gameOver() {
        gameState = .failed
        ninja.detected()
        
        // Stop all NPCs
        for npc in npcs {
            npc.stopPatrol()
        }
        
        // Show game over message
        let message = SKLabelNode(fontNamed: "Arial-BoldMT")
        message.text = "DETECTED!"
        message.fontSize = 40
        message.fontColor = .red
        message.position = CGPoint(x: 0, y: 0)
        message.zPosition = 200
        message.alpha = 0
        cameraNode.addChild(message)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, SKAction.run {
            message.removeFromParent()
        }])
        message.run(sequence)
        
        // Auto restart after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            if self.gameState == .failed {
                self.loadLevel(levelNumber: self.currentLevelNumber)
            }
        }
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }
        
        updateCamera()
        updateDetection()
        updateProgress()
    }
    
    private func updateCamera() {
        let targetX = ninja.position.x

        let visibleW = size.width
        let visibleH = size.height

        // Clamp X to level bounds
        let minX = visibleW / 2
        let maxX = currentLevel.levelWidth - visibleW / 2
        let clampedX = min(max(targetX, minX), maxX)

        // Center camera Y on the play area (~y=220), gently follow ninja Y
        let playAreaCenter: CGFloat = 220
        let targetY = playAreaCenter + (ninja.position.y - playAreaCenter) * 0.4
        let minY = visibleH / 2 - 40
        let maxY: CGFloat = 500
        let clampedY = min(max(targetY, minY), maxY)

        cameraNode.position = CGPoint(x: clampedX, y: clampedY)

        // Parallax: shift each layer based on camera X offset
        for (node, speed) in parallaxLayers {
            node.position.x = clampedX * (1.0 - speed)
        }
    }
    
    private func updateDetection() {
        guard ninja.currentState != .detected else { return }
        
        // Remove old debug lines
        worldNode.enumerateChildNodes(withName: "debugLine") { node, _ in
            node.removeFromParent()
        }
        
        var isDetected = false
        var detectingNPC: StealthNPCCharacter? = nil
        
        // Check if any NPC can see the ninja
        for npc in npcs {
            let canSeeNinja = npc.canSee(point: ninja.position)
            
            // Draw debug line if enabled
            if showDebugDetection {
                let line = SKShapeNode()
                let path = CGMutablePath()
                path.move(to: npc.position)
                path.addLine(to: ninja.position)
                line.path = path
                line.strokeColor = canSeeNinja ? .red : .green
                line.lineWidth = 2
                line.alpha = 0.5
                line.name = "debugLine"
                line.zPosition = 100
                worldNode.addChild(line)
            }
            
            if canSeeNinja {
                // Only detect if ninja is not in hiding zone or is moving
                if !ninja.isInHidingZone || ninja.currentState == .moving {
                    isDetected = true
                    detectingNPC = npc
                    detectionLevel = min(detectionLevel + 0.05, 1.0)
                    
                    // Visual feedback: make detecting NPC flash
                    if npc.action(forKey: "detectingFlash") == nil {
                        let flash = SKAction.sequence([
                            SKAction.fadeAlpha(to: 0.7, duration: 0.2),
                            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
                        ])
                        npc.run(SKAction.repeatForever(flash), withKey: "detectingFlash")
                    }
                    break
                }
            }
        }
        
        // Remove flash from NPCs that are no longer detecting
        if !isDetected {
            for npc in npcs {
                npc.removeAction(forKey: "detectingFlash")
            }
            detectionLevel = max(detectionLevel - 0.02, 0.0)
        } else if let detectingNPC = detectingNPC {
            // Remove flash from other NPCs
            for npc in npcs where npc != detectingNPC {
                npc.removeAction(forKey: "detectingFlash")
            }
        }
        
        updateDetectionIndicator()
        
        // Trigger game over if fully detected
        if detectionLevel >= 1.0 {
            gameOver()
        }
    }
    
    private func updateDetectionIndicator() {
        let detW: CGFloat = 72
        let detH: CGFloat = 8
        let fillW = max(CGFloat(detectionLevel) * detW, 1)

        let color: SKColor
        let labelText: String
        if detectionLevel < 0.3 {
            color = SKColor(red: 0.2, green: 0.9, blue: 0.45, alpha: 1)
            labelText = "SAFE"
        } else if detectionLevel < 0.65 {
            color = SKColor(red: 1.0, green: 0.8, blue: 0.1, alpha: 1)
            labelText = "ALERT"
        } else {
            color = SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1)
            labelText = "DANGER"
        }

        detectionBarFill.path = CGPath(
            roundedRect: CGRect(x: 0, y: -detH / 2, width: fillW, height: detH),
            cornerWidth: 4, cornerHeight: 4, transform: nil
        )
        detectionBarFill.fillColor = color
        detectionLabel.fontColor = color
        detectionLabel.text = labelText

        // Stealth badge update
        let isHidden = ninja.isInHidingZone && ninja.currentState != .moving
        stealthBadge.strokeColor = isHidden
            ? SKColor(red: 0.2, green: 0.9, blue: 0.45, alpha: 0.8)
            : SKColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 0.6)
        stealthLabel.text = isHidden ? "🌙 HIDE" : "👁 SEEN"
        stealthLabel.fontColor = isHidden
            ? SKColor(red: 0.2, green: 0.9, blue: 0.45, alpha: 1)
            : SKColor(red: 1.0, green: 0.4, blue: 0.3, alpha: 1)

        // Pulse detection bar when in danger
        if detectionLevel > 0.5 {
            if detectionBar.action(forKey: "pulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.04, duration: 0.25),
                    SKAction.scale(to: 1.0, duration: 0.25)
                ])
                detectionBar.run(SKAction.repeatForever(pulse), withKey: "pulse")
            }
        } else {
            detectionBar.removeAction(forKey: "pulse")
            detectionBar.setScale(1.0)
        }
    }
    
    private func updateProgress() {
        let totalDistance = currentLevel.endPosition.x - currentLevel.startPosition.x
        let currentDistance = ninja.position.x - currentLevel.startPosition.x
        let progress = max(0, min(1, currentDistance / totalDistance))
        let barWidth = size.width * 0.52
        let barHeight: CGFloat = 8
        let fillWidth = max(barWidth * progress, 1)
        progressBarFill.path = CGPath(
            roundedRect: CGRect(x: 0, y: -barHeight / 2, width: fillWidth, height: barHeight),
            cornerWidth: 4, cornerHeight: 4, transform: nil
        )
        // Color shifts green → amber as ninja gets further
        let r = 0.2 + 0.8 * progress
        let g = 0.9 - 0.4 * progress
        progressBarFill.fillColor = SKColor(red: r, green: g, blue: 0.3, alpha: 1)

        // Move ninja icon along bar
        progressNinjaIcon.position = CGPoint(
            x: -barWidth / 2 + barWidth * progress,
            y: progressNinjaIcon.position.y
        )
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: cameraNode)

        let restartDist = hypot(location.x - restartButton.position.x, location.y - restartButton.position.y)
        if restartDist < 28 {
            currentLevelNumber = 1
            loadLevel(levelNumber: currentLevelNumber)
            return
        }

        // Move button — distance check against button radius
        let buttonDist = hypot(location.x - moveButton.position.x, location.y - moveButton.position.y)
        if buttonDist <= buttonSize / 2 {
            isButtonPressed = true
            moveNinja()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isButtonPressed = false
        
        if ninja.currentState == .moving {
            stopNinja()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isButtonPressed = false
        
        if ninja.currentState == .moving {
            stopNinja()
        }
    }
}
