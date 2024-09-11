# ColorfulX

ColorfulX is a high-performance library designed for creating vibrant, animated mesh like gradient views. It offers powerful functionality and preset options as an enhanced alternative to SwiftUI’s MeshGradientView.

🥳 LAB color models are now used, enabling smooth animated transitions and seamless color interpolation.

![Screenshot](./Example/Screenshot.png)

## Platform

UIKit and AppKit platforms are generally supported.

```
platforms: [
    .iOS(.v14),
    .macOS(.v11),
    .macCatalyst(.v14),
    .tvOS(.v14),
    .visionOS(.v1),
],
```

## Usage

Add this package into your project.

```swift
dependencies: [
    .package(url: "https://github.com/Lakr233/ColorfulX.git", from: "5.5.1"),
]
```

For more detailed information, feel free to explore our example projects. We've provided various presets for your convenience. Each one is identifiable within the demo application. For instance, check out `ColorfulPreset` to find the name, and then use `.constant(preset.colors)` to load it in `ColorfulView`.

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
@Binding var transitionSpeed: Double

ColorfulView(
    color: $colors,
    speed: $speed,
    bias: $bias,
    noise: $noise,
    transitionSpeed: $transitionSpeed
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
view.setColors(color, animated: false)
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

### Customized Preset

Starting from ColorfulX 5.5.0, we offer a new way to define presets. See the following example:

```swift
enum MyPresets: ColorfulColors {
    case white

    var colors: [ColorElement] {
        [
            make(255, 255, 255),
            make(244, 244, 244),
            make(233, 233, 233),
            make(222, 222, 222),
        ]
    }
}

// SwiftUI
ColorfulView(color: MyPresets.white)

// UIKit or AppKit
let view = AnimatedMulticolorGradientView()
view.setColors(MyPresets.white)
```

## Performance

The performance of ColorfulX is truly outstanding! Developers are reportedly incorporating ColorfulX into their applications, and we have received no complaints regarding performance issues. It functions seamlessly even within UITableViewCell and UICollectionViewCell.

Additionally, we have developed a [dynamic wallpaper tweak](https://havoc.app/package/colorfulx) for jailbroken users and have rigorously tested our power-saving mechanism. You can rest assured that there is no battery drain, no overheating, and absolutely no degradation in performance.

We take great pride in this accomplishment.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

The shader code originates from [this source](https://github.com/ArthurGuibert/SwiftUI-MulticolorGradient). Consequently, the name of the original author has been credited in the license file.

---

Copyright © 2024 Lakr Aream. All Rights Reserved.
