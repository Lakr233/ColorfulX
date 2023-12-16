# ColorfulX

ColorfulX is an implementation using Metal for crafting multi-colored gradients.

![Screenshot](./Example/Screenshot.png)

## What's New

- 2023.12.16 2.2.0
    - Option to configure noise.
    - Option to configure fps is now removed, we are now syncing refresh rate with system.
    - Animation speed now stabilized.
    - Demo app downgraded. #1

## Platform

UIKit and AppKit platforms are generally supported.

```
platforms: [
    .iOS(.v14),
    .macOS(.v11),
    .macCatalyst(.v14),
    .tvOS(.v14),
    .visionOS(.v1), // supported from 2.1.0
],
```

## Usage

Add this package into your project.

```swift
dependencies: [
    .package(url: "https://github.com/Lakr233/ColorfulX.git", from: "2.2.1"),
]
```

For more detailed information, feel free to explore our example projects. We've provided various presets for your convenience. Each one is identifiable within the demo application. For instance, check out `ColorfulPreset` to find the name, and then use `.constant(preset.colors)` to implement it in `ColorfulView`.

### SwiftUI

For animated colors with default animation, use the following code:

```swift
import ColorfulX

struct ContentView: View {
    // Just use [SwiftUI.Color], available up to 8 slot.
    @State var colors: [Color] = ColorfulPreset.aurora.colors

    var body: some View {
        ColorfulView(color: $colors)
            .ignoresSafeArea()
    }
}
```

Parameters to control the animation are follow:

```
@Binding var colors: [Color]
@Binding var speed: Double
@Binding var noise: Double
@Binding var transitionInterval: TimeInterval

ColorfulView(
    color: $colors,
    speed: $speed,
    noise: $noise,
    transitionInterval: $duration
)
```

For creating a static gradient, **parse `speed: 0` to `ColorfulView`**, or use the following code:

```swift
import ColorfulX

struct StaticView: View {
    var body: some View {
        MulticolorGradient(parameters: .constant(.init(
            points: [
                .init(color: .init(.init(Color.red)), position: .init(x: 0, y: 0)),
                .init(color: .init(.init(Color.blue)), position: .init(x: 1, y: 0)),
                .init(color: .init(.init(Color.green)), position: .init(x: 0, y: 1)),
                .init(color: .init(.init(Color.yellow)), position: .init(x: 1, y: 1)),
            ],
            bias: 0.01,
            power: 4,
            noise: 32
        )))
    }
}
```

### UIKit/AppKit

For animated colors with default animation, use the following code:

```swift
import MetalKit
import ColorfulX

let view = AnimatedMulticolorGradientView()
view.setColors(color, interpolationEnabled: false)
view.speed = speed
view.transitionDuration = transitionDuration
view.noise = noise
```

For creating a static gradient, use the following code:

```swift
import MetalKit
import ColorfulX

let view = MulticolorGradientView()
view.parameters = .init(points: [
    .init(color: .init(r: 1, g: 0, b: 0), position: .init(x: 1, y: 0)),
    .init(color: .init(r: 0, g: 1, b: 0), position: .init(x: 0, y: 0)),
    .init(color: .init(r: 0, g: 0, b: 1), position: .init(x: 0, y: 1)),
    .init(color: .init(r: 1, g: 1, b: 1), position: .init(x: 1, y: 1)),
], bias: 0.01, power: 2, noise: 32)
```

## Performance

There's no feasible way to create these types of gradients without incurring some costs. Yet, by utilizing Metal and GPU, we can attain a performance level that's quite satisfactory. The render process will only take place when draw parameters changed.

After all, the energy impact of this approach is classified as 'Low'.

From my perspective, it would be advisable to implement a single view per application and opt for a static gradient whenever possible, as this could offer a more efficient solution. Just set the `speed` to `0`.

![PerformanceDemo](./Example/Performance.png)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

The shader code originates from [this source](https://github.com/ArthurGuibert/SwiftUI-MulticolorGradient). Consequently, the name of the original author has been credited in the license file.

---

Copyright © 2023 Lakr Aream. All Rights Reserved.
