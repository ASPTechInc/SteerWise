# SteerWise - Smart Driving Practice App

**File:** [planned-features.md](https://github.com/ASPTechInc/SteerWise/blob/main/docs/md/planned-features.md)

**Repo:** [https://github.com/ASPTechInc/SteerWise](https://github.com/ASPTechInc/SteerWise)

Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.

Licensed under the MIT License (see LICENSE).

---

## Planned Features

These features are under active consideration or development to enhance the learning experience:

- **Map Integration**

  Display real-time routes or simulated driving paths for realistic visual guidance. A `/map` route is reserved in `routes.dart`, but the map view is not built yet (the simulation currently shows a painted mini map). Use the FOSS [`flutter_map`](https://pub.dev/packages/flutter_map) package with OpenStreetMap rather than Google Maps, which F-Droid does not accept, and follow the [OpenStreetMap tile usage policy](https://operations.osmfoundation.org/policies/tiles/).

- **Video Recording & Session Playback**

  Record practice sessions using the device camera. Save and review footage with timestamps for each instruction issued. The Home screen already shows a front-camera preview (`CameraPreviewBox`, built on the `camera` package); recording would add a capture mode on the same controller, at a resolution chosen for recording.

- **Codeberg Mirror and GitHub-free Feedback**

  Mirror the repository on [Codeberg](https://codeberg.org) (non-profit, free-software hosting) and offer a way to send feedback that does not need a GitHub account, such as Codeberg issues or an email address.

- **Reproducible Builds**

  Make release APKs build byte-for-byte the same from the same source. F-Droid can then publish the developer-signed APK (using `Binaries` and `AllowedAPKSigningKeys` in the build recipe), so users can switch between GitHub and F-Droid installs without reinstalling.

- **Device Screenshots of the Home Screen**

  The store screenshots in `fastlane/metadata/android/en-GB/images/phoneScreenshots/` were rendered from the app without a camera. Add screenshots from a real device showing the Home screen with the camera preview and driving simulation.

- **AI-Based Voice Feedback**

  Analyse user responses and give real-time corrective audio feedback (e.g., delayed turns, incorrect steering technique). This would replace the fixed tip shown by the Get Feedback button.

- **Practice Session Tracking**

  Log each session’s start, end, duration, and instruction types followed. Track progress over time with graphs or summaries.

---

## Advanced App Improvement Suggestions

1. **User Experience (UX) & Interaction**

   **Custom Scenario Builder**

   Let users or instructors create custom driving scenarios (e.g., roundabout with 3 exits, 2-way junction with traffic) to tailor practice.

   **Instruction Voice Pack Selector**

   Allow users to pick different voices or languages for spoken instructions (male/female/robotic/friendly tone).

   **Haptic Feedback Support**

   Vibrate the phone for certain instructions (e.g., incorrect manoeuvre or missed instruction).

   **Onboarding Wizard**

   Help users set up their practice environment with step-by-step setup for dinner plate, camera placement, and lighting.

   **Night Mode Visualisation**

   Switch road colours and highlights based on simulated time of day.

2. **Learning Intelligence & Coaching**

   **Mistake Replay**

   Automatically flag and replay segments where mistakes were detected (e.g., wrong direction or hesitation).

   **Skill-Based Unlockable Levels**

   Like a game, unlock new challenges (e.g., parallel parking, reversing) based on previous mastery.

   **Drive Rating System**

   Score a session on multiple axes: smoothness, timing, accuracy of turns, response speed, etc.

   **Coaching Notes Mode**

   Instructors can record voice notes or comments while watching a student’s session replay.

3. **Technical/Platform Features**

   **Voice Command Input**

   Let users respond to instructions via voice for interactive sessions (“Turning left now”).

   **Local DB for Progress & Configs**

   Use sqflite or hive to store offline progress and user settings (the theme preference is already saved with `shared_preferences`).

   **Gesture/Hand Detection with Camera**

   Use TensorFlow Lite or MediaPipe to classify correct push-pull technique in real time.

   **Session Export**

   Export logs or videos with performance summaries to PDF/CSV/video format for review or instructor sharing.

   **Drive Simulator Compatibility**

   Add support for Android-compatible steering hardware for more realistic practice.

4. **Data & Analytics**

   **Heatmaps of Mistakes**

   Visually highlight zones where the user struggles most often (e.g., right turns, roundabouts).

   **Daily Practice Planner**

   Suggest a practice routine each day, like “2 left turns, 1 roundabout, 1 mirror check drill.”

   **Cloud-Based Progress Tracker (Multi-device)**

   Sync driving history across devices or for instructor-managed student profiles.

5. **Security & User Trust**

   **Session Privacy Controls**

   Users can choose whether their recordings are stored, shared, or deleted after each session.

   **Data Consent & GDPR Compliance**

   Clear, user-manageable options for handling video/audio/data.

**Bonus: Monetisation Ideas (for later)**

- Premium features (AI feedback, skill assessments)

- Branded voice packs

- Instructor dashboard subscriptions

- Sponsored tips (from driving schools)
