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
        Image("5")
    ]

    private let enrichedItems: [CarouItem] = [
        CarouItem(image: Image("1"), title: "Slide One", description: "First image in the carousel."),
        CarouItem(image: Image("2"), title: "Slide Two", description: "Second image with a short description."),
        CarouItem(image: Image("3"), title: "Slide Three", description: "Third slide with optional text."),
        CarouItem(image: Image("4"), title: "Slide Four", description: "Fourth item in the enriched list."),
        CarouItem(image: Image("5"), title: "Slide Five", description: "Final slide of the demo.")
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
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
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

#Preview("Demo Enriched") {
    NavigationStack {
        CarouselDemoView(configuration: CarouViewConfiguration(), mode: .enriched)
    }
}
