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
    @State private var timer: Timer?
    @State private var isUserInteracting: Bool = false
    @State private var lastDragTranslation: CGFloat = 0
    @State private var lastDragTime: TimeInterval = 0
    @State private var textBlockHeight: CGFloat = 60

    private let items: [CarouItem]
    private let configuration: CarouViewConfiguration
    private let onItemChanged: ((Int) -> Void)?
    private let onItemTapped: ((Int) -> Void)?
    
    // Layout helpers
    private var layout: EnrichedCarouLayout { configuration.enrichedLayout }
    private var viewAppearance: EnrichedCarouViewAppearance { configuration.enrichedAppearance.view }
    private var insets: EdgeInsets { viewAppearance.imageBackgroundInset }
    private var hasCardAppearance: Bool {
        insets.top > 0 || insets.leading > 0 || insets.trailing > 0 ||
        viewAppearance.backgroundCornerRadius > 0 || viewAppearance.backgroundShadow != nil
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

    var body: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width
            let availableWidth = pageWidth - insets.leading - insets.trailing
            
            // Calculate heights based on layout mode
            let isTextOverlay = layout.textPosition == .overlay
            let isPageControlOverlay = layout.pageControlPosition == .overlay
            
            // When stacked: image takes ~55%, rest for page control + text
            // When overlay: image takes full height minus top inset
            let stackedTextAreaHeight: CGFloat = 100  // Fixed area for stacked text
            let pageControlHeight: CGFloat = 44  // Page control row height
            
            let imageHeight: CGFloat = {
                if isTextOverlay && isPageControlOverlay {
                    return geometry.size.height - insets.top - (viewAppearance.bottomInsetFollowsContent ? 0 : insets.bottom)
                } else if isTextOverlay {
                    return geometry.size.height - insets.top - pageControlHeight
                } else if isPageControlOverlay {
                    return geometry.size.height * 0.55 - insets.top
                } else {
                    return geometry.size.height * 0.55 - insets.top
                }
            }()

            ZStack {
                if items.isEmpty {
                    Color.blue
                } else if items.count == 1 {
                    singleItemView(
                        item: items[0],
                        pageWidth: pageWidth,
                        availableWidth: availableWidth,
                        imageHeight: imageHeight,
                        geometry: geometry
                    )
                } else {
                    multiItemView(
                        pageWidth: pageWidth,
                        availableWidth: availableWidth,
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
        availableWidth: CGFloat,
        imageHeight: CGFloat,
        geometry: GeometryProxy
    ) -> some View {
        let resolvedConfig = configuration.with(viewWidth: pageWidth)
        
        return cardWrapper(pageWidth: pageWidth, height: geometry.size.height) {
            contentLayout(
                imageContent: {
                    item.image
                        .resizable()
                        .carouImageScale(configuration.imageScale)
                        .frame(width: availableWidth, height: imageHeight)
                        .applyImageFrame(appearance: viewAppearance)
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
                        textFont: descriptionFont,
                        textColor: viewAppearance.descriptionColor
                    )
                },
                textBlock: {
                    titleDescriptionBlock(item: item, pageWidth: availableWidth)
                },
                imageHeight: imageHeight,
                availableWidth: availableWidth,
                totalHeight: geometry.size.height
            )
            .onTapGesture { onItemTapped?(0) }
        }
    }
    
    // MARK: - Multi Item View
    
    private func multiItemView(
        pageWidth: CGFloat,
        availableWidth: CGFloat,
        imageHeight: CGFloat,
        geometry: GeometryProxy
    ) -> some View {
        let count = items.count
        let totalPages = count + 2
        let resolvedConfig = configuration.with(viewWidth: pageWidth)
        let effectiveOffset = scrollOffset - dragOffset / availableWidth
        let visiblePage = max(0, min(CGFloat(totalPages - 1), effectiveOffset))
        let currentLogical = logicalIndex(for: Int(round(visiblePage)), count: count, direction: configuration.rideDirection)
        
        return cardWrapper(pageWidth: pageWidth, height: geometry.size.height) {
            contentLayout(
                imageContent: {
                    imageStrip(
                        count: count,
                        totalPages: totalPages,
                        availableWidth: availableWidth,
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
                        textFont: descriptionFont,
                        textColor: viewAppearance.descriptionColor
                    )
                },
                textBlock: {
                    titleDescriptionBlock(item: items[currentLogical], pageWidth: availableWidth)
                        .id(currentLogical)
                        .transition(.opacity)
                        .animation(.easeIn(duration: 0.25), value: currentLogical)
                },
                imageHeight: imageHeight,
                availableWidth: availableWidth,
                totalHeight: geometry.size.height
            )
        }
    }
    
    // MARK: - Image Strip
    
    private func imageStrip(
        count: Int,
        totalPages: Int,
        availableWidth: CGFloat,
        imageHeight: CGFloat
    ) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<totalPages, id: \.self) { p in
                let idx = logicalIndex(for: p, count: count, direction: configuration.rideDirection)
                items[idx].image
                    .resizable()
                    .carouImageScale(configuration.imageScale)
                    .frame(width: availableWidth, height: imageHeight)
                    .applyImageFrame(appearance: viewAppearance)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onItemTapped?(logicalIndex(for: p, count: count, direction: configuration.rideDirection))
                    }
            }
        }
        .frame(width: CGFloat(totalPages) * availableWidth, height: imageHeight)
        .fixedSize(horizontal: true, vertical: false)
        .offset(x: -scrollOffset * availableWidth + dragOffset)
        .frame(width: availableWidth, height: imageHeight, alignment: .leading)
        .clipped()
        .transaction { t in
            if isUserInteracting { t.animation = nil; t.disablesAnimations = true }
        }
        .animation(.easeInOut(duration: 0.3), value: scrollOffset)
        .gesture(dragGesture(count: count, totalPages: totalPages, pageWidth: availableWidth))
    }
    
    // MARK: - Content Layout (handles overlay vs stacked)
    
    @ViewBuilder
    private func contentLayout<ImageContent: View, PageControlContent: View, TextContent: View>(
        imageContent: () -> ImageContent,
        pageControl: () -> PageControlContent,
        textBlock: () -> TextContent,
        imageHeight: CGFloat,
        availableWidth: CGFloat,
        totalHeight: CGFloat
    ) -> some View {
        let isTextOverlay = layout.textPosition == .overlay
        let isPageControlOverlay = layout.pageControlPosition == .overlay
        
        if isTextOverlay && isPageControlOverlay {
            // Both overlay: ZStack with image, page control at bottom, text at bottom
            ZStack(alignment: .bottom) {
                imageContent()
                    .frame(height: imageHeight)
                
                VStack(spacing: 8) {
                    textBlock()
                        .background(overlayTextBackground)
                    pageControl()
                        .frame(height: 32)
                }
                .padding(.bottom, 12)
            }
            .padding(.top, insets.top)
            .padding(.leading, insets.leading)
            .padding(.trailing, insets.trailing)
            
        } else if isTextOverlay {
            // Text overlay, page control stacked
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    imageContent()
                        .frame(height: imageHeight)
                    
                    textBlock()
                        .background(overlayTextBackground)
                        .padding(.bottom, 12)
                }
                .padding(.top, insets.top)
                .padding(.leading, insets.leading)
                .padding(.trailing, insets.trailing)
                
                pageControl()
                    .frame(height: 32)
                    .padding(.vertical, 6)
            }
            
        } else if isPageControlOverlay {
            // Page control overlay, text stacked
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    imageContent()
                        .frame(height: imageHeight)
                    
                    pageControl()
                        .frame(height: 32)
                        .padding(.bottom, 8)
                }
                .padding(.top, insets.top)
                .padding(.leading, insets.leading)
                .padding(.trailing, insets.trailing)
                
                textBlock()
                    .frame(maxHeight: .infinity)
            }
            
        } else {
            // Both stacked (default)
            VStack(spacing: 0) {
                imageContent()
                    .frame(height: imageHeight)
                    .padding(.top, insets.top)
                    .padding(.leading, insets.leading)
                    .padding(.trailing, insets.trailing)
                
                pageControl()
                    .frame(height: 32)
                    .padding(.vertical, 6)
                
                textBlock()
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Card Wrapper
    
    @ViewBuilder
    private func cardWrapper<Content: View>(pageWidth: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        let cornerRadius = viewAppearance.backgroundCornerRadius
        let frameWidth = viewAppearance.backgroundFrameWidth
        let frameColor = viewAppearance.backgroundFrameColor
        let shadow = viewAppearance.backgroundShadow
        
        content()
            .frame(width: pageWidth, height: height)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(frameColor, lineWidth: frameWidth)
            )
            .applyCardShadow(shadow)
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
            }
            if let desc = item.description, !desc.isEmpty {
                Text(desc)
                    .font(descriptionFont)
                    .foregroundColor(viewAppearance.descriptionColor)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: textFrameAlignment)
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

// MARK: - View Extensions for Card Appearance

private extension View {
    /// Applies image frame (border) based on appearance settings.
    @ViewBuilder
    func applyImageFrame(appearance: EnrichedCarouViewAppearance) -> some View {
        if appearance.imageFrameWidth > 0 {
            self.overlay(
                Rectangle()
                    .stroke(appearance.imageFrameColor, lineWidth: appearance.imageFrameWidth)
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
