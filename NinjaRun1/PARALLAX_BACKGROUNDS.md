# 🎨 Parallax Background System

## Overview

Added a **three-layer parallax scrolling background** to create depth and a sense of movement in the game. The backgrounds scroll at different speeds to create a 3D effect.

---

## The Three Layers

### Layer 1: Far Background (Mountains)
- **Z-Position:** -30 (farthest back)
- **Parallax Speed:** 0.3x (slowest)
- **Color:** Dark blue-gray `(0.08, 0.08, 0.12)`
- **Size:** 2.5x level width
- **Content:** Mountain silhouettes
- **Effect:** Creates distant horizon

### Layer 2: Middle Background (Trees)
- **Z-Position:** -20 (middle distance)
- **Parallax Speed:** 0.6x (medium)
- **Color:** Slightly lighter gray `(0.1, 0.12, 0.15)`
- **Size:** 1.8x level width
- **Content:** Tree silhouettes
- **Effect:** Mid-distance forest

### Layer 3: Foreground (Ground)
- **Z-Position:** 0 (front)
- **Parallax Speed:** 1.0x (full speed)
- **Color:** Green-gray `(0.15, 0.2, 0.15)`
- **Size:** Actual level width
- **Content:** Ground with details (rocks, grass)
- **Effect:** Main gameplay surface

---

## How Parallax Works

### Speed Ratios:
```
Camera moves:    →→→→→→ 100%
Far Background:  →→→    30% (slowest)
Mid Background:  →→→→   60% (medium)
Foreground:      →→→→→→ 100% (fastest)
```

### Visual Effect:
```
When ninja moves right →

Far mountains:     →  (slow)
Middle trees:      →→ (medium)
Ground:            →→→ (fast)

Result: Depth perception! 🎬
```

---

## Layer Details

### Mountains (Far Background)

**Features:**
- 5 randomly placed mountains
- Random heights (30-60% of layer height)
- Random widths (80-150 pixels)
- Very dark color for distance
- Triangle shapes

**Code:**
```swift
addMountainSilhouettes(to: farBG, width: levelWidth * 2.5, height: screenHeight)
```

### Trees (Middle Background)

**Features:**
- 15 randomly placed trees
- Random heights (40-80 pixels)
- Tree trunks + triangular foliage
- Slightly lighter than mountains
- Random spacing for variety

**Code:**
```swift
addTreeSilhouettes(to: midBG, width: levelWidth * 1.8, height: screenHeight * 0.7)
```

### Ground Details (Foreground)

**Features:**
- 30 random details across level
- Three types:
  - **Rocks:** Small gray circles (8-15px)
  - **Grass tufts:** Green vertical lines (10-20px tall)
  - **Small details:** Tiny gray dots (3px)
- Adds texture to ground

**Code:**
```swift
addGroundDetails(width: levelWidth, yPosition: groundHeight / 2)
```

---

## Using Custom Background Images

### Option 1: Add Image Assets

If you want to use custom images instead of generated shapes:

1. **Add images to Assets.xcassets:**
   - `farBackground.png` (2048x1024 or larger)
   - `midBackground.png` (2048x1024 or larger)
   - `foreground.png` (2048x512 or larger)

2. **The code automatically uses them:**
```swift
let texture = SKTexture(imageNamed: name)
if texture.size() == .zero {
    // Falls back to colored rectangle
} else {
    // Uses your image!
}
```

### Option 2: Keep Generated Graphics

The system works perfectly with the procedurally generated graphics:
- Mountains, trees, and ground details
- No assets required
- Looks clean and minimalist
- Matches the PRD's "silhouette or ink-brush visual style"

---

## Customization

### Change Parallax Speeds

In `updateParallaxLayers()`:

```swift
// Current values:
let farOffset = cameraX * 0.3  // 30% speed
let midOffset = cameraX * 0.6  // 60% speed

// Make more dramatic:
let farOffset = cameraX * 0.2  // 20% speed (slower)
let midOffset = cameraX * 0.5  // 50% speed

// Make more subtle:
let farOffset = cameraX * 0.5  // 50% speed (faster)
let midOffset = cameraX * 0.8  // 80% speed
```

### Change Layer Colors

In `createBackground()`:

```swift
// Far background (currently dark blue-gray)
color: SKColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)

// Try: Purple night sky
color: SKColor(red: 0.1, green: 0.05, blue: 0.15, alpha: 1.0)

// Try: Orange sunset
color: SKColor(red: 0.3, green: 0.15, blue: 0.1, alpha: 1.0)
```

### Add More Detail

Add more elements to layers:

```swift
// In addMountainSilhouettes():
let mountainCount = 10  // More mountains (was 5)

// In addTreeSilhouettes():
let treeCount = 30  // More trees (was 15)

// In addGroundDetails():
let detailCount = 50  // More ground details (was 30)
```

---

## Performance Notes

### Optimizations Built-In:

✅ **Static layers** - Mountains and trees don't animate individually  
✅ **Simple shapes** - Uses SKShapeNode for efficiency  
✅ **No textures required** - Works without loading images  
✅ **Minimal updates** - Only updates position, no rotation/scaling  
✅ **Proper z-ordering** - Prevents overdraw issues  

### Performance Impact:

- **Negligible** on modern iOS devices
- Adds ~50 SKNodes total
- All static shapes (no animations)
- Updates 2 positions per frame (far + mid layers)

---

## Visual Comparison

### Before:
```
━━━━━━━━━━━━━━━━━━━━━━━━
  [Flat gray ground]
  [Grid lines]
  [No depth]
━━━━━━━━━━━━━━━━━━━━━━━━
```

### After:
```
🏔️🏔️ [Mountains - far]
  🌲🌲🌲 [Trees - mid]
    🪨 ━━━━━━━━━━━━ [Ground + details]
      [Depth! Movement! Life!]
```

---

## Z-Position Hierarchy

```
Layer                    Z-Position    Content
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Far Background           -30          Mountains
Middle Background        -20          Trees
Foreground (Ground)       0           Main surface
Grid Lines                0           Depth markers
Ground Details            1-2         Rocks, grass
Hiding Spots              1           Gray circles
NPCs                      5           Enemies
Ninja                    10           Player
Debug Lines             100           Red/green rays
UI Elements             100+          HUD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Testing the Effect

### Visual Test:

1. **Run the game** (⌘R)
2. **Hold MOVE button**
3. **Watch the backgrounds:**
   - Far mountains scroll slowly
   - Trees scroll faster
   - Ground scrolls fastest
4. **Notice the depth!** 🎬

### Movement Test:

```
Move ninja slowly:    All layers move smoothly
Move ninja fast:      Parallax effect is dramatic
Stop ninja:           All layers stop in sync
```

---

## Troubleshooting

### Backgrounds not appearing?

Check that `createBackground()` is called in `loadLevel()`:
```swift
createBackground()  // Should be there
```

### No parallax effect?

Verify `updateParallaxLayers()` is called in `updateCamera()`:
```swift
updateParallaxLayers(cameraX: clampedX)  // Should be there
```

### Backgrounds too fast/slow?

Adjust multipliers in `updateParallaxLayers()`:
```swift
let farOffset = cameraX * 0.3  // Change this
let midOffset = cameraX * 0.6  // Change this
```

---

## Summary

### What Was Added:

✅ **3 parallax layers** - Far, mid, foreground  
✅ **Procedural graphics** - Mountains, trees, ground details  
✅ **Depth perception** - Different scroll speeds  
✅ **Automatic updates** - Synced with camera  
✅ **No assets required** - Works out of the box  
✅ **Customizable** - Easy to tweak or replace  

### Result:

🎨 **Professional depth effect**  
🏃 **Enhanced sense of movement**  
🌲 **Living, detailed world**  
🎮 **Better player experience**  

---

## Where to Get Background Images (Optional)

If you want to replace the procedural graphics with images:

### Free Asset Sources:

1. **OpenGameArt.org**
   - Search: "parallax background", "forest layers"
   - Filter: CC0 license

2. **Kenney.nl**
   - Look for: "Background Elements" pack
   - All free, public domain

3. **Itch.io**
   - Search: "parallax background pack"
   - Many free options

### Image Requirements:

- **Format:** PNG with transparency
- **Size:** 2048x1024 or larger (for retina)
- **Layers:** Separate images for far/mid/near
- **Style:** Should match game's aesthetic

---

**Now run the game and enjoy the parallax effect!** 🎬🥷✨
