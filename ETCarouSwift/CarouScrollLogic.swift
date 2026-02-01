//
//  CarouScrollLogic.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 01/02/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import CoreGraphics

/// Shared scroll/snap logic for basic and enriched carousels.
enum CarouScrollLogic {
    /// Computes the snap page index (0...totalPages-1) and whether it's a wraparound clone.
    /// Caller should set scrollOffset to content-equivalent page when isWraparound (0→count, totalPages-1→1).
    static func snapTarget(
        effectiveOffset: CGFloat,
        velocity: CGFloat,
        totalPages: Int,
        velocityThreshold: CGFloat = CarouConstants.snapVelocityThreshold
    ) -> (page: Int, isWraparound: Bool) {
        let clamped = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
        let snap: Int
        if velocity < -velocityThreshold {
            snap = min(totalPages - 1, Int(ceil(clamped)))
        } else if velocity > velocityThreshold {
            snap = max(0, Int(floor(clamped)))
        } else {
            snap = Int(round(clamped))
        }
        let page = max(0, min(totalPages - 1, snap))
        let isWraparound = (page == 0 || page == totalPages - 1)
        return (page, isWraparound)
    }

    /// Converts raw snap page to the scroll-offset page (wraparound clones map to content-equivalent page).
    static func scrollPage(fromSnap snap: Int, totalPages: Int, contentCount: Int) -> Int {
        if snap == 0 { return contentCount }
        if snap == totalPages - 1 { return 1 }
        return snap
    }
}
