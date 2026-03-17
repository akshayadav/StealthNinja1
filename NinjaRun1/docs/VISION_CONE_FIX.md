# 🎯 Vision Cone Alignment Fixed!

## The Problem

The **red debug line didn't match the visual cone** because:

1. **Vision cone was drawn pointing RIGHT** (0 radians)
2. **NPC sprite rotates** to `angle - π/2` when moving
3. **Detection algorithm** adds back `π/2` to get the actual facing direction
4. **Result:** Visual cone and detection ray were misaligned by 90 degrees!

---

## The Solution

### ✅ Changed Vision Cone to Point UP Initially

The vision cone now points **UP** (π/2 radians) instead of RIGHT (0 radians).

**Why this works:**
```
NPC moves to target at angle θ
↓
NPC rotates to: θ - π/2
↓
Vision cone (drawn at π/2) + rotation (θ - π/2) = θ
↓
Detection checks: zRotation + π/2 = (θ - π/2) + π/2 = θ
↓
✅ Everything points at angle θ!
```

---

## What Was Changed

### File: `StealthNPCCharacter.swift`

**Before:**
```swift
private func setupVisionCone() {
    let halfAngle = config.visionAngle / 2
    path.addArc(
        center: .zero,
        radius: config.visionRange,
        startAngle: -halfAngle,      // Points RIGHT (0°)
        endAngle: halfAngle,
        clockwise: false
    )
}
```

**After:**
```swift
private func setupVisionCone() {
    let halfAngle = config.visionAngle / 2
    let baseAngle = .pi / 2  // Point UP initially
    
    path.addArc(
        center: .zero,
        radius: config.visionRange,
        startAngle: baseAngle - halfAngle,  // Points UP (90°)
        endAngle: baseAngle + halfAngle,
        clockwise: false
    )
}
```

---

## How It Works Now

### Coordinate System Alignment:

1. **Vision Cone Base Direction:** π/2 (pointing UP)
2. **NPC Rotation:** `angle - π/2` (where angle is direction to target)
3. **Effective Cone Direction:** π/2 + (angle - π/2) = angle ✅
4. **Detection Calculation:** zRotation + π/2 = angle ✅
5. **Debug Line:** Points from NPC to ninja at angle ✅

**Everything now points in the same direction!**

---

## Testing the Fix

### Build and Run:
```
⌘R - Run the game
```

### What You Should See:

✅ **Vision cone (colored triangle) matches the red line direction**
- When NPC faces right → cone points right, red line goes right
- When NPC faces up → cone points up, red line goes up
- When NPC faces left → cone points left, red line goes left
- When NPC faces down → cone points down, red line goes down

✅ **Red line only appears when ninja is INSIDE the cone**
- If ninja is outside cone → green line
- If ninja is inside cone → red line

✅ **Detection happens only when red line is visible**
- Red line = detection active
- Detection meter fills
- NPC flashes

---

## Visual Verification Steps

### Test 1: NPC Facing Right
1. Watch an NPC patrol horizontally to the right
2. **Vision cone should point right** →
3. **Red line (if detecting) should point right** →
4. ✅ They should overlap perfectly

### Test 2: NPC Facing Up  
1. Watch an NPC patrol vertically upward
2. **Vision cone should point up** ↑
3. **Red line (if detecting) should point up** ↑
4. ✅ They should overlap perfectly

### Test 3: NPC Facing Diagonal
1. Watch an NPC patrol diagonally
2. **Vision cone should point diagonally** ↗
3. **Red line (if detecting) should point diagonally** ↗
4. ✅ They should overlap perfectly

### Test 4: Detection Only Inside Cone
1. Stand ninja outside the cone but close to NPC
2. **Should see green line** (not detected)
3. Move ninja into the cone
4. **Line turns red** (detected!)
5. ✅ Detection matches visual

---

## Debug Mode Features

With `showDebugDetection = true` in GameScene.swift:

| Visual | Meaning |
|--------|---------|
| 🟢 **Green line** | NPC cannot see ninja (outside cone or out of range) |
| 🔴 **Red line** | NPC CAN see ninja (inside cone and in range) |
| **Flashing NPC** | This NPC is actively detecting you |
| **Colored cone** | Visual representation of vision area |
| **Lines + cones aligned** | Detection working correctly! |

---

## Math Explanation

### Why We Need the π/2 Offset:

**SpriteKit Coordinate System:**
- 0° points RIGHT →
- π/2 (90°) points UP ↑
- π (180°) points LEFT ←
- 3π/2 (270°) points DOWN ↓

**Sprite Orientation:**
- NPCs are drawn facing UP by default
- To face RIGHT, we rotate by -π/2
- To face direction θ, we rotate by θ - π/2

**Vision Cone:**
- Must be drawn in sprite's local coordinates
- Sprite faces UP, so cone must point UP (π/2)
- When sprite rotates, cone rotates with it

**Detection Algorithm:**
- Calculates in world coordinates
- Converts by adding back the π/2 offset
- Result: `zRotation + π/2 = (θ - π/2) + π/2 = θ`

---

## Summary

### Fixed:
✅ Vision cone now points UP (π/2) initially  
✅ Aligns with sprite's default facing direction  
✅ Rotates correctly with NPC  
✅ Matches detection algorithm  
✅ Red debug line coincides with cone  

### Result:
🎯 **Visual cone = Detection cone = Debug line**  
🎮 **What you see is what you get!**  
✨ **Fair, readable stealth gameplay**  

---

## To Disable Debug Mode

Once you're satisfied the detection works correctly:

In `GameScene.swift`, change:
```swift
private let showDebugDetection: Bool = false  // was: true
```

This removes the debug lines for a cleaner visual experience.

---

**Now run the game! The cone and detection line should be perfectly aligned!** 🎯🥷
