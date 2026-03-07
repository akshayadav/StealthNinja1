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
    private let showDebugDetection: Bool = true
    
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
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
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
        let viewWidth = size.width
        let viewHeight = size.height
        
        // Move Button (bottom center)
        let buttonY = -viewHeight / 2 + buttonSize / 2 + uiPadding
        moveButton = SKShapeNode(circleOfRadius: buttonSize / 2)
        moveButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.8)
        moveButton.strokeColor = .white
        moveButton.lineWidth = 3
        moveButton.position = CGPoint(x: 0, y: buttonY)
        moveButton.zPosition = 100
        moveButton.name = "moveButton"
        cameraNode.addChild(moveButton)
        
        moveButtonLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        moveButtonLabel.text = "MOVE"
        moveButtonLabel.fontSize = 20
        moveButtonLabel.fontColor = .white
        moveButtonLabel.verticalAlignmentMode = .center
        moveButtonLabel.zPosition = 101
        moveButton.addChild(moveButtonLabel)
        
        // Progress Bar (top)
        let barWidth: CGFloat = viewWidth - 100
        let barHeight: CGFloat = 20
        let barY = viewHeight / 2 - barHeight / 2 - uiPadding - 40
        
        progressBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 10)
        progressBar.fillColor = SKColor(white: 0.3, alpha: 0.8)
        progressBar.strokeColor = .white
        progressBar.lineWidth = 2
        progressBar.position = CGPoint(x: 0, y: barY)
        progressBar.zPosition = 100
        cameraNode.addChild(progressBar)
        
        progressBarFill = SKShapeNode(rectOf: CGSize(width: 0, height: barHeight - 4), cornerRadius: 8)
        progressBarFill.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        progressBarFill.strokeColor = .clear
        progressBarFill.position = CGPoint(x: -barWidth / 2, y: 0)
        progressBarFill.zPosition = 101
        progressBar.addChild(progressBarFill)
        
        // Level Label
        levelLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        levelLabel.text = "LEVEL \(currentLevelNumber)"
        levelLabel.fontSize = 24
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 0, y: viewHeight / 2 - 30)
        levelLabel.zPosition = 100
        cameraNode.addChild(levelLabel)
        
        // Detection Indicator
        let indicatorSize: CGFloat = 40
        detectionIndicator = SKShapeNode(circleOfRadius: indicatorSize / 2)
        detectionIndicator.fillColor = .green
        detectionIndicator.strokeColor = .white
        detectionIndicator.lineWidth = 2
        detectionIndicator.position = CGPoint(x: viewWidth / 2 - indicatorSize - uiPadding, y: barY)
        detectionIndicator.zPosition = 100
        cameraNode.addChild(detectionIndicator)
        
        // Restart Button
        restartButton = SKLabelNode(fontNamed: "Arial-BoldMT")
        restartButton.text = "↻"
        restartButton.fontSize = 32
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: -viewWidth / 2 + 30, y: barY)
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
        // Create a simple ground
        let groundHeight: CGFloat = 500
        let ground = SKShapeNode(rectOf: CGSize(width: currentLevel.levelWidth, height: groundHeight))
        ground.fillColor = SKColor(red: 0.15, green: 0.2, blue: 0.15, alpha: 1.0)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: currentLevel.levelWidth / 2, y: 250)
        ground.zPosition = 0
        worldNode.addChild(ground)
        
        // Add some grid lines for depth
        for x in stride(from: CGFloat(0), through: currentLevel.levelWidth, by: 200) {
            let line = SKShapeNode(rectOf: CGSize(width: 2, height: groundHeight))
            line.fillColor = SKColor(white: 0.2, alpha: 0.3)
            line.strokeColor = .clear
            line.position = CGPoint(x: x, y: 250)
            line.zPosition = 0
            worldNode.addChild(line)
        }
    }
    
    private func createMarker(at position: CGPoint, color: SKColor, label: String) {
        let marker = SKShapeNode(circleOfRadius: 30)
        marker.fillColor = color
        marker.alpha = 0.5
        marker.strokeColor = .white
        marker.lineWidth = 2
        marker.position = position
        marker.zPosition = 2
        worldNode.addChild(marker)
        
        let markerLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        markerLabel.text = label
        markerLabel.fontSize = 12
        markerLabel.fontColor = .white
        markerLabel.verticalAlignmentMode = .center
        marker.addChild(markerLabel)
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
        moveButton.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 0.8)
        moveButtonLabel.text = "..."
    }
    
    private func stopNinja() {
        guard ninja.currentState == .moving else { return }
        
        ninja.removeAction(forKey: "movement")
        ninja.hide()
        
        // Check if in hiding zone
        checkHidingZone()
        
        // Update button appearance
        moveButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 0.8)
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
        
        if let fill = progressBarFill as? SKShapeNode,
           let bar = progressBar as? SKShapeNode {
            let barWidth = bar.frame.width
            let fillWidth = barWidth * progress
            
            let newRect = SKShapeNode(rectOf: CGSize(width: fillWidth, height: 16), cornerRadius: 8)
            newRect.fillColor = progressBarFill.fillColor
            newRect.strokeColor = .clear
            newRect.position = CGPoint(x: -barWidth / 2 + fillWidth / 2, y: 0)
            newRect.zPosition = 101
            
            fill.removeFromParent()
            progressBarFill = newRect
            progressBar.addChild(progressBarFill)
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: cameraNode)
        let touchedNode = cameraNode.atPoint(location)
        
        // Check restart button
        if touchedNode.name == "restartButton" || touchedNode.parent?.name == "restartButton" {
            currentLevelNumber = 1
            loadLevel(levelNumber: currentLevelNumber)
            return
        }
        
        // Check move button
        if touchedNode.name == "moveButton" || touchedNode.parent?.name == "moveButton" {
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
