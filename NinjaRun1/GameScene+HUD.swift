//
//  GameScene+HUD.swift
//  NinjaRun1
//
//  HUD setup and update methods.
//

import SpriteKit

extension GameScene {

    func setupUI() {
        let W = size.width
        let H = size.height
        let topY = H / 2 - 52
        let btnY = -H / 2 + buttonSize / 2 + uiPadding + 10
        let amber = PastelPalette.softGold
        let darkPanel = PastelPalette.darkPanel
        let safeGreen = PastelPalette.safeGreen

        // ── MOVE BUTTON ────────────────────────────────────────────────────
        let shadowRing = SKShapeNode(circleOfRadius: buttonSize / 2 + 4)
        shadowRing.fillColor = SKColor.black.withAlphaComponent(0.4)
        shadowRing.strokeColor = .clear
        shadowRing.position = CGPoint(x: 0, y: btnY - 3)
        shadowRing.zPosition = 99
        cameraNode.addChild(shadowRing)

        moveButton = SKShapeNode(circleOfRadius: buttonSize / 2)
        moveButton.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.85)
        moveButton.strokeColor = amber.withAlphaComponent(0.7)
        moveButton.lineWidth = 2.5
        moveButton.position = CGPoint(x: 0, y: btnY)
        moveButton.zPosition = 100
        moveButton.name = "moveButton"
        cameraNode.addChild(moveButton)

        let innerRing = SKShapeNode(circleOfRadius: buttonSize / 2 - 8)
        innerRing.fillColor = .clear
        innerRing.strokeColor = amber.withAlphaComponent(0.25)
        innerRing.lineWidth = 1.5
        moveButton.addChild(innerRing)

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

        let panelBorder = SKShapeNode(rectOf: CGSize(width: W, height: 1.5))
        panelBorder.fillColor = amber.withAlphaComponent(0.4)
        panelBorder.strokeColor = .clear
        panelBorder.position = CGPoint(x: 0, y: -35)
        topPanel.addChild(panelBorder)

        // ── LEVEL BADGE (top center) ───────────────────────────────────────
        let badgeBg = SKShapeNode(rectOf: CGSize(width: 110, height: 28), cornerRadius: 14)
        badgeBg.fillColor = PastelPalette.warmCream.withAlphaComponent(0.9)
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

        let barTrack = SKShapeNode(rectOf: CGSize(width: barWidth + 6, height: barHeight + 6), cornerRadius: 7)
        barTrack.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.3)
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

        progressNinjaIcon = SKLabelNode(text: "🥷")
        progressNinjaIcon.fontSize = 12
        progressNinjaIcon.verticalAlignmentMode = .center
        progressNinjaIcon.position = CGPoint(x: -barWidth / 2, y: barY + 10)
        progressNinjaIcon.zPosition = 101
        cameraNode.addChild(progressNinjaIcon)

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
        detTrack.fillColor = PastelPalette.warmBrown.withAlphaComponent(0.3)
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
        stealthBadge.fillColor = PastelPalette.sageGreen.withAlphaComponent(0.3)
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
        restartButton.fillColor = PastelPalette.warmCream.withAlphaComponent(0.8)
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

        // ── MENU/PAUSE BUTTON (next to restart) ─────────────────────────
        menuButton = SKShapeNode(circleOfRadius: 16)
        menuButton.fillColor = PastelPalette.warmCream.withAlphaComponent(0.8)
        menuButton.strokeColor = SKColor.white.withAlphaComponent(0.3)
        menuButton.lineWidth = 1.5
        menuButton.position = CGPoint(x: -W / 2 + 68, y: topY - 24)
        menuButton.zPosition = 101
        menuButton.name = "menuButton"
        cameraNode.addChild(menuButton)

        let menuIcon = SKLabelNode(text: "☰")
        menuIcon.fontSize = 16
        menuIcon.fontColor = SKColor.white.withAlphaComponent(0.8)
        menuIcon.verticalAlignmentMode = .center
        menuIcon.horizontalAlignmentMode = .center
        menuIcon.position = CGPoint(x: 0, y: 1)
        menuButton.addChild(menuIcon)

        // ── RECIPE PAGE COUNTER (top area, right of restart/menu) ─────────
        let recipeBg = SKShapeNode(rectOf: CGSize(width: 70, height: 28), cornerRadius: 14)
        recipeBg.fillColor = PastelPalette.warmCream.withAlphaComponent(0.9)
        recipeBg.strokeColor = amber.withAlphaComponent(0.6)
        recipeBg.lineWidth = 1.5
        recipeBg.position = CGPoint(x: -W / 2 + 120, y: topY - 24)
        recipeBg.zPosition = 101
        cameraNode.addChild(recipeBg)

        recipePageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        recipePageLabel?.text = "📜 \(min(max(currentLevelNumber - 1, 0), 7))/7"
        recipePageLabel?.fontSize = 12
        recipePageLabel?.fontColor = amber
        recipePageLabel?.verticalAlignmentMode = .center
        recipePageLabel?.position = .zero
        recipeBg.addChild(recipePageLabel!)

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

    func updateDetectionIndicator() {
        let detW: CGFloat = 72
        let detH: CGFloat = 8
        let fillW = max(CGFloat(detectionLevel) * detW, 1)

        let color: SKColor
        let labelText: String
        if detectionLevel < 0.3 {
            color = PastelPalette.safeGreen
            labelText = "SAFE"
        } else if detectionLevel < 0.65 {
            color = PastelPalette.softPeach
            labelText = "ALERT"
        } else {
            color = PastelPalette.dustyRose
            labelText = "DANGER"
        }

        detectionBarFill.path = CGPath(
            roundedRect: CGRect(x: 0, y: -detH / 2, width: fillW, height: detH),
            cornerWidth: 4, cornerHeight: 4, transform: nil
        )
        detectionBarFill.fillColor = color
        detectionLabel.fontColor = color
        detectionLabel.text = labelText

        let isHidden = ninja.isInHidingZone && ninja.currentState != .moving
        stealthBadge.strokeColor = isHidden
            ? PastelPalette.safeGreen.withAlphaComponent(0.8)
            : PastelPalette.dustyRose.withAlphaComponent(0.6)
        stealthLabel.text = isHidden ? "🌙 HIDE" : "👁 SEEN"
        stealthLabel.fontColor = isHidden
            ? PastelPalette.safeGreen
            : PastelPalette.softPeach

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

    func updateProgress() {
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
        let r = 0.2 + 0.8 * progress
        let g = 0.9 - 0.4 * progress
        progressBarFill.fillColor = SKColor(red: r, green: g, blue: 0.3, alpha: 1)

        progressNinjaIcon.position = CGPoint(
            x: -barWidth / 2 + barWidth * progress,
            y: progressNinjaIcon.position.y
        )
    }
}
