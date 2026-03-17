# 🔧 BUILD FIX GUIDE

## The Problem

Your project has **duplicate files** that are causing compilation errors. This happened because:
1. You had original starter files
2. I created new versions with better implementations
3. Xcode created duplicates with " 2" suffix

## ✅ SOLUTION: Delete These Files from Xcode

**In Xcode's Project Navigator, DELETE these files:**

1. ❌ `GameState 2.swift` (delete this one)
2. ❌ `NinjaNode 2.swift` (delete this one)  
3. ❌ `NPCNode 2.swift` (delete this one)
4. ❌ `HidingPoint.swift` (delete this one - we use HidingPointNode.swift instead)

**How to delete:**
- Select the file in the left panel
- Right-click → **Delete**
- Choose **"Move to Trash"** (not just "Remove Reference")

## ✅ Files You SHOULD Keep

Keep these files (they're the correct implementations):

- ✅ `GameState.swift` (no number suffix)
- ✅ `NinjaNode.swift` (no number suffix)
- ✅ `NPCNode.swift` (no number suffix)
- ✅ `HidingPointNode.swift` (note: "Node" at the end)
- ✅ `GameScene.swift`
- ✅ `GameViewController.swift`
- ✅ `LevelData.swift`
- ✅ `AppDelegate.swift`

## After Deleting

1. **Clean Build Folder:**
   - In Xcode menu: Product → Clean Build Folder
   - Or press: **⇧⌘K**

2. **Build Again:**
   - Press **⌘B** to build
   - Should now compile successfully!

3. **Run:**
   - Press **⌘R** to run the game

## If You Still Get Errors

### Error: "Cannot find type 'HidingPoint'"

This means `HidingPoint.swift` is still in the project. Make sure you deleted it and are using `HidingPointNode.swift` instead.

### Error: "Ambiguous type lookup"

This means duplicate files still exist. Check for any files with " 2" suffix and delete them.

### Error: "Cannot override stored property 'isHidden'"

This means the old `NinjaNode.swift` is still being used. Delete all duplicate NinjaNode files and keep only the one that extends `SKSpriteNode` (not `SKNode`).

## Quick Checklist

- [ ] Deleted `GameState 2.swift`
- [ ] Deleted `NinjaNode 2.swift`
- [ ] Deleted `NPCNode 2.swift`
- [ ] Deleted `HidingPoint.swift`
- [ ] Cleaned build folder (⇧⌘K)
- [ ] Built project (⌘B)
- [ ] Errors gone? ✅

## Still Having Issues?

If you're still seeing errors after deleting duplicates, you might need to:

1. **Check for more duplicates:**
   - Look for any other files with " 2", " 3" etc. suffixes
   - Delete all duplicates

2. **Verify file targets:**
   - Select each remaining .swift file
   - In the File Inspector (right panel), check that it's in your app target

3. **Restart Xcode:**
   - Sometimes Xcode needs a restart to clear cached errors
   - Quit Xcode completely and reopen

---

## Summary

**The game code is correct!** You just need to clean up duplicate files that Xcode created. Once you delete the duplicates listed above and clean the build, everything should compile and run perfectly! 🚀
