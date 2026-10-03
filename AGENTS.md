# Swift Code Style Guidelines

## Core Style

- **Indentation**: 4 spaces
- **Braces**: Opening brace on same line
- **Spacing**: Single space around operators and commas
- **Naming**: PascalCase for types, camelCase for properties/methods

## File Organization

- Logical directory grouping
- PascalCase files for types, `+` for extensions
- Modular design with extensions

## Modern Swift Features

- **@Observable macro**: Replace `ObservableObject`/`@Published`
- **Swift concurrency**: `async/await`, `Task`, `actor`, `@MainActor`
- **Result builders**: Declarative APIs
- **Property wrappers**: Use line breaks for long declarations
- **Opaque types**: `some` for protocol returns

## Code Structure

- Early returns to reduce nesting
- Guard statements for optional unwrapping
- Single responsibility per type/extension
- Value types over reference types

## Error Handling

- `Result` enum for typed errors
- `throws`/`try` for propagation
- Optional chaining with `guard let`/`if let`
- Typed error definitions

## Architecture

- Avoid using protocol-oriented design unless necessary
- Dependency injection over singletons
- Composition over inheritance
- Factory/Repository patterns

## Debug Assertions

- Use `assert()` for development-time invariant checking
- Use `assertionFailure()` for unreachable code paths
- Assertions removed in release builds for performance
- Precondition checking with `precondition()` for fatal errors

## Memory Management

- `weak` references for cycles
- `unowned` when guaranteed non-nil
- Capture lists in closures
- `deinit` for cleanup

## Overview

ColorfulX is a Metal-backed gradient renderer for Apple platforms that combines LAB color interpolation, spring-based animation, and a configurable compute pipeline to produce vivid multicolor backgrounds. It supports SwiftUI, UIKit, and AppKit with both animated and static gradient rendering.

## Architecture

### Core Components

**Main Classes:**

- `ColorfulView` (Sources/ColorfulX/ColorfulView.swift:11) - SwiftUI wrapper for animated gradients
- `AnimatedMulticolorGradientView` (Sources/ColorfulX/AnimatedMulticolorGradientView.swift:22) - Core animated gradient view with Metal rendering
- `MulticolorGradientView` (Sources/ColorfulX/MulticolorGradientView.swift:17) - Base Metal-backed gradient view
- `MetalLink` (Sources/ColorfulX/MetalLink.swift:15) - Metal rendering abstraction
- `MetalProgram` (Sources/ColorfulX/MetalProgram.swift:14) - Metal shader program management

**Animation System:**

- `SpeckleAnimationDirector` (Sources/ColorfulX/SpeckleAnimationDirector.swift:8) - Abstract animation director protocol
- `SpeckleAnimationRandomDirector` (Sources/ColorfulX/SpeckleAnimationRandomDirector.swift:8) - Default random animation director
- `animationDirector` property in `AnimatedMulticolorGradientView` (Sources/ColorfulX/AnimatedMulticolorGradientView.swift:35) - Immutable animation behavior set at initialization

**Color System:**

- `ColorfulPreset` (Sources/ColorfulX/ColorfulPreset.swift:10) - Built-in color presets
- `ColorfulColors` (Sources/ColorfulX/ColorfulColors.swift:8) - Protocol for custom palettes
- Uses ColorVector dependency for LAB color interpolation

**Platform Support:**

- `MetalView+UIKit.swift` (Sources/ColorfulX/MetalView+UIKit.swift:9) - UIKit extensions
- `MetalView+AppKit.swift` (Sources/ColorfulX/MetalView+AppKit.swift:9) - AppKit extensions
- SwiftUI integration via `ColorfulView` and `MulticolorGradient`

## Build & Development

### Prerequisites

- Swift 6.2+
- Xcode 26+
- Apple platforms: iOS 15+, macOS 12+, macCatalyst 15+, tvOS 15+, visionOS 1+
- Metal support required

### Building

```bash
./Scripts/test.build.sh
```

## Key Parameters

**Animated Views:**

- `speed` - Animation speed factor
- `bias` - Gradient spread control (0.00001-0.01 typical)
- `noise` - Procedural noise amount
- `transitionSpeed` - Color transition speed
- `frameLimit` - FPS cap (0=unlimited)
- `renderScale` - Resolution scaling for performance

**Static Views:**

- `power` - Falloff curve shaping
- `bias` - Gradient spread control

## Development Workflow

1. Make changes to Sources/ColorfulX/
2. Test with Example app (Example/Workspace.xcworkspace)
3. Run `./Scripts/test.build.sh` to verify builds for all platforms
4. Commit changes

## File Organization

```
Sources/ColorfulX/
├── AnimatedMulticolorGradientView*.swift - Animated gradient core
├── ColorfulView.swift - SwiftUI integration
├── ColorfulPreset.swift - Color presets
├── ColorfulColors.swift - Color palette protocol
├── Metal*.swift - Metal rendering
├── MulticolorGradientView*.swift - Static gradients
└── Various extensions and utilities
```

## Performance Tips

- Use lower `frameLimit` or `renderScale` on battery-constrained devices
- Keep colors ≤ 8 to avoid truncation
- Set `speed = 0` for frozen animation instead of static view
- Lower `noise` for better performance
