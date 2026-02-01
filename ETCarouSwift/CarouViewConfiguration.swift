//
//  CarouViewConfiguration.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

// MARK: - Enums

public enum CarouDirection {
    case leftToRight, rightToLeft
}

/// How the carousel image is scaled within its frame.
public enum CarouImageScale {
    /// Scale to fill the frame; aspect ratio preserved, content may be clipped.
    case fill
    /// Scale to fit inside the frame; aspect ratio preserved, may show letterboxing.
    case fit
}

/// Dot size expressed as a fraction of the carousel view width. Kept as an enum to restrict to valid options.
public enum CarouDotSize: CGFloat {
    case small = 0.02   // 2% of view width
    case medium = 0.03  // 3% of view width
    case large = 0.04   // 4% of view width
    
    /// Absolute dot diameter in points, used when view width is not available.
    public var absoluteSize: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }
    
    /// Threshold for switching to text mode when page count exceeds this value.
    public var overflowThreshold: Int {
        switch self {
        case .small, .medium: return 15
        case .large: return 10
        }
    }
}

// MARK: - Shared Config: Behavior

/// Common carousel behavior — shared by Basic and Enriched views.
public struct CarouBehavior {
    public let rideDirection: CarouDirection
    public let autoRideEnabled: Bool
    public let showTime: Double
    public let imageScale: CarouImageScale
    
    public init(
        rideDirection: CarouDirection = .rightToLeft,
        autoRideEnabled: Bool = true,
        showTime: Double = 2.0,
        imageScale: CarouImageScale = .fill
    ) {
        self.rideDirection = rideDirection
        self.autoRideEnabled = autoRideEnabled
        self.showTime = showTime
        self.imageScale = imageScale
    }
    
    /// Default behavior configuration.
    public static let `default` = CarouBehavior()
}

// MARK: - Shared Config: PageControl Appearance

/// PageControl dots styling — shared by Basic and Enriched views.
public struct CarouPageControlAppearance {
    public let dotColor: Color
    public let currentDotColor: Color
    public let dotSize: CarouDotSize
    
    public init(
        dotColor: Color = .white,
        currentDotColor: Color = .black,
        dotSize: CarouDotSize = .small
    ) {
        self.dotColor = dotColor
        self.currentDotColor = currentDotColor
        self.dotSize = dotSize
    }
    
    /// Default page control appearance.
    public static let `default` = CarouPageControlAppearance()
    
    /// Dot size in points: relative to view width when provided, otherwise absolute fallback.
    public func dotSizePoints(viewWidth: CGFloat?) -> CGFloat {
        if let width = viewWidth {
            return width * dotSize.rawValue
        }
        return dotSize.absoluteSize
    }
    
    /// Whether to use text mode ("3 / 50") instead of dots for the given page count.
    public func shouldUseTextMode(pageCount: Int) -> Bool {
        pageCount > dotSize.overflowThreshold
    }
}

// MARK: - Enriched Layout

/// Where elements are placed in the enriched carousel.
public enum PageControlPosition {
    /// PageControl below image, above title (default).
    case stacked
    /// PageControl overlaid on image (e.g. bottom center).
    case overlay
}

/// Where title & description are placed.
public enum TextPosition {
    /// Title & description below page control (default).
    case stacked
    /// Title & description overlaid on image.
    case overlay
}

/// Layout configuration for enriched carousel — where elements go.
public struct EnrichedCarouLayout {
    public let pageControlPosition: PageControlPosition
    public let textPosition: TextPosition
    
    public init(
        pageControlPosition: PageControlPosition = .stacked,
        textPosition: TextPosition = .stacked
    ) {
        self.pageControlPosition = pageControlPosition
        self.textPosition = textPosition
    }
    
    /// Default layout: both stacked.
    public static let `default` = EnrichedCarouLayout()
}

// MARK: - Enriched Appearance

/// Shadow configuration for card-like appearance.
public struct CarouShadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color = .black.opacity(0.2), radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 2) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    public static let `default` = CarouShadow()
    public static let none = CarouShadow(color: .clear, radius: 0, x: 0, y: 0)
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
    
    // Image
    public let imageBackgroundInset: EdgeInsets
    public let bottomInsetFollowsContent: Bool
    public let imageFrameWidth: CGFloat
    public let imageFrameColor: Color
    
    // Background
    public let backgroundFrameWidth: CGFloat
    public let backgroundFrameColor: Color
    public let backgroundCornerRadius: CGFloat
    public let backgroundShadow: CarouShadow?
    
    public init(
        textAlignment: TextAlignment = .leading,
        titleColor: Color = .primary,
        descriptionColor: Color = .secondary,
        titleFontName: String? = nil,
        titleFontSize: CGFloat = 17,
        titleFontBundle: Bundle? = nil,
        descriptionFontName: String? = nil,
        descriptionFontSize: CGFloat = 15,
        descriptionFontBundle: Bundle? = nil,
        imageBackgroundInset: EdgeInsets = EdgeInsets(),
        bottomInsetFollowsContent: Bool = true,
        imageFrameWidth: CGFloat = 0,
        imageFrameColor: Color = .clear,
        backgroundFrameWidth: CGFloat = 0,
        backgroundFrameColor: Color = .clear,
        backgroundCornerRadius: CGFloat = 0,
        backgroundShadow: CarouShadow? = nil
    ) {
        self.textAlignment = textAlignment
        self.titleColor = titleColor
        self.descriptionColor = descriptionColor
        self.titleFontName = titleFontName
        self.titleFontSize = titleFontSize
        self.titleFontBundle = titleFontBundle
        self.descriptionFontName = descriptionFontName
        self.descriptionFontSize = descriptionFontSize
        self.descriptionFontBundle = descriptionFontBundle
        self.imageBackgroundInset = imageBackgroundInset
        self.bottomInsetFollowsContent = bottomInsetFollowsContent
        self.imageFrameWidth = imageFrameWidth
        self.imageFrameColor = imageFrameColor
        self.backgroundFrameWidth = backgroundFrameWidth
        self.backgroundFrameColor = backgroundFrameColor
        self.backgroundCornerRadius = backgroundCornerRadius
        self.backgroundShadow = backgroundShadow
    }
    
    /// Default view appearance.
    public static let `default` = EnrichedCarouViewAppearance()
}

/// Enriched view appearance: pageControl + view styling.
public struct EnrichedCarouAppearance {
    public let pageControl: CarouPageControlAppearance
    public let view: EnrichedCarouViewAppearance
    
    public init(
        pageControl: CarouPageControlAppearance = .default,
        view: EnrichedCarouViewAppearance = .default
    ) {
        self.pageControl = pageControl
        self.view = view
    }
    
    /// Default enriched appearance.
    public static let `default` = EnrichedCarouAppearance()
}

// MARK: - Legacy Configuration (Backward Compatible)

/// Main configuration struct — backward compatible facade.
/// Basic view uses: behavior + pageControlAppearance.
/// Enriched view uses: behavior + layout + appearance.
public struct CarouViewConfiguration {
    // Composed configs
    public let behavior: CarouBehavior
    public let pageControlAppearance: CarouPageControlAppearance
    public let enrichedLayout: EnrichedCarouLayout
    public let enrichedAppearance: EnrichedCarouAppearance
    
    /// When non-nil, dot size is a fraction of this width. When nil, absolute point sizes are used.
    public let viewWidth: CGFloat?
    
    // Computed for backward compatibility
    public var rideDirection: CarouDirection { behavior.rideDirection }
    public var autoRideEnabled: Bool { behavior.autoRideEnabled }
    public var showTime: Double { behavior.showTime }
    public var imageScale: CarouImageScale { behavior.imageScale }
    public var dotColor: Color { pageControlAppearance.dotColor }
    public var currentDotColor: Color { pageControlAppearance.currentDotColor }
    public var dotSize: CarouDotSize { pageControlAppearance.dotSize }
    
    var dotSizePoints: CGFloat {
        pageControlAppearance.dotSizePoints(viewWidth: viewWidth)
    }
    
    /// Full initializer with composed configs.
    public init(
        behavior: CarouBehavior = .default,
        pageControlAppearance: CarouPageControlAppearance = .default,
        enrichedLayout: EnrichedCarouLayout = .default,
        enrichedAppearance: EnrichedCarouAppearance = .default,
        viewWidth: CGFloat? = nil
    ) {
        self.behavior = behavior
        self.pageControlAppearance = pageControlAppearance
        self.enrichedLayout = enrichedLayout
        self.enrichedAppearance = enrichedAppearance
        self.viewWidth = viewWidth
    }
    
    /// Legacy initializer for backward compatibility.
    public init(
        rideDirection: CarouDirection = .rightToLeft,
        autoRideEnabled: Bool = true,
        showTime: Double = 2.0,
        dotColor: Color = .white,
        currentDotColor: Color = .black,
        dotSize: CarouDotSize = .small,
        imageScale: CarouImageScale = .fill,
        viewWidth: CGFloat? = nil
    ) {
        self.behavior = CarouBehavior(
            rideDirection: rideDirection,
            autoRideEnabled: autoRideEnabled,
            showTime: showTime,
            imageScale: imageScale
        )
        self.pageControlAppearance = CarouPageControlAppearance(
            dotColor: dotColor,
            currentDotColor: currentDotColor,
            dotSize: dotSize
        )
        self.enrichedLayout = .default
        self.enrichedAppearance = .default
        self.viewWidth = viewWidth
    }
    
    /// Returns a configuration with the given view width (e.g. from layout). Use this in the view when you have geometry.
    func with(viewWidth: CGFloat?) -> CarouViewConfiguration {
        CarouViewConfiguration(
            behavior: behavior,
            pageControlAppearance: pageControlAppearance,
            enrichedLayout: enrichedLayout,
            enrichedAppearance: enrichedAppearance,
            viewWidth: viewWidth
        )
    }
}
