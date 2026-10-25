/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

enum TrafficLightState { red, yellow, green }

/// Whether the driving simulation is running. It starts stopped, so
/// nothing moves until the user chooses to drive.
enum SimulationState { stopped, running, paused }
