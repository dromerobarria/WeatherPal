import Foundation

struct OpenWeatherService: WeatherServiceProtocol {
    private let apiKey = "9170e0e85794088df319259526c55afd"
    private let session: URLSession = .shared

    func fetchWeather(lat: Double, lon: Double) async throws -> (hourly: [HourlyWeather], daily: [DailyWeather]) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("[WeatherService] Requesting: \(url)")
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("[WeatherService] Response status: \(httpResponse.statusCode)")
            }
            let decoded = try JSONDecoder().decode(OWForecastResponse.self, from: data)
            let now = Date()
            let calendar = Calendar.current
            // Next hours: from now to end of today (max 24h)
            let hourly = decoded.list.filter { item in
                let date = Date(timeIntervalSince1970: item.dt)
                return date > now && calendar.isDate(date, inSameDayAs: now)
            }.prefix(8).map { item in
                let date = Date(timeIntervalSince1970: item.dt)
                let hour = calendar.component(.hour, from: date)
                return HourlyWeather(
                    hour: hour,
                    temperature: Int(item.main.temp.rounded()),
                    humidity: item.main.humidity,
                    symbol: item.weather.first?.sfSymbol ?? "cloud.sun.fill"
                )
            }
            // Next 5 days: pick the forecast closest to 12:00 for each day
            let groupedByDay = Dictionary(grouping: decoded.list) { item in
                let date = Date(timeIntervalSince1970: item.dt)
                return calendar.startOfDay(for: date)
            }
            let next5Days = groupedByDay.keys.sorted().prefix(5)
            let daily = next5Days.compactMap { day -> DailyWeather? in
                guard let items = groupedByDay[day] else { return nil }
                let targetHour = 12
                let closest = items.min(by: { abs(calendar.component(.hour, from: Date(timeIntervalSince1970: $0.dt)) - targetHour) < abs(calendar.component(.hour, from: Date(timeIntervalSince1970: $1.dt)) - targetHour) })
                guard let item = closest else { return nil }
                let date = Date(timeIntervalSince1970: item.dt)
                let dayLabel = date.formatted(.dateTime.weekday())
                return DailyWeather(
                    day: dayLabel,
                    description: item.weather.first?.main ?? "Clear",
                    temperature: Int(item.main.temp.rounded()),
                    symbol: item.weather.first?.sfSymbol ?? "cloud.sun.fill"
                )
            }
            print("[WeatherService] Success: hourly=\(hourly.count), daily=\(daily.count)")
            return (Array(hourly), Array(daily))
        } catch {
            print("[WeatherService] Error: \(error)")
            throw error
        }
    }
}

// MARK: - OpenWeather API Models

private struct OWForecastResponse: Decodable {
    let list: [OWForecastItem]
}

private struct OWForecastItem: Decodable {
    let dt: TimeInterval
    let main: OWMain
    let weather: [OWWeather]
}

private struct OWMain: Decodable {
    let temp: Double
    let humidity: Int
}

private struct OWWeather: Decodable {
    let main: String
    let icon: String
    let description: String

    var sfSymbol: String {
        switch icon.prefix(2) {
        case "01": return "sun.max.fill"
        case "02": return "cloud.sun.fill"
        case "03", "04": return "cloud.fill"
        case "09", "10": return "cloud.rain.fill"
        case "11": return "cloud.bolt.rain.fill"
        case "13": return "snow"
        case "50": return "cloud.fog.fill"
        default: return "cloud.sun.fill"
        }
    }
} 
