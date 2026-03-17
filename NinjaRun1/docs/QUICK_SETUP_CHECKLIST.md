# 🥷 Quick Setup Checklist for Ninja Animation

## What You Need to Do

### Step 1: Extract Your GIF Frames
You have `EastAnimation.gif` with 6 frames. Extract them first!

**Easiest Method - Use Online Tool:**
1. Go to: https://ezgif.com/split
2. Upload `EastAnimation.gif`
3. Click "Split to frames"
4. Download all 6 frames
5. You'll get files like: `frame_001.png`, `frame_002.png`, etc.
6. Rename them to: `EastAnimation0.png`, `EastAnimation1.png`, ..., `EastAnimation5.png`

### Step 2: Add Images to Xcode Assets

Open Xcode → Your Project → **Assets.xcassets**

#### Add Standing Texture:
- [ ] Right-click → New Image Set
- [ ] Name it: **`SouthStanding`** (exact spelling!)
- [ ] Drag `SouthStanding.png` into the image well

#### Add Animation Frames (do this 6 times):
- [ ] Right-click → New Image Set → Name: **`EastAnimation0`**
  - Drag `EastAnimation0.png` into it
- [ ] Right-click → New Image Set → Name: **`EastAnimation1`**
  - Drag `EastAnimation1.png` into it
- [ ] Right-click → New Image Set → Name: **`EastAnimation2`**
  - Drag `EastAnimation2.png` into it
- [ ] Right-click → New Image Set → Name: **`EastAnimation3`**
  - Drag `EastAnimation3.png` into it
- [ ] Right-click → New Image Set → Name: **`EastAnimation4`**
  - Drag `EastAnimation4.png` into it
- [ ] Right-click → New Image Set → Name: **`EastAnimation5`**
  - Drag `EastAnimation5.png` into it

### Step 3: Verify Names
Your Assets.xcassets should have these 7 image sets:
```
✅ SouthStanding
✅ EastAnimation0
✅ EastAnimation1
✅ EastAnimation2
✅ EastAnimation3
✅ EastAnimation4
✅ EastAnimation5
```

### Step 4: Build & Run
- [ ] Build your project (Cmd+B)
- [ ] Run the game (Cmd+R)
- [ ] Open the **Console** (View → Debug Area → Activate Console)

### Step 5: Check Console Output
You should see:
```
🔍 Attempting to load 6 EastAnimation frames (0-5)...
✅ Loaded: EastAnimation0 - Size: (64.0, 64.0)
✅ Loaded: EastAnimation1 - Size: (64.0, 64.0)
✅ Loaded: EastAnimation2 - Size: (64.0, 64.0)
✅ Loaded: EastAnimation3 - Size: (64.0, 64.0)
✅ Loaded: EastAnimation4 - Size: (64.0, 64.0)
✅ Loaded: EastAnimation5 - Size: (64.0, 64.0)
✅ Successfully loaded all 6 animation frames!
🥷 Number of moving textures loaded: 6
🥷 Standing texture size: (64.0, 64.0)
✅ Standing texture loaded successfully!
```

When ninja moves:
```
🏃 Starting walk animation with 6 frames
👉 Moving right
```

### Step 6: Test
- [ ] Ninja shows standing texture when idle
- [ ] Ninja animates when moving
- [ ] Ninja flips direction when moving left/right
- [ ] Ninja becomes transparent when hiding

---

## 🚨 Troubleshooting

### Problem: "❌ Failed to load: EastAnimation0"
**Fix:** The image set doesn't exist or is misnamed
- Check spelling (case-sensitive!)
- Make sure you created the image set in Assets.xcassets
- Verify the PNG is inside the image set

### Problem: "Number of moving textures loaded: 0"
**Fix:** No frames loaded at all
- Did you extract the GIF frames?
- Are they added to Assets.xcassets?
- Are they named exactly: `EastAnimation0`, `EastAnimation1`, etc.?

### Problem: "Standing texture not found!"
**Fix:** The standing image isn't loading
- Image set must be named exactly: `SouthStanding`
- Check that `SouthStanding.png` is in the image set
- Verify no typos

### Problem: Animation plays but ninja is too small/big
**Fix:** Adjust the size in `StealthNinjaCharacter.swift` line ~36:
```swift
size: CGSize(width: 40, height: 60) // Change these numbers
```

### Problem: Animation is too fast/slow
**Fix:** Adjust speed in `StealthNinjaCharacter.swift` line ~128:
```swift
let timePerFrame = 0.1  // Change this
// 0.05 = faster (20 FPS)
// 0.1 = normal (10 FPS)
// 0.15 = slower (6.7 FPS)
```

---

## 📸 What Your Assets.xcassets Should Look Like

```
Assets.xcassets/
│
├── 📁 SouthStanding.imageset/
│   ├── SouthStanding.png
│   └── Contents.json
│
├── 📁 EastAnimation0.imageset/
│   ├── EastAnimation0.png
│   └── Contents.json
│
├── 📁 EastAnimation1.imageset/
│   ├── EastAnimation1.png
│   └── Contents.json
│
├── 📁 EastAnimation2.imageset/
│   ├── EastAnimation2.png
│   └── Contents.json
│
├── 📁 EastAnimation3.imageset/
│   ├── EastAnimation3.png
│   └── Contents.json
│
├── 📁 EastAnimation4.imageset/
│   ├── EastAnimation4.png
│   └── Contents.json
│
└── 📁 EastAnimation5.imageset/
    ├── EastAnimation5.png
    └── Contents.json
```

---

## ✅ Success Criteria

You'll know it's working when:
1. ✅ Console shows "Successfully loaded all 6 animation frames!"
2. ✅ Console shows "Standing texture loaded successfully!"
3. ✅ Ninja displays your custom standing sprite when idle
4. ✅ Ninja cycles through all 6 animation frames when moving
5. ✅ Animation looks smooth and continuous

**That's it! You're done! 🎉**

If you still have issues, run the game and copy/paste the console output so I can help debug.
