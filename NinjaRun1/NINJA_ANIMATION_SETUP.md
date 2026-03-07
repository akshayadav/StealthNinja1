# Ninja Animation Setup Guide

## Overview
Your ninja character now uses custom animations! The code expects two types of assets:

1. **SouthStanding.png** - For idle/standing/hiding states
2. **EastAnimation.gif** (or extracted frames) - For moving/walking animation

## How to Add Images to Your Xcode Project

### Option 1: Using the GIF Directly (Simplest)

1. In Xcode, open your **Assets.xcassets** folder
2. Right-click and select **New Image Set**
3. Name it **"SouthStanding"**
4. Drag `SouthStanding.png` into the 1x, 2x, or 3x slot (any will work for games)
5. Create another image set named **"EastAnimation"**
6. Drag `EastAnimation.gif` into it

> **Note**: SpriteKit may not animate GIFs automatically. For best results, use Option 2.

### Option 2: Extract GIF Frames (Recommended)

You need to extract the frames from `EastAnimation.gif` as individual PNG images.

#### Using macOS Preview (Built-in):
1. Open `EastAnimation.gif` in **Preview**
2. Go to **File > Export**
3. This extracts each frame - you'll get multiple files
4. Rename them sequentially: `EastAnimation0.png`, `EastAnimation1.png`, etc.

#### Or use an online tool:
- Visit: https://ezgif.com/split
- Upload your GIF and download all frames
- Rename them: `EastAnimation0.png`, `EastAnimation1.png`, `EastAnimation2.png`, etc.

#### Add to Xcode:
1. In Xcode, open **Assets.xcassets**
2. For each frame, create a new Image Set:
   - **EastAnimation0**
   - **EastAnimation1**
   - **EastAnimation2**
   - ... (continue for all frames)
3. Drag the corresponding PNG into each image set

## Alternative Naming Conventions

The code will automatically try these naming patterns:
- `EastAnimation0`, `EastAnimation1`, `EastAnimation2`, ...
- `EastAnimation_0`, `EastAnimation_1`, `EastAnimation_2`, ...
- `EastAnimation` (single GIF)

Choose whichever naming works best for you!

## What the Code Does

### Idle/Standing State:
- Uses **SouthStanding.png**
- Subtle breathing animation (slight scale up/down)
- Displayed when ninja is not moving or is hiding

### Moving State:
- Uses **EastAnimation** frames
- Plays animation at 10 frames per second
- Automatically flips horizontally based on movement direction:
  - Moving right → normal sprite
  - Moving left → flipped sprite

### Hiding State:
- Switches back to **SouthStanding.png**
- Becomes semi-transparent (alpha 0.3) when successfully hidden
- Stays visible but pulses if exposed

### Detected State:
- Uses **SouthStanding.png**
- Flashes red to indicate detection

## Testing

After adding your images:

1. Build and run your project
2. The ninja should now display your custom artwork!
3. Watch for:
   - ✅ Standing sprite appears when idle
   - ✅ Walking animation plays when moving
   - ✅ Sprite flips direction based on movement
   - ✅ Transparency works when hiding

## Troubleshooting

**If the ninja appears as a black rectangle:**
- Your images aren't being found
- Check that image names match exactly (case-sensitive)
- Make sure images are in Assets.xcassets
- Verify the images are included in your target's build settings

**If the walking animation doesn't play:**
- Make sure you've extracted the GIF frames
- Verify frame numbering: 0, 1, 2, 3... (sequential, no gaps)
- Check that all frames are properly added to Assets.xcassets

**To verify images are loaded:**
Add this debug code in `StealthNinjaCharacter.swift` init method:
```swift
print("Standing texture size: \(standingTexture.size())")
print("Number of moving textures: \(movingTextures.count)")
```

If sizes are zero or count is 0, the images aren't loading.

## Customization

You can adjust animation speed in the `moveTo` method:
```swift
let timePerFrame = 0.1 // Change this! (0.1 = 10 FPS, 0.05 = 20 FPS)
```

You can adjust ninja size in the init method:
```swift
super.init(texture: standingTexture, color: .clear, size: CGSize(width: 40, height: 60))
// Change width and height to match your sprite dimensions
```

## Next Steps

Consider adding more animations:
- **NorthStanding.png** - For looking up
- **WestAnimation** - For moving left (instead of flipping)
- **NorthAnimation** - For climbing
- **DeathAnimation** - When detected
- **VictoryAnimation** - When reaching the goal

Each would follow the same pattern as the current implementation!
