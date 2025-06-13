//
//  WeatherPalApp.swift
//  WeatherPal
//
//  Created by Daniel Romero on 13-06-25.
//

import SwiftUI
import SwiftData

@main
struct WeatherPalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

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
                    ContentView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
