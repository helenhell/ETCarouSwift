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

/// Font choice for enriched carousel text (title and description).
enum CarouselDemoFont: String, CaseIterable {
    case system = "System"
    case nunito = "Nunito"
}

/// Value used for navigation to the demo screen (enables value-based navigationDestination).
private struct DemoDestination: Identifiable, Hashable {
    let id = UUID()
    let configuration: CarouViewConfiguration
    let mode: CarouselDemoMode
    let dataSetSize: DemoDataSetSize

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: DemoDestination, rhs: DemoDestination) -> Bool {
        lhs.id == rhs.id
    }
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
    @State private var textFont: CarouselDemoFont = .system
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
    
    @State private var demoDestination: DemoDestination?

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
        
        let (titleFontName, fontBundle): (String?, Bundle?) = textFont == .nunito
            ? ("Nunito-Regular", .main)
            : (nil, nil)
        let viewAppearance = EnrichedCarouViewAppearance(
            textAlignment: textAlignment,
            titleColor: titleColor,
            descriptionColor: descriptionColor,
            titleFontName: titleFontName,
            titleFontSize: titleFontSize,
            titleFontBundle: fontBundle,
            descriptionFontName: titleFontName,
            descriptionFontSize: descriptionFontSize,
            descriptionFontBundle: fontBundle,
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
                    Picker("Text font", selection: $textFont) {
                        ForEach(CarouselDemoFont.allCases, id: \.self) { font in
                            Text(font.rawValue).tag(font)
                        }
                    }
                    .pickerStyle(.menu)
                    
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
        }
        .navigationTitle("Carousel Config")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                demoDestination = DemoDestination(
                    configuration: builtConfiguration,
                    mode: carouselMode,
                    dataSetSize: dataSetSize
                )
            } label: {
                HStack(spacing: 8) {
                    Text("Launch Demo")
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationDestination(item: $demoDestination) { dest in
            CarouselDemoView(configuration: dest.configuration, mode: dest.mode, dataSetSize: dest.dataSetSize)
        }
    }
}

#Preview {
    NavigationStack {
        ConfigurationView()
    }
}
