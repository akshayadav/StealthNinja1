# Info.plist Configuration for Stealth Ninja

## Portrait Mode Setup

To ensure the game only runs in portrait mode, you need to configure your Info.plist file.

### Option 1: Using Xcode Project Settings (Easiest)

1. Click on your **project** in the navigator (the blue icon at the top)
2. Select your **target** (NinjaRun1)
3. Go to the **General** tab
4. Scroll down to **Deployment Info**
5. Under **Device Orientation**, check ONLY:
   - ✅ Portrait
   - ❌ Upside Down (uncheck)
   - ❌ Landscape Left (uncheck)
   - ❌ Landscape Right (uncheck)

### Option 2: Editing Info.plist Directly

If you need to edit the Info.plist file manually:

1. Find `Info.plist` in your project navigator
2. Add or modify these keys:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

For iPad support, also add:

```xml
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
```

### What's Already Done

The `GameViewController.swift` already includes:

```swift
override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
}
```

This provides code-level enforcement of portrait mode.

---

## Additional Info.plist Settings (Optional)

### Hide Status Bar

Already implemented in code:
```swift
override var prefersStatusBarHidden: Bool {
    return true
}
```

But you can also add to Info.plist:
```xml
<key>UIStatusBarHidden</key>
<true/>
<key>UIViewControllerBasedStatusBarAppearance</key>
<false/>
```

### Prevent Screen Sleep During Gameplay

To keep the screen on while playing, add to `GameViewController.swift`:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    UIApplication.shared.isIdleTimerDisabled = true // Keep screen awake
    // ... rest of your code
}
```

---

## Verification

After configuring, test that:

1. App launches in portrait mode
2. Rotating device doesn't change orientation
3. Game remains playable in portrait

---

## Troubleshooting

### App still rotates?
- Check that ALL three places are configured:
  1. Project settings (Deployment Info)
  2. Info.plist (UISupportedInterfaceOrientations)
  3. GameViewController (supportedInterfaceOrientations)

### iPad shows landscape?
- Make sure you set the iPad-specific key in Info.plist
- Or test on iPhone where portrait is default

---

*This configuration ensures your game respects the portrait-only requirement from the PRD!*
