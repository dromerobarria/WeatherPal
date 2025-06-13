//
//  WeatherPalTests.swift
//  WeatherPalTests
//
//  Created by Daniel Romero on 13-06-25.
//

import XCTest
@testable import WeatherPal

final class WeatherPalTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testHomeViewModel_successAndError() async {
        // Arrange
        final class MockWeatherService: WeatherServiceProtocol {
            var shouldFail = false
            func fetchWeather(lat: Double, lon: Double) async throws -> (hourly: [HourlyWeather], daily: [DailyWeather]) {
                if shouldFail { throw URLError(.notConnectedToInternet) }
                return ([HourlyWeather(hour: 12, temperature: 25, humidity: 50, symbol: "sun.max.fill", iconCode: "01d")],
                        [DailyWeather(day: "Mon", description: "Clear", temperature: 25, symbol: "sun.max.fill", iconCode: "01d")])
            }
        }
        let mock = MockWeatherService()
        let viewModel = HomeViewModel(weatherService: mock)
        // Act
        await viewModel.fetchWeather()
        // Assert
        XCTAssertEqual(viewModel.hourly.count, 1)
        XCTAssertEqual(viewModel.daily.count, 1)
        XCTAssertNil(viewModel.errorMessage)
        // Simulate error
        mock.shouldFail = true
        await viewModel.fetchWeather()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.hourly.isEmpty) // Should show placeholder
    }

}
