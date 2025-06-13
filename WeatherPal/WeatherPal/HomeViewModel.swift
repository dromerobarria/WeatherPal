import Foundation
import Observation

enum City: String, CaseIterable, Identifiable {
    case rio = "Rio de Janeiro"
    case beijing = "Beijing"
    case losAngeles = "Los Angeles"
    var id: String { rawValue }
}

struct HourlyWeather: Identifiable {
    let id = UUID()
    let hour: Int
    let temperature: Int
    let humidity: Int
    let symbol: String
}

struct DailyWeather: Identifiable {
    let id = UUID()
    let day: String
    let description: String
    let temperature: Int
    let symbol: String
}

@Observable final class HomeViewModel {
    var selectedCity: City = .rio
    var hourly: [HourlyWeather] = []
    var daily: [DailyWeather] = []

    init() {
        loadMockData()
    }

    func loadMockData() {
        let now = Calendar.current.component(.hour, from: Date())
        hourly = (now..<24).map { hour in
            HourlyWeather(
                hour: hour,
                temperature: Int.random(in: 18...32),
                humidity: Int.random(in: 40...90),
                symbol: ["cloud.sun.fill", "sun.max.fill", "cloud.rain.fill"].randomElement()!
            )
        }
        let days = (0..<5).map { offset -> String in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
            return date.formatted(.dateTime.weekday())
        }
        daily = days.map { day in
            DailyWeather(
                day: day,
                description: ["Clear", "Cloudy", "Rainy", "Partly Cloudy"].randomElement()!,
                temperature: Int.random(in: 18...32),
                symbol: ["cloud.sun.fill", "sun.max.fill", "cloud.rain.fill"].randomElement()!
            )
        }
    }
} 