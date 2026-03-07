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
    
    // MARK: - UI Elements
    private var moveButton: SKShapeNode!
    private var moveButtonLabel: SKLabelNode!
    private var progressBar: SKShapeNode!
    private var progressBarFill: SKShapeNode!
    private var detectionIndicator: SKShapeNode!
    private var restartButton: SKLabelNode!
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
        // Dark night theme for stealth atmosphere
        backgroundColor = SKColor(red: 0.05, green: 0.08, blue: 0.15, alpha: 1.0)
        
        // Setup camera
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        
        // Setup world container
        worldNode = SKNode()
        addChild(worldNode)
        
        // Add atmospheric particles (stars, fog, etc.)
        addAtmosphericEffects()
        
        // Setup UI
        setupUI()
    }
    
    private func setupUI() {
        let viewWidth = size.width
        let viewHeight = size.height
        let topY = viewHeight / 2 - 40
        let btnY = -viewHeight / 2 + buttonSize / 2 + uiPadding

        // === MOVE BUTTON (bottom center) ===
        moveButton = SKShapeNode(circleOfRadius: buttonSize / 2)
        moveButton.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.9, alpha: 0.9)
        moveButton.strokeColor = SKColor.white.withAlphaComponent(0.5)
        moveButton.lineWidth = 2
        moveButton.position = CGPoint(x: 0, y: btnY)
        moveButton.zPosition = 100
        moveButton.name = "moveButton"
        cameraNode.addChild(moveButton)

        moveButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        moveButtonLabel.text = "MOVE"
        moveButtonLabel.fontSize = 20
        moveButtonLabel.fontColor = .white
        moveButtonLabel.verticalAlignmentMode = .center
        moveButton.addChild(moveButtonLabel)

        // === LEVEL LABEL (top center) ===
        levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        levelLabel.text = "LEVEL \(currentLevelNumber)"
        levelLabel.fontSize = 20
        levelLabel.fontColor = SKColor.white.withAlphaComponent(0.9)
        levelLabel.position = CGPoint(x: 0, y: topY)
        levelLabel.zPosition = 100
        cameraNode.addChild(levelLabel)

        // === PROGRESS BAR (below level label) ===
        let barWidth: CGFloat = viewWidth * 0.55
        let barHeight: CGFloat = 6
        let barY = topY - 26

        progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 3)
        progressBar.fillColor = SKColor.white.withAlphaComponent(0.15)
        progressBar.strokeColor = .clear
        progressBar.position = CGPoint(x: 0, y: barY)
        progressBar.zPosition = 100
        cameraNode.addChild(progressBar)

        progressBarFill = SKShapeNode(rectOf: CGSize(width: 1, height: barHeight), cornerRadius: 3)
        progressBarFill.fillColor = SKColor(red: 0.3, green: 1.0, blue: 0.5, alpha: 1.0)
        progressBarFill.strokeColor = .clear
        progressBarFill.position = CGPoint(x: -barWidth / 2, y: 0)
        progressBar.addChild(progressBarFill)

        // === DETECTION INDICATOR (top right) ===
        detectionIndicator = SKShapeNode(circleOfRadius: 12)
        detectionIndicator.fillColor = SKColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1.0)
        detectionIndicator.strokeColor = .clear
        detectionIndicator.position = CGPoint(x: viewWidth / 2 - 28, y: topY)
        detectionIndicator.zPosition = 100
        cameraNode.addChild(detectionIndicator)

        // === RESTART BUTTON (top left) ===
        restartButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartButton.text = "↻"
        restartButton.fontSize = 30
        restartButton.fontColor = SKColor.white.withAlphaComponent(0.8)
        restartButton.position = CGPoint(x: -viewWidth / 2 + 28, y: topY - 8)
        restartButton.zPosition = 100
        restartButton.name = "restartButton"
        cameraNode.addChild(restartButton)
    }
    
    private func loadLevel(levelNumber: Int) {
        // Clear existing level
        worldNode.removeAllChildren()
        hidingPoints.removeAll()
        npcs.removeAll()
        
        // Load level data
        currentLevel = LevelManager.shared.getLevelData(levelNumber: levelNumber)
        currentLevelNumber = levelNumber
        levelLabel.text = "LEVEL \(levelNumber)"
        
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
        // === LAYERED BACKGROUND FOR DEPTH ===
        
        // Far background - Dark sky
        let skyHeight: CGFloat = 800
        let sky = SKShapeNode(rectOf: CGSize(width: currentLevel.levelWidth, height: skyHeight))
        let skyColors = [
            SKColor(red: 0.05, green: 0.08, blue: 0.15, alpha: 1.0),
            SKColor(red: 0.1, green: 0.12, blue: 0.2, alpha: 1.0)
        ]
        sky.fillColor = skyColors[0]
        sky.strokeColor = .clear
        sky.position = CGPoint(x: currentLevel.levelWidth / 2, y: 400)
        sky.zPosition = -10
        worldNode.addChild(sky)
        
        // Add stars
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.9)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...currentLevel.levelWidth),
                y: CGFloat.random(in: 200...700)
            )
            star.zPosition = -9
            
            // Twinkling animation
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1.0...2.0)),
                SKAction.fadeAlpha(to: 0.9, duration: Double.random(in: 1.0...2.0))
            ])
            star.run(SKAction.repeatForever(twinkle))
            
            worldNode.addChild(star)
        }
        
        // Ground layer - Main play area tiled with pixel art ground tiles
        let tileSize: CGFloat = 64
        let groundMinY: CGFloat = 50
        let groundMaxY: CGFloat = 450
        for x in stride(from: CGFloat(0), through: currentLevel.levelWidth, by: tileSize) {
            for y in stride(from: groundMinY, through: groundMaxY, by: tileSize) {
                let tile = SKSpriteNode(imageNamed: "ground_tile")
                tile.size = CGSize(width: tileSize, height: tileSize)
                tile.position = CGPoint(x: x + tileSize / 2, y: y + tileSize / 2)
                tile.zPosition = 0
                worldNode.addChild(tile)
            }
        }

        // Scatter decorative world props
        addWorldProps()
        
        // Add atmospheric fog/mist effect
        let fogParticles = SKEmitterNode()
        fogParticles.particleTexture = SKTexture(imageNamed: "spark") // Falls back gracefully if missing
        fogParticles.particleBirthRate = 5
        fogParticles.numParticlesToEmit = 0
        fogParticles.particleLifetime = 20
        fogParticles.particlePositionRange = CGVector(dx: currentLevel.levelWidth, dy: 400)
        fogParticles.particleSpeed = 10
        fogParticles.particleSpeedRange = 5
        fogParticles.emissionAngle = 0
        fogParticles.emissionAngleRange = .pi / 8
        fogParticles.particleAlpha = 0.1
        fogParticles.particleAlphaRange = 0.05
        fogParticles.particleScale = 3.0
        fogParticles.particleScaleRange = 1.0
        fogParticles.particleColor = .white
        fogParticles.particleBlendMode = .alpha
        fogParticles.position = CGPoint(x: currentLevel.levelWidth / 2, y: 300)
        fogParticles.zPosition = 8
        worldNode.addChild(fogParticles)
    }
    
    private func addWorldProps() {
        // Prop definitions: (textureName, size, zPosition)
        let propDefs: [(String, CGSize, CGFloat)] = [
            ("barrel",      CGSize(width: 48, height: 48), 3),
            ("crate",       CGSize(width: 48, height: 48), 3),
            ("rock",        CGSize(width: 40, height: 36), 3),
            ("tree_top",    CGSize(width: 64, height: 72), 4),
            ("lantern_post",CGSize(width: 40, height: 72), 4)
        ]

        // Predefined scatter positions to avoid gameplay areas (hiding points are near y=150-300)
        let edgeYPositions: [CGFloat] = [60, 80, 380, 410, 430]
        let spacing: CGFloat = 280

        var x: CGFloat = 150
        var propIndex = 0
        while x < currentLevel.levelWidth - 100 {
            let (name, size, zPos) = propDefs[propIndex % propDefs.count]
            let y = edgeYPositions[propIndex % edgeYPositions.count]
            let prop = SKSpriteNode(imageNamed: name)
            prop.size = size
            prop.position = CGPoint(x: x, y: y)
            prop.zPosition = zPos
            worldNode.addChild(prop)
            x += spacing + CGFloat.random(in: -60...60)
            propIndex += 1
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
        
        // Add particle effect for END marker
        if label == "END" {
            let particles = SKEmitterNode()
            particles.particleTexture = SKTexture(imageNamed: "spark")
            particles.particleBirthRate = 20
            particles.numParticlesToEmit = 0
            particles.particleLifetime = 1.5
            particles.particlePositionRange = CGVector(dx: 60, dy: 60)
            particles.particleSpeed = 30
            particles.particleSpeedRange = 20
            particles.emissionAngle = .pi / 2
            particles.emissionAngleRange = .pi * 2
            particles.particleAlpha = 0.8
            particles.particleAlphaSpeed = -0.5
            particles.particleScale = 0.3
            particles.particleScaleSpeed = -0.1
            particles.particleColor = color
            particles.particleBlendMode = .add
            marker.addChild(particles)
        }
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
        
        // Update button appearance
        moveButton.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.9)
        moveButtonLabel.text = "..."
    }
    
    private func stopNinja() {
        guard ninja.currentState == .moving else { return }
        
        ninja.removeAction(forKey: "movement")
        ninja.hide()
        
        // Check if in hiding zone
        checkHidingZone()
        
        // Update button appearance
        moveButton.fillColor = SKColor(red: 0.15, green: 0.5, blue: 0.9, alpha: 0.9)
        moveButtonLabel.text = "MOVE"
    }
    
    private func onNinjaReachedPoint() {
        ninja.targetHidingPointIndex += 1
        
        // ⚠️ CRITICAL: Check if ninja has reached the endpoint
        // When index exceeds hiding points count, ninja is at endpoint
        if ninja.targetHidingPointIndex > hidingPoints.count {
            // Ninja reached the endpoint - complete the level!
            checkLevelComplete()
            moveButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.8)
            moveButtonLabel.text = "MOVE"
            return
        }
        
        if isButtonPressed {
            moveNinja()
        } else {
            ninja.hide()
            checkHidingZone()
            moveButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.8)
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
        // Follow ninja with some smoothing
        let targetX = ninja.position.x
        let targetY = ninja.position.y
        
        // Clamp camera to level bounds
        let minX = size.width / 2
        let maxX = currentLevel.levelWidth - size.width / 2
        let clampedX = min(max(targetX, minX), maxX)
        
        cameraNode.position = CGPoint(x: clampedX, y: targetY)
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
        // Change color based on detection level
        if detectionLevel < 0.3 {
            detectionIndicator.fillColor = .green
        } else if detectionLevel < 0.7 {
            detectionIndicator.fillColor = .yellow
        } else {
            detectionIndicator.fillColor = .red
        }
        
        // Pulse when danger is high
        if detectionLevel > 0.5 {
            if detectionIndicator.action(forKey: "pulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
                detectionIndicator.run(SKAction.repeatForever(pulse), withKey: "pulse")
            }
        } else {
            detectionIndicator.removeAction(forKey: "pulse")
        }
    }
    
    private func updateProgress() {
        let totalDistance = currentLevel.endPosition.x - currentLevel.startPosition.x
        let currentDistance = ninja.position.x - currentLevel.startPosition.x
        let progress = max(0, min(1, currentDistance / totalDistance))
        let barWidth = size.width * 0.55
        let barHeight: CGFloat = 6
        let fillWidth = max(barWidth * progress, 1)
        progressBarFill.path = CGPath(
            roundedRect: CGRect(x: 0, y: -barHeight / 2, width: fillWidth, height: barHeight),
            cornerWidth: 3, cornerHeight: 3, transform: nil
        )
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: cameraNode)

        // Restart button — use distance check (reliable regardless of child node zPositions)
        let restartDist = hypot(location.x - restartButton.position.x, location.y - restartButton.position.y)
        if restartDist < 40 {
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
