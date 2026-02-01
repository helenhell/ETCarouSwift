# Enriched Carousel Feature - Implementation Plan

## Overview
Add support for enriched carousel items (image + title + description) while maintaining backward compatibility with the existing simple image-only carousel.

## Architecture Design

### 1. Data Model ~~(Implemented)~~

#### New Type: `CarouItem`
```swift
public struct CarouItem {
    public let image: Image
    public let title: String?
    public let description: String?
    
    public init(image: Image, title: String? = nil, description: String? = nil) {
        self.image = image
        self.title = title
        self.description = description
    }
}
```

**Alternative consideration:** Could also support `UIImage` variant for UIKit compatibility.

### 2. View Hierarchy ~~(Implemented)~~

```
CarouView (Public API)
├── SimpleCarouView (Internal - for images only)
└── EnrichedCarouView (Internal - for CarouItems)
```

**Naming alternatives:**
- `ImageCarouView` / `RichCarouView`
- `BasicCarouView` / `EnrichedCarouView` ✅ (Recommended)
- `SimpleCarouView` / `ContentCarouView`

### 3. Public API Changes ~~(Implemented)~~

#### `CarouView` - Dual Initializers

**Option A: Two separate initializers (Recommended)**
```swift
public struct CarouView: View {
    // Existing init for images (backward compatible)
    public init(
        imageSet: [Image],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    )
    
    // New init for enriched items
    public init(
        items: [CarouItem],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onItemChanged: ((Int) -> Void)? = nil,
        onItemTapped: ((Int) -> Void)? = nil
    )
    
    // UIKit convenience init (existing)
    public init(
        imageSet: [UIImage],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    )
}
```

**Option B: Single initializer with protocol**
- More complex, less clear API
- Not recommended

### 4. Internal Implementation Structure ~~(Implemented)~~

#### Shared Logic Extraction

**New File: `CarouViewCore.swift` (Internal)**
- Extract common carousel logic:
  - Scroll offset management
  - Drag gesture handling
  - Auto-ride timer logic
  - Page calculation (logical index mapping)
  - Wraparound logic
- Could be a protocol or a base view component

**Option 1: Protocol-based approach**
```swift
protocol CarouViewCore {
    var scrollOffset: CGFloat { get set }
    var dragOffset: CGFloat { get set }
    // ... shared state
    func handleDrag(...)
    func startAutoRide(...)
    // ... shared methods
}
```

**Option 2: ViewBuilder-based approach**
```swift
struct CarouViewCore<Content: View>: View {
    let items: [Content]
    let configuration: CarouViewConfiguration
    // ... shared implementation
}
```

**Option 3: Composition approach (Recommended)**
- Keep logic in separate internal views
- `SimpleCarouView` and `EnrichedCarouView` share common helpers
- Less abstraction, more maintainable

### 5. File Structure ~~(Implemented)~~

```
ETCarouSwift/
├── CarouView.swift (Public API - facade)
├── CarouViewConfiguration.swift (Existing)
├── CarouImageScaleModifier.swift (Existing)
├── CarouItem.swift (New - data model)
├── SimpleCarouView.swift (New - internal, image-only implementation)
├── EnrichedCarouView.swift (New - internal, enriched items implementation)
└── CarouViewHelpers.swift (New - shared utilities)
```

### 6. Enriched View Layout ~~(Partially implemented — stacked only)~~

#### Design Considerations for `EnrichedCarouView`:

**Layout Options:**

**Option A: Overlay (Title/Description over image)**
```
┌─────────────────┐
│                 │
│     Image       │
│                 │
│  ┌───────────┐  │
│  │  Title    │  │
│  │ Description│ │
│  └───────────┘  │
└─────────────────┘
```

**Option B: Stack (Image + Title + Description)**
```
┌─────────────────┐
│     Image       │
├─────────────────┤
│     Title       │
├─────────────────┤
│   Description   │
└─────────────────┘
```

**Option C: Configurable (via configuration)**
- Add `CarouEnrichedLayout` enum to `CarouViewConfiguration`
- Default: Overlay (more visually appealing)

**Recommended:** Option A (Overlay) with optional configuration for customization.

#### Styling Considerations:
- Title/Description text colors (default: white with shadow/background)
- Title/Description font sizes
- Title/Description positioning (top, bottom, center)
- Background gradient/overlay for text readability

### 7. Configuration Extensions

#### `CarouViewConfiguration` Additions:
```swift
public struct CarouViewConfiguration {
    // ... existing properties
    
    // New properties for enriched view
    public let enrichedLayout: CarouEnrichedLayout
    public let titleFont: Font?
    public let descriptionFont: Font?
    public let titleColor: Color
    public let descriptionColor: Color
    public let textOverlayStyle: CarouTextOverlayStyle
}

public enum CarouEnrichedLayout {
    case overlay  // Text over image
    case stacked  // Image + Title + Description stacked
}

public enum CarouTextOverlayStyle {
    case none
    case gradient  // Gradient background for text
    case solid     // Solid background for text
    case shadow    // Text shadow only
}
```

**Alternative:** Keep configuration minimal, use sensible defaults, add customization later if needed.

### 8. Implementation Steps ~~(Phase 1 complete)~~

1. ~~**Create `CarouItem.swift`**~~
   - Define the data model
   - Add UIKit convenience initializer if needed

2. ~~**Extract shared helpers**~~ (logic inlined in views)
   - Create `CarouViewHelpers.swift` with:
     - `logicalIndex(for:count:direction:)`
     - `imageForPage(_:count:direction:)` (or generic version)
     - Auto-ride logic helpers
     - Drag gesture calculation helpers

3. ~~**Create `SimpleCarouView.swift`**~~
   - Move existing `CarouView` body logic here
   - Keep it internal
   - Accept `[Image]` and configuration

4. ~~**Create `EnrichedCarouView.swift`**~~
   - Similar structure to `SimpleCarouView`
   - Accept `[CarouItem]` and configuration
   - Render image + title + description
   - Reuse shared helpers

5. ~~**Refactor `CarouView.swift`**~~
   - Make it a facade/view router
   - Two initializers that create appropriate internal view
   - Maintain backward compatibility

6. **Update `CarouViewConfiguration.swift`**
   - Add enriched view configuration options (see Phase 2 plan below)

7. ~~**Update demo app**~~ (basic enriched example present)
   - Add example of enriched carousel usage

### 9. Backward Compatibility

✅ **Guaranteed:**
- All existing `CarouView` initializers remain unchanged
- Existing API contracts preserved
- No breaking changes

### 10. Testing Considerations

- Test both simple and enriched carousels
- Test with single item, multiple items
- Test auto-ride, manual swipe
- Test with nil title/description
- Test configuration options

### 11. Open Questions / Decisions Needed

1. **Naming:**
   - `SimpleCarouView` vs `ImageCarouView` vs `BasicCarouView`?
   - `EnrichedCarouView` vs `RichCarouView` vs `ContentCarouView`?

2. **Layout:**
   - Default to overlay or stacked layout?
   - How much customization in v1?

3. **Configuration:**
   - Add all styling options now, or start minimal and extend later?

4. **UIKit Support:**
   - Should `CarouItem` support `UIImage` directly, or require conversion?

5. **Delegate Pattern:**
   - Current code uses closures (`onImageChanged`, `onImageTapped`)
   - For enriched: `onItemChanged`, `onItemTapped` (consistent naming)
   - Keep closure-based or consider delegate protocol?

## Recommended Approach

**Phase 1 (MVP):**
- Create `CarouItem` with image, optional title, optional description
- Create `SimpleCarouView` (internal) - move existing logic
- Create `EnrichedCarouView` (internal) - overlay layout, minimal styling
- Refactor `CarouView` as facade with two initializers
- Default overlay layout with white text, shadow for readability

**Phase 2 (Future enhancements):**
- ~~Add layout options (stacked vs overlay)~~ — see Enriched Customization Plan below
- Add more styling customization — see Enriched Customization Plan below
- Add UIKit convenience initializers for `CarouItem`

---

## Phase 2: Enriched View Customization Plan

### Configuration Architecture: Behavior, Layout, Appearance

**Three-way split with shared components.**

| Config | Scope | Contents |
|--------|-------|----------|
| **Behavior** | Both Basic & Enriched | Common params only: rideDirection, autoRideEnabled, showTime, imageScale |
| **PageControl Appearance** | Both Basic & Enriched | dotColor, currentDotColor, dotSize — shared component |
| **Layout** | Enriched only | Where elements go: PageControl overlay/stacked, text overlay/stacked |
| **Enriched Appearance** | Enriched only | Internally: PageControl appearance (reuses shared) + View appearance (text, image frame, background) |

**Config flow by presentation mode:**

| Mode | Receives |
|------|----------|
| **Basic** | `behavior` + `pageControlAppearance` |
| **Enriched** | `behavior` + `layout` + `appearance` |

Enriched `appearance` under-the-hood separates to:
- PageControl appearance (uses shared `CarouPageControlAppearance`)
- View appearance (text styling, image frame, background frame, card insets)

---

### 1. PageControl — Overlay or Stacked

| Option | Description |
|--------|-------------|
| `.stacked` | PageControl below image, above title (current behavior) |
| `.overlay` | PageControl overlaid on image (e.g. bottom center) |

**Config:** `EnrichedCarouLayout.pageControlPosition: .stacked | .overlay`

---

### 1b. PageControl — Overflow Handling

When the image set is large, dots may exceed screen width. Handle with **threshold-based mode switch**.

**Default behavior (implement now):**
- **Small / Medium dot size:** if `n > 15`, switch to text mode ("3 / 50")
- **Large dot size:** if `n > 10`, switch to text mode
- Text is **center-aligned** in both Basic and Enriched views
- In Enriched view, text uses title/description font at description size

**Future config options (implement later):**

```swift
public enum PageControlOverflowMode {
    case dots           // Always show dots (may overflow)
    case textAuto       // Default: auto-switch to "3 / 50" above threshold
}

public enum PageControlTextAlignment {
    case center                 // Default
    case followTextAlignment    // Use title/description alignment (enriched only)
}
```

Add to `CarouPageControlAppearance`:
- `overflowMode: PageControlOverflowMode` (default `.textAuto`)
- `textAlignment: PageControlTextAlignment` (default `.center`)

---

### 2. Title & Description — Overlay or Stacked; Alignment; Foreground Color; Font

| Customization | Config | Notes |
|---------------|--------|-------|
| **Position** | `EnrichedCarouLayout.textPosition: .overlay \| .stacked` | Overlay = over image (with gradient/shadow for readability); Stacked = below image |
| **Alignment** | `EnrichedCarouViewAppearance.textAlignment` | `.leading`, `.center`, `.trailing` |
| **Foreground color** | `EnrichedCarouViewAppearance.titleColor`, `descriptionColor` | `Color` |
| **Font** | Custom font with bundle fallback | See Font Helper below |

**Font helper (bundle + system fallback):**
- Add `CarouFontHelper` or extension: `Font.custom(name: String, size: CGFloat, bundle: Bundle?)`
- If custom font loads from bundle → use it; else fallback to system font (e.g. `.system(size: fontSize, weight:)`)
- Consumer passes bundle (e.g. `Bundle.main` or `Bundle.module` for SPM) and font name
- Config: `EnrichedCarouViewAppearance.titleFontName`, `titleFontSize`, `titleFontBundle`; same for description

---

### 3. Image Background — Card-like Appearance

Support inset background around image to create a “card”:
- **Top / Leading / Trailing insets** — configurable width (points or % of view)
- **Bottom inset** — derived from content: only as tall as title & description when stacked; or fixed when overlay

**Config:** `EnrichedCarouViewAppearance.imageBackgroundInset`; `bottomInsetFollowsContent: Bool`

---

### 4. Image Frame — Width, Color

Border around the image itself (inside the background):
- **Width** — `CGFloat` (stroke width)
- **Color** — `Color`

**Config:** `EnrichedCarouViewAppearance.imageFrameWidth`, `imageFrameColor`

---

### 5. Background Frame — Width, Color, Rounded Corners, Shadow

The outer “card” background:
- **Width** — border stroke width
- **Color** — border color
- **Corner radius** — `CGFloat`
- **Shadow** — color, radius, x, y offset (or use SwiftUI `ShadowStyle`-like parameters)

**Config:** `EnrichedCarouViewAppearance.backgroundFrameWidth`, `backgroundFrameColor`, `backgroundCornerRadius`, `backgroundShadow`

---

### Summary: Config Types

```swift
// ─── Shared: Both Basic & Enriched ────────────────────────────────────────

/// Common carousel behavior (ride direction, auto-ride, show time, image scale).
public struct CarouBehavior {
    public let rideDirection: CarouDirection
    public let autoRideEnabled: Bool
    public let showTime: Double
    public let imageScale: CarouImageScale
}

/// PageControl dots styling — shared by Basic and Enriched.
public struct CarouPageControlAppearance {
    public let dotColor: Color
    public let currentDotColor: Color
    public let dotSize: CarouDotSize
    // Future: overflowMode, textAlignment (see 1b. PageControl — Overflow Handling)
}

// ─── Enriched only ─────────────────────────────────────────────────────────

/// Where elements are placed (overlay vs stacked).
public struct EnrichedCarouLayout {
    public let pageControlPosition: PageControlPosition   // .stacked | .overlay
    public let textPosition: TextPosition                // .overlay | .stacked
}

/// Enriched view appearance. Internally: pageControl + view appearance.
public struct EnrichedCarouAppearance {
    public let pageControl: CarouPageControlAppearance   // Reuses shared
    public let view: EnrichedCarouViewAppearance         // Enriched-specific
}

/// Enriched-specific visual styling (text, image frame, background).
public struct EnrichedCarouViewAppearance {
    // Text
    public let textAlignment: TextAlignment
    public let titleColor: Color
    public let descriptionColor: Color
    public let titleFontName: String?
    public let titleFontSize: CGFloat
    public let titleFontBundle: Bundle?
    public let descriptionFontName: String?
    public let descriptionFontSize: CGFloat
    public let descriptionFontBundle: Bundle?
    
    // Card
    public let cardInset: CGFloat
    public let imageFrameWidth: CGFloat
    public let imageFrameColor: Color
    
    // Background
    public let backgroundFrameWidth: CGFloat
    public let backgroundFrameColor: Color
    public let backgroundCornerRadius: CGFloat
    public let backgroundShadow: CarouShadow?
}

// Helper (e.g. in CarouViewHelpers.swift or new CarouFontHelper.swift)
public enum CarouFontHelper {
    public static func font(name: String, size: CGFloat, bundle: Bundle?, fallback: Font) -> Font
}
```

**Integration:** Refactor `CarouViewConfiguration` to compose these types. Basic init uses `behavior` + `pageControlAppearance`. Enriched init uses `behavior` + `layout` + `appearance` (where `appearance.pageControl` is the shared dots config).

---

### Implementation Order ~~(Completed)~~

1. ~~Extract `CarouBehavior` and `CarouPageControlAppearance` from existing config; migrate Basic to use them~~
2. ~~**PageControl overflow: implement default threshold-based text mode** (small/medium > 15, large > 10; center-aligned)~~
3. ~~Add `CarouFontHelper` / bundle font helper~~
4. ~~Add `EnrichedCarouLayout` and `EnrichedCarouAppearance` (+ `EnrichedCarouViewAppearance`)~~
5. ~~Wire Enriched to receive `behavior` + `layout` + `appearance`~~
6. ~~PageControl position (overlay vs stacked)~~
7. ~~Text position (overlay vs stacked)~~
8. ~~Text styling (alignment, colors, fonts)~~
9. ~~Image background insets (card-like)~~
10. ~~Image frame (width, color)~~
11. ~~Background frame (width, color, corners, shadow)~~

**Future (config options):**
- PageControl overflow mode config (`overflowMode`, `textAlignment`)

## File Changes Summary

**New Files (Phase 1 — done):**
- ~~`CarouItem.swift`~~ - Data model
- ~~`BasicCarouView.swift`~~ - Internal image-only view
- ~~`EnrichedCarouView.swift`~~ - Internal enriched view

**New Files (Phase 2 — done):**
- ~~`CarouFontHelper.swift`~~ - Bundle font with system fallback
- ~~Config types in `CarouViewConfiguration.swift`: `CarouBehavior`, `CarouPageControlAppearance`, `EnrichedCarouLayout`, `EnrichedCarouAppearance`, `EnrichedCarouViewAppearance`, `CarouShadow`~~

**Modified Files (Phase 2 — done):**
- ~~`CarouViewConfiguration.swift`~~ - Refactored to compose behavior + pageControlAppearance; added layout + appearance for enriched
- ~~`BasicCarouView.swift`~~ - Uses dotSize for page control overflow
- ~~`EnrichedCarouView.swift`~~ - Full layout/appearance support (overlay/stacked, card styling)
- ~~`CarouPageControl.swift`~~ - Added threshold-based text mode for overflow

**No Breaking Changes:**
- Legacy `CarouViewConfiguration` init preserved — creates new structure with defaults
