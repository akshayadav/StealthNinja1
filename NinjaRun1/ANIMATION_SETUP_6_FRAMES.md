# Setting Up 6-Frame Ninja Animation

## What You Have
- `SouthStanding.png` - Standing/idle pose
- 6 frames from `EastAnimation.gif` - Walking animation

## Step-by-Step Setup in Xcode

### 1️⃣ Add Standing Texture

1. Open **Assets.xcassets** in Xcode
2. Right-click → **New Image Set**
3. Name it: **`SouthStanding`** (exactly, case-sensitive)
4. Drag your `SouthStanding.png` into any slot (1x, 2x, or 3x)

### 2️⃣ Add Animation Frames

You need to create **6 separate image sets**, one for each frame:

#### Option A: Number from 0 (Recommended)
1. Right-click → **New Image Set** → Name: **`EastAnimation0`**
2. Drag frame 0 into it
3. Right-click → **New Image Set** → Name: **`EastAnimation1`**
4. Drag frame 1 into it
5. Repeat for: `EastAnimation2`, `EastAnimation3`, `EastAnimation4`, `EastAnimation5`

#### Option B: Number from 1
Alternatively, name them:
- `EastAnimation1`, `EastAnimation2`, `EastAnimation3`, `EastAnimation4`, `EastAnimation5`, `EastAnimation6`

(The code tries pattern starting from 0 first, then falls back to other patterns)

### 3️⃣ Your Assets.xcassets Should Look Like:
```
Assets.xcassets/
├── SouthStanding
├── EastAnimation0
├── EastAnimation1
├── EastAnimation2
├── EastAnimation3
├── EastAnimation4
└── EastAnimation5
```

## Extract Frames from GIF (If Not Already Done)

If you still have the GIF and need to extract frames:

### Using macOS Preview:
1. Open `EastAnimation.gif` in Preview
2. You'll see 6 thumbnails in the sidebar
3. Select frame 1 → File → Export → Save as `frame0.png`
4. Select frame 2 → Export → Save as `frame1.png`
5. Continue for all 6 frames

### Using Online Tool (Easiest):
1. Go to: https://ezgif.com/split
2. Upload `EastAnimation.gif`
3. Click "Split to frames"
4. Download all 6 frames
5. Rename them: `frame0.png`, `frame1.png`, ... `frame5.png`

### Using Terminal (Advanced):
```bash
cd ~/Downloads/NinjaRun
# Install ImageMagick if not already installed
brew install imagemagick

# Extract frames
convert EastAnimation.gif frame_%d.png
# This creates: frame_0.png, frame_1.png, ..., frame_5.png
```

## Verify It Works

Run your game and check the Xcode console. You should see:

```
🔍 Attempting to load EastAnimation frames...
✅ Loaded: EastAnimation0
✅ Loaded: EastAnimation1
✅ Loaded: EastAnimation2
✅ Loaded: EastAnimation3
✅ Loaded: EastAnimation4
✅ Loaded: EastAnimation5
🥷 Number of moving textures loaded: 6
🥷 Standing texture size: (64.0, 64.0)  // or whatever your image size is
✅ Standing texture loaded successfully!
```

When you move the ninja:
```
🏃 Starting walk animation with 6 frames
👉 Moving right  // or 👈 Moving left
```

## Troubleshooting

### Issue: Console shows "Number of moving textures loaded: 0"
**Solution**: The image sets aren't named correctly
- Check spelling: Must be exactly `EastAnimation0` (case-sensitive)
- No spaces in names
- Check they're in Assets.xcassets, not just added to project

### Issue: Console shows "Standing texture not found!"
**Solution**: 
- Check image set name is exactly `SouthStanding` (case-sensitive)
- Make sure the PNG is actually in the image set
- Try clicking the image set and verifying the image appears

### Issue: Animation doesn't play smoothly
**Solution**: Adjust animation speed in code:
```swift
let timePerFrame = 0.1 // Change this value
// 0.05 = 20 FPS (faster)
// 0.1 = 10 FPS (normal)
// 0.15 = 6.7 FPS (slower)
```

### Issue: Ninja is too small/large
**Solution**: Adjust size in `StealthNinjaCharacter.swift`:
```swift
size: CGSize(width: 40, height: 60) // Change these values
```

## Quick Checklist
- [ ] Extracted 6 frames from GIF
- [ ] Created `SouthStanding` image set with standing PNG
- [ ] Created `EastAnimation0` through `EastAnimation5` image sets
- [ ] Each animation image set has its corresponding frame
- [ ] Built and ran the game
- [ ] Checked console for success messages
- [ ] Ninja displays standing texture when idle
- [ ] Ninja plays walk animation when moving

## Next Steps
Once this works, you can add more animations:
- `NorthAnimation0-5` - Walking up
- `WestAnimation0-5` - Walking left (or just flip EastAnimation)
- `SouthAnimation0-5` - Walking down
- `HidingPose` - Special hiding animation
- `DetectedAnimation` - When caught

The code structure I created makes it easy to add these later!
