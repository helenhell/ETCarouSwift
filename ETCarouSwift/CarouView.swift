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

public enum CarouDirection {
    case leftToRight, rightToLeft
}

public enum CarouDotSize: CGFloat {
    case small = 1.0
    case medium = 1.5
    case large = 2.0
}

public struct CarouView: View {
    /// Display page index in extended array: [copyOfLast, 0, 1, ..., n-1, copyOfFirst]. Start at 1 (first original).
    @State private var pageIndex: Int = 1
    @State private var timer: Timer?
    @State private var isUserInteracting: Bool = false
    
    private let images: [Image]
    private let rideDirection: CarouDirection
    private let autoRideEnabled: Bool
    private let showTime: Double
    private let dotColor: Color
    private let currentDotColor: Color
    private let dotSize: CarouDotSize
    
    private let onImageChanged: ((Int) -> Void)?
    private let onImageTapped: ((Int) -> Void)?
    
    public init(
        imageSet: [Image],
        rideDirection: CarouDirection = .rightToLeft,
        autoRideEnabled: Bool = true,
        showTime: Double = 2.0,
        dotColor: Color = .white,
        currentDotColor: Color = .black,
        dotSize: CarouDotSize = .small,
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.images = imageSet
        self.rideDirection = rideDirection
        self.autoRideEnabled = autoRideEnabled
        self.showTime = showTime
        self.dotColor = dotColor
        self.currentDotColor = currentDotColor
        self.dotSize = dotSize
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
                    // Multiple images - UIKit-style infinite carousel: [copyOfLast, 0, 1, ..., n-1, copyOfFirst]
                    let count = images.count
                    let totalPages = count + 2
                    TabView(selection: $pageIndex) {
                        ForEach(0..<totalPages, id: \.self) { p in
                            imageForPage(p, count: count)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .tag(p)
                                .onTapGesture {
                                    onImageTapped?(logicalIndex(for: p, count: count))
                                }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.35), value: pageIndex)
                    .onChange(of: pageIndex) { newPage in
                        // Seamless wraparound: jump from copy to original with same easeInOut so it doesn't catch the eye
                        if newPage == totalPages - 1 {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                pageIndex = 1
                            }
                            return
                        }
                        if newPage == 0 {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                pageIndex = count
                            }
                            return
                        }
                        if !isUserInteracting {
                            onImageChanged?(logicalIndex(for: newPage, count: count))
                        }
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { _ in
                                isUserInteracting = true
                                stopAutoRide()
                            }
                            .onEnded { _ in
                                isUserInteracting = false
                                if autoRideEnabled { startAutoRide() }
                            }
                    )
                    .overlay(alignment: .bottom) {
                        CarouPageControl(
                            numberOfPages: count,
                            currentPage: logicalIndex(for: pageIndex, count: count),
                            dotColor: dotColor,
                            currentDotColor: currentDotColor,
                            dotSize: dotSize
                        )
                        .frame(height: geometry.size.height * 0.25)
                        .padding(.bottom, geometry.size.height * 0.05)
                    }
                }
            }
        }
        .onAppear {
            if autoRideEnabled && images.count > 1 {
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
        if page == 0 { return count - 1 }
        if page == count + 1 { return 0 }
        return page - 1
    }
    
    private func startAutoRide() {
        stopAutoRide()
        let count = images.count
        let totalPages = count + 2
        timer = Timer.scheduledTimer(withTimeInterval: showTime, repeats: true) { _ in
            guard !isUserInteracting else { return }
            Task { @MainActor in
                let nextPage = rideDirection == .rightToLeft
                    ? (pageIndex + 1) % totalPages
                    : (pageIndex - 1 + totalPages) % totalPages
                // Use same slide transition as user swipe (easeInOut so it looks identical)
                withAnimation(.easeInOut(duration: 0.35)) {
                    pageIndex = nextPage
                }
                // Only call here when stable; onChange handles jump and callback for 0 / totalPages-1
                if nextPage >= 1 && nextPage <= count {
                    onImageChanged?(logicalIndex(for: nextPage, count: count))
                }
            }
        }
    }
    
    private func stopAutoRide() {
        timer?.invalidate()
        timer = nil
    }
    
    public var carouIndex: Int {
        logicalIndex(for: pageIndex, count: images.count)
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
        rideDirection: CarouDirection = .rightToLeft,
        autoRideEnabled: Bool = true,
        showTime: Double = 2.0,
        dotColor: Color = .white,
        currentDotColor: Color = .black,
        dotSize: CarouDotSize = .small,
        onImageChanged: ((Int) -> Void)? = nil,
        onImageTapped: ((Int) -> Void)? = nil
    ) {
        self.images = imageSet.map { Image(uiImage: $0) }
        self.rideDirection = rideDirection
        self.autoRideEnabled = autoRideEnabled
        self.showTime = showTime
        self.dotColor = dotColor
        self.currentDotColor = currentDotColor
        self.dotSize = dotSize
        self.onImageChanged = onImageChanged
        self.onImageTapped = onImageTapped
    }
}

