//
//  ContentView.swift
//  ETCarouSwiftDemo
//
//  Created by Elena Slovushch on 08/02/2020.
//  Copyright © 2020 ElenaSlovushch. All rights reserved.
//

import SwiftUI
import ETCarouSwift

struct ContentView: View {
    @State private var currentImageIndex: Int = 0
    
    let images: [Image] = [
        Image("1"),
        Image("2"),
        Image("3"),
        Image("4"),
        Image("5")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            CarouView(
                imageSet: images,
                configuration: CarouViewConfiguration(
                    rideDirection: .rightToLeft,
                    autoRideEnabled: true,
                    showTime: 2.0,
                    dotColor: .gray,
                    currentDotColor: .blue,
                    dotSize: .medium
                ),
                onImageChanged: { index in
                    currentImageIndex = index
                    print("Image changed to index: \(index)")
                },
                onImageTapped: { index in
                    print("Image tapped at index: \(index)")
                }
            )
            .frame(height: 300)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
            .padding(.horizontal, 20)
            
            Text("Image #\(currentImageIndex + 1)")
                .font(.system(size: 20, weight: .bold))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
