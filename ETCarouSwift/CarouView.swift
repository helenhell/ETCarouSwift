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
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    @State private var dragOffset: CGFloat = 0
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
                    // Multiple images - infinite carousel using TabView
                    TabView(selection: $currentIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            images[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .tag(index)
                                .onTapGesture {
                                    onImageTapped?(index)
                                }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .never))
                    .onChange(of: currentIndex) { newIndex in
                        if !isUserInteracting {
                            onImageChanged?(newIndex)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { _ in
                                isUserInteracting = true
                                stopAutoRide()
                            }
                            .onEnded { _ in
                                isUserInteracting = false
                                if autoRideEnabled {
                                    startAutoRide()
                                }
                            }
                    )
                    .overlay(alignment: .bottom) {
                        CarouPageControl(
                            numberOfPages: images.count,
                            currentPage: currentIndex,
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
    
    private func startAutoRide() {
        stopAutoRide()
        timer = Timer.scheduledTimer(withTimeInterval: showTime, repeats: true) { _ in
            guard !isUserInteracting else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                if rideDirection == .rightToLeft {
                    currentIndex = (currentIndex + 1) % images.count
                } else {
                    currentIndex = (currentIndex - 1 + images.count) % images.count
                }
            }
            onImageChanged?(currentIndex)
        }
    }
    
    private func stopAutoRide() {
        timer?.invalidate()
        timer = nil
    }
    
    public var carouIndex: Int {
        currentIndex
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

// MARK: - UIImage Extension (for backward compatibility)
extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
