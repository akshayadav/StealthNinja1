//
//  LevelSelectScene.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/16/26.
//

import SpriteKit

class LevelSelectScene: SKScene {

    private var backButton: SKShapeNode!
    private var scrollNode: SKNode!
    private var totalLevels: Int = 0
    private let columns = 3
    private let buttonSize: CGFloat = 80
    private let buttonSpacing: CGFloat = 20

    // Scroll tracking
    private var lastTouchY: CGFloat = 0
    private var scrollOffset: CGFloat = 0
    private var maxScrollOffset: CGFloat = 0

    override func didMove(to view: SKView) {
        backgroundColor = PastelPalette.skyBlue
        totalLevels = LevelManager.shared.getTotalLevels()

        setupBackButton()
        setupTitle()
        setupLevelGrid()
    }

    // MARK: - Setup

    private func setupBackButton() {
        backButton = SKShapeNode(rectOf: CGSize(width: 60, height: 40), cornerRadius: 10)
        backButton.fillColor = PastelPalette.warmBrown
        backButton.strokeColor = SKColor.white.withAlphaComponent(0.3)
        backButton.lineWidth = 2
        backButton.position = CGPoint(x: 50, y: size.height - 60)
        backButton.zPosition = 20

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "← BACK"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        backButton.addChild(label)

        addChild(backButton)
    }

    private func setupTitle() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "LEVEL SELECT"
        title.fontSize = 32
        title.fontColor = PastelPalette.softGold
        title.position = CGPoint(x: size.width / 2, y: size.height - 65)
        title.zPosition = 20
        addChild(title)
    }

    private func setupLevelGrid() {
        scrollNode = SKNode()
        scrollNode.zPosition = 10
        addChild(scrollNode)

        let gridWidth = CGFloat(columns) * buttonSize + CGFloat(columns - 1) * buttonSpacing
        let startX = (size.width - gridWidth) / 2 + buttonSize / 2
        let startY = size.height - 140

        let rows = Int(ceil(Double(totalLevels) / Double(columns)))
        let totalGridHeight = CGFloat(rows) * (buttonSize + buttonSpacing)
        let visibleHeight = size.height - 160
        maxScrollOffset = max(0, totalGridHeight - visibleHeight)

        for level in 1...totalLevels {
            let index = level - 1
            let col = index % columns
            let row = index / columns

            let x = startX + CGFloat(col) * (buttonSize + buttonSpacing)
            let y = startY - CGFloat(row) * (buttonSize + buttonSpacing)

            let isUnlocked = GameProgressManager.shared.isLevelUnlocked(level)
            let stars = GameProgressManager.shared.getStars(for: level)

            let buttonNode = createLevelButton(
                level: level,
                position: CGPoint(x: x, y: y),
                isUnlocked: isUnlocked,
                stars: stars
            )
            scrollNode.addChild(buttonNode)
        }
    }

    private func createLevelButton(level: Int, position: CGPoint,
                                    isUnlocked: Bool, stars: Int) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: buttonSize, height: buttonSize), cornerRadius: 12)
        button.position = position
        button.name = "level_\(level)"

        if isUnlocked {
            button.fillColor = PastelPalette.sageGreen
            button.strokeColor = SKColor.white.withAlphaComponent(0.4)
            button.lineWidth = 2

            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "\(level)"
            label.fontSize = 28
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: 0, y: stars > 0 ? 6 : 0)
            button.addChild(label)

            // Stars display
            if stars > 0 {
                let starsLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
                var starText = ""
                for i in 1...3 {
                    starText += i <= stars ? "★" : "☆"
                }
                starsLabel.text = starText
                starsLabel.fontSize = 14
                starsLabel.fontColor = PastelPalette.softGold
                starsLabel.verticalAlignmentMode = .center
                starsLabel.position = CGPoint(x: 0, y: -20)
                button.addChild(starsLabel)
            }
        } else {
            button.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.5)
            button.strokeColor = SKColor.white.withAlphaComponent(0.2)
            button.lineWidth = 2

            let lockLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            lockLabel.text = "🔒"
            lockLabel.fontSize = 28
            lockLabel.verticalAlignmentMode = .center
            button.addChild(lockLabel)
        }

        return button
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchY = location.y

        if backButton.contains(location) {
            AudioManager.shared.playButtonTap(on: self)
            transitionToMainMenu()
            return
        }

        // Check level buttons
        let locationInScroll = touch.location(in: scrollNode)
        for node in scrollNode.children {
            guard let button = node as? SKShapeNode,
                  let name = button.name,
                  name.hasPrefix("level_"),
                  button.contains(locationInScroll) else { continue }

            let levelStr = name.replacingOccurrences(of: "level_", with: "")
            guard let level = Int(levelStr) else { continue }

            if GameProgressManager.shared.isLevelUnlocked(level) {
                AudioManager.shared.playButtonTap(on: self)
                transitionToGame(levelNumber: level)
            }
            return
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let deltaY = location.y - lastTouchY
        lastTouchY = location.y

        scrollOffset = max(0, min(maxScrollOffset, scrollOffset - deltaY))
        scrollNode.position.y = scrollOffset
    }

    // MARK: - Transitions

    private func transitionToMainMenu() {
        let scene = MainMenuScene()
        scene.size = self.size
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }

    private func transitionToGame(levelNumber: Int) {
        let gameScene = GameScene()
        gameScene.size = self.size
        gameScene.scaleMode = .aspectFill
        gameScene.userData = NSMutableDictionary()
        gameScene.userData?["startLevel"] = levelNumber

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
}
