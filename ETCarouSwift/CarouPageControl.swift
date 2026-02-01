//
//  CarouPageControl.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

struct CarouPageControl: View {
    /// Logical item count (number of pages/slides). Must not include clone pages used for infinite scroll.
    let numberOfPages: Int
    /// Current page index (0-based).
    let currentPage: Int
    let dotColor: Color
    let currentDotColor: Color
    let dotSizePoints: CGFloat
    var direction: CarouDirection = .leftToRight
    var dotSize: CarouDotSize = .small
    
    /// Optional custom font for text mode (e.g. description size in enriched view).
    var textFont: Font?
    /// When nil, text mode uses currentDotColor to match dot styling.
    var textColor: Color?

    /// Use text mode when page count exceeds threshold (small/medium: 15, large: 10).
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
    
    /// Text view for overflow mode ("3 / 17"). Uses numberOfPages as total (logical count).
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
