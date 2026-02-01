//
//  CarouConstants.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 01/02/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import CoreGraphics

/// Shared constants for carousel scroll, snap, and auto-ride behavior.
enum CarouConstants {
    /// Velocity (points per second) above which drag snaps to next/previous page.
    static let snapVelocityThreshold: CGFloat = 200

    /// Duration of the snap animation when releasing drag.
    static let snapAnimationDuration: Double = 0.3

    /// Duration of the auto-ride step animation when advancing to next page.
    static let autoRideStepDuration: Double = 0.35
}
