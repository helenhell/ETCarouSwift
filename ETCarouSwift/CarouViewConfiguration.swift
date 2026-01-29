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

public enum CarouDotSize: CGFloat {
    case small = 1.0
    case medium = 1.5
    case large = 2.0
}

public struct CarouViewConfiguration {
    public let rideDirection: CarouDirection
    public let autoRideEnabled: Bool
    public let showTime: Double
    public let dotColor: Color
    public let currentDotColor: Color
    public let dotSize: CarouDotSize
    
    public init(
        rideDirection: CarouDirection = .rightToLeft,
        autoRideEnabled: Bool = true,
        showTime: Double = 2.0,
        dotColor: Color = .white,
        currentDotColor: Color = .black,
        dotSize: CarouDotSize = .small
    ) {
        self.rideDirection = rideDirection
        self.autoRideEnabled = autoRideEnabled
        self.showTime = showTime
        self.dotColor = dotColor
        self.currentDotColor = currentDotColor
        self.dotSize = dotSize
    }
}
