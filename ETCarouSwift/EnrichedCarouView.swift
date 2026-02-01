//
//  EnrichedCarouView.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

/// Internal: carousel of CarouItems — image strip slides like basic; page control below image; title & description below page control with fade-in on change.
struct EnrichedCarouView: View {
    @State private var scrollOffset: CGFloat = 1
    @State private var dragOffset: CGFloat = 0
    @State private var timer: Timer?
    @State private var isUserInteracting: Bool = false
    @State private var lastDragTranslation: CGFloat = 0
    @State private var lastDragTime: TimeInterval = 0

    private let items: [CarouItem]
    private let configuration: CarouViewConfiguration
    private let onItemChanged: ((Int) -> Void)?
    private let onItemTapped: ((Int) -> Void)?

    init(
        items: [CarouItem],
        configuration: CarouViewConfiguration = CarouViewConfiguration(),
        onItemChanged: ((Int) -> Void)? = nil,
        onItemTapped: ((Int) -> Void)? = nil
    ) {
        self.items = items
        self.configuration = configuration
        self.onItemChanged = onItemChanged
        self.onItemTapped = onItemTapped
        let count = items.count
        let initialPage: CGFloat = count <= 1 ? 1 : (configuration.rideDirection == .rightToLeft ? CGFloat(count) : 1)
        _scrollOffset = State(initialValue: initialPage)
    }

    var body: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width
            let imageHeight = geometry.size.height * 0.55
            let textHeight = geometry.size.height - imageHeight

            ZStack {
                if items.isEmpty {
                    Color.blue
                } else if items.count == 1 {
                    VStack(spacing: 0) {
                        imageStripSection(pageWidth: pageWidth, imageHeight: imageHeight, count: 1, singleItem: items[0])
                        CarouPageControl(
                            numberOfPages: 1,
                            currentPage: 0,
                            dotColor: configuration.dotColor,
                            currentDotColor: configuration.currentDotColor,
                            dotSizePoints: configuration.with(viewWidth: pageWidth).dotSizePoints,
                            direction: configuration.rideDirection
                        )
                        .frame(height: 28)
                        titleDescriptionBlock(item: items[0], pageWidth: pageWidth)
                            .frame(height: textHeight - 28)
                    }
                    .frame(width: pageWidth, height: geometry.size.height)
                    .onTapGesture { onItemTapped?(0) }
                } else {
                    let count = items.count
                    let totalPages = count + 2
                    let resolvedConfig = configuration.with(viewWidth: pageWidth)
                    let effectiveOffset = scrollOffset - dragOffset / pageWidth
                    let visiblePage = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
                    let currentLogical = logicalIndex(for: Int(round(visiblePage)), count: count, direction: configuration.rideDirection)

                    VStack(spacing: 0) {
                        // 1. Image strip only (slides like basic)
                        HStack(spacing: 0) {
                            ForEach(0..<totalPages, id: \.self) { p in
                                let idx = logicalIndex(for: p, count: count, direction: configuration.rideDirection)
                                items[idx].image
                                    .resizable()
                                    .carouImageScale(configuration.imageScale)
                                    .frame(width: pageWidth, height: imageHeight)
                                    .clipped()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        onItemTapped?(logicalIndex(for: p, count: count, direction: configuration.rideDirection))
                                    }
                            }
                        }
                        .frame(width: CGFloat(totalPages) * pageWidth, height: imageHeight)
                        .fixedSize(horizontal: true, vertical: false)
                        .offset(x: -scrollOffset * pageWidth + dragOffset)
                        .frame(width: pageWidth, height: imageHeight, alignment: .leading)
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
                                    onItemChanged?(logicalIndex(for: snap, count: count, direction: configuration.rideDirection))
                                    if configuration.autoRideEnabled { startAutoRide() }
                                }
                        )
                        .frame(height: imageHeight)

                        // 2. Page control right below the image
                        CarouPageControl(
                            numberOfPages: count,
                            currentPage: currentLogical,
                            dotColor: configuration.dotColor,
                            currentDotColor: configuration.currentDotColor,
                            dotSizePoints: resolvedConfig.dotSizePoints,
                            direction: configuration.rideDirection
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .padding(.vertical, 6)

                        // 3. Title & description below page control (fade when index changes)
                        titleDescriptionBlock(item: items[currentLogical], pageWidth: pageWidth)
                            .id(currentLogical)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.25), value: currentLogical)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: textHeight - 44) // 32 + 6*2 for page control row
                    }
                    .frame(width: pageWidth, height: geometry.size.height)
                    .clipped()
                }
            }
        }
        .onAppear {
            if configuration.autoRideEnabled && items.count > 1 { startAutoRide() }
        }
        .onDisappear { stopAutoRide() }
    }

    private func imageStripSection(pageWidth: CGFloat, imageHeight: CGFloat, count: Int, singleItem: CarouItem) -> some View {
        singleItem.image
            .resizable()
            .carouImageScale(configuration.imageScale)
            .frame(width: pageWidth, height: imageHeight)
            .clipped()
    }

    private func titleDescriptionBlock(item: CarouItem, pageWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = item.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
            }
            if let desc = item.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
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
        let count = items.count
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
                    onItemChanged?(logicalIndex(for: nextPage, count: count, direction: configuration.rideDirection))
                } else {
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                        let targetPage = (nextPage == 0 ? count : 1)
                        var t = Transaction()
                        t.disablesAnimations = true
                        withTransaction(t) { scrollOffset = CGFloat(targetPage) }
                        onItemChanged?(logicalIndex(for: targetPage, count: count, direction: configuration.rideDirection))
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
