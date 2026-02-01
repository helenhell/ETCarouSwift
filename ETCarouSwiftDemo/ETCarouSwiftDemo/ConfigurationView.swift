//
//  ConfigurationView.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
import ETCarouSwift

enum CarouselDemoMode: String, CaseIterable {
    case basic = "Basic"
    case enriched = "Enriched"
}

struct ConfigurationView: View {
    // MARK: - Mode
    @State private var carouselMode: CarouselDemoMode = .basic
    @State private var dataSetSize: DemoDataSetSize = .small
    
    // MARK: - Behavior (shared)
    @State private var rideDirection: CarouDirection = .leftToRight
    @State private var autoRideEnabled: Bool = true
    @State private var showTime: Double = 2.0
    @State private var imageScale: CarouImageScale = .fill
    
    // MARK: - PageControl Appearance (shared)
    @State private var dotColor: Color = .gray
    @State private var currentDotColor: Color = .blue
    @State private var dotSize: CarouDotSize = .medium
    
    // MARK: - Enriched Layout
    @State private var pageControlPosition: PageControlPosition = .stacked
    @State private var textPosition: TextPosition = .stacked
    
    // MARK: - Enriched Text Appearance
    @State private var textAlignment: TextAlignment = .leading
    @State private var titleColor: Color = .primary
    @State private var descriptionColor: Color = .secondary
    @State private var titleFontSize: Double = 17
    @State private var descriptionFontSize: Double = 15
    
    // MARK: - Enriched Card Appearance
    @State private var cardInset: Double = 0
    @State private var imageBorderEnabled: Bool = false
    @State private var imageBorderWidth: Double = 0
    @State private var imageBorderColor: Color = .gray
    @State private var backgroundBorderEnabled: Bool = false
    @State private var backgroundBorderWidth: Double = 0
    @State private var backgroundBorderColor: Color = .gray
    @State private var backgroundCornerRadius: Double = 0
    @State private var shadowEnabled: Bool = false
    
    @State private var showDemo = false

    private var builtConfiguration: CarouViewConfiguration {
        let behavior = CarouBehavior(
            rideDirection: rideDirection,
            autoRideEnabled: autoRideEnabled,
            showTime: showTime,
            imageScale: imageScale
        )
        
        let pageControlAppearance = CarouPageControlAppearance(
            dotColor: dotColor,
            currentDotColor: currentDotColor,
            dotSize: dotSize
        )
        
        let enrichedLayout = EnrichedCarouLayout(
            pageControlPosition: pageControlPosition,
            textPosition: textPosition
        )
        
        let viewAppearance = EnrichedCarouViewAppearance(
            textAlignment: textAlignment,
            titleColor: titleColor,
            descriptionColor: descriptionColor,
            titleFontName: nil,
            titleFontSize: titleFontSize,
            titleFontBundle: nil,
            descriptionFontName: nil,
            descriptionFontSize: descriptionFontSize,
            descriptionFontBundle: nil,
            cardInset: cardInset,
            imageBorderWidth: imageBorderEnabled ? imageBorderWidth : 0,
            imageBorderColor: imageBorderColor,
            backgroundBorderWidth: backgroundBorderEnabled ? backgroundBorderWidth : 0,
            backgroundBorderColor: backgroundBorderColor,
            backgroundCornerRadius: backgroundCornerRadius,
            backgroundShadow: shadowEnabled ? CarouShadow.default : nil
        )
        
        let enrichedAppearance = EnrichedCarouAppearance(
            pageControl: pageControlAppearance,
            view: viewAppearance
        )
        
        return CarouViewConfiguration(
            behavior: behavior,
            pageControlAppearance: pageControlAppearance,
            enrichedLayout: enrichedLayout,
            enrichedAppearance: enrichedAppearance
        )
    }

    var body: some View {
        Form {
            Section("Carousel type") {
                Picker("Mode", selection: $carouselMode) {
                    ForEach(CarouselDemoMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Data set", selection: $dataSetSize) {
                    ForEach(DemoDataSetSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Direction & Auto-ride") {
                Picker("Direction", selection: $rideDirection) {
                    Text("Right to Left").tag(CarouDirection.rightToLeft)
                    Text("Left to Right").tag(CarouDirection.leftToRight)
                }
                .pickerStyle(.menu)

                Toggle("Auto-ride enabled", isOn: $autoRideEnabled)

                if autoRideEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Slide duration")
                            Spacer()
                            Text(String(format: "%.1f s", showTime))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $showTime, in: 0.5...5.0, step: 0.5)
                    }
                }
            }

            Section("Page dots") {
                Picker("Dot size", selection: $dotSize) {
                    Text("Small").tag(CarouDotSize.small)
                    Text("Medium").tag(CarouDotSize.medium)
                    Text("Large").tag(CarouDotSize.large)
                }
                .pickerStyle(.menu)

                ColorPicker("Dot color", selection: $dotColor)
                ColorPicker("Current dot color", selection: $currentDotColor)
            }

            Section("Image") {
                Picker("Image scale", selection: $imageScale) {
                    Text("Fill").tag(CarouImageScale.fill)
                    Text("Fit").tag(CarouImageScale.fit)
                }
                .pickerStyle(.menu)
            }
            
            // MARK: - Enriched-specific sections
            if carouselMode == .enriched {
                Section("Layout (Enriched)") {
                    Picker("PageControl position", selection: $pageControlPosition) {
                        Text("Stacked").tag(PageControlPosition.stacked)
                        Text("Overlay").tag(PageControlPosition.overlay)
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Text position", selection: $textPosition) {
                        Text("Stacked").tag(TextPosition.stacked)
                        Text("Overlay").tag(TextPosition.overlay)
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Text Style (Enriched)") {
                    Picker("Text alignment", selection: $textAlignment) {
                        Text("Leading").tag(TextAlignment.leading)
                        Text("Center").tag(TextAlignment.center)
                        Text("Trailing").tag(TextAlignment.trailing)
                    }
                    .pickerStyle(.menu)
                    
                    ColorPicker("Title color", selection: $titleColor)
                    ColorPicker("Description color", selection: $descriptionColor)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Title font size")
                            Spacer()
                            Text(String(format: "%.0f pt", titleFontSize))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $titleFontSize, in: 12...24, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Description font size")
                            Spacer()
                            Text(String(format: "%.0f pt", descriptionFontSize))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $descriptionFontSize, in: 10...20, step: 1)
                    }
                }
                
                Section("Card Style (Enriched)") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Card inset")
                            Spacer()
                            Text(String(format: "%.0f pt", cardInset))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $cardInset, in: 0...30, step: 5)
                    }
                }
                
                Section("Image Border (Enriched)") {
                    Toggle("Enable image border", isOn: $imageBorderEnabled)
                    
                    if imageBorderEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Border width")
                                Spacer()
                                Text(String(format: "%.0f pt", imageBorderWidth))
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $imageBorderWidth, in: 1...10, step: 1)
                        }
                        
                        ColorPicker("Border color", selection: $imageBorderColor)
                    }
                }
                
                Section("Background Border (Enriched)") {
                    Toggle("Enable background border", isOn: $backgroundBorderEnabled)
                    
                    if backgroundBorderEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Border width")
                                Spacer()
                                Text(String(format: "%.0f pt", backgroundBorderWidth))
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $backgroundBorderWidth, in: 1...10, step: 1)
                        }
                        
                        ColorPicker("Border color", selection: $backgroundBorderColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Corner radius")
                            Spacer()
                            Text(String(format: "%.0f pt", backgroundCornerRadius))
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $backgroundCornerRadius, in: 0...30, step: 5)
                    }
                    
                    Toggle("Enable shadow", isOn: $shadowEnabled)
                }
            }

            Section {
                Button {
                    showDemo = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Launch Demo")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
                .listRowBackground(
                    Rectangle()
                        .fill(Color.blue)
                        .ignoresSafeArea(edges: .horizontal)
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("Carousel Config")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showDemo) {
            CarouselDemoView(configuration: builtConfiguration, mode: carouselMode, dataSetSize: dataSetSize)
        }
    }
}

#Preview {
    NavigationStack {
        ConfigurationView()
    }
}
