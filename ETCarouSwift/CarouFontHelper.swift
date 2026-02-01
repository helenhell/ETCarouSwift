//
//  CarouFontHelper.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 01/02/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Helper for loading custom fonts with system fallback.
public enum CarouFontHelper {
    
    /// Creates a Font from a custom font name with fallback to system font.
    /// - Parameters:
    ///   - name: The font name (e.g., "Avenir-Heavy"). If nil, uses system font.
    ///   - size: The font size in points.
    ///   - bundle: The bundle containing the font file. If nil, uses Bundle.main.
    ///   - weight: The weight to use for system font fallback. Default is `.regular`.
    /// - Returns: A SwiftUI Font, either the custom font or system fallback.
    public static func font(
        name: String?,
        size: CGFloat,
        bundle: Bundle? = nil,
        weight: Font.Weight = .regular
    ) -> Font {
        guard let fontName = name, !fontName.isEmpty else {
            return .system(size: size, weight: weight)
        }
        
        // Try to load the custom font
        if fontExists(name: fontName, bundle: bundle) {
            return .custom(fontName, size: size)
        }
        
        // Fallback to system font
        return .system(size: size, weight: weight)
    }
    
    /// Checks if a font with the given name exists and can be loaded.
    /// - Parameters:
    ///   - name: The font name.
    ///   - bundle: The bundle to search in.
    /// - Returns: True if the font exists and can be loaded.
    private static func fontExists(name: String, bundle: Bundle?) -> Bool {
        #if canImport(UIKit)
        // Check if UIFont can instantiate this font
        if UIFont(name: name, size: 12) != nil {
            return true
        }
        #endif
        
        // If not found in system fonts, try to register from bundle
        // (Font registration should be done at app startup, this is just a check)
        return false
    }
}
