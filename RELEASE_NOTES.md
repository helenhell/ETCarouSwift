# Release title

**ETCarouSwift 2.0.0 — SwiftUI carousel with infinite scroll & rich slides**

---

# Release notes

## ETCarouSwift 2.0.0

SwiftUI carousel with infinite scrolling, optional auto-play, and page indicators. Use it for image-only slides or for rich slides (image + title + description) with configurable layout and card styling.

### Highlights

- **Basic carousel** — Image-only slides with `CarouView(imageSet:configuration:onImageChanged:onImageTapped:)`. Infinite scroll, auto-play (configurable direction and interval), and dot page control.
- **Enriched carousel** — Image + title + description via `CarouItem` and the `items` initializer. Stacked or overlay layout; configurable card appearance (inset, background, border, shadow).
- **Configuration** — `CarouViewConfiguration` with legacy (all-in-one) or composed API: `CarouBehavior` (direction, auto-play, show time, image scale, tap-to-pause), `CarouPageControlAppearance` (dot color/size), and for enriched: `EnrichedCarouLayout` and `EnrichedCarouAppearance`.
- **Callbacks** — `onImageChanged` / `onImageTapped` (basic) and `onItemChanged` / `onItemTapped` (enriched).

### Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Installation

Swift Package Manager only. Add the package dependency:

```
https://github.com/helenhell/ETCarouSwift.git
```

Then add the `ETCarouSwift` library to your target. See the [README](https://github.com/helenhell/ETCarouSwift#readme) for usage and the in-repo demo app to try all configuration options.

### Notes

- This release is source-only (SPM); no binary distribution. CocoaPods support has been removed in favor of SPM.
