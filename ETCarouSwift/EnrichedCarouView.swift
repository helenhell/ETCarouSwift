//
//  EnrichedCarouView.swift
//  ETCarouSwift
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI

/// Internal: carousel of CarouItems with configurable layout (overlay/stacked) and card-like appearance.
struct EnrichedCarouView: View {
    @State private var scrollOffset: CGFloat = 1
    @State private var dragOffset: CGFloat = 0
    @State private var autoRideTask: Task<Void, Never>?
    @State private var isUserInteracting: Bool = false
    @State private var lastDragTranslation: CGFloat = 0
    @State private var lastDragTime: TimeInterval = 0

    private let items: [CarouItem]
    private let configuration: CarouViewConfiguration
    private let onItemChanged: ((Int) -> Void)?
    private let onItemTapped: ((Int) -> Void)?
    
    // Layout helpers
    private var layout: EnrichedCarouLayout { configuration.enrichedLayout }
    private var viewAppearance: EnrichedCarouViewAppearance { configuration.enrichedAppearance.view }
    /// When both text and page control use overlay, card configs (inset, border, shadow) are not applicable.
    private var isFullOverlay: Bool {
        layout.textPosition == .overlay && layout.pageControlPosition == .overlay
    }
    private var cardInset: CGFloat {
        isFullOverlay ? 0 : viewAppearance.cardInset
    }
    private var hasCardAppearance: Bool {
        !isFullOverlay && (cardInset > 0 || viewAppearance.backgroundCornerRadius > 0 || viewAppearance.backgroundShadow != nil)
    }

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

    /// Inner height after card inset (top only); used so inset is uniform and no extra top when cardInset = 0.
    private static let pageControlRowHeight: CGFloat = 32
    /// Fixed height for text block (title 1 line + description 2 lines + padding) so image position stays fixed.
    private static let textBlockHeight: CGFloat = 72
    
    /// Returns a value safe for use in frame dimensions (avoids negative or non-finite).
    private static func safeFrameDimension(_ value: CGFloat, minimum: CGFloat = 1) -> CGFloat {
        guard value.isFinite, value >= minimum else { return minimum }
        return value
    }

    var body: some View {
        GeometryReader { geometry in
            let pageWidth = Self.safeFrameDimension(geometry.size.width)
            let totalHeight = Self.safeFrameDimension(geometry.size.height)
            // When cardInset > 0, inner content lives in (pageWidth - 2*cardInset) x (totalHeight - cardInset); padding applied once so top = sides.
            let innerWidth = Self.safeFrameDimension(pageWidth - cardInset * 2)
            let innerHeight = Self.safeFrameDimension(totalHeight - cardInset)
            
            let isTextOverlay = layout.textPosition == .overlay
            let isPageControlOverlay = layout.pageControlPosition == .overlay
            let pageControlHeight: CGFloat = Self.pageControlRowHeight + 4
            
            let stackedBottomHeight = Self.pageControlRowHeight + 4 + Self.textBlockHeight
            let imageHeight: CGFloat = {
                let raw: CGFloat
                if isTextOverlay && isPageControlOverlay {
                    raw = innerHeight
                } else if isTextOverlay {
                    raw = innerHeight - pageControlHeight
                } else if isPageControlOverlay {
                    raw = innerHeight - Self.textBlockHeight
                } else {
                    raw = innerHeight - stackedBottomHeight
                }
                return Self.safeFrameDimension(raw)
            }()

            ZStack {
                if items.isEmpty {
                    Color(.systemFill)
                } else if items.count == 1 {
                    singleItemView(
                        item: items[0],
                        pageWidth: pageWidth,
                        totalHeight: totalHeight,
                        innerWidth: innerWidth,
                        innerHeight: innerHeight,
                        imageHeight: imageHeight,
                        geometry: geometry
                    )
                } else {
                    multiItemView(
                        pageWidth: pageWidth,
                        totalHeight: totalHeight,
                        innerWidth: innerWidth,
                        innerHeight: innerHeight,
                        imageHeight: imageHeight,
                        geometry: geometry
                    )
                }
            }
        }
        .onAppear {
            if configuration.autoRideEnabled && items.count > 1 { startAutoRide() }
        }
        .onDisappear { stopAutoRide() }
    }
    
    // MARK: - Single Item View
    
    private func singleItemView(
        item: CarouItem,
        pageWidth: CGFloat,
        totalHeight: CGFloat,
        innerWidth: CGFloat,
        innerHeight: CGFloat,
        imageHeight: CGFloat,
        geometry: GeometryProxy
    ) -> some View {
        let resolvedConfig = configuration.with(viewWidth: pageWidth)
        
        return cardWrapper(pageWidth: pageWidth, height: totalHeight) {
            contentWithInset(innerWidth: innerWidth, innerHeight: innerHeight) {
                contentLayout(
                    imageContent: {
                        item.image
                            .resizable()
                            .carouImageScale(configuration.imageScale)
                            .frame(width: innerWidth, height: imageHeight)
                            .applyImageBorder(appearance: viewAppearance)
                            .clipped()
                    },
                    pageControl: {
                        CarouPageControl(
                            numberOfPages: 1,
                            currentPage: 0,
                            dotColor: configuration.dotColor,
                            currentDotColor: configuration.currentDotColor,
                            dotSizePoints: resolvedConfig.dotSizePoints,
                            direction: configuration.rideDirection,
                            dotSize: configuration.dotSize,
                            textFont: descriptionFont
                        )
                    },
                    textBlock: {
                        titleDescriptionBlock(item: item, pageWidth: innerWidth)
                    },
                    imageHeight: imageHeight,
                    innerWidth: innerWidth,
                    innerHeight: innerHeight
                )
            }
            .onTapGesture { onItemTapped?(0) }
        }
    }
    
    // MARK: - Multi Item View
    
    private func multiItemView(
        pageWidth: CGFloat,
        totalHeight: CGFloat,
        innerWidth: CGFloat,
        innerHeight: CGFloat,
        imageHeight: CGFloat,
        geometry: GeometryProxy
    ) -> some View {
        let count = items.count
        let totalPages = count + 2
        let resolvedConfig = configuration.with(viewWidth: pageWidth)
        let effectiveOffset = scrollOffset - dragOffset / innerWidth
        let visiblePage = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
        let currentLogical = configuration.rideDirection.logicalIndex(page: Int(round(visiblePage)), count: count)
        
        return cardWrapper(pageWidth: pageWidth, height: totalHeight) {
            contentWithInset(innerWidth: innerWidth, innerHeight: innerHeight) {
                contentLayout(
                    imageContent: {
                        imageStrip(
                            count: count,
                            totalPages: totalPages,
                            innerWidth: innerWidth,
                            imageHeight: imageHeight
                        )
                    },
                    pageControl: {
                        CarouPageControl(
                            numberOfPages: count,
                            currentPage: currentLogical,
                            dotColor: configuration.dotColor,
                            currentDotColor: configuration.currentDotColor,
                            dotSizePoints: resolvedConfig.dotSizePoints,
                            direction: configuration.rideDirection,
                            dotSize: configuration.dotSize,
                            textFont: descriptionFont
                        )
                    },
                    textBlock: {
                        titleDescriptionBlock(item: items[currentLogical], pageWidth: innerWidth)
                            .id(currentLogical)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.25), value: currentLogical)
                    },
                    imageHeight: imageHeight,
                    innerWidth: innerWidth,
                    innerHeight: innerHeight
                )
            }
        }
    }
    
    /// Applies card inset once so top = leading = trailing; when cardInset = 0 no padding, content still framed to inner size.
    @ViewBuilder
    private func contentWithInset<Content: View>(innerWidth: CGFloat, innerHeight: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        let inner = content()
            .frame(width: innerWidth, height: innerHeight)
        if cardInset > 0 {
            inner
                .padding(EdgeInsets(top: cardInset, leading: cardInset, bottom: 0, trailing: cardInset))
        } else {
            inner
        }
    }
    
    // MARK: - Image Strip
    
    private func imageStrip(
        count: Int,
        totalPages: Int,
        innerWidth: CGFloat,
        imageHeight: CGFloat
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<totalPages, id: \.self) { p in
                let idx = configuration.rideDirection.logicalIndex(page: p, count: count)
                items[idx].image
                    .resizable()
                    .carouImageScale(configuration.imageScale)
                    .frame(width: innerWidth, height: imageHeight)
                    .applyImageBorder(appearance: viewAppearance)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onItemTapped?(configuration.rideDirection.logicalIndex(page: p, count: count))
                    }
            }
        }
        .frame(width: CGFloat(totalPages) * innerWidth, height: imageHeight)
        .fixedSize(horizontal: true, vertical: false)
        .offset(x: -scrollOffset * innerWidth + dragOffset)
        .frame(width: innerWidth, height: imageHeight, alignment: .leading)
        .clipped()
        .transaction { t in
            if isUserInteracting { t.animation = nil; t.disablesAnimations = true }
        }
        .animation(.easeInOut(duration: CarouConstants.snapAnimationDuration), value: scrollOffset)
        .gesture(dragGesture(count: count, totalPages: totalPages, pageWidth: innerWidth))
    }
    
    // MARK: - Content Layout (handles overlay vs stacked)
    
    @ViewBuilder
    private func contentLayout<ImageContent: View, PageControlContent: View, TextContent: View>(
        imageContent: () -> ImageContent,
        pageControl: () -> PageControlContent,
        textBlock: () -> TextContent,
        imageHeight: CGFloat,
        innerWidth: CGFloat,
        innerHeight: CGFloat
    ) -> some View {
        let isTextOverlay = layout.textPosition == .overlay
        let isPageControlOverlay = layout.pageControlPosition == .overlay
        
        if isTextOverlay && isPageControlOverlay {
            ZStack(alignment: .bottom) {
                imageContent()
                    .frame(height: imageHeight)
                
                VStack(spacing: 8) {
                    textBlock()
                        .background(overlayTextBackground)
                    pageControl()
                        .frame(height: Self.pageControlRowHeight)
                }
                .padding(.bottom, 12)
            }
            
        } else if isTextOverlay {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    imageContent()
                        .frame(height: imageHeight)
                    
                    textBlock()
                        .background(overlayTextBackground)
                        .padding(.bottom, 8)
                }
                
                pageControl()
                    .frame(height: Self.pageControlRowHeight)
                    .padding(.top, 4)
            }
            
        } else if isPageControlOverlay {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    imageContent()
                        .frame(height: imageHeight)
                    
                    pageControl()
                        .frame(height: Self.pageControlRowHeight)
                        .padding(.bottom, 8)
                }
                
                textBlock()
            }
            
        } else {
            VStack(spacing: 0) {
                imageContent()
                    .frame(height: imageHeight)
                
                pageControl()
                    .frame(height: Self.pageControlRowHeight)
                    .padding(.top, 4)
                
                textBlock()
                    .frame(height: Self.textBlockHeight)
            }
        }
    }
    
    // MARK: - Card Wrapper
    
    /// Applies card-like background and optional styling (border, corner radius, shadow).
    /// When in full overlay layout, card styling is skipped; background only.
    @ViewBuilder
    private func cardWrapper<Content: View>(pageWidth: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        let cornerRadius = viewAppearance.backgroundCornerRadius
        let borderWidth = viewAppearance.backgroundBorderWidth
        let borderColor = viewAppearance.backgroundBorderColor
        let shadow = viewAppearance.backgroundShadow
        let shape = RoundedRectangle(cornerRadius: max(0, cornerRadius))
        
        let base = ZStack {
            shape.fill(Color(.systemBackground))
            content()
        }
        .frame(width: pageWidth, height: height)
        
        if isFullOverlay {
            base
        } else if cornerRadius > 0 {
            base
                .clipShape(shape)
                .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
                .applyCardShadow(shadow)
        } else {
            base
                .overlay(Rectangle().stroke(borderColor, lineWidth: borderWidth))
                .applyCardShadow(shadow)
        }
    }
    
    // MARK: - Overlay Text Background
    
    private var overlayTextBackground: some View {
        LinearGradient(
            colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Drag Gesture
    
    private func dragGesture(count: Int, totalPages: Int, pageWidth: CGFloat) -> some Gesture {
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
                onItemChanged?(configuration.rideDirection.logicalIndex(page: scrollPage, count: count))
                if configuration.autoRideEnabled { startAutoRide() }
            }
    }

    // MARK: - Font Helpers
    
    private var titleFont: Font {
        let viewAppearance = configuration.enrichedAppearance.view
        return CarouFontHelper.font(
            name: viewAppearance.titleFontName,
            size: viewAppearance.titleFontSize,
            bundle: viewAppearance.titleFontBundle,
            weight: .semibold
        )
    }
    
    private var descriptionFont: Font {
        let viewAppearance = configuration.enrichedAppearance.view
        return CarouFontHelper.font(
            name: viewAppearance.descriptionFontName,
            size: viewAppearance.descriptionFontSize,
            bundle: viewAppearance.descriptionFontBundle,
            weight: .regular
        )
    }
    
    private var textHorizontalAlignment: HorizontalAlignment {
        switch configuration.enrichedAppearance.view.textAlignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
    
    private var textFrameAlignment: Alignment {
        switch configuration.enrichedAppearance.view.textAlignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
    
    private func titleDescriptionBlock(item: CarouItem, pageWidth: CGFloat) -> some View {
        let viewAppearance = configuration.enrichedAppearance.view
        
        return VStack(alignment: textHorizontalAlignment, spacing: 4) {
            if let title = item.title, !title.isEmpty {
                Text(title)
                    .font(titleFont)
                    .foregroundColor(viewAppearance.titleColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            if let desc = item.description, !desc.isEmpty {
                Text(desc)
                    .font(descriptionFont)
                    .foregroundColor(viewAppearance.descriptionColor)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: textFrameAlignment)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func startAutoRide() {
        stopAutoRide()
        let count = items.count
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
                    onItemChanged?(direction.logicalIndex(page: nextPage, count: count))
                } else {
                    try? await Task.sleep(nanoseconds: UInt64(CarouConstants.autoRideStepDuration * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    let targetPage = (nextPage == 0 ? count : 1)
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { scrollOffset = CGFloat(targetPage) }
                    onItemChanged?(direction.logicalIndex(page: targetPage, count: count))
                }
            }
        }
    }

    private func stopAutoRide() {
        autoRideTask?.cancel()
        autoRideTask = nil
    }
}

// MARK: - View Extensions for Card Appearance

private extension View {
    /// Applies image border based on appearance settings.
    @ViewBuilder
    func applyImageBorder(appearance: EnrichedCarouViewAppearance) -> some View {
        if appearance.imageBorderWidth > 0 {
            self.overlay(
                Rectangle()
                    .stroke(appearance.imageBorderColor, lineWidth: appearance.imageBorderWidth)
            )
        } else {
            self
        }
    }
    
    /// Applies card shadow based on shadow settings.
    @ViewBuilder
    func applyCardShadow(_ shadow: CarouShadow?) -> some View {
        if let shadow = shadow {
            self.shadow(
                color: shadow.color,
                radius: shadow.radius,
                x: shadow.x,
                y: shadow.y
            )
        } else {
            self
        }
    }
}
