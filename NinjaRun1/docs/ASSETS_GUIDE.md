# 🎨 Stealth Ninja - Asset Guide

## Overview
This document outlines all the visual assets needed for Stealth Ninja. The game currently uses placeholder colored rectangles/circles, but will look much better with proper sprites!

---

## Required Sprites

### 1. **Ninja Character** (`ninja.png`)
- **Size:** 40x60 pixels (or 2x/3x for retina)
- **Style:** Silhouette or minimalist ink-brush style (as per PRD)
- **Description:** The player character - a stealthy ninja
- **Suggested look:** Black/dark figure, possibly with subtle details like a headband or flowing scarf
- **Animation states (optional):**
  - Idle (can be static)
  - Running (optional, for more polish)

### 2. **Hiding Spot** (`hidingspot.png`)
- **Size:** 70-80x70-80 pixels
- **Style:** Dark shadow or bush texture
- **Description:** Visual indicator of safe hiding zones
- **Suggested look:** 
  - Dark shadow patch
  - Small bush
  - Crate or barrel
  - Corner shadow
- **Notes:** Should be semi-transparent to show it's a special zone

### 3. **Guard/Hostile NPC** (`guard.png`)
- **Size:** 40x50 pixels
- **Style:** Matches ninja style (silhouette/minimalist)
- **Description:** Enemy that chases on sight
- **Suggested look:** 
  - Guard with weapon
  - Soldier silhouette
  - Red-tinted to show hostility
  - Possibly with helmet or armor details

### 4. **Civilian/Neutral NPC** (`civilian.png`)
- **Size:** 40x50 pixels
- **Style:** Matches ninja style
- **Description:** Non-hostile NPC that will raise alarms
- **Suggested look:**
  - Farmer or townsperson
  - Blue-tinted to show neutral
  - Simpler silhouette than guards

---

## Where to Get Sprites

### Option 1: **Free Game Asset Sites**
- **OpenGameArt.org** - https://opengameart.org/
  - Search for: "ninja", "stealth", "guard", "2d character"
  - Filter by: CC0 or CC-BY license
  
- **Itch.io Asset Store** - https://itch.io/game-assets/free
  - Many free 2D game assets
  - Search for "ninja sprite" or "stealth game"
  
- **Kenney.nl** - https://kenney.nl/assets
  - Fantastic free game assets
  - Look for: "Platformer Pack", "Topdown Shooter"
  
### Option 2: **Create Simple Shapes**
For MVP, you can use simple geometric shapes:
- **Ninja:** Black rectangle with rounded top
- **Guards:** Red rectangle
- **Civilians:** Blue rectangle
- **Hiding spots:** Dark gray circles

### Option 3: **AI Generation**
Use AI tools to generate sprites:
- **Midjourney** or **DALL-E**
  - Prompt: "minimalist ninja game sprite, silhouette style, black and white, pixel art"
  - Prompt: "stealth game guard sprite, red tinted, minimalist"

### Option 4: **Commission an Artist**
- **Fiverr** - For budget-friendly sprite work
- **ArtStation** - For professional game artists
- **Reddit r/gameDevClassifieds** - For indie-friendly rates

---

## Adding Sprites to Your Xcode Project

### Step 1: Add to Asset Catalog
1. Open your Xcode project
2. Click on `Assets.xcassets` in the navigator
3. Right-click in the left panel → "New Image Set"
4. Name it exactly as shown in the code:
   - `ninja`
   - `hidingspot`
   - `guard`
   - `civilian`
5. Drag your image files into the appropriate slots:
   - 1x: Standard resolution
   - 2x: Retina (2x size)
   - 3x: Super Retina (3x size)

### Step 2: File Format
- **PNG** with transparency is recommended
- Size should be consistent across all character sprites

### Step 3: Test
The code will automatically load these textures. If a texture isn't found, it falls back to colored rectangles/circles.

---

## Current Implementation Status

✅ **Working without sprites:** The game uses colored shapes as placeholders
- Ninja: Black rectangle (40x60)
- Hiding spots: Dark gray circles (70-80 radius)
- Guards: Red rectangles (40x50)
- Civilians: Blue rectangles (40x50)

🎨 **With sprites:** Simply add the images to Assets.xcassets and the game will automatically use them!

---

## Quick Start (No Sprites Needed)

**Good news!** The game is fully playable right now without any sprites. The colored shapes are functional and let you test all the mechanics:

- **Black rectangle** = Ninja
- **Dark gray circles** = Hiding spots (with green/yellow borders)
- **Red rectangles** = Guards (hostile)
- **Blue rectangles** = Civilians (neutral)
- **Colored cones** = Vision ranges

You can add sprites later to make it look more polished!

---

## Recommended Sprite Sizes for Retina Displays

| Asset | 1x | 2x | 3x |
|-------|-----|-----|-----|
| Ninja | 40x60 | 80x120 | 120x180 |
| NPCs | 40x50 | 80x100 | 120x150 |
| Hiding Spot | 80x80 | 160x160 | 240x240 |

---

## Art Style Guidelines (from PRD)

- **Minimalist silhouette or ink-brush visual style**
- **High contrast between light and shadow**
- **Black/dark colors for ninja**
- **Red for hostile enemies**
- **Blue/neutral for civilians**
- **Green for safe zones**

---

*The game is fully functional without any custom sprites. Add them whenever you're ready to polish the visuals!*
