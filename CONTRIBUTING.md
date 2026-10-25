# Contributing to SteerWise

Thanks for your interest in contributing to **SteerWise**!
SteerWise is a free and open-source (FOSS) driving practice app for learner drivers and
contributions of all sizes are welcome, from fixing a typo in a Show Me/Tell Me answer to
building a new practice mode.

---

## How to Contribute

1. **Fork the repository** to your own GitHub account.
2. **Clone your fork** to your local machine.
3. **Create a new branch** for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes**, following the code style below.
5. **Run the tests** and check they still pass.
6. **Commit your changes** with messages that say what changed and why.
7. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
8. **Create a pull request** from your fork's branch to the `main` branch of the original repository.

See [project setup](docs/md/project-setup.md) for installing Flutter and running the app locally.

---

## Technical Stack

SteerWise is a cross-platform Flutter app:

- **Language**: [Dart](https://dart.dev/)
- **Framework**: [Flutter SDK](https://flutter.dev/)
- **State management**: [provider](https://pub.dev/packages/provider) (theme and services) and
  `setState` (screens)
- **Driving simulation**: rules in `lib/src/simulation/driving_game.dart` (plain Dart, unit tested),
  drawn by the painters in `lib/src/widgets/`
- **Voice instructions**: [flutter_tts](https://pub.dev/packages/flutter_tts), shared through
  `lib/src/services/tts_service.dart`
- **Camera preview**: [camera](https://pub.dev/packages/camera) with
  [permission_handler](https://pub.dev/packages/permission_handler), in
  `lib/src/widgets/camera_preview_box.dart` (front camera, low resolution, audio off)
- **Preferences**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Show Me/Tell Me question bank**: `assets/data/show_me_tell_me_questions.json`

The [architecture overview](docs/md/architecture.md) describes how the project is organised.

---

## Code Style

- **Formatting**: Run `dart format .` (or `make format`) before committing changes.
- **Imports**: Use package imports (`package:steer_wise/...`). Run `dart run import_sorter:main` to
  sort them.
- **Linting**: `flutter analyze` (or `make analyse`) should report no issues. The lint rules are in
  [analysis_options.yaml](analysis_options.yaml).
- **File headers**: New Dart and Markdown files should carry the project header. Add it with
  `./scripts/scaffold.sh dart path/to/file.dart` or `./scripts/scaffold.sh md path/to/file.md`.
- **Spelling**: User-facing text and documentation use British English (e.g. "colour",
  "practise", "manoeuvre"), as the app follows the UK driving test.
- **Scope**: Keep each pull request to one feature or bug fix.

---

## Updating the Show Me/Tell Me questions

The questions live in `assets/data/show_me_tell_me_questions.json`. Each entry has:

```json
{
  "type": "tell",
  "question": "Tell me how you'd check that the brakes are working before starting a journey.",
  "answer": "Brakes should not feel spongy or slack..."
}
```

- `type` must be `show` or `tell`.
- `tell` questions need an `answer`. `show` questions are demonstrated while driving, so their
  `answer` can be left empty.
- Please keep the wording in line with the official
  [DVSA car show me tell me questions](https://www.gov.uk/government/publications/car-show-me-tell-me-vehicle-safety-questions).

---

## Testing

Please add or update tests when you change app logic, such as the theme settings, the question bank
or the driving simulation. Keep logic in plain Dart classes (like `DrivingGame` and
`filterQuestions`) where possible, so it can be tested without building widgets.

Unit and widget tests live in `test/`; `test/support/test_app.dart` fakes the camera, speech and
links so screens can be tested without a device. End-to-end tests of the real app live in
`integration_test/`.

### Run the test suite

```bash
flutter test                      # unit and widget tests
flutter test integration_test     # on a connected device or emulator
make android-test                 # integration tests as Android instrumentation tests
```

---

## Reporting Issues

If you find a bug or have a feature request, please
[open an issue](https://github.com/ASPTechInc/SteerWise/issues).

Please report security vulnerabilities privately, as described in [SECURITY.md](SECURITY.md).

By taking part in this project you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
