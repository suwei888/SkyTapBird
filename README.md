# SkyTapBird

SkyTapBird is a lightweight iOS tap-to-fly game built with UIKit and SpriteKit. The project includes the full Xcode project, source code, tests, and pixel-art assets needed to build and run the game.

## Requirements

- macOS with Xcode installed
- iPhone or iPad running iOS 17.0 or later
- Apple ID signed in to Xcode for installing on a real device
- USB cable, or wireless debugging already enabled for the device

## Install on your own iPhone

1. Clone this repository:

   ```sh
   git clone <repository-url>
   cd SkyTapBird
   ```

2. Open the project in Xcode:

   ```sh
   open SkyTapBird.xcodeproj
   ```

3. In Xcode, select the `SkyTapBird` project, then the `SkyTapBird` app target.

4. Open `Signing & Capabilities`.

5. Choose your own Apple developer team in `Team`.

6. Change `Bundle Identifier` from `com.example.SkyTapBird` to a unique value you own, for example `com.yourname.SkyTapBird`. If you also run tests, use matching unique identifiers for the test targets.

7. Connect your iPhone or iPad, unlock it, and trust the computer if iOS asks.

8. Pick your device from the Xcode run destination menu.

9. Press `Run` in Xcode. Xcode will build, sign, install, and launch the game on your device.

## If the app does not launch

- If Xcode says the bundle identifier is already used, choose a more unique bundle identifier.
- If signing fails, make sure your Apple ID is signed in under `Xcode > Settings > Accounts`, then reselect your team in `Signing & Capabilities`.
- If the device does not appear, reconnect it, unlock it, and confirm Developer Mode is enabled on the device if iOS asks for it.
- If the app opens to a black screen, clean the build folder with `Product > Clean Build Folder`, then run again.

## Development

Run unit tests from Xcode with `Product > Test`, or from Terminal:

```sh
xcodebuild test -project SkyTapBird.xcodeproj -scheme SkyTapBird -destination 'platform=iOS Simulator,name=iPhone 16'
```

The app code lives in `SkyTapBird/`, with unit tests in `SkyTapBirdTests/` and UI tests in `SkyTapBirdUITests/`.

## Architecture

The game uses a coordinator-style SpriteKit architecture:

- `GameScene` coordinates the current run and SpriteKit contacts.
- `GameSession` owns pure gameplay state transitions.
- `BirdNode` owns bird physics and animation.
- `PipeSpawner`, `PipeLayoutCalculator`, and `PipePairNode` own obstacle generation.
- `GameHUDNode` and `GameOverPanelNode` own presentation.
- `HighScoreStoring` and `HapticsProviding` isolate platform services.

The deployment target remains iOS 17.0. The scene uses the current view size, safe-area insets, and scene lifecycle callbacks so it can be validated against the iOS 27 SDK without dropping older supported systems.

## Privacy and signing

This repository intentionally does not include a personal Apple Team ID. Every developer should sign the app with their own Apple ID or Apple Developer account before installing it on a device.
