# 🥷 Stealth Ninja - iOS Game

A portrait-mode stealth game built with SpriteKit for iOS. Guide your ninja from Point A to Point B while avoiding detection by guards and civilians!

## ✅ Implementation Status

**FULLY PLAYABLE!** The game is complete and ready to run. All core mechanics are implemented:

- ✅ One-button tap-and-hold controls
- ✅ Ninja movement between hiding points
- ✅ Vision-based detection system
- ✅ NPC patrol patterns
- ✅ 3 complete levels with increasing difficulty
- ✅ Progress tracking and UI
- ✅ Detection indicator
- ✅ Level completion and game over states
- ✅ Portrait mode orientation
- ✅ Horizontal scrolling with camera follow

## 🎮 How to Play

1. **Tap and hold** the blue MOVE button to make the ninja move
2. **Release** to stop and hide
3. Hide in the **gray circles** (hiding spots) to avoid detection
4. Watch the **colored cones** - those are NPC vision ranges:
   - 🔴 **Red NPCs** = Guards (hostile)
   - 🔵 **Blue NPCs** = Civilians (will raise alarm)
5. The **green/yellow/red indicator** shows your detection level
6. Reach the **cyan END marker** to complete the level!

## 🏗️ Project Structure

```
NinjaRun1/
├── GameScene.swift          # Main game logic and rendering
├── GameViewController.swift # View controller (portrait mode)
├── GameState.swift          # Game state enums
├── NinjaNode.swift          # Player character class
├── NPCNode.swift            # Enemy/civilian class
├── HidingPointNode.swift    # Safe zone class
├── LevelData.swift          # Level configurations (3 levels)
├── AppDelegate.swift        # App lifecycle
├── PRD.md                   # Product Requirements Document
└── ASSETS_GUIDE.md          # Guide for adding sprites
```

## 🚀 Getting Started

### Prerequisites
- Xcode 14+ (or latest version)
- iOS 15+ deployment target
- Swift 5.7+

### Running the Game

1. Open the project in Xcode
2. Select an iOS Simulator or device (iPhone recommended)
3. Press `Cmd + R` to build and run
4. The game will launch in **portrait mode**

### First Launch

The game starts at **Level 1** and uses colored shapes as placeholders:
- **Black rectangle** = Your ninja
- **Gray circles** = Hiding spots
- **Red/Blue rectangles** = NPCs with vision cones
- **Green circle** = Start position
- **Cyan circle** = End position

## 🎨 Adding Custom Sprites (Optional)

The game is **fully playable without custom sprites**, but you can add them for polish!

See **ASSETS_GUIDE.md** for:
- Sprite requirements
- Where to download free assets
- How to add them to the project

### Quick Sprite Setup

1. Open `Assets.xcassets`
2. Create new image sets named:
   - `ninja`
   - `hidingspot`
   - `guard`
   - `civilian`
3. Drag your PNG images into the slots
4. Run the game - sprites will load automatically!

## 🎯 Game Features

### Core Mechanics
- **Tap-and-hold movement** - Press to move, release to hide
- **Hiding zones** - Safe spots where ninja becomes semi-transparent
- **Vision detection** - NPCs have cone-shaped vision ranges
- **Patrol patterns** - NPCs move along predefined paths
- **Detection meter** - Gradually fills when exposed, triggers game over at 100%

### UI Elements
- **Move Button** (bottom center) - Main control
- **Progress Bar** (top) - Shows journey from A to B
- **Detection Indicator** (top right) - Shows danger level (green/yellow/red)
- **Level Label** (top center) - Current level number
- **Restart Button** (top left) - Quick restart with ↻ symbol

### Current Levels

#### Level 1 - Tutorial
- Simple straight path
- 5 hiding points
- 2 neutral NPCs with slow patrols
- Wide vision angles
- **Easy difficulty**

#### Level 2 - Village
- Varied height hiding spots
- 7 hiding points (one light-dependent)
- 3 NPCs (mix of hostile and neutral)
- More complex patrol patterns
- **Medium difficulty**

#### Level 3 - Fortress
- Tight spacing between hiding points
- 9 hiding points
- 5 NPCs (3 hostile guards)
- Fast patrols with overlapping vision
- **Hard difficulty**

## 🔧 Customization

### Adding More Levels

Edit `LevelData.swift` and add a new method:

```swift
private func createLevel4() -> LevelData {
    let levelWidth: CGFloat = 3500
    
    let hidingPoints = [
        // Define your hiding points
    ]
    
    let npcs = [
        // Define your NPCs
    ]
    
    return LevelData(
        levelNumber: 4,
        startPosition: CGPoint(x: 100, y: 150),
        endPosition: CGPoint(x: 3300, y: 150),
        hidingPoints: hidingPoints,
        npcs: npcs,
        levelWidth: levelWidth
    )
}
```

Then update `getLevelData()` to include your new level.

### Adjusting Difficulty

**Make it easier:**
- Increase `visionAngle` values (wider cones = easier to see)
- Decrease `visionRange` values (shorter sight distance)
- Add more hiding points
- Slow down patrols (increase distance between patrol points)

**Make it harder:**
- Decrease hiding point sizes
- Increase NPC vision ranges
- Add more hostile NPCs
- Make patrol paths overlap hiding spots
- Set more `isLightDependent: true` hiding points

### Changing Movement Speed

In `GameScene.swift`, look for:
```swift
let duration = TimeInterval(distance / 100.0) // Ninja speed
let duration = TimeInterval(distance / 50.0)  // NPC speed
```

Higher divisor = slower movement, lower = faster.

## 🎵 Adding Sound (Future Enhancement)

The game has placeholders for sound effects. To add audio:

1. Add audio files to your project (`.mp3` or `.wav`)
2. In `GameScene.swift`, find the audio player setup
3. Uncomment and configure the `AVAudioPlayer` code

Suggested sounds:
- Footsteps during movement
- Alert sound when detection increases
- Success chime on level complete
- Failure sound on detection

## 🐛 Troubleshooting

### Game doesn't start
- Make sure `GameViewController` is set as the initial view controller
- Check that the view is cast to `SKView` properly

### NPCs not moving
- Verify patrol points are defined in `LevelData.swift`
- Check console for any errors

### Detection not working
- NPCs vision cones should be visible (semi-transparent colored triangles)
- Make sure ninja is moving outside hiding zones to test

### Camera not following
- Check that `updateCamera()` is being called in `update()`
- Verify level width is set correctly

## 📱 Supported Devices

- **iPhone** (all sizes) - Recommended
- **iPod Touch** (iOS 15+)
- **Portrait orientation only**

*Note: iPad works but is optimized for iPhone/portrait display*

## 🔮 Future Enhancements (Post-MVP)

Ideas from the PRD:
- [ ] Sound effects and background music
- [ ] Time-based scoring system
- [ ] Game Center leaderboards
- [ ] Character unlock/customization
- [ ] Power-ups (smoke bombs, speed boost)
- [ ] Dynamic lighting system
- [ ] More environment types (temple, marketplace, forest)
- [ ] Haptic feedback on detection
- [ ] Tutorial overlay for first launch

## 📄 License

This is a personal project. Feel free to modify and extend!

## 🙏 Credits

Built with:
- **SpriteKit** - Apple's 2D game framework
- **Swift** - Programming language
- Based on the **Stealth Ninja PRD** (see PRD.md)

---

## 🚀 Quick Test Checklist

Before you start customizing, verify everything works:

- [ ] Game launches in portrait mode
- [ ] Blue MOVE button appears at bottom
- [ ] Ninja (black rectangle) starts at green circle
- [ ] NPCs (colored rectangles) patrol with vision cones
- [ ] Press and hold button - ninja moves
- [ ] Release button - ninja stops
- [ ] Hide in gray circles - ninja becomes transparent
- [ ] Get seen by NPC - detection indicator turns red
- [ ] Stay detected too long - "DETECTED!" message appears
- [ ] Reach cyan circle - "LEVEL COMPLETE!" message appears
- [ ] Tap ↻ button - level restarts

**If all items work, you're ready to customize and enhance!**

---

*Have fun building your stealth game! 🥷*
