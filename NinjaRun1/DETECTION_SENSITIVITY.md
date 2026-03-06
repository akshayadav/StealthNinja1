# 🎯 Configurable Detection Sensitivity System

## Overview

Added a **detection sensitivity system** that allows each NPC to have different reaction times before detecting the ninja. This creates varied difficulty and more strategic gameplay.

---

## Detection Sensitivity Scale (1-10)

### Scale Breakdown:

| Level | Name | Detection Time | Color | Description |
|-------|------|----------------|-------|-------------|
| **1** | Very Lenient | 2.0 sec | 🟢 Green | Takes forever to detect |
| **2** | Lenient | 1.8 sec | 🟢 Green | Slow to react |
| **3** | Forgiving | 1.6 sec | 🟢 Green | Tutorial-friendly |
| **4** | Below Average | 1.4 sec | 🟡 Yellow | Slightly slow |
| **5** | Average | 1.2 sec | 🟡 Yellow | Normal guard |
| **6** | Above Average | 1.0 sec | 🟡 Yellow | Alert guard |
| **7** | Strict | 0.8 sec | 🟠 Orange | Trained guard |
| **8** | Very Strict | 0.6 sec | 🟠 Orange | Elite guard |
| **9** | Extremely Strict | 0.4 sec | 🔴 Red | Master guard |
| **10** | INSTANT | 0.2 sec | 🔴 Red | Final boss! |

### Formula:
```
Detection Time = 2.1 - (sensitivity * 0.2) seconds
```

---

## Visual Indicators

### Number Badge Above NPC:
Each NPC displays their sensitivity level as a number (1-10) above their head with:
- **Black circle background** (70% opacity)
- **Colored border** matching sensitivity level
- **Colored number** matching sensitivity level

### Detection Progress:
- **Badge pulses** when detecting ninja
- **Background changes color** as detection fills:
  - Black → Orange (30%) → Red (70%)
- **Indicator size increases** during detection

---

## How It Works

### Detection Accumulation:
```swift
// When NPC sees ninja:
detectionAccumulator += deltaTime  // Time exposed

// When NPC doesn't see ninja:
detectionAccumulator -= deltaTime * 0.5  // Decays at half speed
```

### Detection Trigger:
```swift
if detectionAccumulator >= detectionThreshold {
    // DETECTED! Game Over!
}
```

### Time Tracking:
- Each NPC tracks their own `detectionAccumulator`
- Independent timers per NPC
- Decays when ninja breaks line of sight
- Resets on level restart

---

## Level Configurations

### Level 1 (Tutorial):
```swift
NPC 1: Sensitivity 3 (1.6 sec) - Lenient civilian
NPC 2: Sensitivity 4 (1.4 sec) - Forgiving civilian
```
**Strategy:** Learn mechanics with forgiving guards

### Level 2 (Medium):
```swift
NPC 1: Sensitivity 5 (1.2 sec) - Normal civilian
NPC 2: Sensitivity 7 (0.8 sec) - Strict guard (hostile!)
NPC 3: Sensitivity 6 (1.0 sec) - Alert civilian
```
**Strategy:** Mix of easy and challenging NPCs

### Level 3 (Hard):
```swift
NPC 1: Sensitivity 9 (0.4 sec) - Elite guard (hostile!)
NPC 2: Sensitivity 6 (1.0 sec) - Alert civilian
NPC 3: Sensitivity 8 (0.6 sec) - Very strict guard (hostile!)
NPC 4: Sensitivity 5 (1.2 sec) - Normal civilian
NPC 5: Sensitivity 10 (0.2 sec) - FINAL BOSS GUARD! (hostile!)
```
**Strategy:** Extremely tight timing, mix of difficulties

---

## Gameplay Strategy

### Against Lenient NPCs (1-3):
✅ Can dash through vision briefly  
✅ Forgiving timing windows  
✅ Good for learning patrol patterns  

### Against Medium NPCs (4-6):
⚠️ Need to time movements  
⚠️ Can't linger in vision  
⚠️ Standard stealth gameplay  

### Against Strict NPCs (7-8):
🚨 Must be quick and precise  
🚨 Very short exposure windows  
🚨 Requires planning  

### Against Elite NPCs (9-10):
💀 Nearly instant detection  
💀 Must avoid vision completely  
💀 Expert-level timing required  

---

## Code Implementation

### LevelData.swift:

**NPCConfig now includes:**
```swift
struct NPCConfig {
    let detectionSensitivity: Int  // 1-10 scale
    
    init(..., detectionSensitivity: Int = 5) {
        // Clamps to 1-10 range
        self.detectionSensitivity = max(1, min(10, detectionSensitivity))
    }
}
```

**Example usage:**
```swift
LevelData.NPCConfig(
    startPosition: CGPoint(x: 350, y: 250),
    patrolPoints: [...],
    visionRange: 220,
    visionAngle: CGFloat.pi / 2.5,
    isHostile: true,
    detectionSensitivity: 9  // Very strict!
)
```

### StealthNPCCharacter.swift:

**New properties:**
```swift
var detectionAccumulator: CGFloat = 0.0  // Current exposure time
var detectionThreshold: CGFloat = 0.0    // Time needed to trigger
var sensitivityIndicator: SKLabelNode?   // Visual badge
```

**New methods:**
```swift
func updateDetection(deltaTime: TimeInterval, seeingNinja: Bool) -> Bool
func resetDetection()
func setupSensitivityIndicator()
func getSensitivityColor() -> SKColor
```

### GameScene.swift:

**Updated:**
```swift
override func update(_ currentTime: TimeInterval) {
    let deltaTime = currentTime - lastUpdateTime
    updateDetection(deltaTime: deltaTime)  // Now time-based!
}

private func updateDetection(deltaTime: TimeInterval) {
    for npc in npcs {
        let detectionTriggered = npc.updateDetection(
            deltaTime: deltaTime, 
            seeingNinja: canSeeNinja && shouldDetect
        )
        
        if detectionTriggered {
            gameOver()  // This NPC caught you!
        }
    }
}
```

---

## Visual Feedback

### Player Can See:

1. **Number above NPC** (1-10)
   - Higher number = stricter
   - Color-coded for quick reference

2. **Badge pulsing**
   - Indicates active detection
   - Gets more intense as detection fills

3. **Badge color changes**
   - Black → Orange → Red
   - Shows detection progress

4. **Global detection indicator** (top right)
   - Shows highest NPC detection level
   - Green → Yellow → Red

5. **Debug lines** (if enabled)
   - Red line = seeing ninja
   - Green line = not seeing ninja

---

## Testing the System

### Test 1: Lenient NPC (Sensitivity 3)
1. Walk into NPC's vision
2. Should take **~1.6 seconds** to detect
3. Badge should pulse and turn orange → red slowly
4. Plenty of time to escape

### Test 2: Strict NPC (Sensitivity 7)
1. Walk into NPC's vision
2. Should take **~0.8 seconds** to detect
3. Badge pulses faster
4. Must react quickly!

### Test 3: Elite NPC (Sensitivity 10)
1. Walk into NPC's vision
2. Detects in **~0.2 seconds** (almost instant!)
3. Badge flashes to red immediately
4. Must avoid completely!

### Test 4: Decay System
1. Get seen by any NPC
2. Break line of sight (hide/move away)
3. Watch badge return to normal
4. Detection accumulator decays at 50% speed

---

## Customization

### Change Detection Times:

In `StealthNPCCharacter.swift`:
```swift
// Current formula:
detectionThreshold = 2.1 - (CGFloat(sensitivity) * 0.2)

// Make all NPCs slower:
detectionThreshold = 3.0 - (CGFloat(sensitivity) * 0.2)

// Make all NPCs faster:
detectionThreshold = 1.5 - (CGFloat(sensitivity) * 0.15)
```

### Change Decay Rate:

In `StealthNPCCharacter.swift`, `updateDetection()`:
```swift
// Current: 50% decay rate
detectionAccumulator -= CGFloat(deltaTime) * 0.5

// Faster decay (easier):
detectionAccumulator -= CGFloat(deltaTime) * 1.0

// Slower decay (harder):
detectionAccumulator -= CGFloat(deltaTime) * 0.25
```

### Change Indicator Colors:

In `StealthNPCCharacter.swift`, `getSensitivityColor()`:
```swift
switch config.detectionSensitivity {
case 1...3:
    return .green   // Change to .blue
case 4...6:
    return .yellow  // Change to .cyan
case 7...8:
    return .orange  // Change to .magenta
case 9...10:
    return .red     // Keep red for danger
}
```

---

## Balancing Tips

### For Easier Gameplay:
- Lower all sensitivity values by 2-3
- Increase decay rate to 1.0x
- Add more lenient NPCs (1-3)

### For Harder Gameplay:
- Increase all sensitivity values by 2-3
- Decrease decay rate to 0.25x
- Add more strict NPCs (7-10)

### For Strategic Variety:
- Mix sensitivity levels in same area
- Place lenient NPCs near chokepoints
- Place strict NPCs guarding key paths
- Create "safe" and "danger" zones

---

## Benefits

✅ **More interesting gameplay** - Not all guards are the same  
✅ **Better difficulty curve** - Gradual increase across levels  
✅ **Strategic depth** - Players can identify and plan around NPCs  
✅ **Clear feedback** - Visual indicators show what to expect  
✅ **Balanced challenge** - No instant-fail mechanics (except level 10!)  
✅ **Replayability** - Learning NPC behaviors adds mastery  

---

## Summary

### What Was Added:

- ✅ **1-10 sensitivity scale** for NPCs
- ✅ **Time-based detection** with accumulator system
- ✅ **Visual indicators** showing sensitivity level
- ✅ **Color-coded badges** for quick identification
- ✅ **Progressive difficulty** across 3 levels
- ✅ **Detection decay** when breaking line of sight
- ✅ **Per-NPC tracking** for independent timers

### Result:

🎮 **Varied, strategic stealth gameplay!**  
👀 **Clear visual communication!**  
⏱️ **Fair, time-based detection!**  
🎯 **Perfect difficulty progression!**  

---

**Now each guard has personality through their reaction time!** 🥷🎯✨
