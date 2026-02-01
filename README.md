# ETCarouSwift

A user-friendly and developer-friendly carousel framework built with SwiftUI. ETCarouSwift receives a bunch of images and creates a smooth infinite ride inside the given frame. Dragging is also available along with other handy settings. Simple, light and flawless.

## Demo

Click on the screenshot to try an interactive demo by [appetize.io](https://appetize.io)

[<img src="ETCarouSwift_screenshot.jpg" width="288" height="512" />](https://appetize.io/app/an0dku1e08nm2kv7p8984cyqx8?device=iphone8&scale=75&orientation=portrait&osVersion=13.3)


## Requirements

* iOS 16.0+
* Xcode 14.0+ (for iOS 16)
* Swift 5.7+


## Installation

### Swift Package Manager

ETCarouSwift is distributed as a Swift Package. You can add it to your project in two ways:

#### Option 1: Add from GitHub (Recommended)

1. In Xcode, select **File** → **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/helenhell/ETCarouSwift.git`
3. Choose the version or branch you want to use
4. Click **Add Package**
5. Select the `ETCarouSwift` library product
6. Click **Add Package**

#### Option 2: Add Local Package (For Development)

1. In Xcode, select **File** → **Add Package Dependencies...**
2. Click **Add Local...**
3. Navigate to the `ETCarouSwift` directory (the one containing `Package.swift`)
4. Click **Add Package**
5. Select the `ETCarouSwift` library product
6. Click **Add Package**

### Manual Installation

1. Download the ```ETCarouSwift``` repository
2. Copy the ```ETCarouSwift``` folder into your project
3. In Xcode, add the local package as described in Option 2 above



## Usage

### Get started

Import ```ETCarouSwift``` and ```SwiftUI``` in your SwiftUI view:

```Swift
import SwiftUI
import ETCarouSwift
```

Initialize ```CarouView``` with a bunch of images. Set ```rideDirection``` as well if needed. Default is ```.rightToLeft```:

```Swift
struct ContentView: View {
    let images: [UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!,
        UIImage(named: "5")!
    ]
    
    var body: some View {
        CarouView(
            imageSet: images,
            rideDirection: .rightToLeft
        )
        .frame(height: 300)
    }
}
```

### Settings

All settings can be configured during initialization:

1. **AutoRide** is enabled by default. To disable it:
```Swift
CarouView(
    imageSet: images,
    autoRideEnabled: false
)
```

2. **Page indicator dot color & current dot color**:
```Swift
CarouView(
    imageSet: images,
    dotColor: .white,
    currentDotColor: .black
)
```

3. **Dot size**. Default is ```.small```. Options: ```.small```, ```.medium```, ```.large```
```Swift
CarouView(
    imageSet: images,
    dotSize: .medium
)
```

4. **Show time**. Default is 2 seconds. Relevant when autoRide is enabled:
```Swift
CarouView(
    imageSet: images,
    showTime: 3.5
)
```

### Callbacks

Use closures to handle image changes and taps:

```Swift
CarouView(
    imageSet: images,
    onImageChanged: { index in
        print("Image changed to index: \(index)")
        // Do something when image changed
    },
    onImageTapped: { index in
        print("Image tapped at index: \(index)")
        // Do something on image tap
    }
)
```

### Complete Example

```Swift
import SwiftUI
import ETCarouSwift

struct ContentView: View {
    @State private var currentImageIndex: Int = 0
    
    let images: [UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!,
        UIImage(named: "5")!
    ]
    
    var body: some View {
        VStack {
            CarouView(
                imageSet: images,
                rideDirection: .rightToLeft,
                autoRideEnabled: true,
                showTime: 2.0,
                dotColor: .gray,
                currentDotColor: .blue,
                dotSize: .medium,
                onImageChanged: { index in
                    currentImageIndex = index
                },
                onImageTapped: { index in
                    print("Tapped image at index: \(index)")
                }
            )
            .frame(height: 300)
            
            Text("Image #\(currentImageIndex + 1)")
                .font(.headline)
        }
    }
}
```

### Using SwiftUI Images

You can also use SwiftUI's `Image` type directly:

```Swift
let swiftUIImageSet: [Image] = [
    Image("1"),
    Image("2"),
    Image("3")
]

CarouView(imageSet: swiftUIImageSet)
```

### Enriched carousel

For slides with image, title, and description, use `CarouItem` and the items initializer. You can configure layout (stacked vs overlay), text style, and card appearance (inset, border, shadow).

```Swift
import SwiftUI
import ETCarouSwift

let items: [CarouItem] = [
    CarouItem(
        image: Image("photo1"),
        title: "Title",
        description: "Optional description text."
    ),
    CarouItem(image: Image("photo2"), title: "Another", description: nil)
]

CarouView(
    items: items,
    configuration: CarouViewConfiguration(
        behavior: CarouBehavior(autoRideEnabled: false),
        enrichedLayout: EnrichedCarouLayout(
            pageControlPosition: .overlay,
            textPosition: .overlay
        ),
        enrichedAppearance: EnrichedCarouAppearance(
            view: EnrichedCarouViewAppearance(
                cardInset: 16,
                backgroundCornerRadius: 16,
                backgroundShadow: CarouShadow.default
            )
        )
    ),
    onItemChanged: { index in },
    onItemTapped: { index in }
)
.frame(height: 360)
```

Use `CarouViewConfiguration` with `enrichedLayout` and `enrichedAppearance` for text position (stacked/overlay), page control position, and card style (inset, borders, shadow).

## Author

**Elena Slovushch**
* [@XPlace](https://www.xplace.com/il/en/u/paralel?omloc=us_en)
* [@LinkedIn](https://www.linkedin.com/in/elena-slovushch/)
* [@StackOverFlow](https://stackoverflow.com/users/4506863/elena?tab=profile)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
