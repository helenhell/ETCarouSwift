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
    @State private var autoRideTask: Task<Void, Never>?
    @State private var autoRidePausedByTap: Bool = false
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
                    Color(.systemFill)
                } else if images.count == 1 {
                    images[0]
                        .resizable()
                        .carouImageScale(configuration.imageScale)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .onTapGesture { handleTap(index: 0) }
                } else {
                    let count = images.count
                    let totalPages = count + 2
                    let pageWidth = geometry.size.width
                    let resolvedConfig = configuration.with(viewWidth: pageWidth)
                    let effectiveOffset = scrollOffset - dragOffset / pageWidth
                    let visiblePage = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
                    let currentLogical = configuration.rideDirection.logicalIndex(page: Int(round(visiblePage)), count: count)

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
                                        handleTap(index: configuration.rideDirection.logicalIndex(page: p, count: count))
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
                        .animation(.easeInOut(duration: CarouConstants.snapAnimationDuration), value: scrollOffset)
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
                                    let (snapPage, isWraparound) = CarouScrollLogic.snapTarget(
                                        effectiveOffset: effective,
                                        velocity: velocity,
                                        totalPages: totalPages
                                    )
                                    let scrollPage = CarouScrollLogic.scrollPage(fromSnap: snapPage, totalPages: totalPages, contentCount: count)
                                    if isWraparound {
                                        var t = Transaction()
                                        t.disablesAnimations = true
                                        withTransaction(t) {
                                            scrollOffset = CGFloat(scrollPage)
                                            dragOffset = 0
                                        }
                                    } else {
                                        withAnimation(.easeInOut(duration: CarouConstants.snapAnimationDuration)) {
                                            scrollOffset = CGFloat(scrollPage)
                                            dragOffset = 0
                                        }
                                    }
                                    onImageChanged?(configuration.rideDirection.logicalIndex(page: scrollPage, count: count))
                                    if configuration.autoRideEnabled && !autoRidePausedByTap { startAutoRide() }
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
                        .padding(.bottom, 12)
                    }
                    .frame(width: pageWidth, height: geometry.size.height)
                    .clipped()
                }
            }
        }
        .onAppear {
            if configuration.autoRideEnabled && !autoRidePausedByTap && images.count > 1 { startAutoRide() }
        }
        .onDisappear { stopAutoRide() }
        .onChange(of: configuration.autoRideEnabled) { if !configuration.autoRideEnabled { autoRidePausedByTap = false } }
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

    private func startAutoRide() {
        stopAutoRide()
        let count = images.count
        let totalPages = count + 2
        let direction = configuration.rideDirection
        let showTime = configuration.showTime
        let isRTL = direction == .rightToLeft
        autoRideTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(showTime * 1_000_000_000))
                guard !Task.isCancelled, !isUserInteracting else { return }
                let currentPage = Int(round(scrollOffset))
                let nextPage: Int
                if isRTL {
                    nextPage = (currentPage - 1 + totalPages) % totalPages
                } else {
                    nextPage = (currentPage + 1) % totalPages
                }
                withAnimation(.easeInOut(duration: CarouConstants.autoRideStepDuration)) {
                    scrollOffset = CGFloat(nextPage)
                }
                if nextPage >= 1 && nextPage <= count {
                    onImageChanged?(direction.logicalIndex(page: nextPage, count: count))
                } else {
                    try? await Task.sleep(nanoseconds: UInt64(CarouConstants.autoRideStepDuration * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    let targetPage = (nextPage == 0 ? count : 1)
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { scrollOffset = CGFloat(targetPage) }
                    onImageChanged?(direction.logicalIndex(page: targetPage, count: count))
                }
            }
        }
    }

    private func stopAutoRide() {
        autoRideTask?.cancel()
        autoRideTask = nil
    }

    private func handleTap(index: Int) {
        if configuration.autoRideEnabled && configuration.tapPausesAutoRide && images.count > 1 {
            autoRidePausedByTap.toggle()
            if autoRidePausedByTap {
                stopAutoRide()
            } else {
                startAutoRide()
            }
        }
        onImageTapped?(index)
    }
}
