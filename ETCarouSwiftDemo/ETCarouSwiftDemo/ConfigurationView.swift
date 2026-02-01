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
    @State private var carouselMode: CarouselDemoMode = .basic
    @State private var rideDirection: CarouDirection = .leftToRight
    @State private var autoRideEnabled: Bool = true
    @State private var showTime: Double = 2.0
    @State private var dotColor: Color = .gray
    @State private var currentDotColor: Color = .blue
    @State private var dotSize: CarouDotSize = .medium
    @State private var imageScale: CarouImageScale = .fill
    @State private var showDemo = false

    private var builtConfiguration: CarouViewConfiguration {
        CarouViewConfiguration(
            rideDirection: rideDirection,
            autoRideEnabled: autoRideEnabled,
            showTime: showTime,
            dotColor: dotColor,
            currentDotColor: currentDotColor,
            dotSize: dotSize,
            imageScale: imageScale
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
            CarouselDemoView(configuration: builtConfiguration, mode: carouselMode)
        }
    }
}

#Preview {
    NavigationStack {
        ConfigurationView()
    }
}
