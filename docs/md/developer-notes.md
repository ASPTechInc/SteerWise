th## Table of Contents

- [Overview](#overview)
- [Useful commands for developers](#useful-commands-for-developers)
- [Updating app version notes](#updating-app-version-notes)
- [Releasing the application notes](#releasing-the-application-notes)
- [App Icon Generation](#app-icon-generation)
- [Test GitHub workflows locally](#test-github-workflows-locally)
- [Stop tracking files in Git](#stop-tracking-files-in-git)
- [Enable pre-commit in repository](#enable-pre-commit-in-repository)
- [SDK locations](#sdk-locations)
- [Flutter plugin error notes](#flutter-plugin-error-notes)
- [F-Droid release notes](#f-droid-release-notes)
- [Update or regenerate gradle-daemon-jvm properties](#update-or-regenerate-gradle-daemon-jvm-properties)
- [Rewriting commit history](#rewriting-commit-history)

---

## Overview

This document provides an overview of the Flutter/Dart concepts, commands and project-specific
workflows used in SteerWise to help new developers get up to speed quickly.

It complements what is documented in the [README](/README.md), the
[project setup](project-setup.md) and the [architecture overview](architecture.md).

---

## Useful commands for developers

### Code quality & Maintenance

- **Format everything**: `dart format .`
- **Check for static analysis issues**: `flutter analyze`
- **Run all unit/widget tests**: `flutter test`
- **Clean the build artefacts**: `flutter clean`
- **Fetch dependencies**: `flutter pub get`
- **Sort imports**: `dart run import_sorter:main`
- **Add the project header to new files**: `./scripts/scaffold.sh dart path/to/file.dart`
- **Check for non-free dependencies**: `./scripts/foss_audit.sh`
- **Regenerate the HTML docs**: `./scripts/md-to-html.sh docs/md docs/html` (requires `pandoc`)

Most of these are also available as `make` targets - run `make help` to list them.

- **Check environment health**: `flutter doctor`

### Build commands

- **Build Debug APK**: `flutter build apk --debug`
- **Build Release APK**: `flutter build apk --release`
- **Build Release App Bundle (AAB)**: `flutter build appbundle --release`

### Execution & Telemetry

- **List available Emulators**: `flutter emulators`
- **Disable Dart/Flutter telemetry**: `dart --disable-analytics`
- **Force kill hanging Dart processes**: `pkill -9 dart`

### Framework upgrades

- **Upgrade Dart**: `sudo apt-get update && sudo apt-get install dart`
- **Upgrade Dart version**: `dart --version`

- **Upgrade Flutter**: `flutter upgrade`
- **Check Flutter version**: `flutter --version`

> **Note:** The Flutter version used in this project is 3.47.7
> New Flutter versions should be updated in the GitHub Actions workflows (`.github/workflows/ci.yml` and `.github/workflows/release.yml`) and the F-Droid metadata (`metadata/com.asptechinc.steerwise.yml`).

---

## Updating app version notes

To update the app to a higher version:

1. Insert a new entry in the [CHANGELOG.md](/CHANGELOG.md) describing the changes.
2. Open the [pubspec.yaml](/pubspec.yaml) file and locate the `version:` line (e.g., `version: 1.0.0+1`).
   - Increment the version name before the `+` (e.g., `1.0.1`) which corresponds to Android's
     `versionName`.
   - Increment the build number after the `+` (e.g., `2`) which corresponds to Android's
     `versionCode`.
     The app reads its version at runtime with `package_info_plus` (shown on the About page), so
     `pubspec.yaml` is the only place to change it.
3. Add a store changelog at `fastlane/metadata/android/en-GB/changelogs/<versionCode>.txt`
   (e.g. `2.txt`), keeping it under 500 characters.

---

## Releasing the application notes

A keystore stores the cryptographic signing key required for Android production app releases.

[android/app/build.gradle.kts](/android/app/build.gradle.kts) signs release builds with the key
described in `android/app/keystore.properties`. If that file or its `storeFile` is missing, it
logs a warning and falls back to the debug key so `flutter run --release` still works locally.
Both files are listed in `.gitignore` and must never be committed.

### Create a keystore file

> Replace `keystore.jks` and `key-alias` with your desired secure values.

```bash
keytool -genkeypair \
  -v \
  -keystore keystore.jks \
  -alias key-alias \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### Encode the keystore file

The decoding of this file occurs dynamically inside the GitHub repository release workflow.

```bash
base64 -i keystore.jks | tr -d '\n' > keystore.base64
```

### Update the local keystore configuration

Copy [keystore.properties.example](/android/app/keystore.properties.example) to
`android/app/keystore.properties` and fill in the configuration variables:

```properties
storeFile=keystore.jks
storePassword=YOUR_STORE_PASSWORD
keyAlias=YOUR_KEY_ALIAS
keyPassword=YOUR_KEY_PASSWORD
```

_(A relative `storeFile` is resolved from `android/app/`, so place `keystore.jks` there or use an
absolute path)._

### Create environment secrets in GitHub repository

To support automated production builds via GitHub Actions, add the following Repository Secrets in
GitHub Settings under **Secrets and Variables > Actions**:

```txt
KEY_ALIAS
KEY_PASSWORD
KEYSTORE_CONTENT
KEYSTORE_FILE_NAME
KEYSTORE_PASSWORD
```

### Create app release via Tags

Push a tag matching the pattern `v*` to the `main` branch. The [release.yml](/.github/workflows/release.yml) workflow will
automatically build the release APK and bundle, sign them securely and create a new GitHub
Release.

```bash
git checkout main
git tag v1.0.0
git push origin v1.0.0
```

#### Rebuild an existing tag (Force Push)

```bash
git tag -f v1.0.0 && git push origin v1.0.0 --force
```

---

## App Icon Generation

SteerWise uses the `flutter_launcher_icons` package to automatically format and generate launcher
icons for both Android and iOS. This avoids having to manually resize assets in GIMP or third-party
image manipulation programs.

### Automated Launcher Icon Configuration

1. Place your high-resolution app icon source file at `assets/images/app_icon.png`.
2. Ensure the configuration section exists in your [pubspec.yaml](/pubspec.yaml):
   ```yaml
   flutter_launcher_icons:
     image_path: 'assets/images/app_icon.png'
     android: true
     ios: true
   ```
3. Run the automated generation command in your terminal:
   ```bash
   dart run flutter_launcher_icons
   ```

---

## Test GitHub workflows locally

[**`act`**](https://github.com/nektos/act) is used to test workflows locally without pushing to
GitHub or exhausting Actions runner minutes. It executes workflow runners inside local Docker
containers.

### Installation

- **macOS (Homebrew)**: `brew install act`
- **Linux**: `curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash`
- **Windows**: `choco install act` or `scoop install act`

### Add your user to the docker group

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Install 'newgrp' command
sudo apt install util-linux-extra

# Apply the group changes
newgrp docker

# Verify the fix
docker ps
```

> If changes do not take effect, log out and log back in

### Local workspace variables

Create these environment configurations at the root directory of the project to enable Android
SDK bindings within `act`:

`.env` / `.vars`

```bash
# Contents of .env or .vars file
ANDROID_HOME=/<path-to-your-local-sdk>/Android/Sdk
```

.secrets

```bash
# Contents of .secrets
GITHUB_TOKEN=<github-personal-access-token>
```

### Running workflow tasks

> Alternatively, the `act` command can be executed as `~/bin/act`
> Given that `act` uses Docker containers to run workflows, you will need to have **Docker**
> (or an alternative like Podman) installed and running on your machine.

1. **List all available actions/jobs:**
   ```bash
   act -l
   ```
2. **Test Continuous Integration (CI) pipeline (`ci.yml`):**

   ```bash
   act -j build -W .github/workflows/ci.yml

   # act --env-file .env --container-options "-v /<path-to-directory>/Android/Sdk:/opt/android-sdk" --env ANDROID_HOME=/opt/android-sdk -j build -W .github/workflows/ci.yml

   act -j unit-test -W .github/workflows/ci.yml
   act -j lint -W .github/workflows/ci.yml
   ```

3. **Test release production pipeline (`release.yml`):**

   ```bash
   act -j build -W .github/workflows/release.yml

   # act --secret-file .secrets --container-options "-v /<path-to-directory>/Android/Sdk:/opt/android-sdk" --env ANDROID_HOME=/opt/android-sdk -j build -W .github/workflows/release.yml
   ```

4. **Dry run (to see what steps would run without executing them):**
   ```bash
   act -n
   ```

---

## Stop tracking files in Git

To wipe untracked build caches or files from Git tracking without deleting them locally from your
disk, execute the following from the workspace root:

```bash
# Untrack build directory cache
git rm -r --cached build/

# OR, if there are other build/ folders (like app/build/) that are also being tracked, run:
# git rm -r --cached **/build/

# Commit tracking updates
git commit -m "Stop tracking build/ directory"
```

---

## Enable pre-commit in repository

1. Fetch the new dependency

   ```bash
   flutter pub get
   ```

2. Install the pre-commit git hooks

   ```bash
   # Create Python virtual environment
   python3 -m venv .venv

   # Activate environment
   source .venv/bin/activate

   # Upgrade pip
   python -m pip install --upgrade pip

   # Install pre-commit package
   pip install pre-commit

   # Install pre-commit
   pre-commit install
   ```

   `pre-commit` will be installed at `.git/hooks/pre-commit` in the project root.

3. Run the initial sort across all files

   ```bash
   pre-commit run --all-files
   ```

> Ensure you are within your active Python virtual environment .venv where pre-commit is installed
> if you have not installed it globally.

---

## SDK locations

> Replace `<username>` with your username

Dart SDK is installed at `/home/<username>/flutter/bin/cache/dart-sdk`

Flutter SDK is installed at `/home/<username>/flutter`

---

## Flutter plugin error notes

The `FlutterPlugin.kt` has the following errors in the Flutter version `3.47.4` and Dart version `3.13.3`.

```bash
/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:584:43 No value passed for parameter 'extension'
/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:584:63 Unresolved reference 'androidExtension'
/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt:584:79 Syntax error: Expecting an element.
```

To solve it, ensure that the `androidExtension` is properly passed to the `FlutterPlugin.kt` file and that all required parameters are provided. You may need to update your Flutter and Android Gradle plugin versions to the latest compatible versions.

Change (note the missing comma)

```bash
configureAbiWithoutSplits(projectToAddTasksTo androidExtension)
```

to

```bash
configureAbiWithoutSplits(projectToAddTasksTo, androidExtension)
```

Flutter Upgrades: When you run flutter upgrade, Git inside your Flutter SDK folder might notice this local modification. If it complains about a conflict, you can safely reset or discard changes in that directory before upgrading (git checkout -- packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt), since the upstream Flutter developers will have officially fixed the typo in the newer version anyway.

---

## F-Droid release notes

> Each `.txt` file in `fastlane/metadata/android/en-GB/changelogs/` corresponds to a changelog entry for a specific version code of the SteerWise FOSS app. The maximum supported length for each changelog entry is 500 characters.

> **Keep it FOSS:** F-Droid does not accept apps that depend on non-free libraries such as Google
> Play services, Firebase or Google Maps (the planned map view should use `flutter_map` with
> OpenStreetMap). Run `make foss-audit` (`./scripts/foss_audit.sh`) and `make reuse-lint` before
> each release to check the Dart packages, the Android release classpath and the licensing. The
> [foss_audit.yml](/.github/workflows/foss_audit.yml) workflow runs the same checks, plus
> `fdroid lint`, on every push and pull request to `main`.
>
> Only add artwork, sounds or text you made yourself or whose licence allows it, and record
> anything from elsewhere in `REUSE.toml` (see the DVSA questions entry).

1. Update the build recipe in [`metadata/com.asptechinc.steerwise.yml`](/metadata/com.asptechinc.steerwise.yml)
   (new `Builds` entry, `CurrentVersion` and `CurrentVersionCode`). Keep the `flutter@` srclib
   version in step with the Flutter version used for releases. The store listing text comes from
   `fastlane/metadata/android/`. The recipe sets `UNSIGNED_RELEASE=true` because F-Droid signs
   the APK itself.

2. **Tag the release on Git:**
   Ensure that the release is tagged in the main GitHub repository:

   ```bash
   git tag -a v1.0.0 -m "Release 1.0.0"
   git push origin v1.0.0
   ```

3. **Fork `fdroiddata` on GitLab:**
   - Go to [gitlab.com/fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata) and click **Fork**.

4. **Add the recipe created in step 1:**
   - Clone the fork and add the file to `metadata/com.asptechinc.steerwise.yml`:

     ```bash
     git clone https://gitlab.com/<your-username>/fdroiddata.git
     cd fdroiddata
     cp /path/to/SteerWise/metadata/com.asptechinc.steerwise.yml metadata/
     git add metadata/com.asptechinc.steerwise.yml
     git commit -m "com.asptechinc.steerwise: new app"
     git push origin main
     ```

5. **(Optional) Local linting with `fdroidserver`:**
   If you have `fdroidserver` or Docker installed:

   ```bash
   fdroid lint com.asptechinc.steerwise
   ```

6. Build release version of app for F-Droid distribution:

   ```bash
   fdroid build com.asptechinc.steerwise

   # Or build the same unsigned APK directly
   UNSIGNED_RELEASE=true flutter build apk --release
   ```

7. **Open a merge request:**
   - Navigate to the fork on GitLab and click **Create Merge Request**.
   - Select `RFP` (Request for Packaging) or standard new app template. The F-Droid maintainers and automated CI bots will test building the application and reply directly to the merge request.

---

## Update or regenerate gradle-daemon-jvm properties

```bash
./gradlew updateDaemonJvm --jvm-version 17
```

---

## Rewriting commit history

```bash
# Install git-filter-repo
python -m venv .venv
source .venv/bin/activate
pip install git-filter-repo

# Rewrite commit history
# GitHub name: ASPTechnologies Incorporation
# GitHub email: 318654411+ASPTechInc@users.noreply.github.com
cat > /tmp/mailmap <<'EOF'
ASPTechnologies Incorporation <318654411+ASPTechInc@users.noreply.github.com> <commit-hash+<other-github-username>@users.noreply.github.com>
EOF
git filter-repo --mailmap /tmp/mailmap --force
git remote add origin https://github.com/ASPTechInc/SteerWise.git   # filter-repo removes the remote


# Check it then, force-push:
git log --format='%an <%ae>' | sort | uniq -c
git fetch origin
git push --force-with-lease origin main
git push --set-upstream origin main
git stash pop
```

---
