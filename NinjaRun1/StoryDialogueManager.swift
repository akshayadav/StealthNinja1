//
//  StoryDialogueManager.swift
//  NinjaRun1
//
//  Dialogue overlay system with typewriter text and portrait.
//

import SpriteKit

class StoryDialogueManager {

    private weak var parentNode: SKNode?  // typically cameraNode
    private var dialogueOverlay: SKNode?
    private var lines: [StoryLine] = []
    private var currentLineIndex: Int = 0
    private var isTyping: Bool = false
    private var fullText: String = ""
    private var onComplete: (() -> Void)?

    // UI references
    private var textLabel: SKLabelNode?
    private var nameLabel: SKLabelNode?
    private var portraitSprite: SKSpriteNode?
    private var tapHint: SKLabelNode?

    private let boxWidth: CGFloat = 320
    private let boxHeight: CGFloat = 100
    private let fontSize: CGFloat = 14
    private let typewriterSpeed: TimeInterval = 0.03

    init(parentNode: SKNode) {
        self.parentNode = parentNode
    }

    /// Show a sequence of dialogue lines, then call completion
    func showDialogue(lines: [StoryLine], completion: @escaping () -> Void) {
        guard !lines.isEmpty, let parent = parentNode else {
            completion()
            return
        }

        self.lines = lines
        self.currentLineIndex = 0
        self.onComplete = completion

        // Create overlay
        let overlay = SKNode()
        overlay.name = "dialogueOverlay"
        overlay.zPosition = 400

        // Semi-transparent backdrop (bottom area)
        let bg = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 12)
        bg.fillColor = SKColor(red: 0.12, green: 0.10, blue: 0.08, alpha: 0.92)
        bg.strokeColor = PastelPalette.softGold.withAlphaComponent(0.6)
        bg.lineWidth = 1.5
        bg.position = CGPoint(x: 0, y: -180)
        overlay.addChild(bg)

        // Portrait (left side of box)
        let portrait = SKSpriteNode(color: .clear, size: CGSize(width: 48, height: 48))
        portrait.position = CGPoint(x: -boxWidth / 2 + 36, y: 10)
        portrait.zPosition = 1
        bg.addChild(portrait)
        portraitSprite = portrait

        // Name label
        let name = SKLabelNode(fontNamed: "AvenirNext-Bold")
        name.fontSize = 12
        name.fontColor = PastelPalette.softGold
        name.horizontalAlignmentMode = .left
        name.verticalAlignmentMode = .top
        name.position = CGPoint(x: -boxWidth / 2 + 68, y: 35)
        name.zPosition = 1
        bg.addChild(name)
        nameLabel = name

        // Text label (multi-line via preferredMaxLayoutWidth)
        let text = SKLabelNode(fontNamed: "AvenirNext-Medium")
        text.fontSize = fontSize
        text.fontColor = .white
        text.horizontalAlignmentMode = .left
        text.verticalAlignmentMode = .top
        text.numberOfLines = 0
        text.preferredMaxLayoutWidth = boxWidth - 80
        text.position = CGPoint(x: -boxWidth / 2 + 68, y: 16)
        text.zPosition = 1
        bg.addChild(text)
        textLabel = text

        // Tap hint
        let hint = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hint.text = "tap to continue"
        hint.fontSize = 10
        hint.fontColor = SKColor.white.withAlphaComponent(0.4)
        hint.horizontalAlignmentMode = .right
        hint.position = CGPoint(x: boxWidth / 2 - 12, y: -boxHeight / 2 + 8)
        hint.zPosition = 1
        bg.addChild(hint)
        tapHint = hint

        // Fade hint in/out
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.8),
            SKAction.fadeAlpha(to: 0.5, duration: 0.8),
        ])
        hint.run(SKAction.repeatForever(pulse))

        overlay.alpha = 0
        parent.addChild(overlay)
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
        dialogueOverlay = overlay

        showLine(index: 0)
    }

    /// Call this from touchesBegan to advance dialogue
    func handleTap() -> Bool {
        guard dialogueOverlay != nil else { return false }

        if isTyping {
            // Skip typewriter — show full text immediately
            textLabel?.removeAction(forKey: "typewriter")
            textLabel?.text = fullText
            isTyping = false
            return true
        }

        // Advance to next line
        currentLineIndex += 1
        if currentLineIndex < lines.count {
            showLine(index: currentLineIndex)
        } else {
            dismiss()
        }
        return true
    }

    var isShowing: Bool {
        return dialogueOverlay != nil
    }

    // MARK: - Private

    private func showLine(index: Int) {
        guard index < lines.count else { return }
        let line = lines[index]

        // Update portrait
        let tex = SKTexture(imageNamed: line.portrait)
        if tex.size() != .zero {
            portraitSprite?.texture = tex
            portraitSprite?.size = CGSize(width: 48, height: 48)
        } else {
            // Fallback: show colored rectangle with first letter
            portraitSprite?.texture = nil
            portraitSprite?.color = line.portrait.contains("tanuki")
                ? PastelPalette.warmBrown : PastelPalette.lavender
        }

        nameLabel?.text = line.name
        fullText = line.text

        // Typewriter effect
        textLabel?.text = ""
        isTyping = true

        var charIndex = 0
        let characters = Array(fullText)
        let typeAction = SKAction.repeat(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    guard charIndex < characters.count else { return }
                    self?.textLabel?.text = String(characters[0...charIndex])
                    charIndex += 1
                },
                SKAction.wait(forDuration: typewriterSpeed),
            ]),
            count: characters.count
        )
        let doneAction = SKAction.run { [weak self] in
            self?.isTyping = false
        }
        textLabel?.run(SKAction.sequence([typeAction, doneAction]), withKey: "typewriter")
    }

    private func dismiss() {
        dialogueOverlay?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent(),
        ]))
        dialogueOverlay = nil
        lines = []
        onComplete?()
        onComplete = nil
    }
}
