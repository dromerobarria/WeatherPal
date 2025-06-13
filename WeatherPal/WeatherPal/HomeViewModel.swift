import Foundation
import Observation

struct CityCoordinates {
    let name: String
    let lat: Double
    let lon: Double
}

enum City: String, CaseIterable, Identifiable {
    case rio = "Rio de Janeiro"
    case beijing = "Beijing"
    case losAngeles = "Los Angeles"
    var id: String { rawValue }

    var coordinates: CityCoordinates {
        switch self {
        case .rio:
            return CityCoordinates(name: rawValue, lat: -22.9068, lon: -43.1729)
        case .beijing:
            return CityCoordinates(name: rawValue, lat: 39.9042, lon: 116.4074)
        case .losAngeles:
            return CityCoordinates(name: rawValue, lat: 34.0522, lon: -118.2437)
        }
    }
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

protocol WeatherServiceProtocol {
    func fetchWeather(lat: Double, lon: Double) async throws -> (hourly: [HourlyWeather], daily: [DailyWeather])
}

@Observable final class HomeViewModel {
    var selectedCity: City = .rio {
        didSet { Task { await fetchWeather() } }
    }
    var hourly: [HourlyWeather] = []
    var daily: [DailyWeather] = []
    var lastUpdated: Date? = nil
    var errorMessage: String? = nil
    var isLoading: Bool = false
    private let weatherService: WeatherServiceProtocol
    private var fetchTask: Task<Void, Never>?

    init(weatherService: WeatherServiceProtocol = OpenWeatherService()) {
        self.weatherService = weatherService
        Task { await fetchWeather() }
    }

    @MainActor
    func fetchWeather() async {
        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            defer { isLoading = false }
            let coords = selectedCity.coordinates
            do {
                let (hourly, daily) = try await weatherService.fetchWeather(lat: coords.lat, lon: coords.lon)
                self.hourly = hourly
                self.daily = daily
                self.lastUpdated = Date()
                self.errorMessage = nil
            } catch {
                if (error as? URLError)?.code != .cancelled {
                    self.hourly = Self.placeholderHourly()
                    self.daily = Self.placeholderDaily()
                    self.errorMessage = "Unfortunately we are not able to get the information."
                }
            }
        }
        await fetchTask?.value
    }

    @MainActor
    func refresh() async {
        await fetchWeather()
    }

    func clearError() {
        errorMessage = nil
    }

    static func placeholderHourly() -> [HourlyWeather] {
        let now = Calendar.current.component(.hour, from: Date())
        return (now..<min(now+6, 24)).map { hour in
            HourlyWeather(hour: hour, temperature: 0, humidity: 0, symbol: "questionmark")
        }
    }

    static func placeholderDaily() -> [DailyWeather] {
        let days = (0..<3).map { offset -> String in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
            return date.formatted(.dateTime.weekday())
        }
        return days.map { day in
            DailyWeather(day: day, description: "—", temperature: 0, symbol: "questionmark")
        }
    }
} 