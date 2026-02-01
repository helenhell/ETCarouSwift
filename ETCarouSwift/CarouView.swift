//
//  CarouView.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 31/01/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Public carousel view: use the image-set initializer for a basic carousel (page control overlay), or the items initializer for an enriched carousel (stacked image + title + description).
public struct CarouView: View {
    private let content: AnyView

    /// Basic carousel: images only with page control overlay.
    public init(
        imageSet: [Image],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.content = AnyView(
            BasicCarouView(
                imageSet: imageSet,
                configuration: configuration,
                onImageChanged: onImageChanged,
                onImageTapped: onImageTapped
            )
        )
    }

    /// Enriched carousel: CarouItems with stacked layout (image, title, description) and page control overlay.
    public init(
        items: [CarouItem],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onItemChanged: ((Int) -> Void)? = nil,
        onItemTapped: ((Int) -> Void)? = nil
    ) {
        self.content = AnyView(
            EnrichedCarouView(
                items: items,
                configuration: configuration,
                onItemChanged: onItemChanged,
                onItemTapped: onItemTapped
            )
        )
    }

    public var body: some View {
        content
    }
}

// MARK: - UIKit Image Support
extension CarouView {
    /// Convenience initializer for UIImage array (basic carousel).
    public init(
        imageSet: [UIImage],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.init(
            imageSet: imageSet.map { Image(uiImage: $0) },
            configuration: configuration,
            onImageChanged: onImageChanged,
            onImageTapped: onImageTapped
        )
    }
}
