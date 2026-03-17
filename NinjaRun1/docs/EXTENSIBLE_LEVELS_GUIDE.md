# 🎮 Extensible Level System - How to Add More Levels

## Overview

Your game now supports **unlimited levels** using a professional, scalable system similar to what AAA games use!

---

## 🏗️ System Architecture

### Three-Tier Level System:

1. **Handcrafted Levels** (Levels 1-6) - Designed by you
2. **Level Database** - Easy registration system
3. **Procedural Generation** - Infinite endless mode

---

## ✅ Current Status

### Available Levels:

| Level | Name | Difficulty | NPCs | Features |
|-------|------|------------|------|----------|
| **1** | Tutorial | ⭐ Easy | 2 | Lenient detection |
| **2** | Village | ⭐⭐ Medium | 3 | Mixed hostility |
| **3** | Fortress | ⭐⭐⭐ Hard | 5 | Tight timing |
| **4** | Night Mission | ⭐⭐⭐ Hard | 4 | Light-dependent hiding |
| **5** | Rooftop Chase | ⭐⭐⭐⭐ Very Hard | 5 | Vertical movement |
| **6** | The Gauntlet | ⭐⭐⭐⭐⭐ Extreme | 9 | Maximum challenge |
| **7+** | Endless Mode | 🔄 Infinite | Scales | Procedurally generated |

---

## 📝 How to Add a New Level (Simple Method)

### Step 1: Create Your Level Function

In `LevelDataExtended.swift`, add:

```swift
private func createLevel7() -> LevelData {
    let levelWidth: CGFloat = 2600
    
    let hidingPoints = [
        LevelData.HidingPointConfig(
            position: CGPoint(x: 300, y: 200),
            size: CGSize(width: 70, height: 70),
            isLightDependent: false
        ),
        // Add more hiding points...
    ]
    
    let npcs = [
        LevelData.NPCConfig(
            startPosition: CGPoint(x: 400, y: 250),
            patrolPoints: [
                CGPoint(x: 350, y: 250),
                CGPoint(x: 500, y: 250)
            ],
            visionRange: 200,
            visionAngle: CGFloat.pi / 3,
            isHostile: false,
            detectionSensitivity: 6
        ),
        // Add more NPCs...
    ]
    
    return LevelData(
        levelNumber: 7,
        startPosition: CGPoint(x: 100, y: 200),
        endPosition: CGPoint(x: 2400, y: 200),
        hidingPoints: hidingPoints,
        npcs: npcs,
        levelWidth: levelWidth
    )
}
```

### Step 2: Register in Database

In the `levelDatabase` property, add:

```swift
private var levelDatabase: [Int: LevelData] {
    return [
        4: createLevel4(),
        5: createLevel5(),
        6: createLevel6(),
        7: createLevel7(),  // ← Add your new level!
        // 8: createLevel8(),
        // 9: createLevel9(),
    ]
}
```

**That's it!** Your level is now in the game!

---

## 🎨 Level Design Guidelines

### Hiding Points:

**Spacing:**
- Easy: 300-400 units apart
- Medium: 250-350 units apart  
- Hard: 200-300 units apart
- Extreme: 150-250 units apart

**Size:**
- Easy: 80x80 pixels
- Medium: 70x70 pixels
- Hard: 60x60 pixels
- Extreme: 50x50 pixels

**Y Position:** 150-350 (vertical variety)

### NPCs:

**Number:**
- Easy: 2-3 NPCs
- Medium: 3-4 NPCs
- Hard: 4-6 NPCs
- Extreme: 7-10 NPCs

**Detection Sensitivity:**
- 1-3: Lenient (tutorial)
- 4-6: Medium (normal)
- 7-8: Strict (challenging)
- 9-10: Extreme (expert)

**Vision Range:**
- Small: 150-180
- Medium: 180-220
- Large: 220-260

**Patrol Patterns:**
```swift
// Simple back-and-forth:
patrolPoints: [
    CGPoint(x: 300, y: 250),
    CGPoint(x: 500, y: 250)
]

// Square pattern:
patrolPoints: [
    CGPoint(x: 400, y: 200),
    CGPoint(x: 600, y: 200),
    CGPoint(x: 600, y: 350),
    CGPoint(x: 400, y: 350)
]

// Triangle pattern:
patrolPoints: [
    CGPoint(x: 500, y: 200),
    CGPoint(x: 700, y: 300),
    CGPoint(x: 500, y: 350)
]
```

### Level Width:

```swift
Level 1-2:  2000-2500 units
Level 3-4:  2500-3000 units
Level 5-6:  2400-3500 units
Level 7+:   3000-4000 units
```

---

## 🚀 How Other Games Handle Levels

### 1. **JSON/Plist Files** (Candy Crush, Angry Birds)

**Pros:**
- Easy to edit without recompiling
- Can be updated via server
- Non-programmers can create levels

**Example:**
```json
{
  "levelNumber": 7,
  "width": 2600,
  "hidingPoints": [
    {"x": 300, "y": 200, "size": 70}
  ],
  "npcs": [
    {"x": 400, "y": 250, "sensitivity": 6}
  ]
}
```

**When to use:** When you want 100+ levels or remote updates

### 2. **Level Editor Tools** (Super Mario Maker, Portal)

**Pros:**
- Visual design
- Instant preview
- Can share levels

**Tools:**
- Tiled (free, open-source)
- Unity Level Editor
- Custom tools

**When to use:** Complex level geometry, non-programmer designers

### 3. **Procedural Generation** (Rogue, Minecraft, Spelunky)

**Pros:**
- Infinite content
- Always fresh
- Small file size

**Your game has this!** After level 6, it generates infinite levels.

**When to use:** Endless mode, roguelikes, high replayability

### 4. **Database Systems** (Puzzle games with 1000+ levels)

**Pros:**
- Scales to thousands of levels
- Easy querying
- Analytics integration

**Tools:**
- SQLite
- Core Data
- Realm

**When to use:** 500+ levels, user-generated content

---

## 🎯 Your Current System (Best of Both Worlds!)

### ✅ Advantages:

1. **Handcrafted Levels (1-6):**
   - Full control over difficulty
   - Perfectly balanced
   - Story progression

2. **Easy to Add:**
   - Just write a function
   - Add to database
   - Done!

3. **Procedural Backup:**
   - Never runs out of content
   - Automatic difficulty scaling
   - Replayability

4. **No External Dependencies:**
   - No file parsing
   - No external tools required
   - Fast loading

---

## 📊 Comparison Chart

| Method | Your Game | JSON | Editor | Database |
|--------|-----------|------|--------|----------|
| Easy to add | ✅✅✅ | ✅✅ | ✅✅✅ | ✅ |
| No tools needed | ✅✅✅ | ✅ | ❌ | ✅ |
| Version control | ✅✅✅ | ✅✅ | ❌ | ✅ |
| Live updates | ❌ | ✅✅✅ | ❌ | ✅✅✅ |
| Type safety | ✅✅✅ | ❌ | ✅ | ✅ |
| Performance | ✅✅✅ | ✅✅ | ✅✅✅ | ✅ |
| Scales to 1000+ | ✅ | ✅✅ | ✅ | ✅✅✅ |

---

## 🔄 Procedural Generation Details

Your game automatically generates levels when you run out of handcrafted ones!

### Algorithm:

```swift
func generateProceduralLevel(levelNumber: Int) -> LevelData {
    // Width scales with level number
    levelWidth = 2000 + (levelNumber * 500)
    
    // Difficulty caps at 10
    difficulty = min(levelNumber, 10)
    
    // More hiding points as difficulty increases
    numHidingPoints = 5 + difficulty
    
    // Hiding points get smaller
    size = 70 - (difficulty * 2)
    
    // More NPCs
    numNPCs = 2 + (difficulty / 2)
    
    // Higher detection sensitivity
    sensitivity = min(5 + difficulty, 10)
    
    // Longer vision range
    visionRange = 180 + (difficulty * 10)
}
```

### Endless Mode Features:

✅ Automatic difficulty scaling  
✅ Random but balanced placement  
✅ Variety in NPC patterns  
✅ Mix of hostile and neutral  
✅ Light-dependent spots appear after level 3  

---

## 🎮 Adding Themes

Want different visual themes per level? Add to `LevelData`:

```swift
struct LevelData {
    // ... existing properties
    let theme: LevelTheme
}

enum LevelTheme {
    case village
    case rooftop
    case forest
    case temple
    case fortress
}
```

Then in `createBackground()`:
```swift
switch currentLevel.theme {
case .village:
    // Green colors, houses
case .rooftop:
    // Gray, urban
case .forest:
    // Dark green, trees
}
```

---

## 📦 Exporting to JSON (Optional Future Enhancement)

Want to save/load from files later? Here's how:

```swift
extension LevelData: Codable {
    // Makes it encodable/decodable
}

// Save level:
let encoder = JSONEncoder()
let data = try encoder.encode(levelData)
try data.write(to: fileURL)

// Load level:
let decoder = JSONDecoder()
let data = try Data(contentsOf: fileURL)
let level = try decoder.decode(LevelData.self, from: data)
```

---

## 🎨 Level Templates

### Easy Level Template:
```swift
private func createLevelX() -> LevelData {
    let levelWidth: CGFloat = 2200
    let hidingPoints = generateEvenlySpaced(
        count: 6, 
        width: levelWidth, 
        yRange: 150...250
    )
    let npcs = generateSimplePatrols(
        count: 3,
        width: levelWidth,
        sensitivity: 4
    )
    return LevelData(/* ... */)
}
```

### Hard Level Template:
```swift
private func createLevelY() -> LevelData {
    let levelWidth: CGFloat = 3200
    let hidingPoints = generateTightSpacing(
        count: 10,
        width: levelWidth,
        yRange: 140...320  // More vertical variety
    )
    let npcs = generateOverlappingPatrols(
        count: 8,
        width: levelWidth,
        sensitivity: 9
    )
    return LevelData(/* ... */)
}
```

---

## ✨ Quick Start: Add Level 7 Right Now!

1. **Open** `LevelDataExtended.swift`
2. **Copy** `createLevel6()` function
3. **Paste** below it
4. **Rename** to `createLevel7()`
5. **Change** level number to 7
6. **Adjust** positions, NPCs, difficulty
7. **Add** to `levelDatabase`:
   ```swift
   7: createLevel7(),
   ```
8. **Done!** Build and play!

---

## 🎯 Summary

### Your System Now Supports:

✅ **6 handcrafted levels** (easily add more!)  
✅ **Endless procedural levels** (infinite content!)  
✅ **Easy to extend** (just add a function!)  
✅ **Professional architecture** (like AAA games!)  
✅ **Type-safe** (no parsing errors!)  
✅ **Fast** (no file loading!)  

### To Add a Level:

1. Write level function (5-10 minutes)
2. Add to database (5 seconds)
3. Done! ✅

---

**Now go create amazing levels! The system makes it easy!** 🎮🥷✨
