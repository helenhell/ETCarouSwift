//
//  CarouselDemoView.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 08/02/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
import ETCarouSwift

/// Demo screen that shows the carousel with the given configuration, mode (basic or enriched), and data set size (small = dots, big = text page control).
struct CarouselDemoView: View {
    let configuration: CarouViewConfiguration
    let mode: CarouselDemoMode
    let dataSetSize: DemoDataSetSize
    @State private var currentIndex: Int = 0

    private var images: [Image] { DemoData.basicImages(for: dataSetSize) }
    private var enrichedItems: [CarouItem] { DemoData.enrichedItems(for: dataSetSize) }

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

            Text(mode == .basic ? "Image #\(currentIndex + 1)" : "")
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Demo")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Demo Basic - Small") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .basic, dataSetSize: .small)
    }
}

#Preview("Demo Basic - Big (text page control)") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .basic, dataSetSize: .big)
    }
}

#Preview("Demo Enriched - Small") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .enriched, dataSetSize: .small)
    }
}

#Preview("Demo Enriched - Big (text page control)") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .enriched, dataSetSize: .big)
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
        CarouselDemoView(configuration: config, mode: .enriched, dataSetSize: .small)
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
        CarouselDemoView(configuration: config, mode: .enriched, dataSetSize: .small)
    }
}
