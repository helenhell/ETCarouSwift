//
//  CarouImageScaleModifier.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

/// View modifier that applies a carousel image scale (fill or fit).
/// Apply to a resizable image: `image.resizable().modifier(CarouImageScaleModifier(scale: .fill))`.
public struct CarouImageScaleModifier: ViewModifier {
    let scale: CarouImageScale

    public func body(content: Content) -> some View {
        switch scale {
        case .fill:
            content.scaledToFill()
        case .fit:
            content.scaledToFit()
        }
    }
}

extension View {
    /// Applies the given carousel image scale. Use after `.resizable()` on an `Image`.
    public func carouImageScale(_ scale: CarouImageScale) -> some View {
        modifier(CarouImageScaleModifier(scale: scale))
    }
}
