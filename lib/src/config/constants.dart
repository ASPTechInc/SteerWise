/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

/// App-wide constants. The app version is read at runtime with
/// package_info_plus, so it only needs updating in pubspec.yaml.
class AppConstants {
  static const String appName = 'SteerWise';
  static const String repoUrl = 'https://github.com/ASPTechInc/SteerWise';
  static const String issuesUrl = '$repoUrl/issues/new/choose';

  /// Credit required by the Open Government Licence for the Show Me/Tell Me
  /// questions, which use the DVSA's wording.
  static const String questionsAttribution =
      'Show Me/Tell Me questions: contains public sector information '
      'licensed under the Open Government Licence v3.0.';
  static const String questionsSourceUrl =
      'https://www.gov.uk/government/publications/'
      'car-show-me-tell-me-vehicle-safety-questions';
  static const String oglUrl =
      'https://www.nationalarchives.gov.uk/doc/open-government-licence/'
      'version/3/';

  static const List<String> instructions = [
    'Turn left at the junction',
    'Turn right at the junction',
    'Take the second exit at the roundabout',
    'Pull up on the left in a safe place',
    'Reverse around the corner',
    'Parallel park between the cones',
  ];
}
