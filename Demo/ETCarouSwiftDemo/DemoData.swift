//
//  DemoData.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 01/02/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
import ETCarouSwift

/// Data set size for the demo: small shows dot page control, big shows text page control (e.g. "3 / 16").
enum DemoDataSetSize: String, CaseIterable {
    case small = "Small (dots)"
    case big = "Big (text)"
}

enum DemoData {

    // MARK: - Basic carousel (images only)

    /// Small set (e.g. 6 images) — page control shows dots.
    static let basicImagesSmall: [Image] = [
        Image("1"),
        Image("2"),
        Image("3"),
        Image("4"),
        Image("5"),
        Image("6")
    ]

    /// Big set (16 images) — page control shows text (e.g. "3 / 16") when dot size overflow threshold is exceeded.
    static let basicImagesBig: [Image] = (1...16).map { Image("f\($0)") }

    /// Returns the basic image set for the given size.
    static func basicImages(for size: DemoDataSetSize) -> [Image] {
        switch size {
        case .small: return basicImagesSmall
        case .big: return basicImagesBig
        }
    }

    // MARK: - Enriched carousel (items with title + description)

    private static let enrichedItemsAll: [CarouItem] = [
        CarouItem(image: Image("f1"), title: "Spring Bloom", description: "Fresh petals opening to the morning sun."),
        CarouItem(image: Image("f2"), title: "Garden Rose", description: "Classic beauty in full bloom."),
        CarouItem(image: Image("f3"), title: "Wildflower Meadow", description: "A tapestry of color in the grass."),
        CarouItem(image: Image("f4"), title: "Summer Bouquet", description: "Bright and cheerful summer flowers."),
        CarouItem(image: Image("f5"), title: "Petal Close-Up", description: "Delicate details up close."),
        CarouItem(image: Image("f6"), title: "Lavender Field", description: "Soft purple hues and gentle fragrance."),
        CarouItem(image: Image("f7"), title: "Dahlia", description: "Bold and layered petals."),
        CarouItem(image: Image("f8"), title: "Floral Arrangement", description: "Elegant mix of blooms."),
        CarouItem(image: Image("f9"), title: "Poppy", description: "Vibrant and delicate."),
        CarouItem(image: Image("f10"), title: "Garden Path", description: "Flowers lining the way."),
        CarouItem(image: Image("f11"), title: "Peony", description: "Lush and romantic."),
        CarouItem(image: Image("f12"), title: "Sunflower", description: "Bright face turned to the sky."),
        CarouItem(image: Image("f13"), title: "Tulip", description: "Graceful curves and bold color."),
        CarouItem(image: Image("f14"), title: "Orchid", description: "Exotic and refined."),
        CarouItem(image: Image("f15"), title: "Floral Still Life", description: "A moment of natural beauty."),
        CarouItem(image: Image("f16"), title: "Garden View", description: "Another glimpse of floral beauty."),
    ]

    /// Small set (5 items) — page control shows dots.
    static let enrichedItemsSmall: [CarouItem] = Array(enrichedItemsAll.prefix(5))

    /// Big set (16 items) — page control shows text.
    static let enrichedItemsBig: [CarouItem] = enrichedItemsAll

    /// Returns the enriched item set for the given size.
    static func enrichedItems(for size: DemoDataSetSize) -> [CarouItem] {
        switch size {
        case .small: return enrichedItemsSmall
        case .big: return enrichedItemsBig
        }
    }
}
