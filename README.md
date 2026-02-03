# ETCarouSwift

A SwiftUI carousel with infinite scrolling, optional auto-play, and page indicators. Use it for image-only slides or for rich slides (image plus title and description) with configurable layout and card styling.

## Requirements

* iOS 17.0+
* Xcode 15.0+
* Swift 5.9+

## Installation

Add ETCarouSwift via Swift Package Manager:

1. In Xcode, choose **File** → **Add Package Dependencies...**
2. Enter: `https://github.com/helenhell/ETCarouSwift.git`
3. Pick the version or branch you need, then **Add Package**
4. Add the `ETCarouSwift` library to your target

To try all configuration options (basic and enriched carousel, layouts, appearance), run the demo app included in this repository.

## Usage

### Import

```swift
import SwiftUI
import ETCarouSwift
```

### Basic carousel (images only)

Provide an array of SwiftUI `Image` and an optional `CarouViewConfiguration`. Defaults: auto-play on, direction right-to-left, 2s show time.

```swift
struct ContentView: View {
    let images: [Image] = [
        Image("1"),
        Image("2"),
        Image("3")
    ]

    var body: some View {
        CarouView(
            imageSet: images,
            configuration: CarouViewConfiguration(),
            onImageChanged: { index in },
            onImageTapped: { index in }
        )
        .frame(height: 300)
    }
}
```

### Configuration (basic carousel)

Use `CarouViewConfiguration` to control behavior and page control. You can use the legacy initializer or the composed one.

**Legacy (all in one):**

```swift
let config = CarouViewConfiguration(
    rideDirection: .rightToLeft,
    autoRideEnabled: true,
    showTime: 2.0,
    dotColor: .white,
    currentDotColor: .black,
    dotSize: .medium,
    imageScale: .fill
)

CarouView(imageSet: images, configuration: config)
```

**Composed (behavior + page control):**

```swift
let behavior = CarouBehavior(
    rideDirection: .rightToLeft,
    autoRideEnabled: false,
    showTime: 3.0,
    imageScale: .fit
)
let pageControl = CarouPageControlAppearance(
    dotColor: .gray,
    currentDotColor: .blue,
    dotSize: .large
)
let config = CarouViewConfiguration(
    behavior: behavior,
    pageControlAppearance: pageControl
)

CarouView(imageSet: images, configuration: config)
```

**Configuration options:**

| Area | Options |
|------|--------|
| **CarouBehavior** | `rideDirection` (`.leftToRight` / `.rightToLeft`), `autoRideEnabled`, `tapPausesAutoRide`, `showTime`, `imageScale` (`.fill` / `.fit`) |
| **CarouPageControlAppearance** | `dotColor`, `currentDotColor`, `dotSize` (`.small` / `.medium` / `.large`) |

### Callbacks

- **Basic:** `onImageChanged: (Int) -> Void` — current page index when the slide changes  
- **Basic:** `onImageTapped: (Int) -> Void` — index when the user taps a slide  
- **Enriched:** `onItemChanged` and `onItemTapped` — same idea for item index  

When `autoRideEnabled` and `tapPausesAutoRide` are both true, tapping the carousel pauses auto-advance so the user can view a slide longer; tap again to resume.

```swift
@State private var currentIndex: Int = 0

CarouView(
    imageSet: images,
    onImageChanged: { index in currentIndex = index },
    onImageTapped: { index in print("Tapped \(index)") }
)
```

### Enriched carousel (image + title + description)

Use `CarouItem` for each slide and the `items` initializer. Configure layout (stacked vs overlay) and appearance (card inset, background color, borders, shadow) via `CarouViewConfiguration`.

```swift
let items: [CarouItem] = [
    CarouItem(
        image: Image("photo1"),
        title: "Title",
        description: "Optional description."
    ),
    CarouItem(image: Image("photo2"), title: "Another", description: nil)
]

CarouView(
    items: items,
    configuration: CarouViewConfiguration(),
    onItemChanged: { index in },
    onItemTapped: { index in }
)
.frame(height: 360)
```

**Custom layout and appearance:**

- **EnrichedCarouLayout:** `pageControlPosition` (`.stacked` or `.overlay`), `textPosition` (`.stacked` or `.overlay`)
- **EnrichedCarouAppearance:** combines `CarouPageControlAppearance` and `EnrichedCarouViewAppearance` (text colors/fonts, card inset, background color, borders, corner radius, shadow)
- **Card configs** (card inset, background color, background border, corner radius, shadow) apply only to stacked layout. When both `pageControlPosition` and `textPosition` are `.overlay`, card configs are ignored for a full-bleed image look.

```swift
// Overlay layout: full-bleed image with text overlaid; card configs not applied
let behavior = CarouBehavior(autoRideEnabled: false)
let layout = EnrichedCarouLayout(
    pageControlPosition: .overlay,
    textPosition: .overlay
)
let viewAppearance = EnrichedCarouViewAppearance(
    textAlignment: .center,
    titleColor: .white,
    descriptionColor: .white.opacity(0.9)
)
let enrichedAppearance = EnrichedCarouAppearance(view: viewAppearance)

let config = CarouViewConfiguration(
    behavior: behavior,
    enrichedLayout: layout,
    enrichedAppearance: enrichedAppearance
)

CarouView(items: items, configuration: config, onItemChanged: { _ in }, onItemTapped: { _ in })
    .frame(height: 360)
```

```swift
// Stacked layout: card configs apply (inset, border, corner radius, shadow)
let layout = EnrichedCarouLayout(pageControlPosition: .stacked, textPosition: .stacked)
let viewAppearance = EnrichedCarouViewAppearance(
    cardInset: 16,
    backgroundCornerRadius: 16,
    backgroundShadow: .default
)
let config = CarouViewConfiguration(
    enrichedLayout: layout,
    enrichedAppearance: EnrichedCarouAppearance(view: viewAppearance)
)
CarouView(items: items, configuration: config, onItemChanged: { _ in }, onItemTapped: { _ in })
    .frame(height: 360)
```

### Complete example (basic + current index)

```swift
struct ContentView: View {
    @State private var currentIndex: Int = 0

    let images: [Image] = [Image("1"), Image("2"), Image("3")]

    var body: some View {
        VStack {
            CarouView(
                imageSet: images,
                configuration: CarouViewConfiguration(
                    rideDirection: .rightToLeft,
                    autoRideEnabled: true,
                    showTime: 2.0,
                    dotColor: .gray,
                    currentDotColor: .blue,
                    dotSize: .medium
                ),
                onImageChanged: { index in currentIndex = index },
                onImageTapped: { index in print("Tapped \(index)") }
            )
            .frame(height: 300)

            Text("Slide \(currentIndex + 1) of \(images.count)")
                .font(.headline)
        }
    }
}
```

## Author

**Elena Slovushch**
* [@XPlace](https://www.xplace.com/il/en/u/paralel?omloc=us_en)
* [@LinkedIn](https://www.linkedin.com/in/elena-slovushch/)
* [@StackOverFlow](https://stackoverflow.com/users/4506863/elena?tab=profile)

## License

This project is licensed under the MIT License — see the [LICENSE.md](LICENSE.md) file for details.
