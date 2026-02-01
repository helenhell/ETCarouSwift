//
//  CarouPageControl.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

struct CarouPageControl: View {
    let numberOfPages: Int
    let currentPage: Int
    let dotColor: Color
    let currentDotColor: Color
    let dotSizePoints: CGFloat
    var direction: CarouDirection = .leftToRight
    var dotSize: CarouDotSize = .small
    
    /// Optional custom font for text mode (used in enriched view).
    var textFont: Font?
    /// Optional custom color for text mode (used in enriched view).
    var textColor: Color?

    /// Whether to use text mode based on page count and dot size threshold.
    private var useTextMode: Bool {
        numberOfPages > dotSize.overflowThreshold
    }
    
    var body: some View {
        Group {
            if useTextMode {
                textModeView
            } else {
                dotModeView
            }
        }
        .environment(\.layoutDirection, direction == .rightToLeft ? .rightToLeft : .leftToRight)
    }
    
    /// Dots view (default mode).
    private var dotModeView: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? currentDotColor : dotColor)
                    .frame(width: dotSizePoints, height: dotSizePoints)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
    
    /// Text view for overflow mode ("3 / 50").
    private var textModeView: some View {
        let displayPage = currentPage + 1 // 1-based for display
        let font = textFont ?? .system(size: dotSizePoints * 1.5, weight: .medium)
        let color = textColor ?? currentDotColor
        
        return Text("\(displayPage) / \(numberOfPages)")
            .font(font)
            .foregroundColor(color)
            .monospacedDigit()
    }
}
