
# 🥷 Stealth Ninja — Product Requirements Document (PRD)

## Overview
**Stealth Ninja** is a portrait-mode stealth game where the player controls a ninja moving from **Point A** to **Point B** across a horizontal-scrolling level.  
The ninja must travel undetected, moving between hiding spots while avoiding detection by humans, animals, and other entities with vision or hearing capabilities.

The core loop rewards **timing**, **strategy**, and **stealth awareness**, with simple one-tap control.

---

## Game Summary

| Feature | Description |
|----------|--------------|
| Orientation | Portrait |
| Genre | Stealth / Strategy / Casual |
| Platform | iOS |
| Control | Single Button Tap-and-Hold |
| Goal | Reach the endpoint (Point B) without being detected |
| Core Mechanic | Move and stop strategically to remain hidden |

---

## Core Gameplay Mechanics

### 1. Controls & Input
- Single button located at the **bottom center** of the screen.
- **Press and hold** — The ninja moves forward (automated pathing).
- **Release** — The ninja stops and attempts to hide/blend into surroundings.

### 2. Movement & Scrolling
- The level scrolls **horizontally** (left to right) as the ninja progresses.
- Each level has a **defined path** from Point A to Point B with multiple *hiding points (HP)*.
- When the player holds the button, the ninja smoothly transitions to the next hiding point along the path.

### 3. Hiding Points (HP)
- Predefined safe zones where the ninja can blend and become invisible to NPCs.
- If the player stops **outside** these zones, the ninja is **partially exposed** and risks detection.
- Hiding points can have visual cues (e.g. shadows, bushes, crates, rooftops with dark tiles).

### 4. Detection System
- **Vision Detection:**  
  - NPCs (farmers, guards, animals) have a vision cone or radius.  
  - If the ninja is visible within the cone, detection triggers a fail state.
- **Sound Detection:**  
  - Certain tiles or obstacles (e.g. noisy roofs, loose crates) increase sound level.  
  - Fast movement or abrupt stops may alert nearby NPCs.
- **Lighting & Shadow:**  
  - Some hiding points are only effective in darkness.  
  - Lighting dynamically affects the visibility level.

### 5. Enemies & Environment
- **Neutral NPCs:** Farmers, townsfolk — will raise alarms if they notice the ninja.  
- **Hostile NPCs:** Soldiers, guards — will chase and capture on sight.  
- **Alert animals:** Dogs, birds — can detect through movement or sound.  
- **Environmental Hazards:** Breakable tiles, noisy gravel, swinging lanterns, etc.

### 6. Level Design
- Each level = a horizontal map representing a village, rooftop path, or forest route.  
- **Distance** between A and B defines level difficulty.  
- **Progress dynamically scrolls**, revealing new sections as the ninja moves.  
- **Difficulty scaling:** More NPCs, faster patrols, tighter hiding windows as levels advance.

---

## Visual & UI

### 1. Layout
- **Portrait mode.**
- Bottom area: large single button ("MOVE / HIDE").
- Top area: small HUD with:
  - Level progress bar (A → B)
  - Detection indicator (visibility/sound levels)
  - Restart / Pause buttons.

### 2. Art Style
- Minimalist **silhouette or ink-brush** visual style.
- High contrast between light and shadow.
- Parallax background for depth illusion during horizontal scroll.

---

## Game States

| State | Description |
|--------|--------------|
| Idle | Waiting for player input before movement |
| Moving | Ninja traveling toward next hiding point |
| Hiding | Ninja stationary, blending in (safe if in a valid zone) |
| Detected | Player caught (reset level or checkpoints) |
| Completed | Player reaches Point B safely |

---

## Audio

- Ambient background music (low-intensity instrumental).
- Dynamic sound layers that respond to motion and danger levels.
- Footstep variations depending on surface (wood, tile, gravel).
- Alert sounds when detection meters increase.
- Victory/Failure jingles.

---

## Level Progression

- **Easy Levels:** Fewer obstacles, larger hiding zones.  
- **Mid Levels:** Introduce patrol patterns and alert animals.  
- **Hard Levels:** Combine light, sound, and timing elements dynamically.

Player progression can unlock:
- New costumes (visual skins).
- New environments (temple, marketplace, fortress, forest at night).

---

## Technical Notes

- **Engine:** SpriteKit / SceneKit (for 3D depth illusion optional).  
- **Physics:** Hidden zones defined via `CGRect` zones or collision layers.  
- **Animation:** Use Core Animation or SpriteKit actions for smooth in/out hiding transitions.  
- **State Tracking:** Use an enum for ninja state (idle, hiding, moving, detected).  
- **Sound Integration:** Employ `AVAudioPlayerNode` for adaptive feedback.

---

## Success Criteria

- Intuitive one-button gameplay.
- Satisfying stealth mechanic with clear audio-visual feedback.
- Seamless horizontal scrolling and fluid animations.
- Quick feedback loop (short levels, quick restarts).
- Detection feels fair and readable.

---

## Future Enhancements (Post-MVP)

- Time-based scoring or "Speed + Stealth" performance ranks.
- Leaderboards (Game Center integration).
- Character upgrades or unique abilities (e.g., smoke bombs, silent dash).
- Dynamic lighting simulation (for night missions).

---

## MVP Deliverable Summary

| Feature | Phase | Notes |
|----------|--------|-------|
| One-button tap-and-hold movement | MVP | Core control mechanic |
| Hiding zone logic | MVP | Visual & functional hiding feedback |
| Vision-based detection | MVP | Simple cone detection per NPC |
| Basic horizontal level scroll | MVP | Level reveals gradually |
| Sound feedback (footsteps, alerts) | MVP | Links stealth behavior to audio |
| Restart and completion flows | MVP | Basic UX loop reliability |

---

## Example Gameplay Flow

1. Level loads with ninja hidden in shadow at Point A.  
2. Player presses and holds the button → ninja starts moving.  
3. Player releases → ninja stops and attempts to hide.  
4. NPCs patrol; ninja waits.  
5. Player times next move, advancing to the next hiding point.  
6. Repeats until point B reached or detected.

---

*Document Version: 1.0 — Created for integration with Xcode project (March 2026)*

