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
    var ninja: StealthNinjaCharacter!
    var hidingPoints: [StealthHidingPoint] = []
    var npcs: [StealthNPCCharacter] = []
    var worldNode: SKNode!
    var cameraNode: SKCameraNode!

    // Parallax background layers (back to front)
    var parallaxLayers: [(node: SKNode, speed: CGFloat)] = []

    // MARK: - UI Elements
    var moveButton: SKShapeNode!
    var moveButtonLabel: SKLabelNode!
    var progressBar: SKShapeNode!
    var progressBarFill: SKShapeNode!
    var progressNinjaIcon: SKLabelNode!
    var detectionBar: SKShapeNode!
    var detectionBarFill: SKShapeNode!
    var detectionLabel: SKLabelNode!
    var stealthBadge: SKShapeNode!
    var stealthLabel: SKLabelNode!
    var restartButton: SKShapeNode!
    var levelLabel: SKLabelNode!

    // MARK: - Game State
    var gameState: StealthGamePlayState = .playing
    var currentLevel: LevelData!
    var currentLevelNumber: Int = 1
    var isButtonPressed: Bool = false
    var detectionLevel: CGFloat = 0.0

    // Debug mode - set to true to see detection lines
    let showDebugDetection: Bool = false

    // MARK: - Timer
    var levelStartTime: TimeInterval = 0
    var levelElapsedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Pause
    var menuButton: SKShapeNode!
    private var pauseOverlay: SKNode?

    // MARK: - Audio
    private var footstepPlayer: AVAudioPlayer?
    private var alertSoundPlayer: AVAudioPlayer?

    // MARK: - Story
    var dialogueManager: StoryDialogueManager?
    var recipePageLabel: SKLabelNode?

    // MARK: - Constants
    let buttonSize: CGFloat = 100
    let uiPadding: CGFloat = 20

    override func didMove(to view: SKView) {
        // Check if a starting level was passed via userData
        if let startLevel = userData?["startLevel"] as? Int {
            currentLevelNumber = startLevel
        }
        setupScene()
        loadLevel(levelNumber: currentLevelNumber)
    }

    // MARK: - Setup
    private func setupScene() {
        backgroundColor = PastelPalette.skyBlue

        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode

        worldNode = SKNode()
        addChild(worldNode)

        setupUI()

        dialogueManager = StoryDialogueManager(parentNode: cameraNode)
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
            backgroundColor = SKColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1)
        case .sunnyVillage:
            backgroundColor = PastelPalette.skyBlue
        case .meadowPath, .villageFarm:
            backgroundColor = PastelPalette.skyBlue
        case .riverCrossing:
            backgroundColor = SKColor(red: 0.65, green: 0.82, blue: 0.90, alpha: 1)
        case .harborTown:
            backgroundColor = SKColor(red: 0.72, green: 0.88, blue: 0.95, alpha: 1)
        case .festivalGrounds:
            backgroundColor = SKColor(red: 0.85, green: 0.78, blue: 0.92, alpha: 1)
        case .nightGarden:
            backgroundColor = SKColor(red: 0.15, green: 0.12, blue: 0.25, alpha: 1)
        }

        // Create background
        createBackground()

        // Create start and end markers
        createMarker(at: currentLevel.startPosition, color: PastelPalette.sageGreen, label: "START")
        createMarker(at: currentLevel.endPosition, color: PastelPalette.softGold, label: "END")

        // Create START position as first hiding point (safe zone)
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

        // Add ambient life (decorative creatures)
        addAmbientLife()

        // Create ninja
        ninja = StealthNinjaCharacter()
        ninja.position = currentLevel.startPosition
        worldNode.addChild(ninja)

        // Set ninja to start in hiding zone (at start point)
        ninja.isInHidingZone = true

        // Position camera at start
        updateCamera()

        // Reset game state
        gameState = .playing
        detectionLevel = 0.0
        levelStartTime = 0
        levelElapsedTime = 0
        lastUpdateTime = 0
        updateDetectionIndicator()

        // Play background music for theme
        AudioManager.shared.playBackgroundMusic(theme: currentLevel.theme)

        // Show story intro dialogue
        if let story = StoryData.stories[levelNumber] {
            gameState = .paused
            dialogueManager?.showDialogue(lines: story.introLines) { [weak self] in
                self?.gameState = .playing
            }
        }
    }

    // MARK: - Game Logic
    private func moveNinja() {
        guard gameState == .playing else { return }
        guard ninja.currentState != .moving else { return }

        let nextIndex = ninja.targetHidingPointIndex

        // Determine target position: either next hiding point OR the endpoint
        let targetPosition: CGPoint
        if nextIndex < hidingPoints.count {
            targetPosition = hidingPoints[nextIndex].position
        } else {
            // Past all hiding points - move to endpoint to complete level
            targetPosition = currentLevel.endPosition
        }

        let distance = hypot(targetPosition.x - ninja.position.x,
                            targetPosition.y - ninja.position.y)
        let duration = TimeInterval(distance / 100.0)

        ninja.reveal()
        ninja.moveTo(point: targetPosition, duration: duration) { [weak self] in
            self?.onNinjaReachedPoint()
        }

        moveButton.fillColor = PastelPalette.dustyRose.withAlphaComponent(0.9)
        moveButtonLabel.text = "STOP"
    }

    private func stopNinja() {
        guard ninja.currentState == .moving else { return }

        ninja.removeAction(forKey: "movement")
        ninja.hide()

        checkHidingZone()

        moveButton.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.85)
        moveButtonLabel.text = "MOVE"
    }

    private func onNinjaReachedPoint() {
        ninja.targetHidingPointIndex += 1

        if ninja.targetHidingPointIndex > hidingPoints.count {
            checkLevelComplete()
            moveButton.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.85)
            moveButtonLabel.text = "MOVE"
            return
        }

        if isButtonPressed {
            moveNinja()
        } else {
            ninja.hide()
            checkHidingZone()
            moveButton.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.85)
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
        AudioManager.shared.playLevelComplete(on: self)

        for npc in npcs {
            npc.stopPatrol()
        }

        // Save progress
        GameProgressManager.shared.completeLevel(currentLevelNumber, time: levelElapsedTime)
        let stars = GameProgressManager.shared.getStars(for: currentLevelNumber)

        // Show recipe page pickup animation
        showRecipePagePickup()

        // Show outro dialogue, then results
        if let story = StoryData.stories[currentLevelNumber] {
            dialogueManager?.showDialogue(lines: story.outroLines) { [weak self] in
                guard let self = self else { return }
                // After level 7, show ending cutscene
                if self.currentLevelNumber == 7 {
                    self.dialogueManager?.showDialogue(lines: StoryData.endingLines) {
                        self.showResultsOverlay(time: self.levelElapsedTime, stars: stars)
                    }
                } else {
                    self.showResultsOverlay(time: self.levelElapsedTime, stars: stars)
                }
            }
        } else {
            showResultsOverlay(time: levelElapsedTime, stars: stars)
        }
    }

    private func loadNextLevel() {
        currentLevelNumber += 1
        let totalLevels = LevelManager.shared.getTotalLevels()

        if currentLevelNumber > totalLevels {
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

    private func showResultsOverlay(time: TimeInterval, stars: Int) {
        let overlay = SKNode()
        overlay.name = "resultsOverlay"
        overlay.zPosition = 300

        let bg = SKShapeNode(rectOf: CGSize(width: 280, height: 300), cornerRadius: 20)
        bg.fillColor = PastelPalette.darkPanel
        bg.strokeColor = PastelPalette.softGold.withAlphaComponent(0.6)
        bg.lineWidth = 2
        bg.position = .zero
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "LEVEL COMPLETE!"
        title.fontSize = 24
        title.fontColor = PastelPalette.sageGreen
        title.position = CGPoint(x: 0, y: 100)
        overlay.addChild(title)

        let timeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        timeLabel.text = "Time: \(mins):\(String(format: "%02d", secs))"
        timeLabel.fontSize = 20
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: 0, y: 55)
        overlay.addChild(timeLabel)

        var starText = ""
        for i in 1...3 {
            starText += i <= stars ? "★" : "☆"
        }
        let starsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        starsLabel.text = starText
        starsLabel.fontSize = 36
        starsLabel.fontColor = PastelPalette.softGold
        starsLabel.position = CGPoint(x: 0, y: 15)
        overlay.addChild(starsLabel)

        // Next Level button
        let nextBtn = SKShapeNode(rectOf: CGSize(width: 180, height: 44), cornerRadius: 12)
        nextBtn.fillColor = PastelPalette.sageGreen
        nextBtn.strokeColor = SKColor.white.withAlphaComponent(0.3)
        nextBtn.lineWidth = 2
        nextBtn.position = CGPoint(x: 0, y: -40)
        nextBtn.name = "nextLevelButton"
        overlay.addChild(nextBtn)

        let nextLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nextLabel.text = "NEXT LEVEL"
        nextLabel.fontSize = 18
        nextLabel.fontColor = .white
        nextLabel.verticalAlignmentMode = .center
        nextBtn.addChild(nextLabel)

        // Menu button
        let menuBtn = SKShapeNode(rectOf: CGSize(width: 180, height: 44), cornerRadius: 12)
        menuBtn.fillColor = PastelPalette.warmBrown
        menuBtn.strokeColor = SKColor.white.withAlphaComponent(0.3)
        menuBtn.lineWidth = 2
        menuBtn.position = CGPoint(x: 0, y: -95)
        menuBtn.name = "menuButton"
        overlay.addChild(menuBtn)

        let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuLabel.text = "MAIN MENU"
        menuLabel.fontSize = 18
        menuLabel.fontColor = .white
        menuLabel.verticalAlignmentMode = .center
        menuBtn.addChild(menuLabel)

        overlay.alpha = 0
        cameraNode.addChild(overlay)
        overlay.run(SKAction.fadeIn(withDuration: 0.4))
    }

    private func showPauseMenu() {
        guard gameState == .playing else { return }
        gameState = .paused
        isPaused = true

        let overlay = SKNode()
        overlay.name = "pauseOverlay"
        overlay.zPosition = 300
        pauseOverlay = overlay

        let bg = SKShapeNode(rectOf: CGSize(width: 260, height: 260), cornerRadius: 20)
        bg.fillColor = PastelPalette.darkPanel
        bg.strokeColor = PastelPalette.softGold.withAlphaComponent(0.6)
        bg.lineWidth = 2
        bg.position = .zero
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "PAUSED"
        title.fontSize = 28
        title.fontColor = PastelPalette.softGold
        title.position = CGPoint(x: 0, y: 80)
        overlay.addChild(title)

        let resumeBtn = SKShapeNode(rectOf: CGSize(width: 180, height: 44), cornerRadius: 12)
        resumeBtn.fillColor = PastelPalette.sageGreen
        resumeBtn.strokeColor = SKColor.white.withAlphaComponent(0.3)
        resumeBtn.lineWidth = 2
        resumeBtn.position = CGPoint(x: 0, y: 20)
        resumeBtn.name = "resumeButton"
        overlay.addChild(resumeBtn)
        let resumeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resumeLabel.text = "RESUME"
        resumeLabel.fontSize = 18
        resumeLabel.fontColor = .white
        resumeLabel.verticalAlignmentMode = .center
        resumeBtn.addChild(resumeLabel)

        let restartBtn = SKShapeNode(rectOf: CGSize(width: 180, height: 44), cornerRadius: 12)
        restartBtn.fillColor = PastelPalette.dustyRose
        restartBtn.strokeColor = SKColor.white.withAlphaComponent(0.3)
        restartBtn.lineWidth = 2
        restartBtn.position = CGPoint(x: 0, y: -35)
        restartBtn.name = "pauseRestartButton"
        overlay.addChild(restartBtn)
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 18
        restartLabel.fontColor = .white
        restartLabel.verticalAlignmentMode = .center
        restartBtn.addChild(restartLabel)

        let quitBtn = SKShapeNode(rectOf: CGSize(width: 180, height: 44), cornerRadius: 12)
        quitBtn.fillColor = PastelPalette.warmBrown
        quitBtn.strokeColor = SKColor.white.withAlphaComponent(0.3)
        quitBtn.lineWidth = 2
        quitBtn.position = CGPoint(x: 0, y: -90)
        quitBtn.name = "quitButton"
        overlay.addChild(quitBtn)
        let quitLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        quitLabel.text = "QUIT TO MENU"
        quitLabel.fontSize = 18
        quitLabel.fontColor = .white
        quitLabel.verticalAlignmentMode = .center
        quitBtn.addChild(quitLabel)

        cameraNode.addChild(overlay)
    }

    private func dismissPauseMenu() {
        pauseOverlay?.removeFromParent()
        pauseOverlay = nil
        gameState = .playing
        isPaused = false
    }

    func returnToMainMenu() {
        AudioManager.shared.stopBackgroundMusic()
        let scene = MainMenuScene()
        scene.size = self.size
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }

    private func gameOver() {
        gameState = .failed
        ninja.detected()
        AudioManager.shared.playGameOver(on: self)

        for npc in npcs {
            npc.stopPatrol()
        }

        let message = SKLabelNode(fontNamed: "Arial-BoldMT")
        message.text = "DETECTED!"
        message.fontSize = 40
        message.fontColor = PastelPalette.dustyRose
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            if self.gameState == .failed {
                self.loadLevel(levelNumber: self.currentLevelNumber)
            }
        }
    }

    private func showRecipePagePickup() {
        guard let story = StoryData.stories[currentLevelNumber] else { return }

        let pageNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        pageNode.text = story.recipePageTitle
        pageNode.fontSize = 20
        pageNode.fontColor = PastelPalette.softGold
        pageNode.position = CGPoint(x: 0, y: 40)
        pageNode.zPosition = 350
        pageNode.alpha = 0
        pageNode.setScale(0.5)
        cameraNode.addChild(pageNode)

        let scrollIcon = SKLabelNode(text: "📜")
        scrollIcon.fontSize = 40
        scrollIcon.position = CGPoint(x: 0, y: 80)
        scrollIcon.zPosition = 350
        scrollIcon.alpha = 0
        scrollIcon.setScale(0.3)
        cameraNode.addChild(scrollIcon)

        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.2, duration: 0.3),
        ])
        let settle = SKAction.scale(to: 1.0, duration: 0.15)
        let hold = SKAction.wait(forDuration: 1.5)
        let disappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.moveBy(x: 0, y: 30, duration: 0.4),
        ])
        let seq = SKAction.sequence([appear, settle, hold, disappear, SKAction.removeFromParent()])
        pageNode.run(seq)
        scrollIcon.run(seq)

        // Update recipe counter in HUD
        updateRecipeCounter()
    }

    func updateRecipeCounter() {
        let collected = min(currentLevelNumber, 7)
        recipePageLabel?.text = "📜 \(collected)/7"
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard gameState == .playing else { return }

        // Track level time
        if levelStartTime == 0 {
            levelStartTime = currentTime
            lastUpdateTime = currentTime
        }
        levelElapsedTime = currentTime - levelStartTime

        updateCamera()
        updateDetection()
        updateProgress()
    }

    private func updateCamera() {
        let targetX = ninja.position.x

        let visibleW = size.width
        let visibleH = size.height

        let minX = visibleW / 2
        let maxX = currentLevel.levelWidth - visibleW / 2
        let clampedX = min(max(targetX, minX), maxX)

        let playAreaCenter: CGFloat = 220
        let targetY = playAreaCenter + (ninja.position.y - playAreaCenter) * 0.4
        let minY = visibleH / 2 - 40
        let maxY: CGFloat = 500
        let clampedY = min(max(targetY, minY), maxY)

        cameraNode.position = CGPoint(x: clampedX, y: clampedY)

        for (node, speed) in parallaxLayers {
            node.position.x = clampedX * (1.0 - speed)
        }
    }

    private func updateDetection() {
        guard ninja.currentState != .detected else { return }

        worldNode.enumerateChildNodes(withName: "debugLine") { node, _ in
            node.removeFromParent()
        }

        var isDetected = false
        var detectingNPC: StealthNPCCharacter? = nil

        for npc in npcs {
            let canSeeNinja = npc.canSee(point: ninja.position)

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
                if !ninja.isInHidingZone || ninja.currentState == .moving {
                    isDetected = true
                    detectingNPC = npc
                    detectionLevel = min(detectionLevel + 0.05, 1.0)

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

        if !isDetected {
            for npc in npcs {
                npc.removeAction(forKey: "detectingFlash")
            }
            detectionLevel = max(detectionLevel - 0.02, 0.0)
        } else if let detectingNPC = detectingNPC {
            for npc in npcs where npc != detectingNPC {
                npc.removeAction(forKey: "detectingFlash")
            }
        }

        updateDetectionIndicator()

        if detectionLevel >= 1.0 {
            gameOver()
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: cameraNode)

        // Handle dialogue tap
        if dialogueManager?.handleTap() == true {
            return
        }

        // Handle results overlay buttons
        if let overlay = cameraNode.childNode(withName: "resultsOverlay") {
            for child in overlay.children {
                guard let button = child as? SKShapeNode else { continue }
                let locInOverlay = touch.location(in: overlay)
                if button.name == "nextLevelButton" && button.contains(locInOverlay) {
                    overlay.removeFromParent()
                    loadNextLevel()
                    return
                }
                if button.name == "menuButton" && button.contains(locInOverlay) {
                    returnToMainMenu()
                    return
                }
            }
            return
        }

        // Handle pause overlay buttons
        if let overlay = pauseOverlay {
            let locInOverlay = touch.location(in: overlay)
            for child in overlay.children {
                guard let button = child as? SKShapeNode else { continue }
                if button.name == "resumeButton" && button.contains(locInOverlay) {
                    dismissPauseMenu()
                    return
                }
                if button.name == "pauseRestartButton" && button.contains(locInOverlay) {
                    dismissPauseMenu()
                    loadLevel(levelNumber: currentLevelNumber)
                    return
                }
                if button.name == "quitButton" && button.contains(locInOverlay) {
                    returnToMainMenu()
                    return
                }
            }
            return
        }

        // Menu/pause button (top left)
        if let menuBtn = menuButton {
            let menuDist = hypot(location.x - menuBtn.position.x, location.y - menuBtn.position.y)
            if menuDist < 28 {
                showPauseMenu()
                return
            }
        }

        // Restart button
        let restartDist = hypot(location.x - restartButton.position.x, location.y - restartButton.position.y)
        if restartDist < 28 {
            loadLevel(levelNumber: currentLevelNumber)
            return
        }

        // Move button
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
