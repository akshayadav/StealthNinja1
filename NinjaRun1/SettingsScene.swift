//
//  SettingsScene.swift
//  NinjaRun1
//
//  Created by Akshay Yadav on 3/16/26.
//

import SpriteKit

class SettingsScene: SKScene {

    private var backButton: SKShapeNode!
    private var soundToggle: SKShapeNode!
    private var soundLabel: SKLabelNode!
    private var musicToggle: SKShapeNode!
    private var musicLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        backgroundColor = PastelPalette.skyBlue
        setupBackButton()
        setupTitle()
        setupToggles()
        setupInfoText()
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
        title.text = "SETTINGS"
        title.fontSize = 36
        title.fontColor = PastelPalette.softGold
        title.position = CGPoint(x: size.width / 2, y: size.height - 65)
        title.zPosition = 20
        addChild(title)
    }

    private func setupToggles() {
        let centerX = size.width / 2
        let toggleY = size.height * 0.60

        // Sound toggle
        let soundTitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        soundTitleLabel.text = "Sound Effects"
        soundTitleLabel.fontSize = 22
        soundTitleLabel.fontColor = PastelPalette.warmBrown
        soundTitleLabel.position = CGPoint(x: centerX, y: toggleY + 30)
        soundTitleLabel.zPosition = 10
        addChild(soundTitleLabel)

        soundToggle = createToggleButton(
            isOn: AudioManager.shared.isSoundEnabled,
            position: CGPoint(x: centerX, y: toggleY - 10)
        )
        soundToggle.name = "soundToggle"
        addChild(soundToggle)

        soundLabel = soundToggle.childNode(withName: "toggleLabel") as? SKLabelNode

        // Music toggle
        let musicTitleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        musicTitleLabel.text = "Background Music"
        musicTitleLabel.fontSize = 22
        musicTitleLabel.fontColor = PastelPalette.warmBrown
        musicTitleLabel.position = CGPoint(x: centerX, y: toggleY - 70)
        musicTitleLabel.zPosition = 10
        addChild(musicTitleLabel)

        musicToggle = createToggleButton(
            isOn: AudioManager.shared.isMusicEnabled,
            position: CGPoint(x: centerX, y: toggleY - 110)
        )
        musicToggle.name = "musicToggle"
        addChild(musicToggle)

        musicLabel = musicToggle.childNode(withName: "toggleLabel") as? SKLabelNode
    }

    private func createToggleButton(isOn: Bool, position: CGPoint) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 140, height: 44), cornerRadius: 12)
        button.position = position
        button.zPosition = 10
        button.lineWidth = 2
        updateToggleAppearance(button: button, isOn: isOn)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = isOn ? "ON" : "OFF"
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "toggleLabel"
        button.addChild(label)

        return button
    }

    private func updateToggleAppearance(button: SKShapeNode, isOn: Bool) {
        if isOn {
            button.fillColor = PastelPalette.sageGreen
            button.strokeColor = SKColor.white.withAlphaComponent(0.4)
        } else {
            button.fillColor = PastelPalette.dustyRose.withAlphaComponent(0.7)
            button.strokeColor = SKColor.white.withAlphaComponent(0.3)
        }
    }

    private func setupInfoText() {
        let infoLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        infoLabel.text = "Controls: Tap & Hold to Move"
        infoLabel.fontSize = 18
        infoLabel.fontColor = PastelPalette.warmBrown.withAlphaComponent(0.8)
        infoLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        infoLabel.zPosition = 10
        addChild(infoLabel)

        let subLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subLabel.text = "Release to Hide in Safe Zones"
        subLabel.fontSize = 16
        subLabel.fontColor = PastelPalette.warmBrown.withAlphaComponent(0.6)
        subLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.25 - 30)
        subLabel.zPosition = 10
        addChild(subLabel)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if backButton.contains(location) {
            AudioManager.shared.playButtonTap(on: self)
            transitionToMainMenu()
            return
        }

        if soundToggle.contains(location) {
            AudioManager.shared.isSoundEnabled.toggle()
            let isOn = AudioManager.shared.isSoundEnabled
            updateToggleAppearance(button: soundToggle, isOn: isOn)
            soundLabel?.text = isOn ? "ON" : "OFF"
            AudioManager.shared.playButtonTap(on: self)
            return
        }

        if musicToggle.contains(location) {
            AudioManager.shared.isMusicEnabled.toggle()
            let isOn = AudioManager.shared.isMusicEnabled
            updateToggleAppearance(button: musicToggle, isOn: isOn)
            musicLabel?.text = isOn ? "ON" : "OFF"
            AudioManager.shared.playButtonTap(on: self)
            return
        }
    }

    // MARK: - Transitions

    private func transitionToMainMenu() {
        let scene = MainMenuScene()
        scene.size = self.size
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(scene, transition: transition)
    }
}
