//
//  ContentView.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 08/02/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
import ETCarouSwift

/// Demo screen that shows the carousel with the given configuration and mode (basic or enriched).
struct CarouselDemoView: View {
    let configuration: CarouViewConfiguration
    let mode: CarouselDemoMode
    @State private var currentIndex: Int = 0

    private let images: [Image] = [
        Image("1"),
        Image("2"),
        Image("3"),
        Image("4"),
        Image("5"),
        Image("6")
    ]

    private let enrichedItems: [CarouItem] = [
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

    var body: some View {
        VStack(spacing: 20) {
            Group {
                switch mode {
                case .basic:
                    CarouView(
                        imageSet: images,
                        configuration: configuration,
                        onImageChanged: { index in currentIndex = index },
                        onImageTapped: { _ in }
                    )
                case .enriched:
                    CarouView(
                        items: enrichedItems,
                        configuration: configuration,
                        onItemChanged: { index in currentIndex = index },
                        onItemTapped: { _ in }
                    )
                }
            }
            .frame(height: mode == .enriched ? 380 : 300)
            .padding(.horizontal, 20)

            Text(mode == .basic ? "Image #\(currentIndex + 1)" : "Item #\(currentIndex + 1)")
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Root content: configuration screen (entry point for the demo app).
struct ContentView: View {
    var body: some View {
        NavigationStack {
            ConfigurationView()
        }
    }
}

#Preview("Configuration") {
    ContentView()
}

#Preview("Demo Basic") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .basic)
    }
}

#Preview("Demo Enriched - Default") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .enriched)
    }
}

#Preview("Demo Enriched - Overlay") {
    let behavior = CarouBehavior(autoRideEnabled: false)
    let layout = EnrichedCarouLayout(
        pageControlPosition: .overlay,
        textPosition: .overlay
    )
    let viewAppearance = EnrichedCarouViewAppearance(
        textAlignment: .center,
        titleColor: .white,
        descriptionColor: .white.opacity(0.9)
    )
    let enrichedAppearance = EnrichedCarouAppearance(
        view: viewAppearance
    )
    let config = CarouViewConfiguration(
        behavior: behavior,
        enrichedLayout: layout,
        enrichedAppearance: enrichedAppearance
    )
    
    return NavigationStack {
        CarouselDemoView(configuration: config, mode: .enriched)
    }
}

#Preview("Demo Enriched - Card Style") {
    let behavior = CarouBehavior(autoRideEnabled: false)
    let viewAppearance = EnrichedCarouViewAppearance(
        cardInset: 16,
        imageBorderWidth: 2,
        imageBorderColor: .blue.opacity(0.3),
        backgroundBorderWidth: 1,
        backgroundBorderColor: .gray.opacity(0.3),
        backgroundCornerRadius: 16,
        backgroundShadow: CarouShadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    )
    let enrichedAppearance = EnrichedCarouAppearance(
        view: viewAppearance
    )
    let config = CarouViewConfiguration(
        behavior: behavior,
        enrichedAppearance: enrichedAppearance
    )
    
    return NavigationStack {
        CarouselDemoView(configuration: config, mode: .enriched)
    }
}
