//
//  HomeViewSnapshotTests.swift
//  WeatherPalTests
//
//  Created by Daniel Romero on 13-06-25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import WeatherPal

final class HomeViewSnapshotTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Record = true to update snapshots, false to test
        isRecording = false
    }

    func testHomeView_defaultCity_lightMode() {
        // Arrange: mock data for Rio de Janeiro
        let viewModel = HomeViewModel(weatherService: MockWeatherService())
        viewModel.selectedCity = .rio
        viewModel.hourly = [
            HourlyWeather(hour: 9, temperature: 22, humidity: 60, symbol: "cloud.sun.fill", iconCode: "02d"),
            HourlyWeather(hour: 12, temperature: 25, humidity: 55, symbol: "sun.max.fill", iconCode: "01d")
        ]
        viewModel.daily = [
            DailyWeather(day: "Fri, Nov 1", description: "Clear", temperature: 25, symbol: "sun.max.fill", iconCode: "01d"),
            DailyWeather(day: "Sat, Nov 2", description: "Clouds", temperature: 23, symbol: "cloud.sun.fill", iconCode: "02d")
        ]
        viewModel.lastUpdated = Date(timeIntervalSince1970: 1_700_000_000) // Fixed date
        let view = HomeView(viewModel: viewModel)
            .frame(width: 393, height: 852) // iPhone 15 Pro
            .environment(\.colorScheme, .light)
            .environment(\.locale, Locale(identifier: "en_US"))
        // Act & Assert
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13ProMax)), named: "HomeView_defaultCity_light")
    }
}

// MARK: - MockWeatherService
final class MockWeatherService: WeatherServiceProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> (hourly: [HourlyWeather], daily: [DailyWeather]) {
        ([
            HourlyWeather(hour: 9, temperature: 22, humidity: 60, symbol: "cloud.sun.fill", iconCode: "02d"),
            HourlyWeather(hour: 12, temperature: 25, humidity: 55, symbol: "sun.max.fill", iconCode: "01d")
        ], [
            DailyWeather(day: "Fri, Nov 1", description: "Clear", temperature: 25, symbol: "sun.max.fill", iconCode: "01d"),
            DailyWeather(day: "Sat, Nov 2", description: "Clouds", temperature: 23, symbol: "cloud.sun.fill", iconCode: "02d")
        ])
    }
}
