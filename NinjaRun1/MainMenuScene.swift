//
//  MainMenuScene.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/16/26.
//

import SpriteKit

class MainMenuScene: SKScene {

    private var playButton: SKShapeNode!
    private var levelSelectButton: SKShapeNode!
    private var settingsButton: SKShapeNode!

    override func didMove(to view: SKView) {
        backgroundColor = PastelPalette.skyBlue
        setupTitle()
        setupNinjaDecoration()
        setupButtons()
        setupFloatingPetals()
    }

    // MARK: - Setup

    private func setupTitle() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "STEALTH NINJA"
        title.fontSize = 42
        title.fontColor = PastelPalette.softGold
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.82)
        title.zPosition = 10

        // Subtle shadow
        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.text = "STEALTH NINJA"
        shadow.fontSize = 42
        shadow.fontColor = PastelPalette.warmBrown.withAlphaComponent(0.4)
        shadow.position = CGPoint(x: size.width / 2 + 2, y: size.height * 0.82 - 2)
        shadow.zPosition = 9

        addChild(shadow)
        addChild(title)

        // Subtitle: story tagline
        let subtitle = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        subtitle.text = "The Great Dumpling Heist"
        subtitle.fontSize = 16
        subtitle.fontColor = PastelPalette.warmCream
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.82 - 34)
        subtitle.zPosition = 10
        subtitle.alpha = 0.8
        addChild(subtitle)

        // Gentle pulsing animation
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.5)
        title.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }

    private func setupNinjaDecoration() {
        let ninjaSprite = SKSpriteNode(imageNamed: "ninja_south")
        if ninjaSprite.texture != nil {
            ninjaSprite.setScale(2.0)
        } else {
            // Fallback: use a simple emoji label
            let emoji = SKLabelNode(text: "🥷")
            emoji.fontSize = 80
            emoji.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
            emoji.zPosition = 10
            addChild(emoji)
            return
        }
        ninjaSprite.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        ninjaSprite.zPosition = 10
        addChild(ninjaSprite)

        // Gentle bob animation
        let moveUp = SKAction.moveBy(x: 0, y: 8, duration: 1.2)
        let moveDown = SKAction.moveBy(x: 0, y: -8, duration: 1.2)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        ninjaSprite.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveDown])))

        // Dumpling shop sprite (or fallback)
        let shopSprite = SKSpriteNode(imageNamed: "dumpling_shop")
        if shopSprite.texture != nil && shopSprite.texture!.size() != .zero {
            shopSprite.setScale(1.5)
            shopSprite.position = CGPoint(x: size.width / 2 - 70, y: size.height * 0.54)
            shopSprite.zPosition = 8
            addChild(shopSprite)
        } else {
            // Fallback: small dumpling emoji
            let dumplingLabel = SKLabelNode(text: "🥟")
            dumplingLabel.fontSize = 36
            dumplingLabel.position = CGPoint(x: size.width / 2 - 50, y: size.height * 0.54)
            dumplingLabel.zPosition = 8
            addChild(dumplingLabel)
        }

        // Recipe scroll decoration
        let scrollLabel = SKLabelNode(text: "📜")
        scrollLabel.fontSize = 28
        scrollLabel.position = CGPoint(x: size.width / 2 + 50, y: size.height * 0.55)
        scrollLabel.zPosition = 8
        addChild(scrollLabel)

        // Gentle float on scroll
        let scrollUp = SKAction.moveBy(x: 0, y: 5, duration: 1.5)
        let scrollDown = SKAction.moveBy(x: 0, y: -5, duration: 1.5)
        scrollUp.timingMode = .easeInEaseOut
        scrollDown.timingMode = .easeInEaseOut
        scrollLabel.run(SKAction.repeatForever(SKAction.sequence([scrollUp, scrollDown])))
    }

    private func setupButtons() {
        let buttonWidth: CGFloat = 220
        let buttonHeight: CGFloat = 56
        let cornerRadius: CGFloat = 14
        let centerX = size.width / 2
        let startY = size.height * 0.42

        // PLAY button
        playButton = createButton(
            text: "PLAY",
            color: PastelPalette.sageGreen,
            position: CGPoint(x: centerX, y: startY),
            width: buttonWidth,
            height: buttonHeight,
            cornerRadius: cornerRadius
        )
        addChild(playButton)

        // LEVEL SELECT button
        levelSelectButton = createButton(
            text: "LEVEL SELECT",
            color: PastelPalette.warmBrown,
            position: CGPoint(x: centerX, y: startY - 80),
            width: buttonWidth,
            height: buttonHeight,
            cornerRadius: cornerRadius
        )
        addChild(levelSelectButton)

        // SETTINGS button
        settingsButton = createButton(
            text: "SETTINGS",
            color: PastelPalette.lavender,
            position: CGPoint(x: centerX, y: startY - 160),
            width: buttonWidth,
            height: buttonHeight,
            cornerRadius: cornerRadius
        )
        addChild(settingsButton)
    }

    private func createButton(text: String, color: SKColor, position: CGPoint,
                               width: CGFloat, height: CGFloat, cornerRadius: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: cornerRadius)
        button.fillColor = color
        button.strokeColor = SKColor.white.withAlphaComponent(0.3)
        button.lineWidth = 2
        button.position = position
        button.zPosition = 10

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 11
        button.addChild(label)

        return button
    }

    private func setupFloatingPetals() {
        let spawnPetal = SKAction.run { [weak self] in
            self?.spawnPetal()
        }
        let wait = SKAction.wait(forDuration: 0.8, withRange: 0.6)
        run(SKAction.repeatForever(SKAction.sequence([spawnPetal, wait])))
    }

    private func spawnPetal() {
        let petal = SKShapeNode(ellipseOf: CGSize(width: 8, height: 5))
        petal.fillColor = PastelPalette.dustyRose.withAlphaComponent(0.6)
        petal.strokeColor = .clear
        petal.zPosition = 5

        let startX = CGFloat.random(in: 0...size.width)
        petal.position = CGPoint(x: startX, y: size.height + 20)

        addChild(petal)

        let fallDuration = TimeInterval.random(in: 4.0...7.0)
        let drift = CGFloat.random(in: -60...60)
        let endY: CGFloat = -20

        let fall = SKAction.moveTo(y: endY, duration: fallDuration)
        let sway = SKAction.moveBy(x: drift, y: 0, duration: fallDuration)
        let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -3...3), duration: fallDuration)
        let fadeOut = SKAction.fadeOut(withDuration: fallDuration * 0.3)
        let delayedFade = SKAction.sequence([SKAction.wait(forDuration: fallDuration * 0.7), fadeOut])

        let group = SKAction.group([fall, sway, rotate, delayedFade])
        let remove = SKAction.removeFromParent()

        petal.run(SKAction.sequence([group, remove]))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if playButton.contains(location) {
            AudioManager.shared.playButtonTap(on: self)
            transitionToGame(levelNumber: 1)
        } else if levelSelectButton.contains(location) {
            AudioManager.shared.playButtonTap(on: self)
            transitionToLevelSelect()
        } else if settingsButton.contains(location) {
            AudioManager.shared.playButtonTap(on: self)
            transitionToSettings()
        }
    }

    // MARK: - Transitions

    private func transitionToGame(levelNumber: Int) {
        let gameScene = GameScene()
        gameScene.size = self.size
        gameScene.scaleMode = .aspectFill
        gameScene.userData = NSMutableDictionary()
        gameScene.userData?["startLevel"] = levelNumber

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    private func transitionToLevelSelect() {
        let scene = LevelSelectScene()
        scene.size = self.size
        scene.scaleMode = .aspectFill

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }

    private func transitionToSettings() {
        let scene = SettingsScene()
        scene.size = self.size
        scene.scaleMode = .aspectFill

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
}
