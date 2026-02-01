//
//  BasicCarouView.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

/// Internal: image-only carousel with page control overlay.
struct BasicCarouView: View {
    @State private var scrollOffset: CGFloat = 1
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    @State private var isUserInteracting: Bool = false
    @State private var lastDragTranslation: CGFloat = 0
    @State private var lastDragTime: TimeInterval = 0

    private let images: [Image]
    private let configuration: CarouViewConfiguration
    private let onImageChanged: ((Int) -> Void)?
    private let onImageTapped: ((Int) -> Void)?

    init(
        imageSet: [Image],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.images = imageSet
        self.configuration = configuration
        self.onImageChanged = onImageChanged
        self.onImageTapped = onImageTapped
        let count = imageSet.count
        let initialPage: CGFloat = count <= 1 ? 1 : (configuration.rideDirection == .rightToLeft ? CGFloat(count) : 1)
        _scrollOffset = State(initialValue: initialPage)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if images.isEmpty {
                    Color.blue
                } else if images.count == 1 {
                    images[0]
                        .resizable()
                        .carouImageScale(configuration.imageScale)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .onTapGesture { onImageTapped?(0) }
                } else {
                    let count = images.count
                    let totalPages = count + 2
                    let pageWidth = geometry.size.width
                    let resolvedConfig = configuration.with(viewWidth: pageWidth)
                    let effectiveOffset = scrollOffset - dragOffset / pageWidth
                    let visiblePage = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
                    let currentLogical = logicalIndex(for: Int(round(visiblePage)), count: count, direction: configuration.rideDirection)

                    ZStack(alignment: .bottom) {
                        HStack(spacing: 0) {
                            ForEach(0..<totalPages, id: \.self) { p in
                                imageForPage(p, count: count, direction: configuration.rideDirection)
                                    .resizable()
                                    .carouImageScale(configuration.imageScale)
                                    .frame(width: pageWidth, height: geometry.size.height)
                                    .clipped()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onImageTapped?(logicalIndex(for: p, count: count, direction: configuration.rideDirection))
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
                        .animation(.easeInOut(duration: 0.3), value: scrollOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isUserInteracting = true
                                    stopAutoRide()
                                    var t = Transaction()
                                    t.disablesAnimations = true
                                    withTransaction(t) {
                                        dragOffset = value.translation.width
                                        lastDragTranslation = value.translation.width
                                        lastDragTime = Date().timeIntervalSince1970
                                    }
                                }
                                .onEnded { value in
                                    isUserInteracting = false
                                    let effective = scrollOffset - dragOffset / pageWidth
                                    let dt = max(0.001, Date().timeIntervalSince1970 - lastDragTime)
                                    let velocity = (value.translation.width - lastDragTranslation) / CGFloat(dt)
                                    let velocityThreshold: CGFloat = 200
                                    let clampedEffective = max(0, min(CGFloat(totalPages - 1), effective))
                                    var snap: Int
                                    if velocity < -velocityThreshold {
                                        snap = min(totalPages - 1, Int(ceil(clampedEffective)))
                                    } else if velocity > velocityThreshold {
                                        snap = max(0, Int(floor(clampedEffective)))
                                    } else {
                                        snap = Int(round(clampedEffective))
                                    }
                                    snap = max(0, min(totalPages - 1, snap))
                                    let isWraparound = (snap == 0 || snap == totalPages - 1)
                                    if snap == 0 { snap = count }
                                    else if snap == totalPages - 1 { snap = 1 }
                                    if isWraparound {
                                        var t = Transaction()
                                        t.disablesAnimations = true
                                        withTransaction(t) {
                                            scrollOffset = CGFloat(snap)
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            scrollOffset = CGFloat(snap)
                                            dragOffset = 0
                                        }
                                    }
                                    onImageChanged?(logicalIndex(for: snap, count: count, direction: configuration.rideDirection))
                                    if configuration.autoRideEnabled { startAutoRide() }
                                }
                        )

                        CarouPageControl(
                            numberOfPages: count,
                            currentPage: currentLogical,
                            dotColor: configuration.dotColor,
                            currentDotColor: configuration.currentDotColor,
                            dotSizePoints: resolvedConfig.dotSizePoints,
                            direction: configuration.rideDirection,
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
            if configuration.autoRideEnabled && images.count > 1 { startAutoRide() }
        }
        .onDisappear { stopAutoRide() }
    }

    private func imageForPage(_ p: Int, count: Int, direction: CarouDirection) -> Image {
        switch direction {
        case .leftToRight:
            if p == 0 { return images[count - 1] }
            if p == count + 1 { return images[0] }
            return images[p - 1]
        case .rightToLeft:
            if p == 0 || p == count { return images[0] }
            if p == 1 || p == count + 1 { return images[count - 1] }
            return images[count - p]
        }
    }

    private func logicalIndex(for page: Int, count: Int, direction: CarouDirection) -> Int {
        switch direction {
        case .leftToRight:
            if page <= 0 { return count - 1 }
            if page >= count + 1 { return 0 }
            return max(0, min(count - 1, page - 1))
        case .rightToLeft:
            if page == 0 || page == count { return 0 }
            if page == 1 || page == count + 1 { return count - 1 }
            return max(0, min(count - 1, count - page))
        }
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
                let isRTL = configuration.rideDirection == .rightToLeft
                let nextPage: Int
                if isRTL {
                    nextPage = (currentPage - 1 + totalPages) % totalPages
                } else {
                    nextPage = (currentPage + 1) % totalPages
                }
                withAnimation(.easeInOut(duration: duration)) {
                    scrollOffset = CGFloat(nextPage)
                }
                if nextPage >= 1 && nextPage <= count {
                    onImageChanged?(logicalIndex(for: nextPage, count: count, direction: configuration.rideDirection))
                } else {
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                        let targetPage = (nextPage == 0 ? count : 1)
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) { scrollOffset = CGFloat(targetPage) }
                        onImageChanged?(logicalIndex(for: targetPage, count: count, direction: configuration.rideDirection))
                    }
                }
            }
        }
    }

    private func stopAutoRide() {
        timer?.invalidate()
        timer = nil
    }
}
