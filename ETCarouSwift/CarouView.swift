//
//  CarouView.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 31/01/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

public protocol CarouViewDelegate: AnyObject {
    func carouViewDidChangeImage(_ carouView: CarouView, index currentImageIndex: Int)
    func carouView(_ carouView: CarouView, didTapImageAt index: Int)
}

public struct CarouView: View {
    /// Continuous scroll position (page units): 1 = first original, animatable for same slide as swipe.
    @State private var scrollOffset: CGFloat = 1
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    @State private var isUserInteracting: Bool = false
    
    private let images: [Image]
    private let configuration: CarouViewConfiguration
    private let onImageChanged: ((Int) -> Void)?
    private let onImageTapped: ((Int) -> Void)?
    
    public init(
        imageSet: [Image],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.images = imageSet
        self.configuration = configuration
        self.onImageChanged = onImageChanged
        self.onImageTapped = onImageTapped
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if images.isEmpty {
                    // Empty state
                    Color.blue
                } else if images.count == 1 {
                    // Single image
                    images[0]
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .onTapGesture {
                            onImageTapped?(0)
                        }
                } else {
                    // Custom offset-based carousel: [copyOfLast, 0, 1, ..., n-1, copyOfFirst] — same slide for swipe and auto-ride
                    let count = images.count
                    let totalPages = count + 2
                    let pageWidth = geometry.size.width
                    let effectiveOffset = scrollOffset - dragOffset / pageWidth
                    let visiblePage = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
                    let currentLogical = logicalIndex(for: Int(round(visiblePage)), count: count)
                    
                    ZStack(alignment: .bottom) {
                        // Strip: full width, then offset; frame(alignment: .leading) so visible window is [0, pageWidth] over strip
                        HStack(spacing: 0) {
                            ForEach(0..<totalPages, id: \.self) { p in
                                imageForPage(p, count: count)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: pageWidth, height: geometry.size.height)
                                    .clipped()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onImageTapped?(logicalIndex(for: p, count: count))
                                    }
                            }
                        }
                        .frame(width: CGFloat(totalPages) * pageWidth, height: geometry.size.height)
                        .fixedSize(horizontal: true, vertical: false)
                        .offset(x: -scrollOffset * pageWidth + dragOffset)
                        .frame(width: pageWidth, height: geometry.size.height, alignment: .leading)
                        .clipped()
                        .transaction { t in
                            if isUserInteracting { t.animation = nil; t.disablesAnimations = true }
                        }
                        .animation(.easeInOut(duration: 0.35), value: scrollOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isUserInteracting = true
                                    stopAutoRide()
                                    var t = Transaction()
                                    t.disablesAnimations = true
                                    withTransaction(t) {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    isUserInteracting = false
                                    let effective = scrollOffset - dragOffset / pageWidth
                                    var snap = Int(round(effective))
                                    snap = max(0, min(totalPages - 1, snap))
                                    let isWraparound = (snap == 0 || snap == totalPages - 1)
                                    if snap == 0 { snap = count }
                                    else if snap == totalPages - 1 { snap = 1 }
                                    if isWraparound {
                                        // Edge: longer duration + more pronounced easeInOut (slower start/end)
                                        let edgeAnimation = Animation.timingCurve(0.33, 0, 0.67, 1, duration: 0.6)
                                        withAnimation(edgeAnimation) {
                                            scrollOffset = CGFloat(snap)
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.35)) {
                                            scrollOffset = CGFloat(snap)
                                            dragOffset = 0
                                        }
                                    }
                                    onImageChanged?(logicalIndex(for: snap, count: count))
                                    if configuration.autoRideEnabled { startAutoRide() }
                                }
                        )
                        
                        CarouPageControl(
                            numberOfPages: count,
                            currentPage: currentLogical,
                            dotColor: configuration.dotColor,
                            currentDotColor: configuration.currentDotColor,
                            dotSize: configuration.dotSize
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: geometry.size.height * 0.25)
                        .padding(.bottom, geometry.size.height * 0.05)
                    }
                    .frame(width: pageWidth, height: geometry.size.height)
                    .clipped()
                }
            }
        }
        .onAppear {
            if configuration.autoRideEnabled && images.count > 1 {
                startAutoRide()
            }
        }
        .onDisappear {
            stopAutoRide()
        }
    }
    
    /// Map display page to image: 0 → last, 1..count → originals, count+1 → first
    private func imageForPage(_ p: Int, count: Int) -> Image {
        if p == 0 { return images[count - 1] }
        if p == count + 1 { return images[0] }
        return images[p - 1]
    }
    
    /// Logical index 0..count-1 for callbacks and page control
    private func logicalIndex(for page: Int, count: Int) -> Int {
        if page <= 0 { return count - 1 }
        if page >= count + 1 { return 0 }
        let logical = page - 1
        return max(0, min(count - 1, logical))
    }
    
    private func startAutoRide() {
        stopAutoRide()
        let count = images.count
        let totalPages = count + 2
        let duration: Double = 0.35
        timer = Timer.scheduledTimer(withTimeInterval: configuration.showTime, repeats: true) { _ in
            guard !isUserInteracting else { return }
            Task { @MainActor in
                let currentPage = Int(round(scrollOffset))
                let nextPage = configuration.rideDirection == .rightToLeft
                    ? (currentPage + 1) % totalPages
                    : (currentPage - 1 + totalPages) % totalPages
                // Same slide transition as user swipe (animate scrollOffset)
                withAnimation(.easeInOut(duration: duration)) {
                    scrollOffset = CGFloat(nextPage)
                }
                if nextPage >= 1 && nextPage <= count {
                    onImageChanged?(logicalIndex(for: nextPage, count: count))
                } else {
                    // Landed on copy; instant jump to original (same image = invisible, no backwards scroll)
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                        let targetPage = nextPage == 0 ? count : 1
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) {
                            scrollOffset = CGFloat(targetPage)
                        }
                        onImageChanged?(logicalIndex(for: targetPage, count: count))
                    }
                }
            }
        }
    }
    
    private func stopAutoRide() {
        timer?.invalidate()
        timer = nil
    }
    
    public var carouIndex: Int {
        logicalIndex(for: Int(round(scrollOffset)), count: images.count)
    }
}

// MARK: - Page Control
struct CarouPageControl: View {
    let numberOfPages: Int
    let currentPage: Int
    let dotColor: Color
    let currentDotColor: Color
    let dotSize: CarouDotSize
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? currentDotColor : dotColor)
                    .frame(width: 8 * dotSize.rawValue, height: 8 * dotSize.rawValue)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
}

// MARK: - UIKit Image Support
extension CarouView {
    /// Convenience initializer for UIImage array (UIKit compatibility)
    public init(
        imageSet: [UIImage],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.images = imageSet.map { Image(uiImage: $0) }
        self.configuration = configuration
        self.onImageChanged = onImageChanged
        self.onImageTapped = onImageTapped
    }
}

