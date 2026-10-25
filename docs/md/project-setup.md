# SteerWise - Smart Driving Practice App

**File:** [project-setup.md](https://github.com/ASPTechInc/SteerWise/blob/main/docs/md/project-setup.md)

**Repo:** [https://github.com/ASPTechInc/SteerWise](https://github.com/ASPTechInc/SteerWise)

Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.

Licensed under the MIT License (see LICENSE).

---

## Install Flutter Setup for Linux

1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Add the Flutter SDK to your `PATH` in your `~/.bashrc` or `~/.zshrc` file:
   ```bash
   export PATH="$HOME/flutter/bin:$PATH"
   ```
3. Install dependencies
   ```bash
   flutter doctor --android-licenses
   sudo apt install clang cmake pkg-config ninja-build libgtk-3-dev
   sudo systemctl daemon-reload
   ```
4. Run `flutter doctor` to check if everything is set up correctly

---

## Running the App

1. Clone the repository
   ```bash
      git clone https://github.com/ASPTechInc/SteerWise.git
   ```
2. Open the project in your preferred IDE (e.g., Android Studio, VS Code).
   - For Android Studio:
     - Open Android Studio
     - Click on "Open an existing Android Studio project"
     - Navigate to the cloned `SteerWise` directory and select it.

   - For VS Code:
     - Open VS Code
     - Click on "Open Folder"
     - Navigate to the cloned `SteerWise` directory and select it.

3. Install dependencies

   ```bash
      flutter pub get
   ```

4. Run on emulator or device (make sure you have an emulator running or a device connected):

   ```bash
     flutter run
   ```

   The app asks for camera permission on the Home screen. The rest of the app works if you refuse it.

   Alternatively, use the [Makefile](../../Makefile) shortcuts, e.g. `make run`, `make test` or `make build-apk` (run `make help` to list them).

5. Build APK

   ```bash
     flutter build apk
   ```

   This will generate a release APK for the Flutter app in:
   `build/app/outputs/flutter-apk/app-release.apk`

   > Without `android/app/keystore.properties`, release builds are signed with the debug key. See the [developer notes](../md/developer-notes.md#releasing-the-application-notes) before publishing.

6. Build App Bundle

   ```bash
     flutter build appbundle
   ```

   This will generate a release App Bundle for the Flutter app in:
   `build/app/outputs/bundle/release/app-release.aab`

7. Build iOS App (macOS only)

   ```bash
     flutter build ios
   ```

   This will generate a release iOS app for the Flutter app in:
   `build/ios/iphoneos/Runner.app`

8. Build Web App

   ```bash
     flutter build web
   ```

   This will generate a release web app for the Flutter app in:
   `build/web`

9. Build Windows App (Windows only)

   ```bash
     flutter build windows
   ```

   This will generate a release Windows app for the Flutter app in:
   `build/windows/x64/runner/Release/steer_wise.exe`

10. Build Linux App (Linux only)

    ```bash
      flutter build linux
    ```

    This will generate a release Linux app for the Flutter app in:
    `build/linux/x64/release/bundle/steer_wise`

11. Run the tests
    ```bash
      flutter test
    ```
