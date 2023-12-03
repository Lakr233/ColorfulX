# ColorfulX

ColorfulX is an implementation using Metal for crafting multi-colored gradients.

![Screenshot](./Example/Screenshot.png)

## Platform

UIKit and AppKit platforms are generally supported. Due to `MTKView` not available on visionOS, it's not supported.

```
platforms: [
    .iOS(.v14),
    .macOS(.v14),
    .macCatalyst(.v14),
    .tvOS(.v15),
]
```

## Usage

Add this package into your project.

```swift
dependencies: [
    .package(url: "https://github.com/Lakr233/ColorfulX")
]
```

Generally, you can always have a look at example project for more details. We have included a range of presets for you to use. You can identify each in the demo app. See `ColorfulPreset` for name, and pass `.constant(preset.colors)` into `ColorfulView`.

### SwiftUI

For animated colors with default animation, use the following code:

```swift
import ColorfulX

let defaultPreset: ColorfulPreset = .aurora

struct ContentView: View {
    @State var colors: [Color] = defaultPreset.colors

    var body: some View {
        ColorfulView(colors: $colors)
    }
}
```

For creating a static gradient, use the following code:

```swift
import ColorfulX

struct StaticView: View {
    var body: some View {
        MulticolorGradient(
            parameters: .constant(.init(
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

let view = AnimatedMulticolorGradientView(fps: fps)
view.setColors(colors, interpolationEnabled: false)
view.setSpeedFactor(speedFactor)
view.setColorTransitionDuration(colorTransitionDuration)
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

The shader code is from [here](https://github.com/ArthurGuibert/SwiftUI-MulticolorGradient), thus the name of original author was added to license file.

---

Copyright © 2023 Lakr Aream. All Rights Reserved.
