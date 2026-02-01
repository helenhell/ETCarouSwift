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

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? currentDotColor : dotColor)
                    .frame(width: dotSizePoints, height: dotSizePoints)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .environment(\.layoutDirection, direction == .rightToLeft ? .rightToLeft : .leftToRight)
    }
}
