//
//  CarouItem.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

/// A single item for the enriched carousel: image with optional title and description.
public struct CarouItem {
    public let image: Image
    public let title: String?
    public let description: String?

    public init(image: Image, title: String? = nil, description: String? = nil) {
        self.image = image
        self.title = title
        self.description = description
    }
}
