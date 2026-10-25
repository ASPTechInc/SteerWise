/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:steer_wise/src/screens/driving_simulator.dart';
import 'package:steer_wise/src/widgets/map_view_painter.dart';

/// While the simulation runs it never settles, so these tests pump frames
/// by hand instead of waiting for it to settle.
Future<void> _drive(WidgetTester tester, double seconds) async {
  for (var t = 0.0; t < seconds; t += 0.05) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pumpSimulation(WidgetTester tester, {bool visible = true}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 280,
            // The bottom navigation mutes the tickers of hidden tabs.
            child: TickerMode(
              enabled: visible,
              child: const DrivingSimulationScreen(),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _tap(WidgetTester tester, String tooltip) async {
  await tester.tap(find.byTooltip(tooltip));
  await tester.pump();
}

Future<void> _start(WidgetTester tester) => _tap(tester, 'Start driving');

bool _enabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;

void main() {
  // The first oncoming car always uses the right lane, so these tests do
  // not depend on the random traffic that follows it.

  group('play, pause and stop', () {
    testWidgets('waits for the user before driving', (tester) async {
      await _pumpSimulation(tester);

      await _drive(tester, 3.5);

      expect(find.text('Tap to start driving'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
      expect(_enabled(tester, 'Steer left'), isFalse);
      expect(_enabled(tester, 'Steer right'), isFalse);
      expect(_enabled(tester, 'Stop'), isFalse);
    });

    testWidgets('the play button starts driving', (tester) async {
      await _pumpSimulation(tester);

      await _start(tester);
      await _drive(tester, 3.5);

      expect(find.text('Tap to start driving'), findsNothing);
      expect(find.byTooltip('Pause'), findsOneWidget);
      expect(_enabled(tester, 'Steer left'), isTrue);
      expect(find.text('Score: 1'), findsOneWidget);
    });

    testWidgets('tapping the road starts driving', (tester) async {
      await _pumpSimulation(tester);

      await tester.tap(find.text('Tap to start driving'));
      await tester.pump();

      expect(find.byTooltip('Pause'), findsOneWidget);
    });

    testWidgets('pausing freezes the game until resumed', (tester) async {
      await _pumpSimulation(tester);
      await _start(tester);
      await _drive(tester, 1);

      await _tap(tester, 'Pause');
      expect(find.text('Paused: tap to resume'), findsOneWidget);
      expect(_enabled(tester, 'Steer right'), isFalse);
      expect(_enabled(tester, 'Stop'), isTrue);

      // Paused for longer than it takes a car to pass: nothing moves.
      await _drive(tester, 5);
      expect(find.text('Score: 0'), findsOneWidget);

      await _tap(tester, 'Resume');
      await _drive(tester, 2.5);
      expect(find.text('Score: 1'), findsOneWidget);
    });

    testWidgets('stopping goes back to the start', (tester) async {
      await _pumpSimulation(tester);
      await _start(tester);
      await _drive(tester, 3.5);
      expect(find.text('Score: 1'), findsOneWidget);

      await _tap(tester, 'Stop');

      expect(find.text('Score: 0'), findsOneWidget);
      expect(find.text('Tap to start driving'), findsOneWidget);
      expect(find.byTooltip('Start driving'), findsOneWidget);
      expect(_enabled(tester, 'Stop'), isFalse);
    });

    testWidgets('pauses when its tab is hidden', (tester) async {
      await _pumpSimulation(tester);
      await _start(tester);

      await _pumpSimulation(tester, visible: false);
      await _pumpSimulation(tester);
      await _drive(tester, 5);

      expect(find.text('Paused: tap to resume'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
    });
  });

  testWidgets('scores a point when an oncoming car passes safely', (
    tester,
  ) async {
    await _pumpSimulation(tester);
    await _start(tester);

    await _drive(tester, 3.5);

    expect(find.text('Score: 1'), findsOneWidget);
    expect(find.text('Collision detected'), findsNothing);
  });

  group('crash', () {
    Future<void> crash(WidgetTester tester) async {
      await _pumpSimulation(tester);
      await _start(tester);
      await _tap(tester, 'Steer right');
      await _drive(tester, 3);
      expect(find.text('Collision detected'), findsOneWidget);
    }

    testWidgets('Retry drives again from the start', (tester) async {
      await crash(tester);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Collision detected'), findsNothing);
      expect(find.byTooltip('Pause'), findsOneWidget);

      // Back in the left lane: the first car passes safely again.
      await _drive(tester, 3.5);
      expect(find.text('Collision detected'), findsNothing);
      expect(find.text('Score: 1'), findsOneWidget);
    });

    testWidgets('Stop waits for the user to drive again', (tester) async {
      await crash(tester);

      await tester.tap(find.text('Stop'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Collision detected'), findsNothing);
      expect(find.text('Tap to start driving'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
    });
  });

  testWidgets('steering back to the left lane avoids the crash', (
    tester,
  ) async {
    await _pumpSimulation(tester);
    await _start(tester);

    await _tap(tester, 'Steer right');
    await _drive(tester, 0.5);
    await _tap(tester, 'Steer left');
    await _drive(tester, 3.5);

    expect(find.text('Collision detected'), findsNothing);
    expect(find.text('Score: 1'), findsOneWidget);
  });

  testWidgets('swiping right steers into the oncoming lane', (tester) async {
    await _pumpSimulation(tester);
    await _start(tester);

    await tester.fling(
      find.byType(DrivingSimulationScreen),
      const Offset(150, 0),
      1000,
    );
    await _drive(tester, 3);

    expect(find.text('Collision detected'), findsOneWidget);
  });

  testWidgets('swiping left keeps the car in its lane', (tester) async {
    await _pumpSimulation(tester);
    await _start(tester);

    await tester.fling(
      find.byType(DrivingSimulationScreen),
      const Offset(-150, 0),
      1000,
    );
    await _drive(tester, 3.5);

    expect(find.text('Collision detected'), findsNothing);
  });

  testWidgets('swiping does nothing until driving starts', (tester) async {
    await _pumpSimulation(tester);

    await tester.fling(
      find.byType(DrivingSimulationScreen),
      const Offset(150, 0),
      1000,
    );
    await _start(tester);
    await _drive(tester, 3);

    expect(find.text('Collision detected'), findsNothing);
  });

  group('mini map', () {
    double zoom(WidgetTester tester) {
      final paint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is MapViewPainter,
        ),
      );
      return (paint.painter! as MapViewPainter).zoom;
    }

    testWidgets('can be shown and hidden', (tester) async {
      await _pumpSimulation(tester);
      expect(find.byTooltip('Zoom in'), findsNothing);

      await tester.tap(find.byTooltip('Show mini map'));
      await tester.pump();
      expect(find.byTooltip('Zoom in'), findsOneWidget);
      expect(find.byTooltip('Hide mini map'), findsOneWidget);

      await tester.tap(find.byTooltip('Hide mini map'));
      await tester.pump();
      expect(find.byTooltip('Zoom in'), findsNothing);
    });

    testWidgets('zooms within its limits', (tester) async {
      await _pumpSimulation(tester);
      await tester.tap(find.byTooltip('Show mini map'));
      await tester.pump();
      expect(zoom(tester), 1.0);

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byTooltip('Zoom in'));
        await tester.pump();
      }
      expect(zoom(tester), 2.0);

      for (var i = 0; i < 10; i++) {
        await tester.tap(find.byTooltip('Zoom out'));
        await tester.pump();
      }
      expect(zoom(tester), 0.6);
    });
  });
}
