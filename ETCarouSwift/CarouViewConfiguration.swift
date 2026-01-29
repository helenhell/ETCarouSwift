//
//  CarouViewConfiguration.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 31/01/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

public enum CarouDirection {
    case leftToRight, rightToLeft
}

/// Dot size expressed as a fraction of the carousel view width. Kept as an enum to restrict to valid options.
public enum CarouDotSize: CGFloat {
    case small = 0.02   // 2% of view width
    case medium = 0.03  // 3% of view width
    case large = 0.04   // 4% of view width
    
    /// Absolute dot diameter in points, used when view width is not available.
    var absoluteSize: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }
}

public struct CarouViewConfiguration {
    public let rideDirection: CarouDirection
    public let autoRideEnabled: Bool
    public let showTime: Double
    public let dotColor: Color
    public let currentDotColor: Color
    public let dotSize: CarouDotSize
    /// When non-nil, dot size is a fraction of this width. When nil, absolute point sizes are used.
    public let viewWidth: CGFloat?
    
    public init(
        rideDirection: CarouDirection = .rightToLeft,
        autoRideEnabled: Bool = true,
        showTime: Double = 2.0,
        dotColor: Color = .white,
        currentDotColor: Color = .black,
        dotSize: CarouDotSize = .small,
        viewWidth: CGFloat? = nil
    ) {
        self.rideDirection = rideDirection
        self.autoRideEnabled = autoRideEnabled
        self.showTime = showTime
        self.dotColor = dotColor
        self.currentDotColor = currentDotColor
        self.dotSize = dotSize
        self.viewWidth = viewWidth
    }
    
    /// Returns a configuration with the given view width (e.g. from layout). Use this in the view when you have geometry.
    func with(viewWidth: CGFloat?) -> CarouViewConfiguration {
        CarouViewConfiguration(
            rideDirection: rideDirection,
            autoRideEnabled: autoRideEnabled,
            showTime: showTime,
            dotColor: dotColor,
            currentDotColor: currentDotColor,
            dotSize: dotSize,
            viewWidth: viewWidth
        )
    }
    
    /// Dot size in points: relative to view width when `viewWidth` is set, otherwise absolute fallback.
    var dotSizePoints: CGFloat {
        Self.dotSizeInPoints(dotSize: dotSize, viewWidth: viewWidth)
    }
    
    private static func dotSizeInPoints(dotSize: CarouDotSize, viewWidth: CGFloat?) -> CGFloat {
        if let width = viewWidth {
            return width * dotSize.rawValue
        }
        return dotSize.absoluteSize
    }
}
