//
//  ConfigurationView.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 29/01/2026.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
import ETCarouSwift

struct ConfigurationView: View {
    @State private var rideDirection: CarouDirection = .rightToLeft
    @State private var autoRideEnabled: Bool = true
    @State private var showTime: Double = 2.0
    @State private var dotColor: Color = .gray
    @State private var currentDotColor: Color = .blue
    @State private var dotSize: CarouDotSize = .medium
    @State private var imageScale: CarouImageScale = .fill

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
            Section("Direction & Auto-ride") {
                Picker("Direction", selection: $rideDirection) {
                    Text("Right to Left").tag(CarouDirection.rightToLeft)
                    Text("Left to Right").tag(CarouDirection.leftToRight)
                }
                .pickerStyle(.menu)

                Toggle("Auto-ride enabled", isOn: $autoRideEnabled)
            }

            Section("Timing") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Show time")
                        Spacer()
                        Text(String(format: "%.1f s", showTime))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $showTime, in: 0.5...5.0, step: 0.5)
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
                NavigationLink {
                    CarouselDemoView(configuration: builtConfiguration)
                } label: {
                    HStack {
                        Spacer()
                        Text("Launch Demo")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .listRowBackground(Color.accentColor)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .tint(.white)
            }
        }
        .navigationTitle("Carousel Config")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ConfigurationView()
    }
}
