package com.asptechinc.steerwise

import android.Manifest
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule
import org.junit.runner.RunWith

/**
 * Runs the Flutter tests in integration_test/ as Android instrumentation
 * tests, one JUnit result per Dart test. Choose the Dart file with
 * -Ptarget, for example:
 *
 *   ./gradlew app:connectedDebugAndroidTest -Ptarget=`pwd`/../integration_test/app_test.dart
 */
@RunWith(FlutterTestRunner::class)
class MainActivityTest {
    @Rule
    @JvmField
    val rule = CameraGrantedActivityTestRule()
}

/**
 * Launches [MainActivity] with camera access already granted, so the
 * system permission prompt cannot pause the app in the middle of a test.
 */
@Suppress("DEPRECATION") // FlutterTestRunner only looks for ActivityTestRule.
class CameraGrantedActivityTestRule :
    ActivityTestRule<MainActivity>(MainActivity::class.java, true, false) {
    override fun beforeActivityLaunched() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        val packageName = instrumentation.targetContext.packageName
        instrumentation.uiAutomation
            .executeShellCommand("pm grant $packageName ${Manifest.permission.CAMERA}")
            .close()
    }
}
