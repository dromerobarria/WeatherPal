//
//  WeatherPalApp.swift
//  WeatherPal
//
//  Created by Daniel Romero on 13-06-25.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct WeatherPalApp: App {
    init() {
        try? Tips.configure()
    }

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            showSplash = false
                        }
                } else {
                    HomeView(viewModel: HomeViewModel())
                }
            }
        }
    }
}
